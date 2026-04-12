# ADR 0003: Context Limit Architecture for Large Language Models

- **Context:** Large language models with extensive context windows (e.g., Gemma 4 with 65K tokens) can cause system-wide OOM crashes when KV cache memory requirements exceed physical hardware limits. The April 9, 2026 incident revealed that a 33.6K token prompt with q8_0 KV quantization attempted to allocate 33.6 GB of system RAM, exhausting the 64GB available and causing kernel panic. Additionally, misaligned context/output limits in OpenCode configuration caused infinite compaction loops when `limit.context - limit.output = 0`.

- **Decision:** Implement a layered defense strategy for context management:
  - **Physical Safety Limits:** Set `limit.context` in `opencode.json` to physically safe values (e.g., 32768 for Gemma 4 on 64GB RAM with q8_0 KV cache) that account for actual hardware constraints, not theoretical model capabilities
  - **Server-Client Alignment:** Ensure `ctx-size` in `config/presets.ini` matches `limit.context` in `opencode.json` so the server rejects oversized payloads before allocation attempts
  - **Compaction Buffer:** Maintain `limit.output` at no more than 25% of `limit.context` (e.g., `limit.output = 8192` when `limit.context = 32768`) to provide sufficient prompt space and prevent zero-token compaction loops
  - **VRAM Optimization:** Disable multimodal projector (`mmproj-auto = false`) for text-only use cases to eliminate unnecessary VRAM overhead
  - **Monitoring Protocol:** When operating near memory limits, monitor system RAM usage and be prepared to reduce context limits or KV cache quantization (q8_0 → q4_0) if OOM conditions recur

- **Consequences:**
  - **Positive:** Prevents catastrophic OOM crashes, eliminates compaction loops, provides predictable memory usage, and ensures system stability during long conversations
  - **Negative:** Reduces effective context window below model capability, may require more frequent compaction, limits ability to process very large documents in single prompt
  - **Trade-offs:** Safety vs. capability (smaller context prevents crashes but limits single-prompt processing), Memory vs. speed (q4_0 KV cache would reduce memory by ~50% but may impact quality), Simplicity vs. optimization (disabling mmproj saves VRAM but prevents future multimodal use without reconfiguration)
