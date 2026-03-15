# Ullama 🦙

> Local LLM infrastructure for running open-source models with CUDA acceleration.

[![Platform](https://img.shields.io/badge/platform-linux--64-blue.svg)](https://www.cachyos.org)
[![GPU](https://img.shields.io/badge/GPU-NVIDIA%20RTX%204090-orange.svg)](https://developer.nvidia.com/cuda-toolkit)
[![llama.cpp](https://img.shields.io/badge/inference-llama.cpp-green.svg)](https://github.com/ggml-org/llama.cpp)

## Overview

Ullama provides a complete local LLM setup for running various open-source models on NVIDIA GPU hardware. It combines `llama.cpp` with CUDA support and Open WebUI for an accessible chat interface.

### Features

- 🚀 **GPU Acceleration** - Full CUDA support via llama.cpp
- 🎨 **Open WebUI** - Familiar ChatGPT-like interface
- 📦 **Multiple Models** - Support for Qwen, Mistral, NVIDIA Nemotron, and more
- 🔧 **Easy Updates** - Scripts to keep llama.cpp current
- 💾 **Efficient Memory** - KV cache quantization and MoE optimization

## Quick Start

### Prerequisites

- CachyOS or Arch Linux (other distros may work)
- NVIDIA GPU with CUDA support (RTX 3090/4090 recommended)
- Minimum 16GB VRAM for larger models
- 32GB+ system RAM

### Installation

```bash
# 1. Install Docker
./scripts/install-docker.sh
# Log out and back in, then:

# 2. Start Open WebUI
docker-compose up -d

# 3. Build llama.cpp (if not already done)
cd ~/workspace/machine-learning/llama.cpp
cmake -B build -DGGML_CUDA=ON
cmake --build build --config Release -j$(nproc)

# 4. Launch a model
./scripts/qwen/qwen3-coder-next.sh
```

### Access

Open your browser at **http://localhost:3000** to start chatting.

## Available Models

| Model | Provider | Quantization | Context | Port |
|-------|----------|--------------|---------|------|
| Qwen3-Coder-Next | Unsloth | Q4_K_XL | 262K | 8001 |
| Qwen3.5-9B | Unsloth | - | - | 8001 |
| Qwen3.5-27B | Unsloth | - | - | 8001 |
| Qwen3.5-35B-A3B | Unsloth | - | - | 8001 |
| Qwen3.5-122B-A10B | Unsloth | - | - | 8001 |
| Nemotron-3-Nano-30B-A3B | NVIDIA | Q4_K_XL | 64K | 8001 |
| Devstral-Small | Mistral | - | - | 8001 |

Scripts are organized by provider in the `scripts/` directory.

## Architecture

```
┌──────────────┐      ┌─────────────────┐
│ Open WebUI   │◄────►│ llama.cpp API   │
│ localhost:3000│      │ localhost:8001  │
└──────────────┘      └────────┬────────┘
                               │
                               ▼
                        ┌─────────────┐
                        │ LLM Model   │
                        │ (GGUF)      │
                        └─────────────┘
```

## Configuration

### Docker Compose

The `docker-compose.yaml` configures Open WebUI to connect to llama.cpp running on the host:

```yaml
services:
    openwebui:
        image: ghcr.io/open-webui/open-webui:main
        ports:
            - "3000:8080"
        environment:
            - OPENAI_API_BASE_URL=http://host.docker.internal:8001/v1
```

### Model Scripts

Each model script configures llama-server with optimized parameters:

```bash
# Example: qwen3-coder-next.sh
args=(
    -hf unsloth/Qwen3-Coder-Next-GGUF:Q4_K_XL
    --ctx-size 262144
    --threads 8
    --threads-batch 16
    --flash-attn on
    --port 8001
)
taskset -c 0-7 llama-server "${args[@]}"
```

## Maintenance

### Update llama.cpp

```bash
./scripts/update_llama_cpp.sh
```

### Regenerate Environment Info

```bash
./scripts/update_agent_context.sh
```

### View Logs

```bash
docker-compose logs -f openwebui
watch nvidia-smi  # Monitor GPU usage
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Port 8001 in use | `lsof -i :8001` then kill process |
| Docker permission denied | Add user to docker group, reboot |
| CUDA not detected | Verify `nvcc --version` works |
| Model fails to load | Check GGUF path and quantization |

## Documentation

- [`HOST_ENV.md`](HOST_ENV.md) - Host system specifications
- [`docs/cachy-os.md`](docs/cachy-os.md) - Detailed CachyOS setup guide

## License

See [`LICENSE.md`](LICENSE.md) for licensing information.

---

**Note:** This project is designed for local, offline LLM inference. All model weights are downloaded from HuggingFace and run entirely on your hardware.