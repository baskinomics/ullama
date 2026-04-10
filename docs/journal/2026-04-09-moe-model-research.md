# Research Spike: MoE Models for Documentation Agent

**Date:** 2026-04-09  
**Topic:** Evaluating smaller/MoE models for documentation agent role  
**Status:** Open for research

## Background

Current setup uses Qwen 3.5 as the build agent. Considering whether smaller or Mixture of Experts (MoE) models could be more efficient for documentation-related tasks.

## Research Questions

1. **Performance vs. Cost Tradeoff**
   - What is the performance delta between dense models and MoE for documentation tasks?
   - Do MoE models provide better token efficiency for code documentation?
   - How does context window utilization compare?

2. **Candidate Models**
   - Qwen 3.5 variants (smaller parameter counts)
   - Gemma variants (2B, 7B, 27B)
   - Other MoE architectures (Mixtral, Grok variants if available)

3. **Use Case Specific Considerations**
   - Documentation generation requires accuracy over creativity
   - Code understanding needs precise technical knowledge
   - Lower VRAM usage could enable local deployment of doc agent

## Initial Hypothesis

MoE models with similar parameter counts may offer:
- Better inference speed due to sparse activation
- Lower VRAM requirements during inference
- Comparable or better performance on technical documentation tasks

## Next Steps

- [ ] Benchmark current Qwen 3.5 on documentation tasks
- [ ] Identify 2-3 candidate MoE models for testing
- [ ] Test candidates on representative documentation tasks
- [ ] Measure: accuracy, speed, VRAM usage, token cost
- [ ] Document findings in follow-up journal entry
- [ ] Create ADR if clear winner emerges

## References

- TODO.md: "use smaller / MoE models for doc agent?"
- Current config: Gemma 4 (plan) + Qwen 3.5 (build)
- https://opencode.ai/docs/agents#configure
