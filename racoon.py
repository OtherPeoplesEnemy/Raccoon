import os
import subprocess
import urllib.request
import zipfile
from pathlib import Path

# ASCII art raccoon head
ascii_art_raccoon = """
  ___  __  __ ___ ____   ___   ___   ___   ___
 | __||  \/  | __|__ /  / _ \ / _ \ | _ \ / _ \
 | _| | |\/| | _| |_ \ | (_) | (_) ||  _/| (_) |
 |___||_|  |_|___|___/  \___/ \___/ |_|   \___/
"""

# Print the ASCII art raccoon head
print(ascii_art_raccoon)

# Define the list of tools to be installed via dnf
tools = [
    "nmap",
    "wireshark",
    "aircrack-ng",
    "john",
    "gobuster",
    "nikto",
    "ffuf",
    "hashcat",
    "mingw64-gcc"
]

# Define the kickstart file content
kickstart_content = """
#version=DEVEL
# System authorization information
auth --useshadow --enablemd5
# System bootloader configuration
bootloader --location=mbr
# Partition clearing information
clearpart --all --initlabel
# Disk partitioning information
part / --fstype="ext4" --grow --asprimary --size=1
part swap --recommended
# System language
lang en_US
# Network information
network --bootproto=dhcp
# Root password
rootpw --iscrypted $6$longhashedpassword
# System timezone
timezone America/New_York
# System keyboard
keyboard us
# Reboot after installation
reboot
# Package installation
%packages
@core
{}
%end
""".format("\n".join(tools))

# Function to write the kickstart file
def write_kickstart_file(filename="custom-fedora.ks"):
    with open(filename, "w") as ks_file:
        ks_file.write(kickstart_content)
    print(f"Kickstart file '{filename}' created.")

# Function to install tools using dnf
def install_tools():
    for tool in tools:
        subprocess.run(["sudo", "dnf", "install", "-y", tool], check=True)
    print("All tools installed.")

# Function to install .NET Core SDK for Covenant
def install_dotnet_sdk():
    subprocess.run(["sudo", "dnf", "install", "-y", "dotnet-sdk-8.0"], check=True)
    print(".NET Core SDK 8.0 installed.")

