# Engineering Journal: CachyOS Hard Crash / OOM Panic

## Date: April 9, 2026

### Incident Description
The local development environment running CachyOS experienced a hard crash. After initially fixing the out-of-memory issue, OpenCode entered an infinite compaction loop.

### Investigation
- Queried previous boot logs using `journalctl -b -1 -p 3`.
- Logs revealed a severe Out-Of-Memory (OOM) condition leading to a kernel panic. The system was heavily swapping and failing to allocate pages (`warn_alloc`, `handle_mm_fault`).
- The `llama-server` process was the primary culprit, having dumped core right as the system memory was exhausted.
- Investigated `scripts/presets.ini` and `scripts/logs/server.log` (after adding a `.geminiignore` exception for logs to bypass gitignore restrictions).
- Found that `llama-server` was evaluating a prompt of 33,622 tokens for the `unsloth/gemma-4-31B-it-GGUF:UD-Q3_K_XL` model.
- Following initial fixes to lower context limits, an infinite compaction loop was observed in `~/.local/share/opencode/log/*`.

### Root Cause Analysis
1. **Gemma 4 Architecture:** Gemma 4's massive attention architecture (60 layers, 16 KV heads) requires approximately 1 MB of memory per token when the KV cache is quantized at `q8_0` (the global preset).
2. **Context Blowout:** OpenCode sent a ~33.6K token prompt. The KV cache alone attempted to allocate ~33.6 GB of memory.
3. **Hardware Limits Exceeded:** Combined with the ~20 GB footprint of the model weights on the RTX 4090 (24GB VRAM), the massive cache allocation spilled over to system RAM, completely exhausting the 64GB available and choking the swap file, killing the OS.
4. **OpenCode Compaction Failure:** OpenCode's context limit for this model was set to `65536` in `opencode.json`. Because 33K tokens is well below 65K, OpenCode did not trigger its `compaction` algorithm (which uses a `reserved` buffer to safely prune old tool outputs), inadvertently sending a payload too large for the physical hardware to handle.
5. **Compaction Loop Issue:** When lowering the `limit.context` from 65536 to 32768, the `limit.output` was left at 32768. OpenCode calculates available prompt space as `limit.context - limit.output`. Since 32768 - 32768 = 0, there were 0 tokens available for input. OpenCode continually triggered compaction but could not shrink a prompt to 0 tokens, causing an infinite loop.

### Resolutions Applied
1. **Disabled Multimodal Projector:** Added `mmproj-auto = false` to the Gemma 4 preset in `scripts/presets.ini`. Since Gemma 4 is only being used for text (code agent), disabling the vision encoder prevents any potential future VRAM overhead if the mmproj is bundled.
2. **Enforced OpenCode Compaction:** Lowered the `limit.context` for Gemma 4 in `opencode.json` from `65536` to a physically safe limit of `32768`. This forces OpenCode to trigger compaction and prune the prompt *before* it crashes the backend.
3. **Aligned Server Limits:** Updated `ctx-size` in `scripts/presets.ini` to `32768` to match the new limit set in `opencode.json`. This ensures the server rejects oversized payloads instead of attempting to allocate unavailable memory. (Note: KV cache quantization was left unchanged at `q8_0` per user preference).
4. **Fixed Compaction Loop:** Lowered `limit.output` for Gemma 4 in `opencode.json` to `8192`. This provides 24,576 tokens for input prompts, resolving the math error that caused OpenCode's infinite compaction loop.

### Current Status
The `limit.context` in `opencode.json` and `ctx-size` in `scripts/presets.ini` have been reverted to `65536` and are currently being evaluated for stability and memory pressure.

### Final Recommendations
- Monitor memory usage closely when utilizing the 32K context window, as `q8_0` KV caching will still consume around 32 GB of system RAM for the cache alone.
- If future OOM issues occur with this model, the next step must be to either lower the context limit further (e.g., to `24576` or `16384`) or lower the KV cache quantization to `q4_0`.
- Always ensure `limit.context` is sufficiently larger than `limit.output` in `opencode.json` to provide enough prompt space and avoid compaction loops.

### Modified Files
- `opencode.json`
- `scripts/presets.ini`
- `.geminiignore` (Added to enable reading log files via AI tooling)
- `docs/journal/2026-04-09-cachyos-oom-investigation.md` (This document)

### Suggested Git Commit Message
```text
fix(config): resolve Gemma 4 OOM crash and compaction loops

- Lowered output limit for the same model to 8192 in opencode.json to avoid infinite compaction loops.
- Disabled mmproj-auto for Gemma 4 in presets.ini to save VRAM overhead.
- Added .geminiignore to allow AI agents to parse server logs.
- Documented the investigation, crash, and loop fixes in the engineering journal.

Refs: docs/journal/2026-04-09-cachyos-oom-investigation.md
```