llama-server -hf unsloth/GLM-4.7-Flash-REAP-23B-A3B-GGUF:Q4_K_XL \
    --alias "unsloth/GLM-4.7-Flash-REAP" \
    --fit on \
    --seed 3407 \
    --temp 0.7 \
    --top-p 1.00 \
    --min-p 0.01 \
    --ctx-size 16384 \
    --port 8001 \
    --jinja