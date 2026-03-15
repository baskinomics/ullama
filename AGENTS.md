# Agent Guidelines for Ullama Repository

This file provides instructions for AI agents operating in the Ullama repository. It covers build, lint, test procedures, and code style guidelines.

## 1. Build, Lint, and Test Commands

### 1.1 Build Instructions
The Ullama repository primarily contains bash scripts for configuring and running llama.cpp models. The main build step involves compiling llama.cpp with CUDA support.

- **Build llama.cpp**: Run the provided update script:
  ```bash
  ./scripts/update_llama_cpp.sh
  ```
  This script:
  1. Pulls the latest llama.cpp from upstream
  2. Configures CMake with `-DGGML_CUDA=ON`
  3. Compiles using all available CPU cores

- **Alternative manual build** (if needed):
  ```bash
  cd ~/workspace/machine-learning/llama.cpp
  cmake -B build -DGGML_CUDA=ON
  cmake --build build --config Release -j$(nproc)
  ```

### 1.2 Linting
Lint bash scripts using [shellcheck](https://www.shellcheck.net/).

- **Lint all scripts**:
  ```bash
  find scripts/ -name "*.sh" -exec shellcheck {} +
  ```
- **Lint a single script**:
  ```bash
  shellcheck scripts/qwen/qwen3-coder-next.sh
  ```
- **Fix common issues**: Shellcheck provides suggestions; apply them manually.

### 1.3 Testing
Testing focuses on script syntax and basic functionality.

- **Syntax check** (dry-run):
  ```bash
  bash -n scripts/qwen/qwen3-coder-next.sh
  ```
- **Run a script with safe parameters** (e.g., short timeout, low resource usage):
  ```bash
  timeout 10s scripts/qwen/qwen3-coder-next.sh --help 2>/dev/null || true
  ```
  Note: Most scripts launch llama-server; use `--help` or similar flags if supported.

- **Run a single test** (for a specific model script):
  ```bash
  # Example: Test Qwen3-Coder-Next script syntax and argument parsing
  bash -n scripts/qwen/qwen3-coder-next.sh && \
  scripts/qwen/qwen3-coder-next.sh --help 2>&1 | head -20
  ```

### 1.4 Docker Compose
The repository includes a Docker Compose file for Open WebUI.

- **Start services**:
  ```bash
  docker-compose up -d
  ```
- **Stop services**:
  ```bash
  docker-compose down
  ```
- **View logs**:
  ```bash
  docker-compose logs -f openwebui
  ```

## 2. Code Style Guidelines

### 2.1 Bash Scripting
All bash scripts should follow the Google Shell Style Guide (https://google.github.io/styleguide/shell.xml) with project-specific adaptations.

#### 2.1.1 Shebang and Safety
- Use `#!/usr/bin/env bash` as the shebang.
- Enable safety options: `set -euo pipefail` (or `set -euxo pipefail` for debugging).
- Example header:
  ```bash
  #!/usr/bin/env bash
  set -euo pipefail
  ```

#### 2.1.2 Indentation and Formatting
- Indent with 2 spaces (no tabs).
- Maximum line length: 80 characters (preferable), 100 characters (absolute max).
- Keep arrays and multi-line arguments aligned for readability.

#### 2.1.3 Variables
- Use lowercase with underscores for variable names (`variable_name`).
- Declare variables explicitly when possible (`local` inside functions).
- Quote variable expansions: `"$variable"`.
- Use arrays for lists of items (e.g., command arguments).

#### 2.1.4 Functions
- Declare functions with `function_name() {` (no `function` keyword).
- Place `local` variable declarations at the start of the function.
- Use `return` for status codes; avoid echoing for return values unless intended.
- Example:
  ```bash
  log() {
      echo -e "\033[1;34m==>\033[0m $*"
  }
  ```

#### 2.1.5 Error Handling
- Prefer `set -e` to exit on errors.
- Handle expected errors with conditionals; use `||` for simple cases.
- Provide informative error messages to stderr.
- Example:
  ```bash
  [[ -d "${TARGET_DIR}" ]] || err "Directory not found: ${TARGET_DIR}"
  ```

#### 2.1.6 Logging and Output
- Use stderr for diagnostics and errors; stdout for script output meant for consumption.
- Implement helper functions for logging (`log`, `err`, `info`).
- Avoid excessive verbosity; use quiet flags where available.

#### 2.1.7 Comments
- Explain why, not what.
- Use `#` for comments; keep them updated.
- Section headers can use `#` followed by a description.

#### 2.1.8 Argument Parsing
- For simple scripts, use `args=(...)` arrays to pass to underlying commands.
- For complex argument handling, consider using `getopts` or a structured approach.
- Validate required arguments and environment.

### 2.2 General Code Style
- Files should end with a newline.
- Remove trailing whitespace.
- Use UTF-8 encoding (ASCII subset is fine for bash scripts).
- Name scripts with descriptive, lowercase names and `.sh` extension.
- Place provider-specific scripts in subdirectories under `scripts/` (e.g., `scripts/qwen/`, `scripts/nvidia/`).

### 2.3 Documentation
- Each script should have a brief header describing its purpose.
- Refer to the README.md for overall project documentation.
- Update HOST_ENV.md via `scripts/update_agent_context.sh` when hardware changes.

## 3. Additional Notes

### 3.1 Working with Models
- Model scripts are located in `scripts/<provider>/`.
- They typically define an `args` array and invoke `llama-server` with `taskset` for CPU affinity.
- Adjust parameters (context size, threads, batch size) based on model and hardware.

### 3.2 Environment Setup
- Ensure Docker is installed and the user is in the `docker` group.
- Verify CUDA toolkit and NVIDIA drivers are functional.
- The `llama.cpp` build directory is expected at `${HOME}/workspace/machine-learning/llama.cpp/build`.

### 3.3 Contributing
- Follow the existing style in the repository.
- Test modifications with shellcheck and syntax checks.
- Keep scripts idempotent where possible.
- Update documentation if changing interfaces.

## 4. Summary of Commands

Quick reference for common agent tasks:

- **Lint all scripts**: `find scripts/ -name "*.sh" -exec shellcheck {} +`
- **Check syntax of a script**: `bash -n scripts/<path>/<script>.sh`
- **Build llama.cpp**: `./scripts/update_llama_cpp.sh`
- **Start services**: `docker-compose up -d`
- **Stop services**: `docker-compose down`
- **View logs**: `docker-compose logs -f openwebui`
- **Update host environment**: `./scripts/update_agent_context.sh`

These guidelines ensure consistency and quality across the Ullama repository.