# Function to check if sqlmap is installed
def is_sqlmap_installed():
    try:
        subprocess.run(["sqlmap", "--version"], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        return True
    except FileNotFoundError:
        return False

# Function to download and install sqlmap
def install_sqlmap():
    if is_sqlmap_installed():
        print("sqlmap is already installed, skipping installation.")
    else:
        url = "https://github.com/sqlmapproject/sqlmap/archive/refs/heads/master.zip"
        file_name = "sqlmap.zip"
        install_dir = "/opt/sqlmap"

        # Download the file
        urllib.request.urlretrieve(url, file_name)
        print(f"Downloaded {file_name}")

        # Extract the file with elevated privileges
        subprocess.run(["sudo", "mkdir", "-p", install_dir], check=True)
        subprocess.run(["sudo", "unzip", file_name, "-d", install_dir], check=True)
        print(f"Extracted {file_name} to {install_dir}")

        # Create a symlink for sqlmap.py to make it executable from anywhere
        subprocess.run(["sudo", "ln", "-s", f"{install_dir}/sqlmap-master/sqlmap.py", "/usr/local/bin/sqlmap"], check=True)
        subprocess.run(["sudo", "chmod", "+x", f"{install_dir}/sqlmap-master/sqlmap.py"], check=True)
        print("sqlmap installed.")

# Function to install Metasploit
def install_metasploit():
    # Download and run the Metasploit installer script
    subprocess.run(["curl", "https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb", "-o", "msfinstall"], check=True)
    subprocess.run(["chmod", "755", "msfinstall"], check=True)
    subprocess.run(["./msfinstall"], check=True)
    print("Metasploit installed.")

# Function to install Silver C2
def install_silver_c2():
    # Download the installation script using wget
    subprocess.run(["wget", "-O", "sliver_install.sh", "https://sliver.sh/install"], check=True)
    # Run the installation script with elevated privileges
    subprocess.run(["sudo", "bash", "sliver_install.sh"], check=True)
    print("Silver C2 installed.")

# Function to download and install Burp Suite
def install_burp_suite():
    url = "https://portswigger.net/burp/releases/download?product=community&version=2023.3.1&type=Jar"  # Replace with the latest URL
    file_name = "burpsuite_community.jar"
    install_dir = "/opt/burpsuite"

    # Download the file
    subprocess.run(["sudo", "mkdir", "-p", install_dir], check=True)
    urllib.request.urlretrieve(url, os.path.join(install_dir, file_name))
    print(f"Downloaded Burp Suite to {install_dir}/{file_name}")

    # Optional: create a launcher script
    launcher_script = os.path.join(install_dir, "burpsuite.sh")
    with open(launcher_script, "w") as f:
        f.write(f"#!/bin/bash\njava -jar {install_dir}/{file_name}\n")
    subprocess.run(["sudo", "chmod", "+x", launcher_script], check=True)
    print(f"Created Burp Suite launcher script at {launcher_script}")

    print("Burp Suite installed.")

# Function to download and install RustScan
def install_rustscan():
    url = "https://github.com/RustScan/RustScan/releases/download/2.0.1/rustscan_2.0.1_amd64.deb"  # Replace with the latest URL
    file_name = "rustscan_2.0.1_amd64.deb"

    # Download the file
    urllib.request.urlretrieve(url, file_name)
    print(f"Downloaded {file_name}")

    # Install the .deb package
    subprocess.run(["sudo", "dnf", "install", "-y", "alien"], check=True)  # Ensure 'alien' is installed
    subprocess.run(["sudo", "alien", "--to-rpm", file_name], check=True)  # Convert .deb to .rpm
    subprocess.run(["sudo", "dnf", "install", "-y", file_name.replace('.deb', '.rpm')], check=True)  # Install the converted .rpm
    print(f"Installed RustScan from {file_name}")

# Function to download and install enum4linux
def install_enum4linux():
    url = "https://github.com/CiscoCXSecurity/enum4linux-ng/archive/refs/heads/main.zip"
    file_name = "enum4linux.zip"
    install_dir = "/opt/enum4linux"

    # Download the file
    urllib.request.urlretrieve(url, file_name)
    print(f"Downloaded {file_name}")

    # Extract the file with elevated privileges
    subprocess.run(["sudo", "mkdir", "-p", install_dir], check=True)
    subprocess.run(["sudo", "unzip", file_name, "-d", install_dir], check=True)
    print(f"Extracted {file_name} to {install_dir}")

    print("enum4linux installed.")

# Function to download and install impacket-GetUserSPNs
def install_impacket():
    url = "https://github.com/SecureAuthCorp/impacket/archive/refs/heads/master.zip"
    file_name = "impacket.zip"
    install_dir = "/opt/impacket"

    # Download the file
    urllib.request.urlretrieve(url, file_name)
    print(f"Downloaded {file_name}")

    # Extract the file with elevated privileges
    subprocess.run(["sudo", "mkdir", "-p", install_dir], check=True)
    subprocess.run(["sudo", "unzip", file_name, "-d", install_dir], check=True)
    print(f"Extracted {file_name} to {install_dir}")

    # Install the impacket scripts
    subprocess.run(["sudo", "pip3", "install", f"{install_dir}/impacket-master"], check=True)
    print("impacket-GetUserSPNs installed.")

# Function to download and install BloodHound/Sharphound
def install_bloodhound():
    url = "https://github.com/BloodHoundAD/BloodHound/releases/download/4.0.3/BloodHound-linux-x64.zip"
    file_name = "BloodHound-linux-x64.zip"
    install_dir = "/opt/bloodhound"

    # Download the file
    urllib.request.urlretrieve(url, file_name)
    print(f"Downloaded {file_name}")

    # Extract the file with elevated privileges
    subprocess.run(["sudo", "mkdir", "-p", install_dir], check=True)
    subprocess.run(["sudo", "unzip", file_name, "-d", install_dir], check=True)
    print(f"Extracted {file_name} to {install_dir}")

    print("BloodHound/SharpHound installed.")

# Function to download and install CMSeek
def install_cmseek():
    url = "https://github.com/Tuhinshubhra/CMSeeK/archive/refs/heads/master.zip"
    file_name = "CMSeek.zip"
    install_dir = "/opt/cmseek"

    # Download the file
    urllib.request.urlretrieve(url, file_name)
    print(f"Downloaded {file_name}")

    # Extract the file with elevated privileges
    subprocess.run(["sudo", "mkdir", "-p", install_dir], check=True)
    subprocess.run(["sudo", "unzip", file_name, "-d", install_dir], check=True)
    print(f"Extracted {file_name} to {install_dir}")

    print("CMSeek installed.")

# Function to download and install pspy
def install_pspy():
    url = "https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64"
    file_name = "pspy64"
    install_dir = "/usr/local/bin"

    # Download the file
    urllib.request.urlretrieve(url, os.path.join(install_dir, file_name))
    print(f"Downloaded {file_name}")

    # Set executable permissions
    subprocess.run(["sudo", "chmod", "755", os.path.join(install_dir, file_name)], check=True)
    print(f"Installed pspy to {install_dir}/{file_name}")

# Function to download and install CloudFox
def install_cloudfox():
    url = "https://github.com/BishopFox/cloudfox/releases/download/v1.7.1/cloudfox_1.7.1_linux_amd64.tar.gz"
    file_name = "cloudfox.tar.gz"
    install_dir = "/opt/cloudfox"

    # Download the file
    urllib.request.urlretrieve(url, file_name)
    print(f"Downloaded {file_name}")

    # Extract the file with elevated privileges
    subprocess.run(["sudo", "mkdir", "-p", install_dir], check=True)
    subprocess.run(["sudo", "tar", "-xzvf", file_name, "-C", install_dir], check=True)
    print(f"Extracted {file_name} to {install_dir}")

    # Move the binary to /usr/local/bin
    subprocess.run(["sudo", "mv", f"{install_dir}/cloudfox", "/usr/local/bin"], check=True)
    subprocess.run(["sudo", "chmod", "+x", "/usr/local/bin/cloudfox"], check=True)
    print("CloudFox installed.")

# Function to download and install Sublist3r
def install_sublist3r():
    url = "https://github.com/aboul3la/Sublist3r/archive/refs/heads/master.zip"
    file_name = "Sublist3r.zip"
    install_dir = "/opt/sublist3r"

    # Download the file
    urllib.request.urlretrieve(url, file_name)
    print(f"Downloaded {file_name}")

    # Extract the file with elevated privileges
    subprocess.run(["sudo", "mkdir", "-p", install_dir], check=True)
    subprocess.run(["sudo", "unzip", file_name, "-d", install_dir], check=True)
    print(f"Extracted {file_name} to {install_dir}")

    print("Sublist3r installed.")

# Function to download and install ysoserial
def install_ysoserial():
    url = "https://github.com/frohoff/ysoserial/releases/download/v0.0.6/ysoserial-all.jar"
    file_name = "ysoserial-all.jar"
    install_dir = "/opt/ysoserial"

    # Download the file
    subprocess.run(["sudo", "mkdir", "-p", install_dir], check=True)
    urllib.request.urlretrieve(url, os.path.join(install_dir, file_name))
    print(f"Downloaded {file_name} to {install_dir}")

    # Create a launcher script
    launcher_script = os.path.join(install_dir, "ysoserial.sh")
    with open(launcher_script, "w") as f:
        f.write(f"#!/bin/bash\njava -jar {install_dir}/{file_name}\n")
    subprocess.run(["sudo", "chmod", "+x", launcher_script], check=True)
    print(f"Created ysoserial launcher script at {launcher_script}")

    print("ysoserial installed.")

# Function to download and install unicorn
def install_unicorn():
    url = "https://github.com/trustedsec/unicorn/archive/refs/heads/master.zip"
    file_name = "unicorn.zip"
    install_dir = "/opt/unicorn"

    # Download the file
    urllib.request.urlretrieve(url, file_name)
    print(f"Downloaded {file_name}")

    # Extract the file with elevated privileges
    subprocess.run(["sudo", "mkdir", "-p", install_dir], check=True)
    subprocess.run(["sudo", "unzip", file_name, "-d", install_dir], check=True)
    print(f"Extracted {file_name} to {install_dir}")

    print("unicorn installed.")

# Function to download and install Empire
def install_empire():
    url = "https://github.com/BC-SECURITY/Empire/archive/refs/heads/master.zip"
    file_name = "Empire.zip"
    install_dir = "/opt/empire"

    # Download the file
    urllib.request.urlretrieve(url, file_name)
    print(f"Downloaded {file_name}")

    # Extract the file with elevated privileges
    subprocess.run(["sudo", "mkdir", "-p", install_dir], check=True)
    subprocess.run(["sudo", "unzip", file_name, "-d", install_dir], check=True)
    print(f"Extracted {file_name} to {install_dir}")

    # Install dependencies and Empire
    subprocess.run(["sudo", "apt-get", "update"], check=True)
    subprocess.run(["sudo", "apt-get", "install", "-y", "build-essential", "python3-dev", "python3-pip"], check=True)
    subprocess.run(["sudo", "pip3", "install", "-r", f"{install_dir}/Empire-master/requirements.txt"], check=True)
    subprocess.run([f"{install_dir}/Empire-master/setup/install.sh"], check=True)
    print("Empire installed.")

# Function to download and install Covenant
def install_covenant():
    url = "https://github.com/cobbr/Covenant/archive/refs/heads/master.zip"
    file_name = "Covenant.zip"
    install_dir = "/opt/covenant"

    # Download the file
    urllib.request.urlretrieve(url, file_name)
    print(f"Downloaded {file_name}")

    # Extract the file with elevated privileges
    subprocess.run(["sudo", "mkdir", "-p", install_dir], check=True)
    subprocess.run(["sudo", "unzip", file_name, "-d", install_dir], check=True)
    print(f"Extracted {file_name} to {install_dir}")

    # Install dependencies and build Covenant
    subprocess.run(["dotnet", "build"], cwd=f"{install_dir}/Covenant-master/Covenant", check=True)
    print("Covenant installed.")

# Function to download and install Merlin
def install_merlin():
    url = "https://github.com/Ne0nd0g/merlin/releases/download/v1.5.0/merlinServer-Linux-x64.7z"
    file_name = "merlinServer-Linux-x64.7z"
    install_dir = "/opt/merlin"

    # Download the file
    urllib.request.urlretrieve(url, file_name)
    print(f"Downloaded {file_name}")

    # Extract the file with elevated privileges
    subprocess.run(["sudo", "mkdir", "-p", install_dir], check=True)
    subprocess.run(["sudo", "7z", "x", file_name, f"-o{install_dir}"], check=True)
    print(f"Extracted {file_name} to {install_dir}")

    print("Merlin installed.")

# Function to download and install GoPhish
def install_gophish():
    url = "https://github.com/gophish/gophish/releases/download/v0.11.0/gophish-v0.11.0-linux-64bit.zip"
    file_name = "gophish.zip"
    install_dir = "/opt/gophish"

    # Download the file
    urllib.request.urlretrieve(url, file_name)
    print(f"Downloaded {file_name}")

    # Extract the file with elevated privileges
    subprocess.run(["sudo", "mkdir", "-p", install_dir], check=True)
    subprocess.run(["sudo", "unzip", file_name, "-d", install_dir], check=True)
    print(f"Extracted {file_name} to {install_dir}")

    print("GoPhish installed.")

# Function to download and install RedELK
def install_redelk():
    url = "https://github.com/outflanknl/RedELK/archive/refs/heads/master.zip"
    file_name = "redelk.zip"
    install_dir = "/opt/redelk"

    # Download the file
    urllib.request.urlretrieve(url, file_name)
    print(f"Downloaded {file_name}")

    # Extract the file with elevated privileges
    subprocess.run(["sudo", "mkdir", "-p", install_dir], check=True)
    subprocess.run(["sudo", "unzip", file_name, "-d", install_dir], check=True)
    print(f"Extracted {file_name} to {install_dir}")

    # Install dependencies
    subprocess.run(["sudo", "pip3", "install", "-r", f"{install_dir}/RedELK-master/elkserver/docker-elk/requirements.txt"], check=True)
    print("RedELK installed.")

# Function to download and install Caldera
def install_caldera():
    url = "https://github.com/mitre/caldera/archive/refs/heads/master.zip"
    file_name = "caldera.zip"
    install_dir = "/opt/caldera"

    # Download the file
    urllib.request.urlretrieve(url, file_name)
    print(f"Downloaded {file_name}")

    # Extract the file with elevated privileges
    subprocess.run(["sudo", "mkdir", "-p", install_dir], check=True)
    subprocess.run(["sudo", "unzip", file_name, "-d", install_dir], check=True)
    print(f"Extracted {file_name} to {install_dir}")

    # Install dependencies
    subprocess.run(["sudo", "pip3", "install", "-r", f"{install_dir}/caldera-master/requirements.txt"], check=True)
    print("Caldera installed.")

# Function to create the custom ISO
def create_custom_iso(iso_name="custom-fedora.iso"):
    subprocess.run(["sudo", "livecd-creator", "--config=custom-fedora.ks", "--fslabel=CustomFedora", "--cache=/var/cache/live"], check=True)
    print(f"Custom ISO '{iso_name}' created.")

# Main function
def main():
    print("Setting up the environment...")
    write_kickstart_file()
    print("Installing required tools...")
    install_tools()
    print("Installing .NET Core SDK for Covenant...")
    install_dotnet_sdk()
    print("Installing sqlmap...")
    install_sqlmap()
    print("Installing Metasploit...")
    install_metasploit()
    print("Installing Silver C2...")
    install_silver_c2()
    print("Installing Burp Suite...")
    install_burp_suite()
    print("Installing RustScan...")
    install_rustscan()
    print("Installing enum4linux...")
    install_enum4linux()
    print("Installing impacket-GetUserSPNs...")
    install_impacket()
    print("Installing BloodHound/SharpHound...")
    install_bloodhound()
    print("Installing CMSeek...")
    install_cmseek()
    print("Installing pspy...")
    install_pspy()
    print("Installing CloudFox...")
    install_cloudfox()
    print("Installing Sublist3r...")
    install_sublist3r()
    print("Installing ysoserial...")
    install_ysoserial()
    print("Installing unicorn...")
    install_unicorn()
    print("Installing Empire...")
    install_empire()
    print("Installing Covenant...")
    install_covenant()
    print("Installing Merlin...")
    install_merlin()
    print("Installing GoPhish...")
    install_gophish()
    print("Installing RedELK...")
    install_redelk()
    print("Installing Caldera...")
    install_caldera()
    print("Creating the custom ISO...")
    create_custom_iso()

if __name__ == "__main__":
    main()
