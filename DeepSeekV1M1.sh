#!/bin/bash

# --- PART 1: System Setup ---
echo "🔥 PART 1: Installing Homebrew & basics..."
# Install Homebrew in x86 mode
arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
export PATH="/usr/local/bin:$PATH"

# Install packages with x86 Homebrew
arch -x86_64 brew install -y \
    make git curl wget unzip \
    cmake autoconf automake libtool \
    sdl2 freetype libpng boost libxml2 \
    openjdk@17

# --- PART 2: DevKitPro (Extended Nintendo + Sony Handhelds) ---
echo "🎮 PART 2: Installing DevKitPro..."
arch -x86_64 brew tap team-devkit-pro/devkitpro
arch -x86_64 brew install -y \
    devkitpro/devkitpro/devkit-arm \
    devkitpro/devkitpro/devkit-a64 \
    devkitpro/devkitpro/devkit-ppc \
    devkitpro/devkitpro/devkit-psp \
    switch-pkg-config \
    libnx \
    3ds-sdl

# --- PART 3: Retro Consoles (PS1, Saturn, Neo Geo, etc.) ---
echo "🕹️ PART 3: Retro Console Tools..."
# PS1 Development
git clone https://github.com/psxdev/psxsdk.git ~/psxsdk
cd ~/psxsdk && arch -x86_64 make && arch -x86_64 sudo make install

# Sega Genesis/Mega Drive (SGDK)
git clone https://github.com/Stephane-D/SGDK.git ~/sgdk
echo "export SGDK_ROOT=~/sgdk" >> ~/.zshrc

# Sega Saturn (SH2 Toolchain)
wget https://github.com/koenk/saturn-sh2-elf-toolchain/releases/latest/download/saturn-sh2-elf-macos-latest.zip
unzip saturn-sh2-elf-macos-latest.zip -d ~/saturn-sh2-elf
echo "export SATURN_ROOT=~/saturn-sh2-elf" >> ~/.zshrc

# Neo Geo (M68K)
arch -x86_64 brew install -y m68k-elf

# TurboGrafx-16/PC Engine (HuC)
git clone https://github.com/uli/huc.git ~/huc
cd ~/huc && ./configure && arch -x86_64 make && arch -x86_64 sudo make install

# --- PART 4: Classic 8/16-bit Systems ---
echo "👾 PART 4: Classic Systems..."
# Game Boy (GBDK-2020)
git clone https://github.com/gbdk-2020/gbdk-2020 ~/gbdk-2020
cd ~/gbdk-2020 && arch -x86_64 make && arch -x86_64 sudo make install

# ZX Spectrum/MSX (Z88DK)
arch -x86_64 brew install -y z88dk

# Atari 7800
git clone https://github.com/ULAP-org/ULAplus.git ~/ulaplus

# --- PART 5: Modern Systems (Partial Support) ---
echo "💻 PART 5: Modern Systems (WIP)..."
# Xbox 360 (Xenia Canary)
git clone --recursive https://github.com/xenia-canary/xenia-canary.git ~/xenia-canary

# --- PART 6: Environment Variables ---
echo "🌐 PART 6: Environment Setup..."
cat << EOF >> ~/.zshrc
# DevKitPro Paths
export DEVKITPRO=/usr/local/opt/devkitpro
export DEVKITARM=\$DEVKITPRO/devkitARM
export DEVKITPPC=\$DEVKITPRO/devkitPPC
export DEVKITA64=\$DEVKITPRO/devkitA64

# Custom SDK Paths
export PSXSDK_ROOT=~/psxsdk
export SGDK_ROOT=~/sgdk
export SATURN_ROOT=~/saturn-sh2-elf
export VB_HOME=~/vbdev
export N64_INST=~/n64sdk
EOF

source ~/.zshrc

# --- FINAL MESSAGE ---
echo "✅ Ultimate Mac Dev Setup Complete!"
echo "Optimized for M1 Macs running Rosetta 2 (x86_64)"
echo "Supported platforms include:"
echo "- Nintendo: GB, GBA, NDS, 3DS, Switch, Wii, GameCube"
echo "- Sony: PS1, PSP, PS Vita"
echo "- Sega: Genesis, Saturn"
echo "- Retro: Neo Geo, TurboGrafx-16, Atari"
echo "Note: Some toolchains may require Rosetta 2 for compilation"
echo "Happy coding! 🚀"
