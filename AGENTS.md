# Agent Guidelines for Ullama Repository

This file provides instructions for AI agents operating in the Ullama repository.

## 1. Build, Lint, and Test Commands

### 1.1 Build Instructions

- **Build llama.cpp**: Run `make build` or `./scripts/update_llama_cpp.sh`
  This pulls latest llama.cpp, configures CMake with `-DGGML_CUDA=ON`, and compiles.

- **Manual build** (if needed):
  ```bash
  cd ~/workspace/machine-learning/llama.cpp
  cmake -B build -DCMAKE_BUILD_TYPE=Release -DGGML_CUDA=ON
  cmake --build build --config Release -j$(nproc)
  ```

### 1.2 Linting

- **Lint all scripts**: Run `make lint` or:
  ```bash
  find scripts/ -name "*.sh" -exec shellcheck {} +
  ```
- **Lint a single script**: Run `shellcheck scripts/run-server.sh`

### 1.3 Testing

- **Syntax check**: Run `make test` or `bash -n scripts/<file>.sh`
- **Full validation pipeline**: Run `make validate`

### 1.4 Docker Compose

- **Start services**: `make docker-up` or `docker-compose up -d`
- **Stop services**: `make docker-down` or `docker-compose down`
- **View logs**: `make docker-logs` or `docker-compose logs -f openwebui`

### 1.5 Server Management (tmux)

- **Start server (tmux)**: `make server-tmux`
- **Stop server (tmux)**: `make stop`
- **Stop tmux session**: `make stop-tmux`

### 1.6 Maintenance

- **Ensure port is open**: `make port-open`


## 2. Code Style Guidelines

### 2.1 Bash Scripting
Follow Google Shell Style Guide with these project-specific requirements:
- **Safety:** Use `#!/usr/bin/env bash` and `set -euo pipefail`.
- **Structure:** Use a `main() { ... }` function pattern called at the end: `main "$@"`.
- **Variables:** `readonly` for constants, `local` for function scope, always quote expansions `"$var"`.
- **Arguments:** Use arrays for command arguments (e.g., `ARGS=(--flag1 --flag2)`).
- **Functions:** Use `name() {` syntax (no `function` keyword).
- **Error Handling:** Use `[[ condition ]] || err "message"` for early validation.
- **Logging:** Use `log()` for info (blue) and `err()` for errors (red, exits).

### 2.2 Formatting
- **Indentation:** 2 spaces.
- **Line Length:** Max 80-100 chars.
- **Organization:** Scripts in `scripts/`, descriptive lowercase names, purpose header at top.

## 3. Common Patterns

### Router Server Invocation
```bash
CMD_PREFIX="taskset -c 0-7"  # Linux CPU affinity
CMD_PREFIX=""                 # macOS
$CMD_PREFIX llama-server "${ARGS[@]}" "$@"
```

### OS Detection
```bash
OS_TYPE=$(uname -s)
[[ "$OS_TYPE" = "Darwin" ]] && PRESET_FILE="config/macos-presets.ini" || PRESET_FILE="config/presets.ini"
```

## 4. Commit Message Style

### Conventional Commits

All commit messages should follow [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <subject>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `chore`: Maintenance, configs, non-user-facing changes
- `docs`: Documentation changes
- `refactor`: Code restructuring without behavior changes
- `test`: Adding or updating tests

**Examples:**
- `feat(presets): add Qwen3.5-27B reasoning-distilled model`
- `chore(presets): move Qwen3.5-397B-A17B to macOS presets`
- `fix(server): resolve CUDA memory allocation issue`

**Guidelines:**
- Use imperative mood: "add" not "added"
- Lowercase subject, no period at end
- Include scope in parentheses when applicable
- Use bullet points with hyphens for commit body

## 5. Quick Reference

| Task | Command |
|------|---------|
| Lint all | `find scripts/ -name "*.sh" -exec shellcheck {} +` |
| Syntax check | `bash -n scripts/<file>.sh` |
| Build llama.cpp | `./scripts/update_llama_cpp.sh` |
| Start services | `docker-compose up -d` |
| Stop services | `docker-compose down` |
| Update context | `./scripts/update_agent_context.sh` |

### SSH + tmux Remote Access

For remote server access (temporary until systemd implementation):

- **Start:** `./scripts/start-server-tmux.sh`
- **Attach:** `tmux attach -t ullama-server`
- **Stop:** `tmux kill-session -t ullama-server`
- **API Endpoint:** `http://<hostname>:8001/v1`

See `scripts/README.md` for full documentation.
