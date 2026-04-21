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
# Replace the repo and filename with the actual values from the mapping table above.
# Use `huggingface-cli list-repo-files <repo>` to verify the exact filename first.
huggingface-cli download unsloth/Qwen3.6-35B-A3B-GGUF qwen3.6-35b-a3b-q4_k_xl.gguf --local-dir ./models --local-dir-use-symlinks False
```

*Crucial Pedantic Note: The explicit inclusion of `--local-dir-use-symlinks False` is a non-negotiable directive for this architecture. By default, the Hugging Face CLI optimizes disk usage by downloading to a centralized `~/.cache/huggingface/` directory and creating symbolic links (symlinks) to the target directory. In Infrastructure-as-Code (IaC) or containerized environments, symlinks can introduce opaque resolution errors or pathing anomalies. Bypassing symlinks guarantees that the physical binary blob resides exactly where specified.*

## 3. Reconfiguration of the Router Preset Definitions (`.ini`)

The final technical requirement involves meticulously updating both `config/presets.ini` and `config/presets-macos.ini`. These files must be modified to deprecate any reliance on Hugging Face URI schemes (`hf://`) or the `-hf` auto-download flag abstraction. Instead, they must be strictly configured to reference absolute or correctly resolved relative paths pointing to the locally stored artifacts.

**Deprecated Approach (Implicit HF Resolution within Preset Configs):**
```ini
[unsloth/Qwen3.6-35B-A3B]
# This configuration is considered legacy as it delegates asset resolution to the 
# runtime engine via external network calls, violating the principle of local determinism.
hf = unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q4_K_XL
```

**Modernized Approach (Explicit Local File System Pathing):**
```ini
[unsloth/Qwen3.6-35B-A3B]
# The path is relative to the repository root where run-server.sh is invoked.
# The `model` field replaces the `hf` field to use a local file instead of remote resolution.
model = ./models/qwen3.6-35b-a3b-q4_k_xl.gguf
```

*(Advisory: The `./models/` path is relative to the repository root. `run-server.sh` resolves preset paths from the project root context, so `./models/` is correct.)*

Note: `config/presets-macos.ini` requires identical updates for any active model entries, using `model = ./models/<file>` instead of `hf = ...`.

### Model Download Mapping

| Preset Section | HF Repo | Target Quant | Local Filename |
|---|---|---|---|
| `unsloth/Qwen3.5-122B-A10B` | `unsloth/Qwen3.5-122B-A10B-GGUF` | Q3_K_XL | `qwen3.5-122b-a10b-q3_k_xl.gguf` |
| `unsloth/Qwen3.5-27B` | `unsloth/Qwen3.5-27B-GGUF` | Q4_K_XL | `qwen3.5-27b-q4_k_xl.gguf` |
| `unsloth/Qwen3.6-35B-A3B` | `unsloth/Qwen3.6-35B-A3B-GGUF` | Q4_K_XL | `qwen3.6-35b-a3b-q4_k_xl.gguf` |
| `unsloth/Gemma-4-31B` | `unsloth/gemma-4-31B-it-GGUF` | Q4_0 | `gemma-4-31b-it-q4_0.gguf` |
| `unsloth/Gemma-4-26B-A4B` | `unsloth/gemma-4-26B-A4B-it-GGUF` | Q6_K_XL | `gemma-4-26b-a4b-it-q6_k_xl.gguf` |

*Verify exact filenames on HuggingFace before downloading:*
```bash
huggingface-cli list-repo-files unsloth/Qwen3.6-35B-A3B-GGUF | grep -i q4_k
```

## Comprehensive Summary of Architectural Benefits within Router Mode

- **Zero-Latency Model Context Switching:** When an incoming API request necessitates that the router context-switch from one active model to another (a constraint strictly governed by the `--models-max 1` parameter to prevent VRAM over-allocation), the required model is loaded instantaneously from local non-volatile storage. This entirely bypasses the need for the engine to pause execution to negotiate ETags or validate asset integrity against the remote Hugging Face API endpoints.
- **Absolute Air-Gapped Reliability:** The server architecture becomes entirely self-sufficient, capable of initial bootstrap and arbitrary model context switching in a completely disconnected, offline environment.
- **Deterministic Storage Allocation:** The management of volatile and non-volatile storage becomes transparent. Multi-gigabyte model artifacts are strictly isolated within the explicitly defined `./models` directory, preventing the gradual and opaque consumption of disk space historically associated with the hidden `~/.cache/huggingface` directory structure.

## References
- https://huggingface.co/docs/hub/models-downloading#using-the-hugging-face-client-library
- https://huggingface.co/docs/huggingface_hub/en/guides/cli#download-an-entire-repository
