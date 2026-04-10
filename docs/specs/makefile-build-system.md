# Spec: Makefile Build System

## Context & Research

### Problem Statement
Current build and run operations are scattered across multiple shell scripts without a unified interface. This creates:
- Inconsistent command patterns across scripts
- Higher cognitive load for users to remember which script to run
- No centralized documentation of available operations
- Difficulty in discovering available commands

### Current Limitations
- Multiple scripts (`run-server.sh`, `update_llama_cpp.sh`, `install-docker.sh`, etc.)
- No single entry point for common operations
- Scripts have different logging and error handling patterns
- No standard way to list available commands or get help

### References
- Git-Native Documentation Spec: `docs/specs/git-native-docs.md`
- AGENTS.md: Build and lint commands section
- Existing scripts in `scripts/` directory

## Proposed Approach

### Architectural Changes
Introduce a `Makefile` as the primary interface for all build, run, and maintenance operations. The Makefile will:
- Provide a unified command interface
- Delegate to existing shell scripts (no duplication)
- Offer helpful targets with descriptions
- Standardize error handling and logging across operations

### Data Structures/Models
```
Makefile targets:
├── Build
│   ├── build          # Build llama.cpp from source
│   ├── clean          # Clean build artifacts
│   └── update         # Update and rebuild llama.cpp
├── Run
│   ├── server         # Start llama-server with router
│   ├── server-debug   # Start with debug logging
│   └── stop           # Stop running services
├── Docker
│   ├── docker-up      # Start docker-compose services
│   ├── docker-down    # Stop docker-compose services
│   └── docker-logs    # View service logs
├── Maintenance
│   ├── lint           # Lint all shell scripts
│   ├── test           # Test script syntax
│   └── validate       # Full validation pipeline
└── Help
    ├── help           # Show all available targets
    └── help-<target>  # Show detailed help for specific target
```

### Execution Plan
1. Create Makefile with standardized target patterns
2. Define phony targets for all operations
3. Implement help system with target descriptions
4. Wrap existing scripts (no code duplication)
5. Add validation and linting targets
6. Document target usage in Makefile comments
7. Update AGENTS.md to reference Makefile as primary interface
8. Test all targets for correctness

## Implementation Checklist

### Core Makefile
- [ ] Create Makefile with proper structure and conventions
- [ ] Define PHONY targets list
- [ ] Implement help target with formatted output
- [ ] Add build targets (build, clean, update)
- [ ] Add run targets (server, server-debug, stop)
- [ ] Add docker targets (docker-up, docker-down, docker-logs)
- [ ] Add maintenance targets (lint, test, validate)

### Integration
- [ ] Ensure all existing scripts are properly invoked
- [ ] Add error handling wrapper for script failures
- [ ] Standardize logging output format
- [ ] Test cross-platform compatibility (Linux/macOS)

### Documentation
- [ ] Add inline comments for each target
- [ ] Update AGENTS.md Quick Reference section
- [ ] Update README.md with Makefile usage examples
- [ ] Create MIGRATION.md for script-to-makefile transition

### Testing
- [ ] Test `make help` displays all targets correctly
- [ ] Test `make build` invokes update_llama_cpp.sh
- [ ] Test `make server` invokes run-server.sh
- [ ] Test `make lint` runs shellcheck on all scripts
- [ ] Test `make validate` runs full validation pipeline
- [ ] Verify error messages are clear and actionable
