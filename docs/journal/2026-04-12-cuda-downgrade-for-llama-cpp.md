# 2026-04-12: CUDA Downgrade for llama.cpp

## Summary
Downgraded CUDA from 13.2 to 13.1 on CachyOS to resolve compatibility issues in `llama.cpp` identified in [issue #21255](https://github.com/ggml-org/llama.cpp/issues/21255).

## Problem
The current CUDA 13.2 installation caused issues with `llama.cpp` builds/execution. A downgrade to a stable 13.1 environment was required.

## Implementation

### Downgrade Process
Used the `downgrade` utility to manage the transition via the Arch Linux Archive (ALA).

1. **Install utility:** `sudo pacman -S downgrade`
2. **Perform downgrade:** `sudo downgrade cuda` (Selected `13.1.x` version from prompt).
3. **Pin version:** Added `cuda` to `IgnorePkg` in `/etc/pacman.conf` to prevent automatic upgrades during `pacman -Syu`.

```ini
# /etc/pacman.conf
IgnorePkg = cuda
```

### Troubleshooting: Driver vs. Toolkit Discrepancy
Post-downgrade, `nvidia-smi` continued to report CUDA version **13.2**. 

**Insight:** `nvidia-smi` displays the **CUDA Driver API** version (the maximum version supported by the installed NVIDIA driver), not the **CUDA Toolkit/Runtime API** version. For compilation and runtime execution of `llama.cpp`, the Toolkit version is what matters.

### Verification

**1. Compiler Check:**
Verified the `nvcc` version directly.
```bash
[zoo@jupiter ullama]$ nvcc --version

nvcc: NVIDIA (R) Cuda compiler driver
...
Cuda compilation tools, release 13.1, V13.1.115
...
```

**2. Build System Check:**
Cleaned the build cache and reconfigured CMake to ensure no stale 13.2 references remained.
```bash
rm -rf build/
cmake -B build -DGGML_CUDA=ON ...
```

**CMake Output Confirmation:**
```text
-- Found CUDAToolkit: /opt/cuda/targets/x86_64-linux/include;/opt/cuda/targets/x86_64-linux/include/cccl (found version "13.1.115")
-- The CUDA compiler identification is NVIDIA 13.1.115 with host compiler GNU 15.2.1
```

## Conclusion
The environment is successfully running CUDA 13.1.115. The discrepancy between `nvidia-smi` and `nvcc` is expected behavior and does not indicate a failed downgrade.
