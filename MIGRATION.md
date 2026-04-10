# Migration Guide: From Shell Scripts to Makefile

This document outlines the transition from using individual shell scripts to using the unified `Makefile` interface for common operations in the Ullama repository.

## Why use the Makefile?

The `Makefile` provides a single entry point for all build, run, and maintenance tasks, offering:

- **Unified Interface**: No need to remember specific script names or paths.
- **Standardized Commands**: Consistent command patterns across different operations.
- **Built-in Help**: Quickly discover available commands with `make help`.
- **Improved Discoverability**: All available operations are documented within the Makefile itself.

## Quick Reference

| Task | Old Command | New Command |
|------|-------------|-------------|
| **Build llama.cpp** | `./scripts/update_llama_cpp.sh` | `make build` |
| **Clean Build** | `rm -rf ~/workspace/machine-learning/llama.cpp/build` | `make clean` |
| **Update llama.cpp** | `./scripts/update_llama_cpp.sh` | `make update` |
| **Start Server** | `./scripts/run-server.sh` | `make server` |
| **Start Server (tmux)**| `./scripts/start-server-tmux.sh` | `make server-tmux` |
| **Stop Server** | `./scripts/stop-server-tmux.sh` | `make stop` |
| **Stop tmux session** | `./scripts/stop-server-tmux.sh` | `make stop-tmux` |
| **Docker Up** | `docker-compose up -d` | `make docker-up` |
| **Docker Down** | `docker-compose down` | `make docker-down` |
| **Lint Scripts** | `find scripts/ -name "*.sh" -exec shellcheck {} +` | `make lint` |
| **Test Syntax** | `bash -n scripts/*.sh` | `make test` |
| **Full Validation** | `bash -n scripts/*.sh && find scripts/ -name "*.sh" -exec shellcheck {} +` | `make validate` |
| **Open Port** | `./scripts/ensure-port-open.sh` | `make port-open` |

## Transitioning

We recommend using the `make` commands for all daily development and maintenance tasks. The individual scripts are still available in the `scripts/` directory for advanced use cases or specific debugging, but the `Makefile` is now the primary interface.

If you encounter any issues with the Makefile targets, please report them as issues in the repository.
