#!/bin/bash
# macOS Wi-Fi Optimization and Cleanup Script
# Validated for macOS Monterey and later

echo "Starting Wi-Fi optimization..."

# 1. Clear DNS Cache
# Flushes stale domain name data and restarts the macOS DNS responder service.
# This resolves issues where websites load slowly or fail to resolve.
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder



# 2. Cycle the Wi-Fi Interface
# Soft-resets the Wi-Fi hardware to clear minor driver glitches.
# Note: 'en0' is the default Wi-Fi interface on almost all Apple Silicon Macs.
sudo networksetup -setairportpower en0 off
sleep 3 # Pauses for 3 seconds to let the hardware fully power down
sudo networksetup -setairportpower en0 on
sleep 4 # Pauses to allow the Mac to reconnect to your preferred network

# 3. Renew DHCP Lease
# Forces the Mac to drop its old IP address and request a fresh one from the router.
# This eliminates IP conflict errors on busy home or office networks.
sudo ipconfig set en0 DHCP

# 4. Network Diagnostics
# Displays your active Wi-Fi configuration (IP address, subnet, router).
echo "Current Wi-Fi Configuration:"
networksetup -getinfo Wi-Fi

# Pings Google's reliable public DNS server 4 times to verify internet connectivity.
echo "Testing Internet Connectivity..."
ping -c 4 8.8.8.8

echo "Wi-Fi optimization complete!"
