#!/bin/bash
# bootstrap.sh — Netbook Linux v2 Bootstrap Script
# Smart fallback: GitHub if possible, otherwise /cdrom local repo

set -e
set -u

echo "🔧 Starting Netbook Linux v2 Bootstrap..."

### STEP 1: Check for Git and Internet Access
if command -v git >/dev/null 2>&1 && ping -c 1 github.com >/dev/null 2>&1; then
    echo "🌐 Git is available. Cloning from GitHub..."

    git clone https://github.com/elfern-hub/netbook-linux.git ~/Projects/netbook-linux
    cd ~/Projects/netbook-linux

    echo "📦 Installing meta-packages from local Git repo..."
    sudo dpkg -i packages/netbook-core_*.deb || true
    sudo dpkg -i packages/netbook-gui_*.deb || true
    sudo apt install -f -y

else
    echo "💾 Git not available or GitHub unreachable. Falling back to ISO/CDROM..."

    # Add custom repo from ISO if not already present
    if ! grep -q '/cdrom' /etc/apt/sources.list.d/netbook.list 2>/dev/null; then
        echo "deb [trusted=yes] file:///cdrom dists/stable netbook" | sudo tee /etc/apt/sources.list.d/netbook.list
    fi

    sudo apt update
    sudo apt install -y netbook-core netbook-gui
fi

### STEP 2: Enable Core Services
echo "⚙️ Enabling critical services..."
sudo systemctl enable tlp
sudo systemctl enable ufw
sudo systemctl enable lightdm
sudo systemctl enable NetworkManager
sudo systemctl enable ssh
# systemctl --user enable udiskie # (optional for Openbox/LXQt setups)

### STEP 3: Create Folder Structure (if not already present)
if [ ! -d "$HOME/Projects/netbook-linux" ]; then
    echo "🗂 Creating default Netbook Linux project folders..."
    mkdir -p ~/Projects/netbook-linux/{scripts,packages/netbook-tools/DEBIAN,notes,iso,staging,meta}
    touch ~/Projects/netbook-linux/{README.md,CHANGELOG.md,TODO.md}
fi

echo "🎉 Bootstrap complete. Reboot when ready or continue customization."
