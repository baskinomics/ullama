# Ullama

> Version-controlled infrastructure-as-code and reference for local LLM deployment with CUDA acceleration.

[![Platform](https://img.shields.io/badge/platform-linux--64-blue.svg)](https://www.cachyos.org)
[![GPU](https://img.shields.io/badge/GPU-NVIDIA%20RTX%204090-orange.svg)](https://developer.nvidia.com/cuda-toolkit)
[![llama.cpp](https://img.shields.io/badge/inference-llama.cpp-green.svg)](https://github.com/ggml-org/llama.cpp)
[![Version](https://img.shields.io/badge/version-0.3.0-blue.svg)](VERSION)

## Overview

Ullama serves as a personal infrastructure-as-code (IaC) repository to persist and version control a complete local LLM setup. It is intended to act as a reference for deploying various open-source models on NVIDIA GPU hardware by combining llama.cpp with CUDA support, a router-server for dynamic model management, and Open WebUI for an accessible chat interface.

### Features

- **GPU Acceleration** - Full CUDA support via llama.cpp
- **Open WebUI** - Familiar ChatGPT-like interface
- **Router Server** - Dynamic model loading/unloading with preset-based configuration
- **Multiple Models** - Support for Qwen, Gemma, NVIDIA Nemotron, GLM, and more
- **Easy Updates** - Scripts to keep llama.cpp current
- **Efficient Memory** - KV cache quantization and MoE optimization

## Quick Start

### Prerequisites

- CachyOS or Arch Linux (other distros may work)
- NVIDIA GPU with CUDA support (RTX 3090/4090 recommended)
- Minimum 16GB VRAM for larger models
- 32GB+ system RAM

### Installation

```bash
# 1. Install Docker
# Note: If docker is not installed, use the manual install-docker.sh script first.
# Once installed, log out and back in, then:

# 2. Start Open WebUI
make docker-up

# 3. Build llama.cpp (if not already done)
make build

# 4. Start the router server
make server
```

### Access

Open your browser at **http://localhost:3000** to start chatting. The router server will automatically load models based on your requests.

### Remote Server Access (Advanced)

For running the server on a remote machine (e.g., `jupiter`) while accessing from your local machine, see the [Remote Server Access documentation](scripts/README.md#advanced-remote-server-access-temporary-solution).

> **Note:** This is a temporary workaround until the systemd service implementation is complete. See [`docs/specs/systemd-plan.md`](docs/specs/systemd-plan.md).

## Available Models

Models are configured via preset files (`config/presets.ini` for Linux, `config/presets-macos.ini` for macOS). The router server automatically manages model loading based on requests.

### Qwen Models (Alibaba)

| Model | Quantization | Context | Notes |
|-------|--------------|---------|-------|
| Qwen3.5-122B-A10B | UD-Q3_K_XL | 131K | MoE (10B active), CPU expert routing |
| Qwen3.5-27B | UD-Q4_K_XL | 65K | Dense model |
| Qwen3.6-35B-A3B | UD-Q4_K_XL | 131K | MoE (3B active) |

### Gemma Models (Google)

| Model | Quantization | Context | Notes |
|-------|--------------|---------|-------|
| Gemma-4-31B | Q4_0 | 131K | Dense multimodal |
| Gemma-4-26B-A4B | UD-Q6_K_XL | 262K | MoE (3.8B active), multimodal |

See [`config/presets.ini`](config/presets.ini) for the complete configuration.

## Architecture

Ullama uses a router-server pattern for efficient model management:

```mermaid
graph LR
    subgraph "User Interface"
        WebUI["Open WebUI<br/>(localhost:3000)"]
    end

    subgraph "Backend Infrastructure"
        Router["Router Server<br/>(llama.cpp port 8001)"]
        Presets["Model Presets<br/>(config/presets.ini)"]
        Loading["Dynamic Model<br/>Loading/Unloading"]
    end

    WebUI <--> Router
    Router <--> Presets
    Router <--> Loading
```

### How It Works

1. **Open WebUI** connects to the router server at `http://localhost:8001/v1`
2. **Router Server** reads model configurations from preset files
3. **Dynamic Loading**: Only one model is loaded in VRAM at a time (`--models-max 1`)
4. **Preset-Based**: Models are configured via `.ini` files with optimized parameters

## Configuration

### Docker Compose

The `docker-compose.yaml` configures Open WebUI to connect to the router server:

```yaml
services:
    openwebui:
        image: ghcr.io/open-webui/open-webui:main
        ports:
            - "3000:8080"
        environment:
            - OPENAI_API_BASE_URL=http://host.docker.internal:8001/v1
```

### Router Server

The `run-server.sh` script starts the router with preset-based model management:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Router Configuration
ROUTER_ARGS=(
    --models-preset "$PRESET_FILE"
    --models-max 1           # Only one model in VRAM at a time
    --parallel 1             # Single parallel processing
    --no-mmproj              # Disable multimodal projector
    --port 8001              # OpenAI-compatible API port
    --log-file "$LOG_FILE"
    --log-colors on
)

# CPU affinity for optimal performance (Linux only)
CMD_PREFIX="taskset -c 0-7"

$CMD_PREFIX llama-server "${ROUTER_ARGS[@]}"
```

### Model Presets

Presets are configured in INI format. Each model is a section with optimized parameters:

```ini
; Global defaults
[*]
seed = 3407
fit = on
flash-attn = on
threads = 8
threads-batch = 16
jinja = true

; Individual model configuration
[unsloth/Qwen3.5-27B]
hf = unsloth/Qwen3.5-27B-GGUF:UD-Q4_K_XL
ctx-size = 65536
temp = 0.6
top-p = 0.95
min-p = 0.00
cache-type-k = q8_0
cache-type-v = q8_0
```

#### Common Parameters

| Parameter | Description |
|-----------|-------------|
| `hf` | HuggingFace model repo and quantization variant |
| `ctx-size` | Maximum context window size (tokens) |
| `n-gpu-layers` | Layers to offload to GPU (99/999 = all) |
| `n-cpu-moe` | CPU layers for MoE expert routing |
| `cache-type-k/v` | KV cache quantization (q8_0, q4_0, bf16, f16) |
| `threads` | CPU threads for non-GPU layers |
| `threads-batch` | CPU threads for batch processing |
| `temp` | Sampling temperature (higher = more random) |
| `top-p` | Nucleus sampling threshold |
| `top-k` | Top-K sampling (0 = disabled) |
| `min-p` | Minimum probability threshold |
| `fit` | Auto-fit model to GPU memory (on/off) |
| `flash-attn` | Flash attention for speed (on/off) |
| `cmoe` | Enable cross-MoE routing (on/off) |

See [`config/presets.ini`](config/presets.ini) for the complete configuration and [`llama.cpp server docs`](https://github.com/ggml-org/llama.cpp/tree/master/tools/server#model-presets) for all options.

### Adding New Models

1. Add a new section to `config/presets.ini`:
    ```ini
    [provider/model-name:quantization]
    hf = provider/model-name-GGUF:quantization
    ctx-size = 32768
    # ... other parameters
    ```

2. Restart the router server:
    ```bash
    make stop
    make server
    ```

3. Select the model in Open WebUI interface

## Maintenance

### Update llama.cpp

```bash
make build
```

### Regenerate Environment Info

```bash
./scripts/update_agent_context.sh
```

### View Logs

```bash
# Router server logs
tail -f scripts/logs/server.log

# Open WebUI logs
make docker-logs

# Monitor GPU usage
watch nvidia-smi
```

### Restart Services

```bash
# Restart router server
make stop
make server

# Restart Open WebUI
make docker-down
make docker-up
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Port 8001 in use | `lsof -i :8001` then `pkill -f llama-server` |
| Docker permission denied | Add user to docker group, reboot |
| CUDA not detected | Verify `nvcc --version` works |
| Model fails to load | Check router logs: `tail -f scripts/logs/server.log` |
| Preset file not found | Verify `presets.ini` exists in `config/` directory |
| Model switching slow | Increase `--models-max` or reduce context size |
| VRAM OOM errors | Use lower quantization (Q3 vs Q4) or smaller model |

## Documentation

- [`HOST_ENV.md`](HOST_ENV.md) - Host system specifications
- [`docs/specs/cachy-os.md`](docs/specs/cachy-os.md) - Detailed CachyOS setup guide
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) - Architecture notes and design decisions
- [`scripts/README.md`](scripts/README.md) - Script documentation and remote access guide
- [`docs/adrs/`](docs/adrs/) - Architectural Decision Records
- [`docs/specs/`](docs/specs/) - Technical blueprints and implementation plans
- [`docs/journal/`](docs/journal/) - Engineering journal entries

## License

See [`LICENSE.md`](LICENSE.md) for licensing information.

---

**Note:** This project is designed for local, offline LLM inference. All model weights are downloaded from HuggingFace and run entirely on your hardware.
