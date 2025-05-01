#!/bin/bash

# Security Raccoon Installer
# Author: [Your Name]
# Version: 1.2

set -e

# --- Colors ---
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# --- Require root privileges ---
if [ "$EUID" -ne 0 ]; then 
  echo -e "${RED}[-] Please run as root (use sudo).${NC}"
  exit 1
fi

# --- Banner ---
banner() {
    echo -e "${GREEN}"
    echo "   _____                         _ _             _____                                  "
    echo "  / ____|                       (_) |           |  __ \                                 "
    echo " | (___   ___  ___ _   _ _ __ ___ _| |_ _   _     | |__) |___  ___ ___  _ __ ___  ___     "
    echo "  \___ \ / _ \/ __| | | | '__/ __| | __| | | |    |  _  // _ \/ __/ _ \| '__/ _ \/ __|    "
    echo "  ____) |  __/ (__| |_| | | | (__| | |_| |_| |    | | \ \  __/ (_| (_) | | |  __/\__ \    "
    echo " |_____/ \___|\___|\__,_|_|  \___|_|\__|\__, |    |_|  \_\___|\___\___/|_|  \___||___/    "
    echo "                                         __/ |                                           "
    echo "                                        |___/                                            "
    echo "                       SECURITY RACCOON INSTALLER                                       "
    echo
    echo "       (\\_/)    "
    echo "      ( •_•)     Security Raccoon reporting for duty."
    echo "     / >📦       Installing tools like a pro..."
    echo -e "${NC}"
}

check_fedora() {
    if [ ! -f /etc/fedora-release ]; then
        echo -e "${RED}[-] This script is intended for Fedora systems only!${NC}"
        exit 1
    fi
}

create_structure() {
    echo -e "${GREEN}[+] Creating /opt/tools and /opt/assets...${NC}"
    mkdir -p /opt/tools
    mkdir -p /opt/assets
}

install_packages() {
    echo -e "${GREEN}[+] Installing KDE Plasma Desktop...${NC}"
    dnf groupinstall -y "KDE Plasma Workspaces"
    dnf install -y kde-settings

    echo -e "${GREEN}[+] Installing hacking-friendly KDE apps...${NC}"
    dnf install -y yakuake konsole ark plasma-nm krunner

    echo -e "${GREEN}[+] Installing core pentest tools...${NC}"
    dnf install -y nmap wireshark aircrack-ng john gobuster nikto ffuf \
                   git python3-pip cmake gcc g++ make unzip wget curl ruby

    echo -e "${GREEN}[+] Installing Python-based tools...${NC}"
    pip3 install --upgrade pip
    pip3 install impacket sqlmap

    echo -e "${GREEN}[+] Installing Ruby tools...${NC}"
    gem install evil-winrm
}

set_kde_default() {
    echo -e "${GREEN}[+] Setting KDE Plasma as default session...${NC}"
    echo "exec startplasma-x11" > ~/.xinitrc
}

clone_tools() {
    echo -e "${GREEN}[+] Cloning GitHub tools into /opt/tools...${NC}"

    cd /opt/tools
    git clone https://github.com/Tuhinshubhra/CMSeek.git || echo "CMSeek already exists."
    git clone https://github.com/BishopFox/cloudfox.git || echo "CloudFox already exists."
    git clone https://github.com/aboul3la/Sublist3r.git || echo "Sublist3r already exists."

    echo -e "${GREEN}[+] Installing Sublist3r requirements...${NC}"
    pip3 install -r /opt/tools/Sublist3r/requirements.txt || true

    echo -e "${GREEN}[+] Downloading RustScan binary...${NC}"
    wget https://github.com/RustScan/RustScan/releases/latest/download/rustscan-x86_64-unknown-linux-musl.tar.gz -O rustscan.tar.gz
    tar -xvzf rustscan.tar.gz
    chmod +x rustscan
    rm -f rustscan.tar.gz

    echo -e "${GREEN}[+] Downloading Sliver C2 binary...${NC}"
    wget https://github.com/BishopFox/sliver/releases/latest/download/sliver-server_linux -O sliver-server
    chmod +x sliver-server

    echo -e "${GREEN}[+] Downloading Burp Suite Community Installer...${NC}"
    wget https://portswigger.net/burp/releases/download?product=community&version=2024.2.1&type=Linux -O burpsuite_community_linux.sh
    chmod +x burpsuite_community_linux.sh

    echo -e "${GREEN}[+] Installing bloodhound-python...${NC}"
    git clone https://github.com/fox-it/bloodhound-python.git || echo "bloodhound-python already exists."
    cd /opt/tools/bloodhound-python
    pip3 install -r requirements.txt
    python3 setup.py install
}

create_symlinks() {
    echo -e "${GREEN}[+] Creating symlinks for tools...${NC}"
    ln -sf /opt/tools/rustscan /usr/local/bin/rustscan || true
    ln -sf /opt/tools/sliver-server /usr/local/bin/sliver-server || true
}

setup_parrot_prompt() {
    echo -e "${GREEN}[+] Setting up Parrot-style terminal prompt...${NC}"
    cp ~/.bashrc ~/.bashrc.backup

    cat >> ~/.bashrc << 'EOF'

# Parrot OS-style prompt
PS1="\[\033[0;31m\]┌─\[\033[0;37m\][\[\033[0;32m\]\u\[\033[0;37m\]@\[\033[0;36m\]\h\[\033[0;37m\]]\[\033[0;31m\]─\[\033[0;37m\][\[\033[0;33m\]\w\[\033[0;37m\]]\n\[\033[0;31m\]└──╼ \[\033[0;33m\]\$\[\033[0m\] "
EOF

    cp ~/.bashrc /root/.bashrc
}

set_kde_wallpaper() {
    echo -e "${GREEN}[+] Setting KDE wallpaper if available...${NC}"
    WALLPAPER="/opt/assets/background.png"
    if [ -f "$WALLPAPER" ]; then
        mkdir -p ~/Pictures
        cp "$WALLPAPER" ~/Pictures/raccoon_bg.png
    else
        echo -e "${RED}[-] Wallpaper not found. Skipping wallpaper setup.${NC}"
    fi
}

summary() {
    echo -e "${GREEN}"
    echo "=============================================="
    echo " Security Raccoon is ready! 🦝💻"
    echo " Tools: Installed in /opt/tools"
    echo " Burp:  Run manually → sudo bash /opt/tools/burpsuite_community_linux.sh"
    echo " KDE:   Default session set. Reboot to load Plasma."
    echo " Terminal: Raccoon-themed Parrot-style prompt active!"
    echo "=============================================="
    echo -e "${NC}"
}

# --- Run Everything ---
banner
check_fedora
create_structure
install_packages
set_kde_default
clone_tools
create_symlinks
setup_parrot_prompt
set_kde_wallpaper
summary
