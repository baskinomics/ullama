# MoE Offloading Reference: `-ngl`, `-cmoe`, and `-ncmoe`

This document provides a technical reference for managing memory and performance when running Mixture of Experts (MoE) models in `llama-server`.

## Overview

Large MoE models (like Mixtral or Grok) present a unique challenge: they have a massive total parameter count, but only a fraction of those parameters are active during any single token generation. Traditional layer-wise offloading via `-ngl` can quickly exhaust VRAM because it attempts to move the entire layer (including all experts) to the GPU.

The `-cmoe` and `-ncmoe` flags allow for a more granular "hybrid" offloading strategy where the heavy expert weights can be kept in system RAM while the rest of the layer components remain on the GPU.

---

## Flag Definitions

### 1. `-ngl, --gpu-layers [N|auto|all]`
*   **Purpose**: The primary mechanism for offloading model layers to VRAM.
*   **Function**: Determines the maximum number of layers to be stored in the GPU.
*   **Values**:
    *   `N`: An exact number of layers.
    *   `auto`: Automatically offload as many layers as possible based on available VRAM.
    *   `all`: Offload every layer to the GPU.

### 2. `-cmoe, --cpu-moe`
*   **Purpose**: Specialized MoE offloading.
*   **Function**: Forces **all** Mixture of Experts (MoE) weights in the model to remain in system RAM (CPU), regardless of the `-ngl` setting.
*   **Use Case**: When you want the attention mechanisms and non-MoE components of all layers to run on the GPU for speed, but the model's total expert weights are too large for your VRAM.

### 3. `-ncmoe, --n-cpu-moe [N]`
*   **Purpose**: Granular, layer-specific MoE offloading.
*   **Function**: Keeps the MoE weights of only the **first $N$ layers** in the CPU.
*   **Use Case**: When you want to optimize the performance of the initial layers (which are often more critical for processing) by keeping them on the GPU, while offloading the experts of subsequent layers to CPU to save space.

---

## Interaction and Relationship

These flags work in a hierarchical and complementary manner.

| Flag Combination | Behavior | Result |
| :--- | :--- | :--- |
| **`-ngl all`** | All layers (including experts) are moved to GPU. | **Maximum Speed**, but **Highest VRAM usage**. |
| **`-ngl [N] + -cmoe`** | Layers 0 to $N$ are on GPU, but their **experts** are in CPU. | **Medium Speed**, **Low VRAM usage**. Great for huge models on consumer GPUs. |
| **`-ngl [N] + -ncmoe [M]`** | Layers 0 to $M$ have experts in CPU. Layers $M+1$ to $N$ have experts in GPU. | **Fine-tuned Performance/VRAM balance**. |

### Key Concept: Hybrid Offloading
The relationship between these flags enables **Hybrid Offloading**. Instead of an "all-or-nothing" approach per layer, you can decouple the **layer structure** (Attention, Norms, etc.) from the **expert weights**.

*   **GPU handles**: The "routing" and "attention" parts of the layers (low VRAM, high compute).
*   **CPU handles**: The massive "expert" weight matrices (high VRAM, high memory bandwidth).

---

## Usage Examples

### Scenario 1: Running a massive MoE model on a single 24GB GPU
If a model has 64 layers and 141B parameters, it won't fit even with `-ngl 64`.
```bash
# Offload all layers to GPU, but keep all experts in RAM
llama-server -m model.gguf -ngl all -cmoe
```

### Scenario 2: Partial Expert Offloading for Speed
If you want the first 20 layers to be fully on the GPU (including experts) to speed up initial processing, but keep the rest of the experts in RAM:
```bash
# This requires careful calculation of -ngl and -ncmoe
# If -ngl is 64, but -ncmoe is 20, then layers 21-64 have experts in VRAM.
# Note: -ncmoe keeps the first N in CPU. To keep others in GPU, 
# you'd actually want to use -ngl and then selectively use -ncmoe if the logic 
# follows "keep in CPU".
```
*(Note: Check specific implementation behavior: `-ncmoe` keeps the first $N$ in CPU, meaning layers $N+1$ onwards are eligible for GPU expert offloading via `-ngl`.)*

---
*Generated for the Ullama project.*
