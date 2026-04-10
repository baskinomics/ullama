# Spec: Preset Modularization

## Context & Research

### Problem Statement
Current preset configuration is monolithic, making it difficult to:
- Manage model lifecycle (testing → core → legacy)
- Understand which models are production-ready vs experimental
- Onboard new contributors to the model selection process
- Maintain clear separation of concerns between model categories

### Current Limitations
- All presets in single file(s) without categorization
- No clear lifecycle management for models
- Difficult to identify which models are actively maintained
- Testing models mixed with production models creates confusion

### References
- Git-Native Documentation Spec: `docs/specs/git-native-docs.md`
- Current preset files in repository root

## Proposed Approach

### Architectural Changes
Segment presets into three distinct categories:

1. **Core Models** (`presets/core.ini`)
   - Production-ready, well-tested models
   - Actively maintained and recommended for use
   - Stable configurations with known performance characteristics

2. **Testing Models** (`presets/testing.ini`)
   - Experimental or newly added models
   - Under active evaluation
   - May have unstable configurations or performance issues

3. **Legacy Models** (`presets/legacy.ini`)
   - Deprecated but still functional models
   - Not actively maintained
   - Kept for reference or migration purposes

### Data Structures/Models
```
presets/
├── core.ini        # Production models
├── testing.ini     # Experimental models
├── legacy.ini      # Deprecated models
└── README.md       # Category definitions and usage guide
```

### Execution Plan
1. Audit current preset file(s) to catalog all models
2. Define criteria for each category (core/testing/legacy)
3. Create directory structure and new preset files
4. Migrate existing models to appropriate categories
5. Update all references to old preset locations
6. Add README with category definitions and lifecycle workflow
7. Update documentation to reference new structure

## Implementation Checklist
- [ ] Audit current presets and catalog all models
- [ ] Define category criteria document
- [ ] Create `presets/` directory structure
- [ ] Create `presets/core.ini` with production models
- [ ] Create `presets/testing.ini` with experimental models
- [ ] Create `presets/legacy.ini` with deprecated models
- [ ] Create `presets/README.md` with usage guide
- [ ] Update server scripts to reference new preset locations
- [ ] Update docker-compose if presets are mounted
- [ ] Test each category file loads correctly
- [ ] Remove old monolithic preset file(s)
- [ ] Update any external documentation referencing presets
