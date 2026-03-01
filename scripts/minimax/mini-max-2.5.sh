args=(
    -hf unsloth/MiniMax-M2.5-GGUF:IQ2_XXS
    --alias "unsloth/MiniMax-M2.5"
    --ctx-size 16384
    --threads 16
    --n-gpu-layers 81
    --n-cpu-moe 80
    --batch-size 4096
    --ubatch-size 128
    --cache-type-k q4_0
    --cache-type-v q4_0
    --flash-attn on
    --fit off
    --no-mmap
    --seed 3407
    --temp 1.0
    --top-p 0.95
    --min-p 0.01
    --top-k 40
    --port 8001
    --jinja
)

llama-server "${args[@]}"

