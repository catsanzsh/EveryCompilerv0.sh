#!/bin/bash

# --- PART 1: System Setup ---
echo "🔥 PART 1: Updating system & installing basics..."
sudo apt-get update -y
sudo apt-get install -y \
    make git curl wget \
    clang gcc g++ \
    cmake autoconf automake \
    libsdl2-dev libfreetype6-dev \
    zlib1g-dev libpng-dev

# --- PART 2: DevKitPro (Nintendo + more) ---
echo "🎮 PART 2: Installing DevKitPro (Switch, 3DS, GBA, etc.)..."
sudo gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C52048C0C0748FEE227D47A2702353E0F7E48EDB 4AEEB1A8
curl -L https://apt.devkitpro.org/install-devkitpro-pacman | sudo bash
sudo dkp-pacman -Syu
sudo dkp-pacman -S \
    devkitARM \          # GBA, NDS, 3DS
    devkitA64 \          # Switch
    devkitPPC \          # Wii, GameCube
    switch-pkg-config \  # Switch tools
    libnx \              # Switch libs
    3ds-dev \            # 3DS tools
    gba-dev              # GBA tools

# --- PART 3: Retro Consoles (PS1, PS2, N64, etc.) ---
echo "🕹️ PART 3: Retro Console Tools..."
# PS2 (PS2DEV)
git clone https://github.com/ps2dev/ps2dev.git ~/ps2dev
cd ~/ps2dev && ./setup.sh

# N64 (libdragon)
git clone https://github.com/DragonMinded/libdragon.git ~/libdragon
cd ~/libdragon && make install

# Dreamcast (KallistiOS)
git clone https://github.com/KallistiOS/KallistiOS.git ~/KallistiOS
cd ~/KallistiOS && make setup

# --- PART 4: Modern Consoles (PS3, PS4, PS5-ish, Xbox) ---
echo "💿 PART 4: Modern Console Tools (WIP/Partial Support)..."
# PS3 (PS3DEV - unofficial)
git clone https://github.com/ps3dev/ps3toolchain.git ~/ps3toolchain
cd ~/ps3toolchain && ./toolchain.sh

# Xbox (Xenia - emulator, but has dev tools)
git clone --recursive https://github.com/xenia-project/xenia.git ~/xenia
cd ~/xenia && ./xenia-setup.sh

# --- PART 5: Classic (Atari, NES, SNES) ---
echo "📺 PART 5: Classic 8/16-bit Tools..."
# NES (cc65)
sudo apt-get install -y cc65

# Atari 2600 (dasm)
git clone https://github.com/dasm-assembler/dasm.git ~/dasm
cd ~/dasm && make && sudo make install

# SNES (WLA-DX)
git clone https://github.com/vhelin/wla-dx.git ~/wla-dx
cd ~/wla-dx && cmake . && make && sudo make install

# --- PART 6: Environment Variables ---
echo "🌍 PART 6: Setting up environment..."
echo "export DEVKITPRO=/opt/devkitpro" >> ~/.bashrc
echo "export DEVKITARM=/opt/devkitpro/devkitARM" >> ~/.bashrc
echo "export DEVKITPPC=/opt/devkitpro/devkitPPC" >> ~/.bashrc
echo "export PS2DEV=~/ps2dev" >> ~/.bashrc
echo "export KOS_ROOT=~/KallistiOS" >> ~/.bashrc

source ~/.bashrc

# --- DONE ---
echo "✅ DONE! VIBE CHECK PASSED."
echo "Now go make some ROMs, homebrew, or chaos. 🚀"
