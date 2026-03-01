llama-server -hf unsloth/GLM-4.5-Air-GGUF:Q5_K_XL \
    --alias "unsloth/GLM-4.5-Air" \
    --threads -1 \
    --n-gpu-layers 999 \
    --prio 3 \
    --temp 1.0 \
    --top-p 0.95 \
    --top-k 40 \
    --ctx-size 16384 \
    --jinja

# ./llama.cpp/llama-server \
#     --model unsloth/GLM-4.6-GGUF/GLM-4.6-UD-TQ1_0.gguf \
#     --alias "unsloth/GLM-4.6" \
#     --threads -1 \
#     --n-gpu-layers 999 \
#     -ot ".ffn_.*_exps.=CPU" \
#     --prio 3 \
#     --temp 1.0 \
#     --top-p 0.95 \
#     --top-k 40 \
#     --ctx-size 16384 \
#     --port 8001 \
#     --jinja