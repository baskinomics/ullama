# Ullama Project Context

Ullama is an Infrastructure-as-Code (IaC) project designed to manage and orchestrate local Large Language Model (LLM) environments. It primarily uses `llama-server` (from `llama.cpp`) for serving models and Docker for ancillary services like Open WebUI and Ollama.

## Project Overview

- **Core Purpose:** Automating the setup and execution of local LLM servers with optimized configurations.
- **Main Technologies:** 
  - **llama.cpp / llama-server:** Used for high-performance GGUF model serving.
  - **Docker & Docker Compose:** Used for running [Open WebUI](https://github.com/open-webui/open-webui) and managing [Ollama](https://ollama.com/) instances.
  - **Shell Scripts:** Provide a consistent interface for launching specific models with tuned parameters (context size, GPU layers, etc.).
- **Architecture:** The project consists of standalone shell scripts for different models, a centralized Ollama wrapper, and a Docker Compose setup for the user interface.

## Building and Running

### Running Model Servers
Each `.sh` script in the root directory corresponds to a specific model. These scripts launch `llama-server` with optimized flags for the specific hardware/model combination.

- **Example (Qwen 3.5):**
  ```bash
  ./qwen3.5.sh
  ```
- **Port Consistency:** Most model servers are configured to run on port `8001` (OpenAI-compatible API).

### Managing Ollama via Docker
The `ollama-wrapper.sh` script provides a convenient CLI for managing an Ollama container.

- **Status:** `./ollama-wrapper.sh status`
- **Run/Start:** `./ollama-wrapper.sh run` or `./ollama-wrapper.sh start`
- **Pull Model:** `./ollama-wrapper.sh pull <model_name>`
- **Logs:** `./ollama-wrapper.sh logs`

### Web Interface (Open WebUI)
Open WebUI provides a ChatGPT-like interface for interacting with the local models.

- **Start:** `docker-compose up -d`
- **Access:** Typically available at `http://localhost:3000` (mapped to `8080` internally).

## Development Conventions

### Shell Scripting Standards
As detailed in `AGENTS.md`, the project follows specific conventions for its automation scripts:

- **Shebang:** Always use `#!/bin/bash`.
- **Naming:** Files use lowercase with hyphens (e.g., `minimax-2.5.sh`). Variables use `UPPER_CASE`.
- **Model Configuration:** Scripts use the `-hf` flag to pull/reference models directly from Hugging Face and use `--alias` for consistent naming in APIs.
- **Reproducibility:** A fixed seed (`--seed 3407`) is often used in model scripts to ensure consistent outputs during testing.

### Adding New Models
To add a new model to the infrastructure:
1. Create a new `.sh` script named after the model.
2. Follow the established pattern using `llama-server` with appropriate `--ctx-size`, `--n-gpu-layers`, and `--port 8001`.
3. Update the `opencode.json` provider configuration if the model needs to be exposed to specific integrations.

### Testing
- **Syntax Check:** Use `bash -n <script>.sh` to verify script validity.
- **Manual Verification:** Start the server and verify the health endpoint or use a tool like `curl` to hit the `/v1/models` endpoint.
