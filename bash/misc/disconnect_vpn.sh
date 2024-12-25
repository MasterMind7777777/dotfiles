#!/bin/bash

# Variables
LOCAL_GATEWAY="192.168.0.1"
LOCAL_INTERFACE="wlp0s20f3"

# Disconnect from VPN
echo "Disconnecting from VPN..."
sudo pkill snx

# Wait for disconnection
sleep 3

# Restore original routing
echo "Restoring original routing table..."
sudo ip route del default
sudo ip route add default via "$LOCAL_GATEWAY" dev "$LOCAL_INTERFACE"

# Restore original DNS
if [[ -f /etc/resolv.conf.backup ]]; then
  echo "Restoring original DNS settings from backup..."
  sudo mv /etc/resolv.conf.backup /etc/resolv.conf
else
  echo "DNS backup not found. Setting Google DNS as fallback..."
  echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
  echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf
fi

echo "Disconnected from VPN. Internet connectivity restored via local network."
