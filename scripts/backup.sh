#!/usr/bin/env bash

echo "🔍 Checking changes..."
cd /etc/nixos

# Pull ก่อนเผื่อมี commit ใหม่จาก GitHub
echo "⬇️  Pulling latest changes..."
sudo git pull --rebase

if [[ -n $(git status --porcelain) ]]; then
    echo "📦 Adding files..."
    sudo git add .
    
    echo "💾 Committing..."
    sudo git commit -m "Backup $(date +%Y-%m-%d_%H:%M:%S)"
    
    echo "🚀 Pushing to GitHub..."
    sudo git push
    
    echo "✅ Backup complete!"
else
    echo "ℹ️  No changes to backup"
fi
