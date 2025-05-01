#!/bin/bash

echo "[+] Installing Python and CLI dependencies..."

# Ensure dnf is up to date
sudo dnf update -y

# Install Python, pip, and dev tools
sudo dnf install -y python3 python3-pip python3-devel gcc git

# Install Go
sudo dnf install -y golang

# Install Rich library for fancy CLI
pip3 install rich

echo "[✓] Dependencies installed. You can now run: python3 installer.py"
