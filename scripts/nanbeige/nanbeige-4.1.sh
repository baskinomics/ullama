args=(
    -hf mradermacher/Nanbeige4.1-3B-GGUF:F16
    --alias "mradermacher/Nanbeige4.1-3B"
    --ctx-size 131072
    # --threads 16
    --threads 8
    --threads-batch 16
    --n-gpu-layers 99
    --cache-type-k q8_0
    --cache-type-v q8_0
    --flash-attn on
    --fit off
    --seed 3407
    --temp 0.60
    --top-p 0.95
    --min-p 0.01
    # --top-k 50
    --port 8001
    --jinja
)

llama-server "${args[@]}"
