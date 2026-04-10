# Research: Jackrong & Unsloth Model Variants

**Date:** 2026-04-09  
**Topic:** Evaluate Jackrong GGUF variants for Gemma 4 and Qwen 3.5  
**Status:** Open for testing

## Background

Researching alternative GGUF implementations for current model families to compare performance, efficiency, and quality.

## Models Under Investigation

### Jackrong
- Qwopus3.5-27B-v3 (Gemma 4 variant)
- Qwopus3.5-9B-v3 (Qwen 3.5 variant)
- Gemopus-4-E4B-it (Gemma 4 E4B variant)

## Research Questions

- What is the performance delta compared to current models?
- Do "opus" variants provide better token efficiency?
- How does context window utilization compare?
- Are smaller models viable for specific use cases?

## Testing Plan

- [ ] Download each model variant
- [ ] Test inference speed and VRAM usage
- [ ] Evaluate quality on representative prompts
- [ ] Compare against current production models

## Results

[To be filled during testing]

## References

- Current config: Gemma 4 (plan) + Qwen 3.5 (build)
- TODO.md: "use smaller / MoE models for doc agent?"
- https://huggingface.co/Jackrong/Qwopus3.5-27B-v3-GGUF
- https://huggingface.co/Jackrong/Qwopus3.5-9B-v3-GGUF
- https://huggingface.co/Jackrong/Gemopus-4-E4B-it-GGUF
