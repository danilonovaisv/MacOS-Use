#!/usr/bin/env bash

# system_audit.sh - Audit macOS M1 / Apple Silicon metrics and print JSON payload to stdout

set -euo pipefail

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
HOSTNAME=$(hostname)
OS_VERSION=$(sw_vers -productVersion 2>/dev/null || echo "Unknown")
OS_BUILD=$(sw_vers -buildVersion 2>/dev/null || echo "Unknown")
ARCH=$(uname -m)

# Hardware Model / CPU
MODEL=$(sysctl -n hw.model 2>/dev/null || echo "Mac")
CPU_BRAND=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Apple Silicon")
NCPU=$(sysctl -n hw.ncpu 2>/dev/null || echo "0")

# Memory in Bytes -> GB
MEM_BYTES=$(sysctl -n hw.memsize 2>/dev/null || echo "0")
MEM_GB=$(awk "BEGIN {printf \"%.2f\", $MEM_BYTES/1073741824}")

# Battery status
BATTERY_INFO=$(pmset -g batt 2>/dev/null | grep -o "[0-9]*%; [a-z]*;" || echo "100%; charged;")
BATTERY_PERCENT=$(echo "$BATTERY_INFO" | grep -o "[0-9]*%" | tr -d '%' || echo "100")
BATTERY_STATE=$(echo "$BATTERY_INFO" | awk -F';' '{print $2}' | xargs || echo "charged")

# Disk space on /
DISK_FREE_GB=$(df -g / | tail -1 | awk '{print $4}')
DISK_TOTAL_GB=$(df -g / | tail -1 | awk '{print $2}')
DISK_USAGE_PCT=$(df -g / | tail -1 | awk '{print $5}' | tr -d '%')

cat <<EOF
{
  "timestamp": "${TIMESTAMP}",
  "system": {
    "hostname": "${HOSTNAME}",
    "os_version": "${OS_VERSION}",
    "os_build": "${OS_BUILD}",
    "arch": "${ARCH}",
    "model": "${MODEL}",
    "cpu": "${CPU_BRAND}",
    "cpu_cores": ${NCPU},
    "memory_gb": ${MEM_GB}
  },
  "battery": {
    "percentage": ${BATTERY_PERCENT},
    "state": "${BATTERY_STATE}"
  },
  "storage": {
    "free_gb": ${DISK_FREE_GB},
    "total_gb": ${DISK_TOTAL_GB},
    "usage_percentage": ${DISK_USAGE_PCT}
  }
}
EOF
