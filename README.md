# NixOS Configuration - Dell 7447

## 🚀 Quick Restore (ลงเครื่องใหม่)

### 1. ติดตั้ง NixOS (Minimal - No Desktop)
```bash
# เลือก:
# - No desktop environment
# - Username: nixka
# - Hostname: nixos
```

### 2. Clone Configuration
```bash
# Login เข้าระบบใหม่
# เชื่อม WiFi (ถ้าจำเป็น)
nmtui

# Clone repo
git clone https://github.com/mafai3/nixos-config.git ~/nixos-backup

# Backup hardware config ใหม่ (สำคัญ!)
sudo cp /etc/nixos/hardware-configuration.nix ~/hardware-new.nix

# Copy configuration
sudo cp ~/nixos-backup/configuration.nix /etc/nixos/
sudo cp -r ~/nixos-backup/scripts /etc/nixos/

# ใช้ hardware config ใหม่
sudo cp ~/hardware-new.nix /etc/nixos/hardware-configuration.nix
```

### 3. Rebuild
```bash
sudo nixos-rebuild switch
```

### 4. Reboot
```bash
reboot
```

### 5. Setup Git (หลัง Reboot)
```bash
cd /etc/nixos

# Initialize git
sudo git init
sudo git remote add origin https://github.com/mafai3/nixos-config.git

# Set credentials
sudo git config user.name "mafai3"
sudo git config user.email "your-email@example.com"

# Add safe directory
git config --global --add safe.directory /etc/nixos

# Set remote URL with token
sudo git remote set-url origin https://mafai3:YOUR_TOKEN@github.com/mafai3/nixos-config.git

# Pull
sudo git pull origin master

# Test backup
nix-save
```

---

## 📝 Main Settings
- **CPU**: i7-4700HQ
- **GPU**: GTX 850M (Legacy 470 driver)
- **RAM**: 8GB + zRAM 50%
- **Desktop**: i3wm + Polybar + Picom
- **Theme**: Dracula / One Dark Pro

---

## 🔧 Customization
Edit these in `configuration.nix`:
- Line 129: `networking.hostName` (ถ้าต้องการเปลี่ยนชื่อเครื่อง)
- Line 280-300: User settings
