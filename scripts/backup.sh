#!/usr/bin/env bash

# NixOS GitHub Backup Script

echo "🔄 Backing up NixOS configuration to GitHub..."

cd /etc/nixos || exit

# Check if git repo exists
if [ ! -d ".git" ]; then
    echo "❌ Not a git repository!"
    echo "Run: cd /etc/nixos && sudo git init"
    exit 1
fi

# Add files
git add configuration.nix
git add hardware-configuration.nix 2>/dev/null || true
git add scripts/ 2>/dev/null || true

# Check if there are changes
if git diff --staged --quiet; then
    echo "✅ No changes to commit"
    exit 0
fi

# Commit with timestamp
git commit -m "Auto backup $(date '+%Y-%m-%d %H:%M:%S')"

# Push to GitHub
git push origin main

echo "✅ Backup complete!"
