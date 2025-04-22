#!/bin/bash

# ============================================================
# Script: ultimate-dev-setup.sh
# Description: Robust installation of compilers, toolchains, 
#              AArch64‑ELF cross‑compiler, and PS1–PS4 homebrew devkits
#              on Ubuntu (WSL2 supported).
# Note: Run with sudo for full functionality.
# ============================================================

# Exit on error, unset variable, pipe failure
set -euo pipefail

# Text styles for output
BOLD="\033[1m"
RESET="\033[0m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
PURPLE="\033[1;35m"
RED="\033[0;31m"

# Function to handle errors
error_handler() {
    echo -e "${RED}❌ Error in line $1. Exit code $2.${RESET}"
    exit "$2"
}
trap 'error_handler ${LINENO} $?' ERR

# Welcome message
echo -e "${PURPLE}=============================================================${RESET}"
echo -e "${PURPLE}🤖 Ultimate Dev Environment & Homebrew SDK Setup 🤖${RESET}"
echo -e "${PURPLE}=============================================================${RESET}\n"

# ------------------------------------------------------------
# System Update & Core Dependencies
# ------------------------------------------------------------
echo -e "${CYAN}🔄 Updating package lists...${RESET}"
apt-get update
echo -e "${GREEN}✅ Package lists updated.${RESET}\n"

echo -e "${CYAN}📦 Installing essential tools...${RESET}"
apt-get install -y \
    curl git build-essential cmake clang gfortran \
    default-jdk python3 python3-pip python3-venv \
    nodejs npm ruby golang ghc cabal-install \
    libmpc-dev libgmp-dev libssl-dev zlib1g-dev \
    libboost-all-dev libxml2-dev libsdl2-dev
echo -e "${GREEN}✅ Core dependencies installed.${RESET}\n"

# ------------------------------------------------------------
# Rust Installation (User-space)
# ------------------------------------------------------------
echo -e "${CYAN}🦀 Installing Rust...${RESET}"
if ! command -v rustup &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "${HOME}/.cargo/env"
else
    echo -e "${YELLOW}⚠️  Rust already installed. Skipping.${RESET}"
fi
echo -e "${GREEN}✅ Rust ready: $(rustc --version)${RESET}\n"

# ------------------------------------------------------------
# AArch64-ELF Cross-Compiler
# ------------------------------------------------------------
echo -e "${CYAN}🔧 Installing AArch64-ELF toolchain...${RESET}"
apt-get install -y gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu
echo -e "${GREEN}✅ AArch64 toolchain installed.${RESET}"
echo -e "Toolchain version: $(aarch64-linux-gnu-gcc --version | head -n1)\n"

# ------------------------------------------------------------
# PlayStation Homebrew SDKs
# ------------------------------------------------------------
install_sdk() {
    local name=$1 repo=$2 dir=$3 install_cmd=$4
    echo -e "${CYAN}🎮 Installing ${name}...${RESET}"
    if [ -d "$dir" ]; then
        echo -e "${YELLOW}⚠️  ${name} directory exists. Skipping.${RESET}"
        return
    fi
    
    git clone --depth 1 "$repo" "$dir" || return
    cd "$dir"
    eval "$install_cmd"
    cd - >/dev/null
    echo -e "${GREEN}✅ ${name} installed.${RESET}"
}

# PSn00bSDK (PS1)
install_sdk "PS1 DevKit" "https://github.com/psn00bSDK/psn00bSDK" \
    "/opt/psn00bSDK" "make -j$(nproc) && make install"

# PS2DEV (PS2)
install_sdk "PS2 DevKit" "https://github.com/ps2dev/ps2dev" \
    "/opt/ps2dev" "mkdir build && cd build && cmake .. && make -j$(nproc)"

# PS3SDK (PS3)
install_sdk "PS3 DevKit" "https://github.com/ps3dev/PS3SDK" \
    "/opt/ps3dev" "./setup.sh"

# Orbdev (PS4)
install_sdk "PS4 DevKit" "https://github.com/orbisdev/orbisdev" \
    "/opt/orbisdev" "./build-all.sh"

# ------------------------------------------------------------
# Environment Configuration
# ------------------------------------------------------------
echo -e "\n${CYAN}🔧 Setting environment variables...${RESET}"
cat << 'EOF' >> /etc/profile.d/devkit.sh
export PS1DEV=/opt/psn00bSDK
export PS2DEV=/opt/ps2dev
export PS3DEV=/opt/ps3dev
export ORBISDEV=/opt/orbisdev
export PATH="${PATH}:${PS1DEV}/bin:${PS2DEV}/bin:${PS3DEV}/bin:${ORBISDEV}/bin"
EOF
echo -e "${GREEN}✅ Environment variables set system-wide.${RESET}\n"

# ------------------------------------------------------------
# Validation
# ------------------------------------------------------------
echo -e "${CYAN}🔍 Verifying installations...${RESET}"
{
    echo "GCC: $(gcc --version | head -n1)"
    echo "Clang: $(clang --version | head -n1)"
    echo "Rust: $(rustc --version)"
    echo "AArch64-GCC: $(aarch64-linux-gnu-gcc --version | head -n1)"
    echo "PSn00bSDK: $(test -f /opt/psn00bSDK/bin/ps-gcc && echo OK || echo MISSING)"
    echo "PS2DEV: $(test -f /opt/ps2dev/bin/ee-gcc && echo OK || echo MISSING)"
} | column -t -s:
echo -e "\n${GREEN}✅ Validation complete.${RESET}"

# Final Message
echo -e "\n${PURPLE}=============================================================${RESET}"
echo -e "${PURPLE}🎉 Installation Complete! 🎉${RESET}"
echo -e "${PURPLE}Log out and back in to ensure all environment variables are loaded.${RESET}"
echo -e "${PURPLE}=============================================================${RESET}"
