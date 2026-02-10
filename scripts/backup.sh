#!/usr/bin/env bash

set -e

echo "🔍 Checking changes..."
cd /etc/nixos

# เช็คว่ามี uncommitted changes ไหม
if [[ -n $(git status --porcelain) ]]; then
    echo "📦 Staging changes..."
    git add configuration.nix
    git add scripts/ 2>/dev/null || true
    git add .gitignore 2>/dev/null || true
    
    echo "💾 Committing local changes..."
    git commit -m "Backup $(date +%Y-%m-%d_%H:%M:%S)"
fi

# Pull (ถ้า branch มีอยู่แล้ว)
echo "⬇️  Syncing with GitHub..."
git pull --rebase origin master 2>/dev/null || echo "ℹ️  Nothing to pull"

# Push ขึ้น GitHub
echo "🚀 Pushing to GitHub..."
git push origin master

echo "✅ Backup complete!"
