# Comprehensive Plan: Migration to Manual Model Management Paradigm

This document delineates the required procedural migration path from the legacy practice of relying on `llama-server`'s inherently abstracted, built-in Hugging Face downloader utility towards a more deterministic, explicit model management strategy utilizing the official Hugging Face Command Line Interface (CLI). This paradigm shift is specifically tailored and strictly adapted for the `run-server.sh` router execution environment and its associated `.ini` structured preset configuration architecture.

## 1. Prerequisites: Installation of the Hugging Face CLI via `uv`

The foundational prerequisite for this operational shift is the installation of the `huggingface_hub` Python package, specifically the variant that explicitly includes the CLI binaries. We will utilize `uv`, a deterministic and highly performant Python toolchain manager, to provision this utility.

```bash
# Execute this command to install the CLI tool into an isolated, globally accessible environment
# managed by uv. The '--upgrade' flag guarantees that any pre-existing installation is upgraded
# to the latest available version, thereby mitigating potential compatibility regressions.
uv tool install --upgrade "huggingface_hub[cli]"

# Alternatively, to execute the command ephemerally without permanent installation, 
# or if you prefer to bypass global tool installation, you can utilize uvx:
# uvx --from "huggingface_hub[cli]" huggingface-cli download ...
```

## 2. Establishment of a Local Model Repository and Explicit Asset Acquisition

Historically, `llama-server` was permitted to download model assets dynamically and transiently during runtime instantiation as requested by the router. To circumvent this unpredictable latency and reliance on external network availability during server operation, we must establish a dedicated, static local directory (e.g., `./models` situated at the root of the project repository).

```bash
# The '-p' flag is crucial here; it ensures the directory is created if it does not exist,
# while silently succeeding without error if the directory is already present, thus ensuring idempotency.
mkdir -p models

# Explicitly command the Hugging Face CLI to download the specified GGUF artifact.
# Qwen/Qwen1.5-7B-Chat-GGUF represents the precise repository namespace and model identifier.
# qwen1_5-7b-chat-q4_k_m.gguf is the exact filename of the quantized model weight file requested.
huggingface-cli download Qwen/Qwen1.5-7B-Chat-GGUF qwen1_5-7b-chat-q4_k_m.gguf --local-dir ./models --local-dir-use-symlinks False
```

*Crucial Pedantic Note: The explicit inclusion of `--local-dir-use-symlinks False` is a non-negotiable directive for this architecture. By default, the Hugging Face CLI optimizes disk usage by downloading to a centralized `~/.cache/huggingface/` directory and creating symbolic links (symlinks) to the target directory. In Infrastructure-as-Code (IaC) or containerized environments, symlinks can introduce opaque resolution errors or pathing anomalies. Bypassing symlinks guarantees that the physical binary blob resides exactly where specified.*

## 3. Reconfiguration of the Router Preset Definitions (`.ini`)

The final technical requirement involves meticulously updating both `scripts/presets.ini` and `scripts/macos-presets.ini`. These files must be modified to deprecate any reliance on Hugging Face URI schemes (`hf://`) or the `-hf` auto-download flag abstraction. Instead, they must be strictly configured to reference absolute or correctly resolved relative paths pointing to the locally stored artifacts.

**Deprecated Approach (Implicit HF Resolution within Preset Configs):**
```ini
[qwen]
# This configuration is considered legacy as it delegates asset resolution to the 
# runtime engine via external network calls, violating the principle of local determinism.
model = hf://Qwen/Qwen1.5-7B-Chat-GGUF/qwen1_5-7b-chat-q4_k_m.gguf
alias = qwen
```

**Modernized Approach (Explicit Local File System Pathing):**
```ini
[qwen]
# The path must be constructed relative to the Current Working Directory (CWD) from which 
# the llama-server binary is invoked by the run-server.sh script. Assuming the script is 
# executed from the project root or the script internally navigates correctly, the path 
# reflects a traversal to the aforementioned local directory.
model = ../models/qwen1_5-7b-chat-q4_k_m.gguf
alias = qwen
```

*(Advisory: The validity of the `../models/` relative path is contingent upon the exact execution context of `llama-server`. Should `run-server.sh` execute `llama-server` directly from within the `scripts/` directory, the `../` traversal is correct. If execution occurs from the repository root, the path must be amended to strictly `./models/` or simply `models/`).*

## Comprehensive Summary of Architectural Benefits within Router Mode

- **Zero-Latency Model Context Switching:** When an incoming API request necessitates that the router context-switch from one active model to another (a constraint strictly governed by the `--models-max 1` parameter to prevent VRAM over-allocation), the required model is loaded instantaneously from local non-volatile storage. This entirely bypasses the need for the engine to pause execution to negotiate ETags or validate asset integrity against the remote Hugging Face API endpoints.
- **Absolute Air-Gapped Reliability:** The server architecture becomes entirely self-sufficient, capable of initial bootstrap and arbitrary model context switching in a completely disconnected, offline environment.
- **Deterministic Storage Allocation:** The management of volatile and non-volatile storage becomes transparent. Multi-gigabyte model artifacts are strictly isolated within the explicitly defined `./models` directory, preventing the gradual and opaque consumption of disk space historically associated with the hidden `~/.cache/huggingface` directory structure.

## References
- https://huggingface.co/docs/hub/models-downloading#using-the-hugging-face-client-library
- https://huggingface.co/docs/huggingface_hub/en/guides/cli#download-an-entire-repository
