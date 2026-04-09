# systemd Service Implementation Plan for Ullama Router Server

## Overview

This document outlines the plan to implement a systemd service for running the Ullama router server (`scripts/run-server.sh`) as a background daemon on Linux systems.

---

## System Context

**Host System**: CachyOS (Linux 6.19.11)
- **CPU**: AMD Ryzen 9 7950X3D (16-core)
- **GPU**: NVIDIA RTX 4090
- **RAM**: 62GiB
- **Storage**: 1.9TB (/ partition, 65% used)

**Binary Location**: `/home/zoo/workspace/machine-learning/llama.cpp/build/bin/llama-server`

---

## Implementation Plan

### 1. Create systemd Service Unit File

**Location**: `/etc/systemd/system/ullama-server.service`

**Service Type**: `simple` (default)
- The script runs `llama-server` in foreground mode
- systemd can directly manage the process lifecycle

### 2. Create Service Directory Structure

```
ullama/
├── service/
│   └── ullama-server.service    # systemd unit file
├── scripts/
│   ├── run-server.sh            # existing script
│   └── logs/
│       └── server.log           # log file (managed by logrotate)
└── systemd-plan.md              # this document
```

### 3. Configure Log Rotation

**Location**: `/etc/logrotate.d/ullama-server`

**Configuration**:
- Weekly rotation
- Retain 4 weeks of logs
- Compress old logs (gzip)
- Use `copytruncate` to avoid service restart

### 4. Create Supporting Scripts

| Script | Purpose |
|--------|---------|
| `install-service.sh` | Install service file and enable |
| `uninstall-service.sh` | Remove service and disable |
| `status-service.sh` | Check service status and logs |

---

## Configuration Decisions & Rationale

### Decision 1: Run as User `zoo` (Not Dedicated Service User)

**Choice**: Service runs under the current user account (`zoo`)

**Rationale**:
- **Simplicity**: No additional user management required
- **File Access**: Full access to existing model files in `~/workspace/machine-learning/`
- **Environment**: Inherits existing PATH, permissions, and HuggingFace authentication
- **Use Case**: Personal workstation, not a production/shared server

**Trade-offs**:
- ⚠️ Service runs with full user privileges (security consideration for production)
- ⚠️ Resource contention with user's other processes
- ✅ Simplified setup and maintenance

---

### Decision 2: Auto-start on Boot = YES

**Choice**: Service enabled to start automatically at system boot

**Rationale**:
- Provides always-available API endpoint for clients
- Ideal for background model serving
- Minimal resource impact on this hardware (RTX 4090, 62GiB RAM)

**Implementation**:
```bash
systemctl enable ullama-server.service
```

---

### Decision 3: Log Rotation via logrotate = YES

**Choice**: Configure logrotate for `scripts/logs/server.log`

**Pedantic Justification**:

#### Problem: Unbounded Log Growth

Without rotation, `server.log` grows indefinitely:
- **Typical growth rate**: 10-50MB/day (depending on request volume)
- **Annual accumulation**: 3.6-18GB
- **Risk**: Disk exhaustion causing system-wide failures

#### Problem: Performance Degradation

Large single-file logs suffer from:
- Slow `tail -f`, `grep`, `cat` operations
- Poor file system metadata operation scaling
- `inotify` watchers may miss events on massive files

#### Problem: Debugging Difficulty

- Finding historical errors in multi-GB files is tedious
- No natural time-based boundaries for log analysis
- Cannot easily archive old logs without manual intervention

#### Solution: logrotate Configuration

```bash
# /etc/logrotate.d/ullama
/home/zoo/workspace/machine-learning/ullama/scripts/logs/server.log {
    weekly
    rotate 4
    compress
    delaycompress
    missingok
    notifempty
    create 0644 zoo zoo
    copytruncate
}
```

**Technical Justification**:
- `weekly`: Balances disk usage vs. debugging granularity
- `rotate 4`: 28-day retention covers typical troubleshooting window
- `compress`: Reduces long-term storage from ~140MB/week to ~14MB/week (90% savings)
- `copytruncate`: Avoids complex signal handling; brief log loss window mitigated by low-traffic rotation timing

---

### Decision 4: CPU Affinity in Script (Not systemd)

**Choice**: Keep `taskset -c 0-7` in `run-server.sh`

