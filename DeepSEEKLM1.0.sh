#!/bin/zsh

# --- PART 0: Rosetta Check ---
# Ensure running under Rosetta 2 if needed
if [[ $(uname -m) == 'arm64' ]]; then
    echo "🛠  Running under Rosetta 2..."
    exec arch -x86_64 /bin/zsh "$0" "$@"
fi

# --- PART 1: System Setup ---
echo "🔥 PART 1: Updating system & installing basics..."
brew update
brew install -q \
    make git curl wget unzip \
    cmake autoconf automake libtool \
    sdl2 freetype libpng jpeg-turbo \
    zlib boost libxml2 \
    openjdk@17

# Set Java home (macOS specific)
export JAVA_HOME=$(/usr/libexec/java_home -v17)

# --- PART 2: DevKitPro (Nintendo/Sony Handhelds) ---
echo "🎮 PART 2: Installing DevKitPro..."
brew install --cask devkitpro/devkitten/devkitpro-pacman
sudo dkp-pacman -Syu --noconfirm
sudo dkp-pacman -S --noconfirm \
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

# --- PART 3: Retro Consoles ---
echo "🕹️ PART 3: Retro Console Tools..."
# PS1 Development
git clone https://github.com/psxdev/psxsdk.git ~/psxsdk
cd ~/psxsdk && make && sudo make install

# Sega Genesis (SGDK)
brew install libpng
git clone https://github.com/Stephane-D/SGDK.git ~/sgdk
echo "export SGDK_ROOT=~/sgdk" >> ~/.zshrc

# Sega Saturn (Cross-compiler)
brew install sh-elf-binutils sh-elf-gcc

# Neo Geo (M68K)
brew install m68k-elf-binutils m68k-elf-gcc

# TurboGrafx-16 (HuC)
git clone https://github.com/uli/huc.git ~/huc
cd ~/huc && ./configure && make && sudo make install

# --- PART 4: Classic Systems ---
echo "👾 PART 4: Classic 8/16-bit..."
# Game Boy (GBDK-2020)
brew install gbdk-2020

# ZX Spectrum/MSX
brew install z88dk

# Atari 7800 (via homebrew-core)
brew install cc65

# ColecoVision (custom install)
git clone https://github.com/sanikoyes/Colemizer.git ~/colemizer
cd ~/colemizer && make

# --- PART 5: Modern Systems ---
echo "💻 PART 5: Modern Systems (Experimental)..."
# Xenia (macOS build)
git clone https://github.com/xenia-project/xenia.git ~/xenia
cd ~/xenia && ./xenia-setup.sh

# --- PART 6: Environment Setup ---
echo "🌐 PART 6: Environment Variables..."
cat << EOF >> ~/.zshrc
# DevKitPro Paths
export DEVKITPRO=/opt/devkitpro
export DEVKITARM=\$DEVKITPRO/devkitARM
export DEVKITPPC=\$DEVKITPRO/devkitPPC

# Retro Tools
export SATURN_ROOT=/usr/local  # Homebrew SH2 tools
export PSXSDK_ROOT=~/psxsdk
export VB_HOME=~/vbdev
export DREAMCAST_ROOT=~/KallistiOS
EOF

source ~/.zshrc

# --- FINAL MESSAGE ---
echo "✅ macOS Dev Setup Complete!"
echo "Supported platforms include:"
echo "- Nintendo: GB/GBA, NDS/3DS, Switch, Wii/GC"
echo "- Sony: PS1, PSP, Vita"
echo "- Sega: Genesis, Saturn (partial)"
echo "- Retro: Neo Geo, TurboGrafx-16, Atari"
echo "Note: Some tools require manual compilation"
echo "Use 'arch -x86_64' for Rosetta 2 compatibility when needed 🍏"
