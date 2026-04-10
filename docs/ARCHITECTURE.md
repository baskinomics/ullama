# Ullama Architecture Notes

## System Overview

Ullama is a personal infrastructure-as-code repository for local LLM deployment with CUDA acceleration. It combines llama.cpp's router server mode with preset-based configuration to enable dynamic model management on NVIDIA GPU hardware.

## Core Components

### 1. Router Server (llama.cpp)
- **Role:** Central inference engine with dynamic model loading
- **Port:** 8001 (OpenAI-compatible API)
- **Key Features:**
  - Single model in VRAM at a time (`--models-max 1`)
  - Preset-based configuration via INI files
  - Automatic model switching based on requests
  - CPU affinity binding for optimal performance (taskset -c 0-7)

### 2. Open WebUI (Docker)
- **Role:** User interface layer
- **Port:** 3000
- **Connection:** Connects to router server at `http://host.docker.internal:8001/v1`
- **Features:** ChatGPT-like interface, conversation management

### 3. Preset Configuration
- **Location:** `scripts/presets.ini` (Linux), `scripts/macos-presets.ini` (macOS)
- **Purpose:** Define model parameters, quantization, context limits
- **Structure:** Global defaults + per-model overrides

### 4. Build & Runtime Scripts
- `scripts/run-server.sh` - Launch router server with OS-specific configuration
- `scripts/update_llama_cpp.sh` - Pull and rebuild llama.cpp from source
- `scripts/install-docker.sh` - Docker installation automation

## Data Flow

```
User Request (WebUI:3000)
    ↓
Router Server (llama.cpp:8001)
    ↓
Preset Configuration (presets.ini)
    ↓
Model Loading (HuggingFace → VRAM)
    ↓
Inference (CUDA Accelerated)
    ↓
Response (OpenAI API Format)
    ↓
User Interface (WebUI)
```

## Hardware Architecture

### Host System (CachyOS)
- **CPU:** AMD Ryzen 9 7950X3D (16-core, 32-thread)
- **GPU:** NVIDIA RTX 4090 (24GB VRAM)
- **RAM:** 64GB DDR5
- **Storage:** 1.9TB NVMe

### Resource Allocation Strategy
- **VRAM:** Model weights + KV cache (primary inference memory)
- **RAM:** KV cache overflow, system operations (64GB total)
- **CPU:** 8-core affinity (cores 0-7) for MoE expert routing and non-GPU layers
- **Swap:** Fallback for extreme memory pressure (monitored to prevent OOM)

## Key Architectural Decisions

### Model Loading Strategy
**Decision:** Single model in VRAM (`--models-max 1`)
- **Rationale:** Prevents VRAM exhaustion on 24GB card
- **Trade-off:** Model switching latency vs. concurrent model support

### KV Cache Quantization
**Decision:** q8_0 for K/V caches by default
- **Rationale:** Minimal quality loss (~1% perplexity increase)
- **Trade-off:** ~1MB per token memory usage vs. q4_0 (~0.5MB/token)
- **See:** ADR 0003 for context limit implications

### CPU Affinity
**Decision:** taskset -c 0-7 in run-server.sh
- **Rationale:** Single CCD optimization for 3D V-Cache architecture
- **Trade-off:** Portability (in script) vs. centralization (in systemd)
- **See:** ADR 0002 for systemd integration details

### Context Limits
**Decision:** Layered defense with aligned limits
- **opencode.json:** `limit.context` = 32768 (safety limit)
- **presets.ini:** `ctx-size` = 32768 (server rejection threshold)
- **Trade-off:** Reduced context window vs. system stability
- **See:** ADR 0003 for detailed rationale

## Documentation Architecture

### Git-Native Documentation System
- **Specs:** `docs/specs/` - Technical blueprints and implementation plans
- **ADRs:** `docs/adrs/` - Immutable architectural decisions
- **Journal:** `docs/journal/` - Chronological engineering logs
- **Tasks:** `TODO.md` - Task inbox with spec/ADR references

### Document Lifecycle
1. **Research:** Journal entry or draft spec
2. **Design:** Formalize in spec file
3. **Implement:** Execute spec checklist
4. **Record:** Keep spec as permanent reference

## Security Considerations

### Current State
- Service runs under user `zoo` account (personal workstation)
- No network exposure (localhost only)
- Models downloaded from HuggingFace (trust model required)

### Future Considerations
- Dedicated service user for production deployment
- Network firewall rules if exposing beyond localhost
- Model weight verification and signing

## Performance Characteristics

### Inference Latency
- **First Token:** 100-500ms (model loading if not cached)
- **Subsequent Tokens:** 20-50 tokens/sec (model dependent)
- **Model Switch:** 2-10 seconds (unload + load)

### Memory Usage
- **Qwen3.5-27B:** ~16GB VRAM (Q4_K_XL)
- **Gemma-4-31B:** ~20GB VRAM (Q3_K_XL)
- **KV Cache:** ~1MB/token (q8_0 quantization)

## Known Limitations

1. **Context Window:** Limited by physical RAM for large contexts with q8_0 KV cache
2. **Model Switching:** Latency when switching between models
3. **Single Instance:** No concurrent model support
4. **Linux-Specific:** CPU affinity and systemd features require Linux
5. **VRAM Bound:** 24GB VRAM limits model size and context combinations

## Future Enhancements

- [ ] Preset modularization (core/testing/legacy) - see `docs/specs/preset-modularization.md`
- [ ] Makefile build system - see `docs/specs/makefile-build-system.md`
- [ ] systemd service hardening - see `docs/adrs/0002-systemd-service.md`
- [ ] MoE model evaluation for doc agent - see `docs/journal/2026-04-09-moe-model-research.md`
- [ ] Open WebUI removal (export conversations first) - see `TODO.md`
