#!/usr/bin/env bash
# Generates a dynamic hardware/environment context file for AI agents.

set -euo pipefail

OUTPUT_FILE="${1:-HOST_ENV.md}"
OS_TYPE=$(uname -s)

# Initialize variables
OS_NAME=""
KERNEL=$(uname -r)
UPTIME=$(uptime | awk -F'( |,|:)+' '{d=h=m=0; if ($7=="min") m=$6; else {if ($7~/^day/) {d=$6;h=$8;m=$9} else {h=$6;m=$7}}} {print d+0,"days,",h+0,"hours,",m+0,"mins"}' | sed 's/^0 days, //')
SHELL_INFO="${BASH_VERSION:+bash $BASH_VERSION}${ZSH_VERSION:+zsh $ZSH_VERSION}"
LOCALE="${LANG:-Unknown}"
LOCAL_IP="Unknown"
CPU_INFO=""
MEM_TOTAL=""
DISK_ROOT=""
GPU_INFO=""
STATIC_HW_INFO=""

PKG_PACMAN=0
PKG_FLATPAK=0
PKG_BREW=0
PKG_BREW_CASK=0

# OS-Specific Queries
if [ "$OS_TYPE" = "Linux" ]; then
    OS_NAME=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2 || echo "Linux")
    LOCAL_IP=$(ip -4 route get 8.8.8.8 2>/dev/null | awk '{print $7}' | head -n 1 || echo "Unknown")
    CPU_INFO=$(grep -m 1 'model name' /proc/cpuinfo | cut -d ':' -f2 | sed 's/^ *//')
    MEM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
    DISK_ROOT=$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')
    GPU_INFO=$(lspci 2>/dev/null | grep -iE 'vga|3d|display' | awk -F': ' '{print $2}' | sed 's/ (rev .*)//' | paste -sd ", " - || echo "Unknown")

    # Inject static PC components
    STATIC_HW_INFO="* **Cooling:** Noctua NH-D15 chromax.black 82.52 CFM CPU Cooler
* **Power Supply:** EVGA SuperNOVA 1600 P+ 1600 W 80+ Platinum Fully Modular ATX
* **Chassis:** Fractal Design Meshify 2 XL ATX Full Tower
* **Display:** Pro 34WD-10 (3440x1440, 34\", 60 Hz) [External]"

    if command -v pacman >/dev/null 2>&1; then
        PKG_PACMAN=$(pacman -Qq 2>/dev/null | wc -l || echo 0)
    fi
    if command -v flatpak >/dev/null 2>&1; then
        PKG_FLATPAK=$(flatpak list 2>/dev/null | wc -l || echo 0)
    fi

elif [ "$OS_TYPE" = "Darwin" ]; then
    OS_NAME="macOS $(sw_vers -productVersion)"
    ACTIVE_IF=$(route get 8.8.8.8 2>/dev/null | awk '/interface:/ {print $2}')
    LOCAL_IP=$(ipconfig getifaddr "$ACTIVE_IF" 2>/dev/null || echo "Unknown")
    CPU_INFO=$(sysctl -n machdep.cpu.brand_string)
    MEM_TOTAL="$(( $(sysctl -n hw.memsize) / 1073741824 )) GB"
    DISK_ROOT=$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')
    GPU_INFO=$(system_profiler SPDisplaysDataType 2>/dev/null | awk -F': ' '/Chipset Model/ {print $2}' | paste -sd ", " - || echo "Unknown")

    # Inject static MacBook components
    STATIC_HW_INFO="* **Chassis:** Integrated MacBook Pro Enclosure
* **Power Supply:** Apple USB-C Power Adapter / Internal Battery
* **Cooling:** Integrated Active/Passive Cooling"
fi

# Package Manager Queries (Cross-platform)
if command -v brew >/dev/null 2>&1; then
    PKG_BREW=$(brew list --formula 2>/dev/null | wc -l | tr -d ' ' || echo 0)
    PKG_BREW_CASK=$(brew list --cask 2>/dev/null | wc -l | tr -d ' ' || echo 0)
fi

# Generate the Markdown file
cat <<EOF > "$OUTPUT_FILE"
# Host System Specification

This document defines the hardware and software environment of the host machine. AI agents and automated scripts should use this context for hardware-accelerated tasks, environment-specific build configurations, and workload optimization.

## 1. System Environment
* **Operating System:** $OS_NAME
* **Kernel:** $OS_TYPE $KERNEL
* **Shell:** $SHELL_INFO
* **Uptime:** $UPTIME
* **Locale:** $LOCALE
* **Network (Local IP):** $LOCAL_IP

## 2. Core Compute Hardware
* **CPU:** $CPU_INFO
* **GPU(s):** $GPU_INFO
* **Memory:** $MEM_TOTAL
* **Disk Usage (\`/\`):** $DISK_ROOT

## 3. Physical & Power Constraints
$STATIC_HW_INFO

## 4. Software Dependencies & Packages
EOF

# Conditionally append package manager info
[ "$PKG_PACMAN" -gt 0 ] && echo "* **Pacman:** $PKG_PACMAN packages" >> "$OUTPUT_FILE"
[ "$PKG_FLATPAK" -gt 0 ] && echo "* **Flatpak:** $PKG_FLATPAK packages" >> "$OUTPUT_FILE"
[ "$PKG_BREW" -gt 0 ] && echo "* **Homebrew:** $PKG_BREW formula(e), $PKG_BREW_CASK cask(s)" >> "$OUTPUT_FILE"

echo "Updated $OUTPUT_FILE successfully for $OS_TYPE."
