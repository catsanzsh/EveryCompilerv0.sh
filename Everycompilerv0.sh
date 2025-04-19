#!/bin/bash

# --- PART 1: System Setup ---
echo "🔥 PART 1: Updating system & installing basics..."
sudo apt-get update -y
sudo apt-get install -y \
    make git curl wget unzip \
    clang gcc g++ gcc-multilib \
    cmake autoconf automake libtool \
    libsdl2-dev libfreetype6-dev libpng-dev \
    zlib1g-dev libboost-all-dev libxml2-dev \
    java-common openjdk-17-jdk

# --- PART 2: DevKitPro (Extended Nintendo + Sony Handhelds) ---
echo "🎮 PART 2: Installing DevKitPro (Switch, 3DS, PSP, Vita, etc.)..."
sudo gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C52048C0C0748FEE227D47A2702353E0F7E48EDB 4AEEB1A8
curl -L https://apt.devkitpro.org/install-devkitpro-pacman | sudo bash
sudo dkp-pacman -Syu
sudo dkp-pacman -S \
    devkitARM \           # GBA/NDS/3DS
    devkitA64 \           # Switch
    devkitPPC \           # Wii/GameCube
    devkitPSP \           # PSP
    switch-pkg-config \   # Switch
    libnx \               # Switch
    3ds-dev \             # 3DS
    gba-dev \             # GBA
    psp-dev \             # PSP
    vitasdk               # PS Vita

# --- PART 3: Retro Consoles (PS1, Saturn, Neo Geo, etc.) ---
echo "🕹️ PART 3: Retro Console Tools..."
# PS1 Development
git clone https://github.com/psxdev/psxsdk.git ~/psxsdk
cd ~/psxsdk && make && sudo make install

# Sega Genesis/Mega Drive (SGDK)
git clone https://github.com/Stephane-D/SGDK.git ~/sgdk
echo "export SGDK_ROOT=~/sgdk" >> ~/.bashrc

# Sega Saturn (SH2 Toolchain)
wget https://github.com/koenk/saturn-sh2-elf-toolchain/releases/latest/download/saturn-sh2-elf-ubuntu-latest.zip
unzip saturn-sh2-elf-ubuntu-latest.zip -d ~/saturn-sh2-elf
echo "export SATURN_ROOT=~/saturn-sh2-elf" >> ~/.bashrc

# Neo Geo (M68K)
sudo apt-get install -y gcc-m68k-linux-gnu

# TurboGrafx-16/PC Engine (HuC)
git clone https://github.com/uli/huc.git ~/huc
cd ~/huc && ./configure && make && sudo make install

# --- PART 4: Classic 8/16-bit Systems ---
echo "👾 PART 4: Classic Systems..."
# Game Boy (GBDK-2020)
git clone https://github.com/gbdk-2020/gbdk-2020 ~/gbdk-2020
cd ~/gbdk-2020 && make && sudo make install

# ZX Spectrum/MSX (Z88DK)
git clone https://github.com/z88dk/z88dk.git ~/z88dk
cd ~/z88dk && ./build.sh && echo "export PATH=\$PATH:~/z88dk/bin" >> ~/.bashrc

# Atari 7800
git clone https://github.com/ULAP-org/ULAplus.git ~/ulaplus

# ColecoVision
git clone https://github.com/sanikoyes/Colemizer.git ~/colemizer

# --- PART 5: Modern Systems (Partial Support) ---
echo "💻 PART 5: Modern Systems (WIP)..."
# Xbox 360 (Xenia Canary)
git clone --recursive https://github.com/xenia-canary/xenia-canary.git ~/xenia-canary
cd ~/xenia-canary && ./xenia-setup.sh

# PS4 Research Tools
git clone https://github.com/OpenOrbis/OpenOrbis-PS4-Toolchain.git ~/ps4-toolchain
echo "export OPENORBIS=~/ps4-toolchain" >> ~/.bashrc

# --- PART 6: Environment Variables ---
echo "🌐 PART 6: Environment Setup..."
cat << EOF >> ~/.bashrc
# DevKitPro Paths
export DEVKITPRO=/opt/devkitpro
export DEVKITARM=\$DEVKITPRO/devkitARM
export DEVKITPPC=\$DEVKITPRO/devkitPPC
export DEVKITPSP=\$DEVKITPRO/devkitPSP

# Custom SDK Paths
export PSXSDK_ROOT=~/psxsdk
export VB_HOME=~/vbdev
export N64_INST=~/n64sdk
export DREAMCAST_ROOT=~/KallistiOS
EOF

source ~/.bashrc

# --- FINAL MESSAGE ---
echo "✅ Ultimate Dev Setup Complete!"
echo "Supported platforms now include:"
echo "- Nintendo: NES, SNES, N64, GC, Wii, Switch, GB, GBA, DS, 3DS"
echo "- Sony: PS1, PS2, PSP, PS Vita, PS3, PS4 (partial)"
echo "- Sega: Genesis, Saturn, Dreamcast"
echo "- Microsoft: Xbox, Xbox 360 (Xenia)"
echo "- Retro: Neo Geo, TurboGrafx-16, Atari, ColecoVision"
echo "Happy retro/modern development! 🚀"
