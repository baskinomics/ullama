# Ullama - Local LLM Infrastructure

A local large language model (LLM) infrastructure project that runs various open-source models using `llama.cpp` with CUDA acceleration, served via Open WebUI.

## Project Overview

This project provides a complete setup for running multiple LLMs locally on an NVIDIA GPU-powered system. It uses:

- **llama.cpp** - High-performance inference engine with CUDA support
- **Open WebUI** - Web-based chat interface for interacting with models
- **Docker Compose** - Container orchestration for the Open WebUI service
- **Shell scripts** - Model server launch configurations for various LLMs

### Architecture

```
┌─────────────────────┐     ┌──────────────────────┐
│   Open WebUI        │◄────│  llama.cpp Server    │
│   (Docker:3000)     │     │  (Port 8001)         │
└─────────────────────┘     └──────────────────────┘
                                    │
                                    ▼
                           ┌──────────────────┐
                           │  LLM Models      │
                           │  (GGUF format)   │
                           └──────────────────┘
```

## Host Environment

- **OS:** CachyOS (Arch Linux-based)
- **CPU:** AMD Ryzen 9 7950X3D 16-Core Processor
- **GPU:** NVIDIA GeForce RTX 4090
- **Memory:** 61GB RAM
- **Storage:** 1.9TB NVMe (778G used)

See [`HOST_ENV.md`](HOST_ENV.md) for detailed system specifications.

## Directory Structure

```
ullama/
├── docker-compose.yaml      # Open WebUI container configuration
├── HOST_ENV.md             # Host system specification
├── LICENSE.md              # License file
├── QWEN.md                 # This file - agent context
├── docs/
│   └── cachy-os.md         # CachyOS setup guide
└── scripts/
    ├── install-docker.sh           # Docker installation script
    ├── update_llama_cpp.sh         # Update and rebuild llama.cpp
    ├── update_agent_context.sh     # Generate HOST_ENV.md dynamically
    ├── minimax/                    # MiniMax model scripts
    ├── mistral/                    # Mistral model scripts
    ├── nanbeige/                   # NanBeige model scripts
    ├── nvidia/                     # NVIDIA Nemotron model scripts
    ├── openai/                     # OpenAI model scripts
    ├── qwen/                       # Qwen model scripts
    └── zai/                        # ZAI model scripts
```

## Building and Running

### Prerequisites

1. **Install Docker** (CachyOS):
   ```bash
   ./scripts/install-docker.sh
   # Log out and back in for docker group changes to take effect
   ```

2. **Build llama.cpp with CUDA**:
   ```bash
   cd ~/workspace/machine-learning/llama.cpp
   rm -rf build/
   cmake -B build -DGGML_CUDA=ON
   cmake --build build --config Release -j$(nproc)
   ```

3. **Add llama.cpp to PATH** (if needed):
   ```bash
   fish_add_path ~/workspace/machine-learning/llama.cpp/build/bin
   ```

### Starting Services

1. **Start Open WebUI**:
   ```bash
   docker-compose up -d
   ```

2. **Verify installation**:
   ```bash
   docker-compose ps
   curl http://localhost:8001/v1/models
   watch nvidia-smi
   ```

3. **Launch a model server**:
   ```bash
   # Example: Start Qwen3-Coder-Next
   ./scripts/qwen/qwen3-coder-next.sh
   
   # Example: Start Nemotron-3-Nano
   ./scripts/nvidia/nemotron-3-nano.sh
   ```

4. **Access Open WebUI**:
   - Open browser at `http://localhost:3000`

### Stopping Services

```bash
docker-compose down
# Kill running model servers
pkill llama-server
```

## Available Models

Model scripts are organized by provider in `scripts/`:

| Provider | Models |
|----------|--------|
| **Qwen** | Qwen3-Coder-Next, Qwen3.5 (9B, 27B, 35B, 122B) |
| **NVIDIA** | Nemotron-3-Nano (30B A3B) |
| **Mistral** | Devstral Small |
| **MiniMax** | MiniMax 2.5, M2.1 (macOS) |

### Model Configuration Parameters

Common parameters used in model scripts:

- `-hf` / `--hf`: HuggingFace model reference with GGUF quantization
- `--ctx-size`: Context window size (e.g., 262144 for long context)
- `--threads`: CPU threads for non-GPU layers
- `--threads-batch`: Threads for batch processing
- `--n-gpu-layers`: Layers to offload to GPU
- `--flash-attn`: Flash attention enablement
- `--cache-type-k/v`: KV cache quantization
- `--temp`, `--top-p`, `--top-k`: Sampling parameters

## Development Conventions

### Script Naming

- Model scripts: `{provider}/{model-name}.sh`
- Utility scripts: `kebab-case.sh`

### Code Style

- Shell scripts use `set -euo pipefail` for strict error handling
- Array-based argument passing preferred (`args=(...)`)
- Comments explain non-obvious configurations

### GPU Optimization

- Scripts use `taskset -c 0-N` to bind processes to specific CPU cores
- MoE models use `--n-cpu-moe` for expert routing on CPU
- KV cache quantization (`q8_0`) reduces memory footprint

## Maintenance

### Update llama.cpp

```bash
./scripts/update_llama_cpp.sh
```

This script:
1. Pulls latest changes from upstream
2. Rebuilds with CUDA enabled
3. Uses rebase for clean history

### Regenerate Host Environment

```bash
./scripts/update_agent_context.sh HOST_ENV.md
```

## Troubleshooting

### Port Conflicts

```bash
# Check port usage
ss -tlnp | grep -E ':(3000|8001)'
lsof -i :3000
lsof -i :8001
```

### CUDA Verification

```bash
nvcc --version
lspci | grep VGA
pacman -Qs nvidia
```

### Docker Logs

```bash
docker-compose logs -f openwebui
docker-compose logs -f ollama
```

## License

See [`LICENSE.md`](LICENSE.md) for project licensing information.