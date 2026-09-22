#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=========================================="
echo "Starting Ubuntu Python Environment Setup"
echo "=========================================="

# Update and Upgrade System
echo "--> Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Essential Utilities (Git, Vim, Screen)
echo "--> Installing Git, Vim, and Screen..."
sudo apt-get install -y git vim screen curl wget software-properties-common apt-transport-https ca-certificates gnupg lsb-release

# 1. Download and Install Google Chrome
#echo "--> Downloading and installing Google Chrome..."
#wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
#sudo apt-get install -y ./google-chrome-stable_current_amd64.deb
#rm google-chrome-stable_current_amd64.deb

# 2. Install Python3 Full, Pip3, and Remote-PDB
echo "--> Installing Python 3, Pip, and development tools..."
sudo apt-get install -y python3-full python3-pip python3-dev
echo "--> Installing remote-pdb via pip..."
pip3 install remote-pdb --break-system-packages || pip3 install remote-pdb

# Install Anaconda
echo "--> Downloading and installing Anaconda..."
ANACONDA_VERSION="2024.10-1" # Fallback/Latest stable pattern identifier
wget -q https://repo.anaconda.com/archive/Anaconda3-${ANACONDA_VERSION}-Linux-x86_64.sh -O anaconda.sh
bash anaconda.sh -b -p $HOME/anaconda3
rm anaconda.sh

# Setup Anaconda Environment Variables
echo "--> Configuring Anaconda environment variables..."
$HOME/anaconda3/bin/conda init bash
$HOME/anaconda3/bin/conda init zsh || true

# 3. Install VS Code
echo "--> Installing Visual Studio Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt-get update -y
sudo apt-get install -y code

# 4. Install Docker
echo "--> Installing Docker Engine..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu   $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to docker group to run without sudo
sudo usermod -aG docker $USER
sudo newgrp docker

#install libreoffice
sudo apt install libreoffice

#install flask
source ~/.bashrc
conda activate base
python3 -m pip install flask



echo "=========================================="
echo "Setup complete! Please restart your terminal"
echo "or run 'source ~/.bashrc' to apply changes."
echo "=========================================="
