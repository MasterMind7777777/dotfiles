#!/bin/bash

# Variables
VPN_SERVER="vpn3.sdventures.com"
USERNAME="g.nesterenok"
DNS1="192.168.179.33"
DNS2="192.168.179.34"

# Connect to VPN
echo "Connecting to VPN..."
sudo snx -s "$VPN_SERVER" -u "$USERNAME"

# Wait for the connection to establish
sleep 5

# Check if the VPN interface exists
VPN_INTERFACE=$(ip route show | grep -oP '(?<=dev )tunsnx')
if [[ -z "$VPN_INTERFACE" ]]; then
  echo "VPN interface not found. Connection failed."
  exit 1
fi

# Backup resolv.conf
echo "Backing up /etc/resolv.conf..."
sudo cp /etc/resolv.conf /etc/resolv.conf.backup

# Update DNS to use the VPN's DNS servers
echo "Updating DNS to use VPN's DNS servers..."
echo "nameserver $DNS1" | sudo tee /etc/resolv.conf
echo "nameserver $DNS2" | sudo tee -a /etc/resolv.conf

# Delete existing default route
echo "Deleting existing default route..."
sudo ip route del default

# Add default route through the VPN interface
echo "Adding new default route via VPN..."
sudo ip route add default dev tunsnx

# Verify routing
echo "Updated routing table:"
ip route show

echo "Connected to VPN. All traffic is routed through the VPN."
