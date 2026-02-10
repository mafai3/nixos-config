#!/usr/bin/env bash

set -e

echo "🔍 Checking changes..."
cd /etc/nixos

# Pull ก่อนเผื่อมี commit ใหม่จาก GitHub
echo "⬇️  Pulling latest changes..."
git pull --rebase origin master

# เช็คว่ามี changes ไหม
if [[ -n $(git status --porcelain) ]]; then
    echo "📦 Adding files..."
    git add configuration.nix
    git add scripts/ 2>/dev/null || true
    
    echo "💾 Committing..."
    git commit -m "Backup $(date +%Y-%m-%d_%H:%M:%S)"
    
    echo "🚀 Pushing to GitHub..."
    git push origin master
    
    echo "✅ Backup complete!"
else
    echo "ℹ️  No changes to backup"
fi
