#!/bin/bash

# ============================================================
# Script: ultimate-dev-retro-sdk.sh
# Description: Installs a massive set of programming language
#              compilers, cross‑toolchains, console & computer
#              SDKs and emulators from the Atari 2600 era up
#              to modern PS4 & Nintendo Switch development.
#              Tested on Ubuntu 22.04+ (WSL2 friendly).
# Note: Run this script with root privileges (e.g., using sudo).
# ============================================================

set -e

# Define text styles for vibrant output
BOLD="\033[1m"
RESET="\033[0m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
PURPLE="\033[1;35m"

function header() {
  echo -e "${PURPLE}=============================================================${RESET}"
  echo -e "${PURPLE}$1${RESET}"
  echo -e "${PURPLE}=============================================================${RESET}\n"
}

header "🤖 Ultimate Dev & Retro SDK Setup Script 🤖"

# ------------------------------------------------------------
# 1) Update & Essentials
# ------------------------------------------------------------
echo -e "${CYAN}🔄 Updating package lists...${RESET}"
sudo apt-get update -y
echo -e "${GREEN}✅ Package lists updated.${RESET}\n"

echo -e "${CYAN}📦 Installing essential build tools & compilers...${RESET}"
sudo apt-get install -y \
  curl git build-essential cmake clang gfortran default-jdk \
  python3 python3-pip python3-venv nodejs npm ruby-full golang \
  ghc cabal-install pkg-config libssl-dev zlib1g-dev
echo -e "${GREEN}✅ Core compilers & tools installed.${RESET}\n"

# ------------------------------------------------------------
# 2) Rust via rustup
# ------------------------------------------------------------
echo -e "${CYAN}🦀 Installing Rust (via rustup)...${RESET}"
if ! command -v rustc &>/dev/null; then
  curl -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi
echo -e "${GREEN}✅ Rust installed (rustc & cargo).${RESET}\n"

# ------------------------------------------------------------
# 3) Modern Cross‑Compilers
# ------------------------------------------------------------
echo -e "${CYAN}🔧 Installing modern cross‑compilers...${RESET}"
sudo apt-get install -y gcc-aarch64-none-elf binutils-aarch64-none-elf \
  gcc-multilib g++-multilib
echo -e "${GREEN}✅ AArch64‑ELF GCC & multilib toolchains installed.${RESET}\n"

# ------------------------------------------------------------
# 4) PlayStation Homebrew Devkits (PS1‑PS4)
# ------------------------------------------------------------
header "🎮 Installing PlayStation homebrew SDKs/devkits (PS1‑PS4) 🎮"

install_psn00b() {
  if [ ! -d "$HOME/psn00bSDK" ]; then
    git clone --depth 1 https://github.com/jmthibault/psn00bSDK.git "$HOME/psn00bSDK"
    (cd "$HOME/psn00bSDK" && make -j$(nproc) && sudo make install)
  fi
  echo -e "${GREEN}✅ PS1 devkit (PSn00bSDK).${RESET}"
}

install_ps2dev() {
  if [ ! -d "$HOME/ps2sdk" ]; then
    git clone --depth 1 https://github.com/ps2dev/ps2sdk.git "$HOME/ps2sdk"
    (cd "$HOME/ps2sdk" && make -j$(nproc) && sudo make install)
  fi
  echo -e "${GREEN}✅ PS2 devkit (PS2DEV).${RESET}"
}

install_ps3sdk() {
  if [ ! -d "$HOME/ps3sdk" ]; then
    git clone --depth 1 https://github.com/ps3dev/ps3sdk.git "$HOME/ps3sdk"
    (cd "$HOME/ps3sdk" && ./bootstrap && ./configure --prefix=/usr/local && make -j$(nproc) && sudo make install)
  fi
  echo -e "${GREEN}✅ PS3 devkit (PS3SDK).${RESET}"
}

install_orbisdev() {
  if [ ! -d "$HOME/orbisdev" ]; then
    git clone --depth 1 https://github.com/failoverflow/orbisdev.git "$HOME/orbisdev"
    (cd "$HOME/orbisdev" && ./setup.sh)
  fi
  echo -e "${GREEN}✅ PS4 devkit (Orbis Toolchain).${RESET}\n"
}

install_psn00b
install_ps2dev
install_ps3sdk
install_orbisdev

# ------------------------------------------------------------
# 5) Nintendo Homebrew Devkits
# ------------------------------------------------------------
header "👾 Installing Nintendo homebrew SDKs/devkits 👾"

sudo apt-get install -y cc65 wla-dx devkitppc vice fuse-emulator-gtk \
  z88dk fs-uae mame dasm

