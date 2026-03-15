#!/usr/bin/env bash
set -euo pipefail

# Docker Installation Script for CachyOS
# Enables Docker with NVIDIA GPU support for Open WebUI

echo "=== Docker Installation for CachyOS ==="
echo ""

# Step 1: Install Docker and Docker Compose
echo "[1/4] Installing Docker and Docker Compose..."
sudo pacman -S --noconfirm docker docker-compose

# Step 2: Install NVIDIA Container Toolkit
echo "[2/4] Installing NVIDIA Container Toolkit..."
sudo pacman -S --noconfirm nvidia-container-toolkit

# Step 3: Enable and Start Docker
echo "[3/4] Starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Step 4: Add current user to Docker group
echo "[4/4] Adding user '$USER' to docker group..."
sudo usermod -aG docker "$USER"

echo ""
echo "=== Installation Complete ==="
echo ""
echo "IMPORTANT: You must log out and back in (or reboot) for the docker group changes to take effect."
echo ""
echo "After logging back in, verify with:"
echo "  docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi"
echo "  docker-compose config"
echo ""
echo "Then you can run your docker-compose.yaml:"
echo "  cd /home/zoo/workspace/machine-learning/ullama"
echo "  docker-compose up -d"