**Rationale**:
- **Portability**: Script works on any Linux system without systemd
- **Explicit**: CPU binding visible in script, easy to modify
- **Flexible**: Can change per-invocation via script arguments
- **macOS Compatibility**: Script already handles Darwin (no `taskset`)

**Trade-offs**:
- ✅ Single source of truth for CPU binding
- ✅ Script remains portable and testable outside systemd
- ⚠️ Redundant if systemd also sets `CPUAffinity` (not recommended)

**Alternative (Not Chosen)**: Move to systemd `CPUAffinity=0-7`
- Would require removing `taskset` from script
- Less flexible (requires `systemctl daemon-reload` for changes)
- Linux-specific (reduces portability)

---

## Proposed Service File

```ini
# /etc/systemd/system/ullama-server.service

[Unit]
Description=Ullama Router Server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=zoo
WorkingDirectory=/home/zoo/workspace/machine-learning/ullama
ExecStart=/home/zoo/workspace/machine-learning/ullama/scripts/run-server.sh
Restart=always
RestartSec=5
LimitNOFILE=65536
Environment="PATH=/home/zoo/workspace/machine-learning/llama.cpp/build/bin:/home/zoo/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
StandardOutput=append:/home/zoo/workspace/machine-learning/ullama/scripts/logs/server.log
StandardError=append:/home/zoo/workspace/machine-learning/ullama/scripts/logs/server.log

# CPU affinity handled in script via taskset
# CPUAffinity=0-7

[Install]
WantedBy=multi-user.target
```

---

## Implementation Steps (For Future Execution)

### Step 1: Create Service Directory
```bash
mkdir -p service
```

### Step 2: Write Service Unit File
- Create `service/ullama-server.service` with above configuration

### Step 3: Write Installation Script
- `scripts/install-service.sh`:
  - Copy service file to `/etc/systemd/system/`
  - Run `systemctl daemon-reload`
  - Run `systemctl enable ullama-server.service`
  - Run `systemctl start ullama-server.service`

### Step 4: Write Logrotate Configuration
- Create `/etc/logrotate.d/ullama` with rotation config
- Test with `logrotate -f /etc/logrotate.d/ullama`

### Step 5: Write Uninstall Script
- `scripts/uninstall-service.sh`:
  - Stop and disable service
  - Remove service file
  - Remove logrotate config

### Step 6: Testing
```bash
systemctl status ullama-server.service
journalctl -u ullama-server.service -f
curl http://localhost:8001/v1/models
```

---

## Service Management Commands

| Command | Purpose |
|---------|---------|
| `systemctl start ullama-server` | Start service |
| `systemctl stop ullama-server` | Stop service |
| `systemctl restart ullama-server` | Restart service |
| `systemctl status ullama-server` | Check status |
| `systemctl enable ullama-server` | Enable auto-start |
| `systemctl disable ullama-server` | Disable auto-start |
| `journalctl -u ullama-server -f` | Follow logs |
| `systemctl is-active ullama-server` | Check if running |

---

## Summary of Decisions

| Question | Decision | Rationale |
|----------|----------|-----------|
| User | `zoo` | Personal workstation, simpler setup |
| Auto-start | Yes | Always-available API endpoint |
| Log rotation | Yes (logrotate) | Prevents disk exhaustion, aids debugging |
| CPU affinity | Keep in script | Portability, single source of truth |
| Restart policy | `always` | Auto-recover from any exit |
| Restart delay | 5 seconds | Prevent rapid restart loops |
| File Limits | `LimitNOFILE=65536` | Prevent EMFILE during high concurrency |
| Environment | Explicit `PATH` | Ensure `llama-server` is resolvable without `.bashrc` |
| Thread Count | `8` | Align with CPU affinity (0-7) to avoid cross-CCD latency |

---

## Notes for Implementation

1. **Script Compatibility**: Current `run-server.sh` runs in foreground, compatible with systemd `Type=simple`
2. **Dual Logging**: Service logs to both journal (`journalctl`) and file (`server.log`) for flexibility
3. **Network Dependency**: Service waits for network (`After=network-online.target`) before starting
4. **Thread Optimization**: Add `-t 8` to `run-server.sh` to match the CPU affinity mask (0-7) and prevent cross-CCD latency.
5. **No Script Modifications Required**: Current script already handles CPU affinity and logging appropriately (except for the thread optimization)

5. **Future Enhancements**:
   - Consider `IOScheduling=idle` for background priority

---

*Document created: 2026-04-08*
*Status: Plan ready for implementation*
