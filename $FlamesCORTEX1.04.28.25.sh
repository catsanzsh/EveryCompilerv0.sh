#!/bin/bash

# Define colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print a banner
print_banner() {
    echo -e "${CYAN}=======================================${NC}"
    echo -e "${CYAN} $1 ${NC}"
    echo -e "${CYAN}=======================================${NC}"
}

# Install DevkitPro for Nintendo Consoles and PSP
print_banner "DevkitPro (Nintendo Consoles and PSP)"

LOG_FILE="devkitpro_install.log"

echo -e "${CYAN}Checking if DevkitPro pacman is installed...${NC}"
if command -v dkp-pacman &> /dev/null; then
    echo -e "${GREEN}dkp-pacman is already installed.${NC}"
else
    echo -e "${CYAN}Installing DevkitPro pacman...${NC}"
    curl -sSL https://apt.devkitpro.org/install-devkitpro-pacman | sudo bash || {
        echo -e "${RED}DevkitPro bootstrap failed! Exiting.${NC}"
        exit 1
    }
fi

# Source the environment setup
if [ -f /etc/profile.d/devkit-env.sh ]; then
    source /etc/profile.d/devkit-env.sh
else
    echo -e "${YELLOW}Warning: /etc/profile.d/devkit-env.sh not found. Environment may not be set up correctly.${NC}"
fi

echo -e "${CYAN}Updating package database...${NC}"
dkp-pacman -Sy --noconfirm | tee -a "$LOG_FILE"

echo -e "${CYAN}Installing supported meta-packages...${NC}"
dkp-pacman -S --noconfirm --needed \
    gba-dev \
    nds-dev \
    3ds-dev \
    gamecube-dev \
    wii-dev \
    wiiu-dev \
    switch-dev \
    psp-dev 2>&1 | tee -a "$LOG_FILE" || {
    echo -e "${YELLOW}Some packages may have failed to install. Check $LOG_FILE for details.${NC}"
}

echo -e "${GREEN}✔ DevkitPro toolchains & libs installation attempted.${NC}"
echo -e "${YELLOW}Installation log saved to $LOG_FILE${NC}"
