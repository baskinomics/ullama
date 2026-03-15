# Host System Specification

This document defines the hardware and software environment of the host machine. AI agents and automated scripts should use this context for hardware-accelerated tasks, environment-specific build configurations, and workload optimization.

## 1. System Environment
* **Operating System:** CachyOS
* **Kernel:** Linux 6.19.3-2-cachyos
* **Shell:** bash 5.3.9(1)-release
* **Uptime:** 3 hours, 51 mins
* **Locale:** en_US.UTF-8
* **Network (Local IP):** 192.168.1.176

## 2. Core Compute Hardware
* **CPU:** AMD Ryzen 9 7950X3D 16-Core Processor
* **GPU(s):** NVIDIA Corporation AD102 [GeForce RTX 4090],Advanced Micro Devices, Inc. [AMD/ATI] Raphael
* **Memory:** 61Gi
* **Disk Usage (`/`):** 778G / 1.9T (42%)

## 3. Physical & Power Constraints
* **Cooling:** Noctua NH-D15 chromax.black 82.52 CFM CPU Cooler
* **Power Supply:** EVGA SuperNOVA 1600 P+ 1600 W 80+ Platinum Fully Modular ATX
* **Chassis:** Fractal Design Meshify 2 XL ATX Full Tower
* **Display:** Pro 34WD-10 (3440x1440, 34", 60 Hz) [External]

## 4. Software Dependencies & Packages
* **Pacman:** 1308 packages
* **Flatpak:** 22 packages
