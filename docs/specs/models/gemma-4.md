# Gemma 4 Model Specification

## Status
- **Stability**: Stable as of llama.cpp PR #21534 merge
- **Build requirement**: Build from master source (releases lag behind)

## Build Warnings
- **DO NOT use CUDA 13.2** - confirmed broken, generates non-functional builds
- **Recommended**: CUDA 12.x or 13.0/13.1.1

## Runtime Configuration

### Chat Template
- **File**: `google-gemma-4-31B-it-interleaved.jinja`
- **Location**: `templates/google-gemma-4-31B-it-interleaved.jinja`
- **Usage**: `--chat-template-file templates/google-gemma-4-31B-it-interleaved.jinja`
- **Purpose**: Preserves reasoning before tool calls for agentic workflows
- **Note**: Official template is non-interleaved; interleaved version prepared by Aldehir

### Memory & Cache Settings
- `--cache-ram 2048` - Cache RAM size (2 GB)
- `--ctxcp 2` - Context checkpoints (2 per slot)
- `-np 1` - Single slot (unless multi-slot needed)
- **KV Cache Quantization**: 
  - Keys: `q5_0` 
  - Values: `q4_0`
  - Rationale: Keys carry attention distribution (noise propagates multiplicatively through softmax); values tolerate aggressive compression

### Sampling Parameters
- `--min-p 0.0` - Override llama.cpp default of 0.05

## Model Variants

### 31B Dense (Multimodal)
- Native 256K context
- Vision: Works with `--mmproj` flag
- Chat template: `google-gemma-4-31B-it-interleaved.jinja`

### 26B A4B MoE
- 25.2B total params, 3.8B active
- Vision: Works with `--mmproj` flag
- Chat template: Same as 31B

### 2B / 4B Variants
- **Warning**: Built-in chat templates differ by ~3 lines from 26B/31B
- May require separate interleaved chat template (not yet available in llama.cpp repo)

## Known Limitations
- Flash attention on Vulkan: Broken
- Audio input (2B/4B): Not yet supported
- Audio quality: Degrades below Q5 quantization

## Context Checkpoints
- **Non-hybrid, non-iSWA models**: Use KV cache truncation (checkpoints not needed)
- **iSWA models**: Checkpoints useful but fewer than hybrid models require

---

## Agentic Workflow Optimization: `--cache-ram` and `--ctxcp`

### The Problem: System RAM Exhaustion in Agentic Harnesses

In agentic workflows like OpenCode, the model engages in **iterative multi-turn sessions** where:
1. A base context (project files, instructions) remains constant
2. Auxiliary tasks (keyword extraction, summarization, code generation) are interleaved
3. Each auxiliary task appends to the conversation history

Without proper cache management, this leads to:
- **KV cache growth**: Each turn accumulates KV cache entries
- **System RAM pressure**: KV cache for large models (31B) can exceed available RAM
- **Prompt reprocessing**: Without checkpoints, the server re-reads the entire prompt on context switches

### The Solution: Host-Memory Prompt Caching

#### `--cache-ram 2048` (2 GB Host Memory Cache)

**Mechanism**: Introduces a host-memory prompt cache that acts as "extra slots" for prefix similarity matching. When a new task arrives, the server:
1. Calculates prefix similarity between the new prompt and cached prompts
2. Hot-swaps cached prompts into the `llama_context` if it reduces processing
3. Stores the cache in regular system RAM (not VRAM)

**Impact for OpenCode**:
- **Prevents OOM**: Caps KV cache at 2 GB, preventing system RAM exhaustion during long agentic sessions
- **Reduces reprocessing**: Cached prompts are reused instead of re-processed, saving compute
- **Enables single-slot operation**: Eliminates the need for multiple slots, which would fragment VRAM

#### `--ctxcp 2` (2 Context Checkpoints per Slot)

**Mechanism**: Creates checkpoints at strategic points during prompt processing. These checkpoints allow the server to:
1. Save intermediate KV states at predefined token intervals
2. Resume from checkpoints instead of re-processing from scratch
3. Efficiently handle context switches within the same session

**Impact for OpenCode**:
- **Faster context switching**: When the agent switches between tasks (e.g., from code analysis to file editing), the server can resume from a checkpoint rather than re-processing the entire prompt
- **Reduced latency**: Checkpoints enable prefix caching within the same slot, avoiding full prompt re-reads
- **Memory efficiency**: 2 checkpoints provide a balance between memory usage and reprocessing avoidance

### Combined Effect

| Scenario | Without Settings | With `--cache-ram 2048 --ctxcp 2` |
|----------|------------------|-----------------------------------|
| 10-turn agentic session | Full prompt reprocessing each turn | Prefix cached, minimal reprocessing |
| System RAM usage | Unbounded growth | Capped at 2 GB |
| VRAM fragmentation | Multiple slots needed | Single slot sufficient |
| Latency per turn | High (full re-read) | Low (checkpoint resume) |

### Why These Specific Values?

- **2048 MiB**: Sufficient for Gemma 4's typical agentic context while preventing OOM on systems with 16-32 GB RAM
- **2 checkpoints**: Balances memory overhead with reprocessing avoidance; more checkpoints yield diminishing returns for non-hybrid models

## Conversation

`opencode -s ses_28d9d1226ffegjzlkVANqDpZYd`
