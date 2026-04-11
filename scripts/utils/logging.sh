#!/usr/bin/env bash
set -euo pipefail

# Standardized logging utility for Ullama scripts

# Colors
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

err() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
    exit 1
}

debug() {
    echo -e "${CYAN}[DEBUG]${NC} $*"
}
