args=(
    -hf unsloth/Qwen3.5-122B-A10B-GGUF:UD-Q3_K_XL
    --alias "unsloth/Qwen3.5-122B-A10B"
    --ctx-size 131072
    --threads 8          # Optimal for keeping workload on the 3D V-Cache CCD
    --threads-batch 16
    # --n-gpu-layers 15    # Maximum number of layers to store in VRAM, either an exact number, 'auto', or 'all' (default: auto) ~35% offload targeting 24GB VRAM
    # --n-cpu-moe 30       # Keep the Mixture of Experts (MoE) weights of the first N layers in the CPU
    --cache-type-k q8_0
    --cache-type-v q8_0
    --batch-size 1024
    --ubatch-size 4096
    --flash-attn on
    --fit on
    --seed 3407
    --temp 0.6
    --top-p 0.95
    --min-p 0.00
    --top-k 20
    --repeat_penalty 1.05
    --presence-penalty 0.0
    --port 8001
    --jinja
    --mlock
    --no-mmap
)

llama-server "${args[@]}"
