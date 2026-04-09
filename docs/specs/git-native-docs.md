# Git-Native Documentation Specification

## 1. Overview
The goal of this system is to preserve engineering context and maintain vendor independence by treating documentation as code. Instead of relying on external issue trackers, all research, design decisions, and task tracking are stored directly within the Git repository.

## 2. Documentation Taxonomy

### 2.1 Specifications (Specs)
Specifications are durable, deeply technical documents that capture the "How" and "Why" of a system component.
- **Purpose:** Context preservation and technical alignment.
- **Location:** `docs/specs/`
- **Nature:** Exploratory and historical. They survive the implementation phase to serve as an architectural reference.
- **Content:** Problem definition, proposed approach, research/references, and an implementation checklist.

### 2.2 Architecture Decision Records (ADRs)
ADRs are lightweight, immutable records of critical technical tradeoffs.
- **Purpose:** Documenting the final decision resulting from research or a spec.
- **Location:** `docs/adrs/`
- **Nature:** Concise and focused on the consequence of a choice.

### 2.3 Engineering Journal
A chronological log for research spikes, debugging sessions, and raw notes.
- **Purpose:** Low-friction capture of "stream-of-consciousness" engineering.
- **Location:** `docs/journal/`
- **Format:** Date-prefixed files (e.g., `2026-04-08-memory-leak-investigation.md`).

### 2.4 Task Tracking
Micro-tasks and ephemeral items are tracked via a simple checklist.
- **Purpose:** Transactional progress tracking.
- **Location:** Root `TODO.md` or within a specific Spec file.

## 3. Specs vs. Features Decision Matrix

| Attribute | Specification Pattern | Feature/TODO Pattern |
| --- | --- | --- |
| **Primary Goal** | Context preservation & technical alignment | Task orchestration & progress tracking |
| **Lifecycle** | Long-lived (Draft $\rightarrow$ Active $\rightarrow$ Record) | Short-lived (Created $\rightarrow$ Checked off $\rightarrow$ Forgotten) |
| **Granularity** | Macro (Encompasses multiple tasks/refactors) | Micro (Single actionable unit of code) |
| **Failure Mode** | Analysis paralysis (over-engineering docs) | Loss of "Why" (reasoning lost after merge) |

### When to write a Specification:
- **Research Dependency:** Work requires reading papers or analyzing 3rd party code.
- **High Reversibility Cost:** Changing the implementation later would require massive refactoring.
- **Non-Obvious Tradeoffs:** Deliberate sacrifices (e.g., VRAM vs. Speed) that need justification.

### When to track as a Feature:
- **Established Patterns:** Adding variations of existing, proven architecture.
- **Low Complexity:** Task is isolated and doesn't impact core system performance.
- **Self-Documenting:** The commit message and code clearly explain the intent.

## 4. Repository Organization

```
├── TODO.md                # Global task inbox and micro-tasks
├── docs/
│   ├── specs/             # Feature blueprints and research
│   │   └── feature-x.md
│   ├── adrs/              # Architecture Decision Records
│   │   └── 0001-decision-y.md
│   └── journal/           # Chronological engineering logs
│       └── 2026-04-08-spike.md
```

## 5. Operational Workflow

### 5.1 Lifecycle
1. **Research:** Create a Journal entry or a draft Spec.
2. **Design:** Formalize the approach in a Spec file.
3. **Implement:** Execute tasks using the checklist within the Spec.
4. **Record:** Merge code and keep the Spec as a permanent architectural record.

### 5.2 Git Integration
- **Commit References:** Reference the spec file in commit messages to link code to reasoning.
  - *Example:* `feat: implement tensor splitting (refs docs/specs/tensor-splitting.md)`
- **State Management:** Use Markdown task lists (`- [ ]`) within Spec files to replace traditional issue tickets.

## 6. Templates

### Spec Template
```markdown
# Spec: [Title]

## Context & Research
- Problem statement
- Links to papers/references
- Current limitations

## Proposed Approach
- Architectural changes
- Data structures/Models
- Execution plan

## Implementation Checklist
- [ ] Task 1
- [ ] Task 2
```

### Micro-ADR Template
```markdown
# ADR [Number]: [Title]

- **Context:** What is the technical constraint or problem?
- **Decision:** What are we doing?
- **Consequences:** What are the tradeoffs? (e.g., Performance vs. Compatibility)
```
