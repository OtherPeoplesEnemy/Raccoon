#!/bin/bash

# Security Raccoon Installer (Fedora-based Pentesting Distro)
# Author: [Your Name]
# Version: 1.3

set -e

# --- Colors ---
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Require root privileges ---
if [ "$EUID" -ne 0 ]; then 
  echo -e "${RED}[-] Please run as root! (use sudo)${NC}"
  exit 1
fi

# --- Banner ---
banner() {
    echo -e "${GREEN}"
    echo "   _____                         _ _             _____                                  "
    echo "  / ____|                       (_) |           |  __ \\                                 "
    echo " | (___   ___  ___ _   _ _ __ ___ _| |_ _   _     | |__) |___  ___ ___  _ __ ___  ___     "
    echo "  \\___ \\ / _ \\/ __| | | | '__/ __| | __| | | |    |  _  // _ \\/ __/ _ \\| '__/ _ \\/ __|    "
    echo "  ____) |  __/ (__| |_| | | | (__| | |_| |_| |    | | \\ \\  __/ (_| (_) | | |  __/\\__ \\    "
    echo " |_____/ \\___|\\___|\\__,_|_|  \\___|_|\\__|\\__, |    |_|  \\_\\___|\\___\\___/|_|  \\___||___/    "
    echo "                                         __/ |                                           "
    echo "                                        |___/                                            "
    echo "                       SECURITY RACCOON INSTALLER                                       "
    echo
    echo "       (\\_/)    "
    echo "      ( •_•)     Security Raccoon reporting for duty."
    echo "     / >\ud83d\udce6       Installing tools like a pro..."
    echo -e "${NC}"
}

check_fedora() {
    if [ ! -f /etc/fedora-release ]; then
        echo -e "${RED}[-] This script is intended for Fedora systems only!${NC}"
        exit 1
    fi
}

create_structure() {
    echo -e "${GREEN}[+] Creating /opt/tools and /opt/assets if not exist...${NC}"
    mkdir -p /opt/tools
    mkdir -p /opt/assets
}

install_packages() {
    echo -e "${GREEN}[+] Installing KDE Plasma Desktop...${NC}"
    dnf groupinstall -y "KDE Plasma Workspaces"
    dnf install -y kde-settings sddm
    systemctl enable sddm

    echo -e "${GREEN}[+] Installing hacking-friendly KDE apps...${NC}"
    dnf install -y yakuake konsole ark plasma-nm krunner

    echo -e "${GREEN}[+] Installing core pentest tools...${NC}"
    dnf install -y nmap wireshark aircrack-ng john gobuster nikto ffuf \
                    git python3-pip cmake gcc g++ make unzip wget curl ruby

    echo -e "${GREEN}[+] Installing Python-based tools...${NC}"
    pip3 install --upgrade pip
    pip3 install impacket sqlmap

    echo -e "${GREEN}[+] Installing Ruby tools (for Evil-WinRM)...${NC}"
    gem install evil-winrm
}

clone_tools() {
    echo -e "${GREEN}[+] Cloning GitHub tools into /opt/tools...${NC}"

    cd /opt/tools
    git clone https://github.com/Tuhinshubhra/CMSeek.git || echo "CMSeek already cloned."
    git clone https://github.com/BishopFox/cloudfox.git || echo "CloudFox already cloned."
    git clone https://github.com/aboul3la/Sublist3r.git || echo "Sublist3r already cloned."

    echo -e "${GREEN}[+] Installing Sublist3r requirements...${NC}"
    pip3 install -r /opt/tools/Sublist3r/requirements.txt || true

    echo -e "${GREEN}[+] Downloading RustScan binary...${NC}"
    cd /opt/tools
    wget https://github.com/RustScan/RustScan/releases/latest/download/rustscan-x86_64-unknown-linux-musl.tar.gz -O rustscan.tar.gz
    tar -xvzf rustscan.tar.gz
    chmod +x rustscan
    rm -f rustscan.tar.gz

    echo -e "${GREEN}[+] Downloading Sliver C2 binary...${NC}"
    wget https://github.com/BishopFox/sliver/releases/latest/download/sliver-server_linux -O sliver-server
    chmod +x sliver-server

    echo -e "${GREEN}[+] Downloading Burp Suite Community Edition Installer...${NC}"
    wget https://portswigger.net/burp/releases/download?product=community&version=2024.2.1&type=Linux -O burpsuite_community_linux.sh
    chmod +x burpsuite_community_linux.sh

    echo -e "${GREEN}[+] Cloning and installing bloodhound-python...${NC}"
    git clone https://github.com/fox-it/bloodhound-python.git || echo "bloodhound-python already cloned."
    cd /opt/tools/bloodhound-python
    pip3 install -r requirements.txt
    python3 setup.py install
}

create_symlinks() {
    echo -e "${GREEN}[+] Creating symlinks for tools...${NC}"

    ln -sf /opt/tools/rustscan /usr/local/bin/rustscan 2>/dev/null || true
    ln -sf /opt/tools/sliver-server /usr/local/bin/sliver-server 2>/dev/null || true
}

set_kde_default() {
    echo -e "${GREEN}[+] Setting KDE Plasma as default desktop...${NC}"
    echo "exec startplasma-x11" > ~/.xinitrc
}

set_kde_wallpaper() {
    echo -e "${GREEN}[+] Setting KDE wallpaper (if available)...${NC}"
    WALLPAPER="/opt/assets/background.png"
    if [ -f "$WALLPAPER" ]; then
        mkdir -p ~/Pictures
        cp "$WALLPAPER" ~/Pictures/raccoon_bg.png
    fi
}

setup_parrot_prompt() {
    echo -e "${GREEN}[+] Configuring Parrot OS-style terminal prompt...${NC}"
    cp ~/.bashrc ~/.bashrc.backup
    cat >> ~/.bashrc << 'EOF'
# Parrot OS-style prompt
PS1="\[\033[0;31m\]\u@\h \[\033[0;32m\]\w\[\033[0m\]\n\[\033[0;31m\]└──╼ \[\033[0;33m\]\$ \[\033[0m\]"
EOF
    cp ~/.bashrc /root/.bashrc
    source ~/.bashrc || true
}

summary() {
    echo -e "${GREEN}"
    echo "======================================="
    echo " Security Raccoon Installed! 🎉"
    echo " Tools are in /opt/tools"
    echo " rustscan and sliver-server are global commands"
    echo " Burp Suite installer: /opt/tools/burpsuite_community_linux.sh"
    echo " Login manager: SDDM (enabled)"
    echo " Desktop: KDE Plasma with Parrot-style terminal"
    echo "======================================="
    echo -e "${NC}"
}

# --- Run Everything ---
banner
check_fedora
create_structure
install_packages
clone_tools
customize_desktop
create_symlinks
set_kde_default
set_kde_wallpaper
setup_parrot_prompt
summary
