#!/bin/bash
export LD_PRELOAD=libtcmalloc.so.4
cd "$1" || { echo "Error: Could not enter directory '$1'"; exit 1; }
./webui.sh --debug --autolaunch --listen --uv