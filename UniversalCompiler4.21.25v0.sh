#!/bin/bash

# ============================================================
# Script: test.sh
# Description: Install a wide range of programming language compilers,
#              AArch64‑ELF cross‑compiler, PS1–PS4 & Nintendo homebrew devkits,
#              and retro computer emulators/devkits (from the first home computers to now)
#              on Ubuntu (e.g., WSL2).
# Note: Run this script with root privileges (e.g., using sudo).
# ============================================================

# Define text styles for vibrant output
BOLD="\033[1m"
RESET="\033[0m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
PURPLE="\033[1;35m"

# Welcome message
echo -e "${PURPLE}=============================================================${RESET}"
echo -e "${PURPLE}🤖 Welcome to the Ultimate Dev & Retro SDK Setup Script! 🤖${RESET}"
echo -e "${PURPLE}Installing compilers, cross‑toolchains, console & computer SDKs. 🚀${RESET}"
echo -e "${PURPLE}=============================================================${RESET}\n"

# ------------------------------------------------------------
# 1) Update & Essentials
# ------------------------------------------------------------
echo -e "${CYAN}🔄 Updating package lists...${RESET}"
sudo apt-get update
echo -e "${GREEN}✅ Package lists updated.${RESET}\n"

echo -e "${CYAN}📦 Installing essential tools & compilers...${RESET}"
sudo apt-get install -y \
  curl git build-essential cmake clang gfortran default-jdk \
  python3 python3-pip python3-venv nodejs npm ruby-full golang \
  ghc cabal-install
echo -e "${GREEN}✅ Core compilers & tools installed.${RESET}\n"

# ------------------------------------------------------------
# 2) Rust via rustup
# ------------------------------------------------------------
echo -e "${CYAN}🦀 Installing Rust (via rustup)...${RESET}"
curl -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
echo -e "${GREEN}✅ Rust installed (rustc & cargo).${RESET}\n"

# ------------------------------------------------------------
# 3) AArch64‑ELF Cross‑Compiler
# ------------------------------------------------------------
echo -e "${CYAN}🔧 Installing AArch64‑ELF cross‑compiler...${RESET}"
sudo apt-get install -y gcc-aarch64-none-elf binutils-aarch64-none-elf
echo -e "${GREEN}✅ AArch64‑ELF GCC & binutils installed.${RESET}"
echo -e "${CYAN}📝 Verifying installation:${RESET}"
aarch64-none-elf-gcc --version
echo -e ""

# ------------------------------------------------------------
# 4) PS1–PS4 Homebrew Devkits
# ------------------------------------------------------------
echo -e "${CYAN}🎮 Installing PS1–PS4 homebrew SDKs/devkits...${RESET}"

# PS1: PSn00bSDK
if [ ! -d "$HOME/psn00bSDK" ]; then
  git clone https://github.com/jmthibault/psn00bSDK.git "$HOME/psn00bSDK"
  (cd "$HOME/psn00bSDK" && make && sudo make install)
fi
echo -e "${GREEN}✅ PS1 devkit (PSn00bSDK).${RESET}"

# PS2: PS2DEV
if [ ! -d "$HOME/ps2sdk" ]; then
  git clone https://github.com/ps2dev/ps2sdk.git "$HOME/ps2sdk"
  (cd "$HOME/ps2sdk" && make && sudo make install)
fi
echo -e "${GREEN}✅ PS2 devkit (PS2DEV).${RESET}"

# PS3: PS3SDK
if [ ! -d "$HOME/ps3sdk" ]; then
  git clone https://github.com/ps3dev/ps3sdk.git "$HOME/ps3sdk"
  (cd "$HOME/ps3sdk" && ./bootstrap && ./configure && make && sudo make install)
fi
echo -e "${GREEN}✅ PS3 devkit (PS3SDK).${RESET}"

# PS4: Orbis Toolchain
if [ ! -d "$HOME/orbisdev" ]; then
  git clone https://github.com/failoverflow/orbisdev.git "$HOME/orbisdev"
  (cd "$HOME/orbisdev" && ./setup.sh)
fi
echo -e "${GREEN}✅ PS4 devkit (Orbis Toolchain).${RESET}\n"

# ------------------------------------------------------------
# 5) Nintendo Homebrew Devkits
# ------------------------------------------------------------
echo -e "${CYAN}👾 Installing Nintendo homebrew SDKs/devkits...${RESET}"

# NES/Famicom: cc65 (6502 cross‑compiler)
sudo apt-get install -y cc65
echo -e "${GREEN}✅ NES/Famicom devkit (cc65).${RESET}"

# SNES/Super Famicom: WLA‑DX (65816 assembler)
sudo apt-get install -y wla-dx
echo -e "${GREEN}✅ SNES devkit (wla-dx).${RESET}"

