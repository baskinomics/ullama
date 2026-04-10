# ADR 0002: systemd Service Architecture for Ullama Router Server

- **Context:** The Ullama router server needs to run as a persistent background service on Linux systems. Current manual invocation via `scripts/run-server.sh` requires active terminal sessions and doesn't survive system reboots. The systemd implementation plan (`docs/specs/systemd-plan.md`) provides detailed technical specifications for daemonization, log rotation, and process management.

- **Decision:** Adopt systemd as the service manager with the following architectural choices:
  - Run service under user `zoo` account (not dedicated service user) for simplified file access and environment inheritance
  - Enable auto-start on boot via `systemctl enable` for always-available API endpoint
  - Implement logrotate for `scripts/logs/server.log` with weekly rotation, 4-week retention, and compression
  - Keep CPU affinity (`taskset -c 0-7`) in `run-server.sh` rather than systemd unit for portability
  - Use `Restart=always` with `RestartSec=5` for automatic recovery from failures
  - Set `LimitNOFILE=65536` to prevent file descriptor exhaustion during high concurrency
  - Configure dual logging to both systemd journal and file for debugging flexibility

- **Consequences:**
  - **Positive:** Service persists across reboots, auto-recovers from crashes, manages logs automatically, and provides standardized service management via systemctl
  - **Negative:** Linux-only solution (macOS continues using direct script invocation), service runs with full user privileges (acceptable for personal workstation), adds system-level configuration complexity
  - **Trade-offs:** Simplified setup (user account) vs. security best practices (dedicated service user), portability (CPU affinity in script) vs. centralization (all config in unit file)
