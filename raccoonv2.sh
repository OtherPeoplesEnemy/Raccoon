#!/bin/bash

# Security Raccoon Installer
# Author: [Your Name]
# Version: 1.4

# --- Colors ---
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# --- Logging ---
LOGFILE="$(pwd)/security_raccoon_install.log"
exec > >(tee -a "$LOGFILE") 2>&1

# --- Require root privileges ---
if [ "$EUID" -ne 0 ]; then 
  echo -e "${RED}[-] Please run as root (use sudo).${NC}"
  exit 1
fi

# --- Banner ---
banner() {
    echo -e "${GREEN}"
    echo "                                                                                                           "
    echo "   _________                          .__  __           __________                                          " 
    echo "  /   _____/ ____   ____  __ _________|__|/  |_ ___.__. \______   \_____    ____  ____  ____   ____   ____ "  
    echo "  \_____  \_/ __ \_/ ___\|  |  \_  __ \  \   __<   |  |  |       _/\__  \ _/ ___\/ ___\/  _ \ /  _ \ /    \ " 
    echo "  /        \  ___/\  \___|  |  /|  | \/  ||  |  \___  |  |    |   \ / __ \\  \__\  \__(  <_> |  <_> )   |  \ "
    echo " /_______  /\___  >\___  >____/ |__|  |__||__|  / ____|  |____|_  /(____  /\___  >___  >____/ \____/|___|  / "
    echo "         \/     \/     \/                       \/              \/      \/     \/    \/                  \/ "
    echo "                       SECURITY RACCOON INSTALLER                                                            "
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
    dnf install -y yakuake konsole ark plasma-nm

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
    RUSTSCAN_URL=$(curl -s https://api.github.com/repos/RustScan/RustScan/releases/latest \
        | grep "browser_download_url.*linux-musl" \
        | cut -d '"' -f 4 | head -n 1)
    wget "$RUSTSCAN_URL" -O rustscan.tar.gz || echo "RustScan download failed."
    if [ -f rustscan.tar.gz ]; then
        tar -xvzf rustscan.tar.gz
        chmod +x rustscan || true
        rm -f rustscan.tar.gz
    else
        echo -e "${RED}[-] RustScan archive not found. Skipping extract.${NC}"
    fi

    echo -e "${GREEN}[+] Downloading Sliver C2 binary...${NC}"
    wget https://github.com/BishopFox/sliver/releases/latest/download/sliver-server_linux -O sliver-server
    chmod +x sliver-server

    echo -e "${GREEN}[+] Downloading Burp Suite Community Installer...${NC}"
    wget "https://portswigger.net/burp/releases/download?product=community&version=2024.2.1&type=Linux" -O burpsuite_community_linux.sh
    chmod +x burpsuite_community_linux.sh

    echo -e "${GREEN}[+] Installing bloodhound-python...${NC}"
    git clone https://github.com/dirkjanm/bloodhound-python.git || echo "bloodhound-python already exists."
    cd /opt/tools/bloodhound-python || echo "bloodhound-python folder not found. Skipping install."
    if [ -f requirements.txt ]; then
        pip3 install -r requirements.txt
        python3 setup.py install
    fi
}

create_symlinks() {
    echo -e "${GREEN}[+] Creating symlinks for tools...${NC}"
    [ -f /opt/tools/rustscan ] && ln -sf /opt/tools/rustscan /usr/local/bin/rustscan
    [ -f /opt/tools/sliver-server ] && ln -sf /opt/tools/sliver-server /usr/local/bin/sliver-server
}

setup_parrot_prompt() {
    echo -e "${GREEN}[+] Setting up Parrot-style terminal prompt...${NC}"

    if [ "$EUID" -ne 0 ]; then
        cp ~/.bashrc ~/.bashrc.backup
        cat >> ~/.bashrc << 'EOF'

# Parrot OS-style prompt
PS1="\[\033[0;31m\]┌─\[\033[0;37m\][\[\033[0;32m\]\u\[\033[0;37m\]@\[\033[0;36m\]\h\[\033[0;37m\]]\[\033[0;31m\]─\[\033[0;37m\][\[\033[0;33m\]\w\[\033[0;37m\]]\n\[\033[0;31m\]└──╼ \[\033[0;33m\]\$\[\033[0m\] "
EOF
        cp ~/.bashrc /root/.bashrc
    fi
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
    echo " Terminal: Parrot-style prompt active!"
    echo " Log file saved to: $LOGFILE"
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
