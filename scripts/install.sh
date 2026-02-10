#!/usr/bin/env bash

# NixOS Restore Script
# ใช้หลังติดตั้ง NixOS เสร็จแล้ว

set -e

echo "🔄 NixOS Configuration Restore"
echo "=============================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run with sudo"
    exit 1
fi

# 1. Backup current hardware config
echo "📦 Backing up hardware configuration..."
cp /etc/nixos/hardware-configuration.nix /root/hardware-configuration.nix.backup

# 2. Clone repo
echo "📥 Cloning configuration from GitHub..."
if [ -d ~/nixos-config ]; then
    rm -rf ~/nixos-config
fi
git clone https://github.com/mafai3/nixos-config.git ~/nixos-config

# 3. Copy files
echo "📋 Copying configuration files..."
cp ~/nixos-config/configuration.nix /etc/nixos/
cp -r ~/nixos-config/scripts /etc/nixos/

# 4. Restore hardware config
echo "🔧 Restoring hardware configuration..."
cp /root/hardware-configuration.nix.backup /etc/nixos/hardware-configuration.nix

# 5. Setup channels
echo "📡 Setting up channels..."
nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz home-manager
nix-channel --update

echo ""
echo "✅ Configuration restored!"
echo ""
echo "Next steps:"
echo "1. Review /etc/nixos/configuration.nix"
echo "2. Run: sudo nixos-rebuild switch"
echo "3. Run: reboot"
echo ""
