# Agent Guidelines for Ullama Repository

This file provides instructions for AI agents operating in the Ullama repository.

## 1. Build, Lint, and Test Commands

### 1.1 Build Instructions

- **Build llama.cpp**: Run the provided update script:
  ```bash
  ./scripts/update_llama_cpp.sh
  ```
  This pulls latest llama.cpp, configures CMake with `-DGGML_CUDA=ON`, and compiles.

- **Manual build** (if needed):
  ```bash
  cd ~/workspace/machine-learning/llama.cpp
  cmake -B build -DCMAKE_BUILD_TYPE=Release -DGGML_CUDA=ON
  cmake --build build --config Release -j$(nproc)
  ```

### 1.2 Linting

- **Lint all scripts**:
  ```bash
  find scripts/ -name "*.sh" -exec shellcheck {} +
  ```
- **Lint a single script**:
  ```bash
  shellcheck scripts/run-server.sh
  ```

### 1.3 Testing

- **Syntax check**:
  ```bash
  bash -n scripts/run-server.sh
  ```
- **Test a script** (safe dry-run):
  ```bash
  bash -n scripts/run-server.sh && scripts/run-server.sh --help 2>&1 | head -20
  ```
- **Full validation pipeline**:
  ```bash
  bash -n scripts/*.sh && find scripts/ -name "*.sh" -exec shellcheck {} +
  ```

### 1.4 Docker Compose

- **Start services**: `docker-compose up -d`
- **Stop services**: `docker-compose down`
- **View logs**: `docker-compose logs -f openwebui`

## 2. Code Style Guidelines

### 2.1 Bash Scripting

Follow Google Shell Style Guide with project adaptations.

#### Shebang and Safety
```bash
#!/usr/bin/env bash
set -euo pipefail
```

#### Structure Pattern
All scripts should use a `main()` function pattern:
```bash
log() {
    echo -e "\033[1;34m==>\033[0m $*"
}

err() {
    echo -e "\033[1;31mERROR:\033[0m $*" >&2
    exit 1
}

main() {
    local var_name="value"
    [[ -d "${PATH}" ]] || err "Path not found: ${PATH}"
    # ... logic
}

main "$@"
```

#### Variables
- Use `readonly` for constants: `readonly TARGET_DIR="..."`
- Use `local` for function-scoped variables
- Always quote expansions: `"$variable"`
- Use arrays for command arguments: `ARGS=(--flag1 --flag2)`

#### Functions
- Use `name() {` syntax (no `function` keyword)
- Place `local` declarations at function start
- Return exit codes with `return N` or `exit N`

#### Error Handling
- Use `set -euo pipefail` for strict mode
- Handle expected failures with `||`:
  ```bash
  git rebase origin/master || err "Rebase failed"
  ```
- Validate prerequisites early with `[[ condition ]] || err "message"`

#### Logging
- Use `log()` for info messages (stdout, blue)
- Use `err()` for errors (stderr, red, exits)
- Keep stdout clean for script output consumption

### 2.2 Formatting

- **Indentation**: 2 spaces, no tabs
- **Line length**: Max 80 chars (preferable), 100 max
- **Quotes**: Always `"$var"` not `$var`
- **Arrays**: Multi-line for readability
  ```bash
  ROUTER_ARGS=(
      --models-preset "$PRESET_FILE"
      --models-max 1
      --port 8001
  )
  ```

### 2.3 File Organization

- Scripts live in `scripts/`
- Use descriptive lowercase names: `update_llama_cpp.sh`
- Include purpose header comment at top of each script
- End files with newline, no trailing whitespace

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
[[ "$OS_TYPE" = "Darwin" ]] && PRESET_FILE="macos-presets.ini" || PRESET_FILE="presets.ini"
```

## 4. Quick Reference

| Task | Command |
|------|---------|
| Lint all | `find scripts/ -name "*.sh" -exec shellcheck {} +` |
| Syntax check | `bash -n scripts/<file>.sh` |
| Build llama.cpp | `./scripts/update_llama_cpp.sh` |
| Start services | `docker-compose up -d` |
| Stop services | `docker-compose down` |
| Update context | `./scripts/update_agent_context.sh` |