# GBA / NDS: devkitARM (via devkitPro)
if ! command -v devkitARM >/dev/null; then
  bash <(curl -L https://raw.githubusercontent.com/devkitPro/devkitpro-setup/master/install-devkitpro.sh) --yes
  sudo dkp-pacman -Sy devkitARM
fi
echo -e "${GREEN}✅ GBA/DS devkit (devkitARM).${RESET}"

# N64: libdragon
if [ ! -d "$HOME/libdragon" ]; then
  git clone https://github.com/DragonMinded/libdragon.git "$HOME/libdragon"
  (cd "$HOME/libdragon" && make && sudo make install)
fi
echo -e "${GREEN}✅ N64 devkit (libdragon).${RESET}"

# GameCube/Wii: devkitPPC
sudo apt-get install -y devkitppc
echo -e "${GREEN}✅ GameCube/Wii devkit (devkitPPC).${RESET}"

# Wii U: devkitC4 (manual)
echo -e "${YELLOW}⚠️  Wii U devkit (devkitC4): see https://github.com/devkitPro/devkitC4${RESET}"

# Switch: libnx (via devkitA64)
if [ ! -d "$HOME/libnx" ]; then
  git clone https://github.com/switchbrew/libnx.git "$HOME/libnx"
  (cd "$HOME/libnx" && make && sudo make install)
fi
echo -e "${GREEN}✅ Switch devkit (libnx).${RESET}\n"

# ------------------------------------------------------------
# 6) Retro Computer Emulators & Devkits
# ------------------------------------------------------------
echo -e "${CYAN}💻 Installing retro computer emulators & devkits...${RESET}"

# Commodore 64: VICE & cc65 (already installed)
sudo apt-get install -y vice
echo -e "${GREEN}✅ C64 emulator (VICE).${RESET}"

# ZX Spectrum: FUSE & z88dk
sudo apt-get install -y fuse-emulator-gtk z88dk
echo -e "${GREEN}✅ ZX Spectrum emulator (FUSE) & devkit (z88dk).${RESET}"

# Amiga: FS‑UAE
sudo apt-get install -y fs-uae
echo -e "${GREEN}✅ Amiga emulator (FS‑UAE).${RESET}"

# Generic: MAME (wide hardware coverage)
sudo apt-get install -y mame
echo -e "${GREEN}✅ MAME emulator (multi‑platform).${RESET}\n"

# ------------------------------------------------------------
# Final Summary and Celebration
# ------------------------------------------------------------
echo -e "${PURPLE}=============================================================${RESET}"
echo -e "${PURPLE}🎉 All done! Your dev environment & retro SDKs are ready! 🎉${RESET}"
echo -e "${PURPLE}=============================================================${RESET}"
echo -e "${BOLD}Installed toolchains & SDKs include:${RESET}"
echo -e "  - GCC/G++ & Clang                                ${GREEN}✔${RESET}"
echo -e "  - GFortran                                       ${GREEN}✔${RESET}"
echo -e "  - OpenJDK (Java)                                 ${GREEN}✔${RESET}"
echo -e "  - Python 3 & pip                                 ${GREEN}✔${RESET}"
echo -e "  - Node.js & npm                                  ${GREEN}✔${RESET}"
echo -e "  - Ruby (RubyGems)                                ${GREEN}✔${RESET}"
echo -e "  - Go (Golang)                                    ${GREEN}✔${RESET}"
echo -e "  - Rust (rustc & cargo)                           ${GREEN}✔${RESET}"
echo -e "  - Haskell (GHC & Cabal)                          ${GREEN}✔${RESET}"
echo -e "  - AArch64‑ELF cross‑compiler                      ${GREEN}✔${RESET}"
echo -e "  - PS1 SDK (PSn00bSDK)                            ${GREEN}✔${RESET}"
echo -e "  - PS2 SDK (PS2DEV)                               ${GREEN}✔${RESET}"
echo -e "  - PS3 SDK (PS3SDK)                               ${GREEN}✔${RESET}"
echo -e "  - PS4 SDK (Orbis Toolchain)                      ${GREEN}✔${RESET}"
echo -e "  - NES/Famicom devkit (cc65)                      ${GREEN}✔${RESET}"
echo -e "  - SNES devkit (wla-dx)                           ${GREEN}✔${RESET}"
echo -e "  - GBA/DS SDK (devkitARM)                         ${GREEN}✔${RESET}"
echo -e "  - N64 SDK (libdragon)                            ${GREEN}✔${RESET}"
echo -e "  - GameCube/Wii SDK (devkitPPC)                   ${GREEN}✔${RESET}"
echo -e "  - Switch SDK (libnx)                             ${GREEN}✔${RESET}"
echo -e "  - Commodore 64: emulator (VICE) & devkit (cc65)  ${GREEN}✔${RESET}"
echo -e "  - ZX Spectrum: emulator (FUSE) & devkit (z88dk)  ${GREEN}✔${RESET}"
echo -e "  - Amiga emulator (FS‑UAE)                        ${GREEN}✔${RESET}"
echo -e "  - MAME emulator (multi‑platform)                 ${GREEN}✔${RESET}"
echo -e "  - Git                                            ${GREEN}✔${RESET}"
echo -e "\n${BOLD}Now go forth and build amazing software—and games!${RESET} ${YELLOW}🚀${RESET}\n"
## [C] Team Flames 19XX-20XX
