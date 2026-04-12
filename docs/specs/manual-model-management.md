# Spec: Manual Model Management

## Context & Research
The legacy approach relies on `llama-server`'s built-in Hugging Face downloader, which resolves `hf://` URIs at runtime. This introduces network latency during model context switching, creates a dependency on external API availability, and stores assets in an opaque global cache (`~/.cache/huggingface`).

## Proposed Approach
Shift to a deterministic model management strategy where assets are explicitly downloaded to a local project directory and referenced by direct file paths.

### 1. Tooling Setup
Use `uv` to install the Hugging Face CLI for deterministic asset acquisition.
```bash
uv tool install --upgrade "huggingface_hub[cli]"
```

### 2. Asset Acquisition Workflow
Establish a local repository and download GGUF artifacts without symlinks to ensure physical residency within the project.
```bash
# Create local storage
mkdir -p models

# Download specific artifact
huggingface-cli download <REPO_ID> <FILENAME> --local-dir ./models --local-dir-use-symlinks False
```

### 3. Preset Configuration
Update `config/presets.ini` and `config/presets-macos.ini` to reference local paths instead of HF URIs.

**From:** `model = hf://Qwen/Qwen1.5-7B-Chat-GGUF/qwen1_5-7b-chat-q4_k_m.gguf`
**To:** `model = ./models/qwen1_5-7b-chat-q4_k_m.gguf`

## Implementation Checklist
- [ ] Install `huggingface_hub[cli]` via `uv`
- [ ] Create `./models` directory
- [ ] Download required GGUF models to `./models`
- [ ] Update `.ini` presets to use local paths
- [ ] Verify server startup and model switching without network access

## Benefits
- **Zero-Latency Switching:** Immediate loading from local storage during context switches.
- **Air-Gapped Reliability:** Full offline capability.
- **Deterministic Storage:** Transparent disk usage within the project root.