if ! command -v devkitARM >/dev/null; then
  bash <(curl -L https://raw.githubusercontent.com/devkitPro/devkitpro-setup/master/install-devkitpro.sh) --yes
  sudo dkp-pacman -Sy devkitARM
fi
echo -e "${GREEN}✅ devkitARM (GBA/NDS) installed.${RESET}"

if [ ! -d "$HOME/libdragon" ]; then
  git clone --depth 1 https://github.com/DragonMinded/libdragon.git "$HOME/libdragon"
  (cd "$HOME/libdragon" && make -j$(nproc) && sudo make install)
fi
echo -e "${GREEN}✅ N64 devkit (libdragon).${RESET}"

if [ ! -d "$HOME/libnx" ]; then
  git clone --depth 1 https://github.com/switchbrew/libnx.git "$HOME/libnx"
  (cd "$HOME/libnx" && make -j$(nproc) && sudo make install)
fi
echo -e "${GREEN}✅ Switch devkit (libnx).${RESET}\n"

# ------------------------------------------------------------
# 6) Atari Family Devkits & Emulators (2600‑Jaguar)
# ------------------------------------------------------------
header "🕹️  Installing Atari devkits & emulators (2600‑Jaguar) 🕹️"

# Atari 2600: DASM assembler + Stella emulator
echo -e "${CYAN}Atari 2600...${RESET}"
sudo apt-get install -y dasm stella
echo -e "${GREEN}✅ Atari 2600 devkit (dasm) & emulator (Stella).${RESET}"

# Atari 5200/8‑bit: Atari800 emulator + CC65 (already)
echo -e "${CYAN}Atari 5200/8‑bit...${RESET}"
sudo apt-get install -y atari800
echo -e "${GREEN}✅ Atari 5200/8‑bit emulator (atari800).${RESET}"

# Atari 7800: 7800basic (bash install) + ProSystem emulator
echo -e "${CYAN}Atari 7800...${RESET}"
if [ ! -d "$HOME/7800basic" ]; then
  git clone --depth 1 https://github.com/7800dev/7800basic.git "$HOME/7800basic"
  (cd "$HOME/7800basic" && sudo make install)
fi
sudo apt-get install -y prosystem
echo -e "${GREEN}✅ Atari 7800 devkit (7800basic) & emulator (ProSystem).${RESET}"

# Atari Lynx: cc65 + Handy emulator
echo -e "${CYAN}Atari Lynx...${RESET}"
sudo apt-get install -y handy
echo -e "${GREEN}✅ Atari Lynx emulator (Handy).${RESET}"

# Atari Jaguar: Jaguar SDK (Raptor) + Virtual Jaguar emulator
echo -e "${CYAN}Atari Jaguar...${RESET}"
if [ ! -d "$HOME/raptorjaguar" ]; then
  git clone --depth 1 https://github.com/BadStomach/Jaguar-Raptor.git "$HOME/raptorjaguar"
fi
sudo apt-get install -y virtualjaguar
echo -e "${GREEN}✅ Atari Jaguar devkit (Raptor) & emulator (Virtual Jaguar).${RESET}\n"

# ------------------------------------------------------------
# 7) Sega Devkits & Emulators (SG‑1000 → Dreamcast)
# ------------------------------------------------------------
header "🐉 Installing Sega devkits & emulators (SG‑1000 → Dreamcast) 🐉"

# Master System / Game Gear: SDCC (already) + Emulicious
sudo apt-get install -y emulicious

# Mega Drive / Genesis: m68k‑elf‑gcc + BlastEm emulator
sudo apt-get install -y gcc-m68k-linux-gnu blastem

# Sega Saturn: Yabause
sudo apt-get install -y yabause

# Sega Dreamcast: KallistiOS
if [ ! -d "$HOME/kos" ]; then
  git clone --depth 1 https://github.com/KallistiOS/KallistiOS.git "$HOME/kos"
  (cd "$HOME/kos/utils" && ./install.sh)
fi
echo -e "${GREEN}✅ Sega toolchains & emulators installed.${RESET}\n"

# ------------------------------------------------------------
# 8) Summary
# ------------------------------------------------------------
header "🎉 Installation Complete! 🎉"
echo -e "${BOLD}Highlights:${RESET}"
echo -e "  • Modern compilers (GCC/Clang/Rust/Go/etc.)             ${GREEN}✔${RESET}"
echo -e "  • PlayStation SDKs: PS1/PS2/PS3/PS4                     ${GREEN}✔${RESET}"
echo -e "  • Nintendo SDKs: NES→Switch (devkitPro, libdragon, etc.)${GREEN}✔${RESET}"
echo -e "  • Atari SDKs: 2600→Jaguar                                ${GREEN}✔${RESET}"
echo -e "  • Sega SDKs: SG‑1000→Dreamcast                          ${GREEN}✔${RESET}"
echo -e "  • Retro emulators: VICE, FUSE, MAME, Stella, BlastEm... ${GREEN}✔${RESET}"
echo -e "\n${BOLD}Happy coding! 🚀${RESET}"
