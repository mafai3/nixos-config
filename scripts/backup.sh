#!/usr/bin/env bash

echo "🔍 Checking changes..."
cd /etc/nixos

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
