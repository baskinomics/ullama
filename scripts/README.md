# Ullama Scripts

Bash scripts for running and managing AI models with llama.cpp.

## Directory Structure

```
scripts/
├── update_llama_cpp.sh      # Update and build llama.cpp
├── update_agent_context.sh  # Generate host environment context
├── install-docker.sh        # Install Docker with GPU support
├── minimax/                 # MiniMax model scripts
├── mistral/                 # Mistral model scripts
├── nanbeige/                # Nanbeige model scripts
├── nvidia/                  # NVIDIA model scripts
├── openai/                  # OpenAI model scripts
├── qwen/                    # Qwen model scripts
├── stepfun/                 # StepFun model scripts
├── tesslate/                # Tesslate model scripts
└── zai/                     # ZAI model scripts
```

## Usage

### Running a Model

```bash
./scripts/<provider>/<model>.sh
```

Example:
```bash
./scripts/qwen/qwen3-coder-next.sh
./scripts/nvidia/nemotron-3-super_UD_Q3_K_XL.sh
```

### Updating llama.cpp

```bash
./scripts/update_llama_cpp.sh
```

### Generating Environment Context

```bash
./scripts/update_agent_context.sh
```

This generates `HOST_ENV.md` with hardware specifications.

## Model Providers

| Provider | Description |
|----------|-------------|
| `minimax/` | MiniMax models (M2.1, M2.5) |
| `mistral/` | Mistral models (Devstral) |
| `nanbeige/` | Nanbeige models |
| `nvidia/` | NVIDIA Nemotron models |
| `openai/` | OpenAI models (GPT-OSS) |
| `qwen/` | Qwen models (3.5 series, Coder) |
| `stepfun/` | StepFun models |
| `tesslate/` | Tesslate models |
| `zai/` | ZAI models (GLM series) |

## Common Parameters

Most scripts use the following parameters:

- `--ctx-size`: Context window size
- `--threads`: Number of CPU threads
- `--cache-type-k/v`: KV cache quantization
- `--flash-attn`: Flash attention (CUDA)
- `--fit`: Fit model to VRAM
- `--port`: Server port
- `--jinja`: Enable Jinja chat templates

## Platform Notes

### Linux
- Scripts use `taskset` for CPU affinity
- Requires NVIDIA Container Toolkit for GPU support
- Uses `set -euo pipefail` for safety

### macOS
- Scripts may have `-ngl 999` for GPU layer offload
- Different hardware detection commands
- May use different quantization defaults

## Build Requirements

1. **llama.cpp**: Built with CUDA support (`-DGGML_CUDA=ON`)
2. **Docker**: Optional, for containerized runs
3. **NVIDIA Drivers**: Required for GPU acceleration

## Logging

Scripts create log files with `-logs.txt` suffix in their respective directories. Logs are automatically managed and can be cleaned up as needed.

## Code Style

All scripts follow:
- `#!/usr/bin/env bash` shebang
- `set -euo pipefail` safety options
- 2-space indentation
- 80 character line length (max 100)
- Consistent parameter ordering

## Contributing

When adding new model scripts:
1. Follow existing naming conventions
2. Use consistent parameter ordering
3. Add brief header comments
4. Test with `bash -n <script>.sh` for syntax validation
5. Run `shellcheck <script>.sh` for linting
