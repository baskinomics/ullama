# ADR 0001: Adoption of Conventional Commits Specification

- **Context:** To maintain a clean, machine-readable history and enable automated changelog generation and semantic versioning, the project requires a standardized commit message format.
- **Decision:** Adopt the Conventional Commits 1.0.0 specification. Commit messages MUST be prefixed with a type (`feat`, `fix`, etc.), an optional scope, and a description. Breaking changes MUST be indicated by a `!` after the type/scope or a `BREAKING CHANGE:` footer.
- **Consequences:** 
    - Enables automated versioning and changelog generation.
    - Improves clarity and searchability of the project history.
    - Requires developers to adhere to a specific format, slightly increasing the effort for manual commits.
