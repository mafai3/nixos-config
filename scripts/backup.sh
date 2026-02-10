#!/usr/bin/env bash

set -e  # Exit on error

echo "🔄 Backing up NixOS configuration..."

cd /etc/nixos

# Add files
echo "📝 Adding files..."
git add configuration.nix
git add scripts/ 2>/dev/null || true

# Check if there are changes
if git diff --cached --quiet; then
    echo "✅ No changes to commit"
else
    # Commit
    echo "💾 Committing..."
    git commit -m "Auto backup $(date '+%Y-%m-%d %H:%M:%S')"
    
    # Push
    echo "🚀 Pushing to GitHub..."
    git push origin master
    
    if [ $? -eq 0 ]; then
        echo "✅ Push successful!"
    else
        echo "❌ Push failed!"
        exit 1
    fi
fi

echo "✅ Backup complete!"
