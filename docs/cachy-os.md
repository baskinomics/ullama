# CachyOS Setup Guide for Ullama

This guide documents the setup process for configuring a CachyOS Linux system to run the Ullama local LLM infrastructure.

## Prerequisites

- CachyOS (Arch Linux-based)
- NVIDIA GPU with CUDA support
- Minimum 16GB GPU VRAM for model serving
- 8GB system RAM minimum

## Initial System Setup

### Update System

```bash
sudo pacman -Syu
```

### Install Required Packages

```bash
# Development tools and utilities
sudo pacman -S base-devel procps-ng curl file git
sudo pacman -S lsd
sudo pacman -S nvidia-utils cuda

# SSH server (for remote access)
sudo pacman -S openssh
sudo systemctl enable --now sshd
```

### SSH Configuration

Edit SSH configuration:
```bash
sudo vim /etc/ssh/sshd_config
```

Configure SSH keys:
```bash
ssh-keygen -t ed25519 -C "seanbaskin@gmail.com"
ssh-copy-id -i ~/.ssh/id_ed25519.pub zoo@192.168.1.101
```

Add to `~/.ssh/config`:
```
Host 192.168.1.101
    IdentityFile ~/.ssh/id_ed25519
```

Manage SSH agent:
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### Firewall Configuration

```bash
sudo ufw status verbose
sudo ufw allow ssh
```

## Development Environment Setup

### Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Configure fish shell (add to `~/.config/fish/config.fish`):
```fish
echo >> ~/.config/fish/config.fish
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)"
```

### Install Development Tools

```bash
brew install gcc
brew install qwen-code
```

## Building llama.cpp with CUDA

```bash
cd ~/workspace/machine-learning/
git clone https://github.com/ggml-org/llama.cpp
cd llama.cpp

# Clean previous builds
rm -rf build/

# Configure with CUDA support
cmake -B build -DGGML_CUDA=ON

# Build (parallel)
cmake --build build --config Release -j$(nproc)
```

Add to PATH (if needed):
```bash
fish_add_path /path/to/llama.cpp/build/bin
```

## Install opencode

```bash
sudo pacman -S opencode
```

## Configure Ullama Infrastructure

### Clone/Copy Project Files

```bash
cd ~/workspace/machine-learning/
cp ~/workspace/machine-learning/ullama/opencode.json .
cp ~/workspace/machine-learning/ullama/*.sh .
```

### Configure Environment

Edit `.env`:
```bash
vim .env
```

Edit model server scripts:
```bash
vim glm-4.7-flash-reap.sh
vim qwen3-coder-next.sh
```

Edit opencode configuration:
```bash
vim opencode.json
```

## Running the Infrastructure

### Start Services

```bash
docker compose up -d
```

### Verify Installation

```bash
# Check Docker services
docker compose ps

# Test llama.cpp API
curl http://localhost:8001/v1/models

# Check GPU status
watch nvidia-smi
```

### Run Model Servers

```bash
# Start GLM-4.7-Flash-REAP server
./glm-4.7-flash-reap.sh

# Start Qwen3-Coder-Next server
./qwen3-coder-next.sh
```

## Troubleshooting

### CUDA Check

```bash
nvcc --version
lspci | grep VGA
pacman -Qs nvidia
```

### Port Conflicts

```bash
# Check if ports are in use
ss -tlnp | grep -E ':(3000|8001)'

# Or use lsof
lsof -i :3000
lsof -i :8001
```

### Docker Issues

```bash
# Restart Docker services
docker compose restart

# View logs
docker compose logs -f openwebui
docker compose logs -f ollama

# Stop all services
docker compose down
```

## Notes

- The setup uses CachyOS package management (`pacman`, `paru`)
- SSH is configured for remote access to the development machine
- Homebrew installed via Linuxbrew for additional packages
- `chwd` commands may be used for CUDA workspace configuration