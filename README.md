# Security Raccoon

**Security Raccoon** is a custom Fedora-based penetration testing distribution designed for red teamers, pentesters, and cyber enthusiasts who want a powerful, visually appealing, and scriptable Linux environment. Inspired by Kali and Parrot OS, Security Raccoon features a KDE Plasma desktop, raccoon-themed hacker branding, and an extensive suite of offensive security tools.

---

## 🚀 Features

- 🐧 **Fedora Base** – Secure, fast, and up-to-date RPM-based Linux distro
- 🖥️ **KDE Plasma Desktop** – Beautiful, customizable, and hacker-themed
- 🛠️ **Preinstalled Security Tools** including:
  - `nmap`, `wireshark`, `aircrack-ng`, `john`, `ffuf`, `nikto`, `gobuster`, `sqlmap`, `hashcat`
  - `Sliver`, `CloudFox`, `Sublist3r`, `CMSeek`, `impacket`, `bloodhound-python`
- 💻 **Parrot OS-style Terminal Prompt** with green-on-black shell and hacker prompt
- 📦 **Raccoon branding** – ASCII banner, optional custom wallpaper, and future boot splash
- 🧪 **Symlinked binaries** for easy access: `rustscan`, `sliver-server`, and more
- 🧙‍♂️ **Custom scriptable installer** – install everything in one shot

---

## 📦 Installation Instructions

### 1. Clone the Repo
```bash
git clone https://github.com/YOUR_USERNAME/security-raccoon.git
cd security-raccoon
```

### 2. Run the Installer (on Fedora 39+)
```bash
chmod +x install_pentest_distro.sh
sudo ./install_pentest_distro.sh
```

### 3. Optional
- Add a custom raccoon wallpaper to `/opt/assets/background.png`
- Run the Burp Suite installer manually:
  ```bash
  sudo bash /opt/tools/burpsuite_community_linux.sh
  ```

---

## 📸 Screenshots
*(Coming soon – KDE desktop with raccoon background and terminal preview)*

---

## 🛠️ Project Goals
- Build an ISO for live boot and installation
- Offer a Python version with interactive menus
- Expand tool support for cloud, forensics, and red teaming

---

## 📄 License
This project is licensed under the MIT License. See the LICENSE file for details.

---

## 🤝 Contributing
Pull requests, feedback, and new tool suggestions are welcome! Feel free to fork and improve the script or build process.

---

## 🦝 Credits
Built by OtherPeoplesEnemy , fueled by caffeine, curiosity, and raccoons with keyboards.
