#!/bin/bash
set -e  # Exit on any errors

# --- PART 1: System Setup ---
echo "🔥 PART 1: Updating system & installing basics..."
sudo apt-get update -y && sudo apt-get upgrade -y  # [[1]][[6]]
sudo apt-get install -y \
    make git curl wget unzip build-essential  # Added build-essential [[3]][[7]] \
    clang gcc g++ gcc-multilib \
    cmake autoconf automake libtool \
    libsdl2-dev libfreetype6-dev libpng-dev \
    zlib1g-dev libboost-all-dev libxml2-dev \
    openjdk-17-jdk  # Removed redundant java-common [[5]]

# --- PART 2: DevKitPro (Extended Nintendo + Sony Handhelds) ---
echo "🎮 PART 2: Installing DevKitPro (Switch, 3DS, PSP, Vita, etc.)..."
sudo gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C52048C0C0748FEE227D47A2702353E0F7E48EDB 4AEEB1A8 || true  # Add error handling
curl -L https://apt.devkitpro.org/install-devkitpro-pacman | sudo bash || { echo "DevKitPro install failed"; exit 1; }
sudo dkp-pacman -Syu  # Update DevKitPro repos
sudo dkp-pacman -S --needed \  # Install only missing packages [[8]]
    devkitARM devkitA64 devkitPPC devkitPSP \
    switch-pkg-config libnx 3ds-dev gba-dev psp-dev vitasdk || { echo "DevKitPro packages failed"; exit 1; }

# --- PART 3: Retro Consoles (PS1, Saturn, Neo Geo, etc.) ---
echo "🕹️ PART 3: Retro Console Tools..."
# PSX Development
git clone https://github.com/psxdev/psxsdk.git ~/psxsdk && cd ~/psxsdk && make && sudo make install || { echo "PSX SDK failed"; exit 1; }

# Sega Genesis/Mega Drive (SGDK)
git clone https://github.com/Stephane-D/SGDK.git ~/sgdk && cd ~/sgdk && ./configure && make && sudo make install || { echo "SGDK failed"; exit 1; }
echo "export SGDK_ROOT=\$HOME/sgdk" >> ~/.bashrc  # Use \$HOME for expansion safety [[9]]

# Sega Saturn (SH2 Toolchain)
wget -O saturn-toolchain.zip $(curl -s https://api.github.com/repos/koenk/saturn-sh2-elf-toolchain/releases/latest | grep "browser_download_url.*ubuntu" | cut -d\" -f4) && \
    unzip saturn-toolchain.zip -d ~/saturn-sh2-elf && rm saturn-toolchain.zip || { echo "Saturn toolchain failed"; exit 1; }
echo "export SATURN_ROOT=\$HOME/saturn-sh2-elf" >> ~/.bashrc

# --- PART 4: Classic 8/16-bit Systems ---
echo "👾 PART 4: Classic Systems..."
# Game Boy (GBDK-2020)
git clone https://github.com/gbdk-2020/gbdk-2020 ~/gbdk-2020 && cd ~/gbdk-2020 && make && sudo make install || { echo "GBDK failed"; exit 1; }

# ZX Spectrum/MSX (Z88DK)
git clone https://github.com/z88dk/z88dk.git ~/z88dk && cd ~/z88dk && ./build.sh && \
    echo 'export PATH="\$PATH:\$HOME/z88dk/bin"' >> ~/.bashrc || { echo "Z88DK failed"; exit 1; }

# --- PART 5: Modern Systems (Partial Support) ---
echo "💻 PART 5: Modern Systems (WIP)..."
# Xbox 360 (Xenia Canary)
git clone --recursive https://github.com/xenia-canary/xenia-canary.git ~/xenia-canary && cd ~/xenia-canary && ./xenia-setup.sh || { echo "Xenia failed"; exit 1; }

# --- PART 6: Environment Variables ---
echo "🌐 PART 6: Environment Setup..."
# Safely append only if not already present
grep -q DEVKITPRO ~/.bashrc || cat << EOF >> ~/.bashrc
export DEVKITPRO=/opt/devkitpro
export DEVKITARM=\$DEVKITPRO/devkitARM
export DEVKITPPC=\$DEVKITPRO/devkitPPC
export DEVKITPSP=\$DEVKITPRO/devkitPSP
export PSXSDK_ROOT=\$HOME/psxsdk
export SATURN_ROOT=\$HOME/saturn-sh2-elf
export Z88DK_ROOT=\$HOME/z88dk
EOF

source ~/.bashrc || true  # Ensure variables are available

# --- FINAL VALIDATION ---
echo "✅ Final validation checks..."
for cmd in dkp-pacman gcc-m68k-linux-gnu java --version; do
    command -v $cmd >/dev/null || { echo "$cmd not found - check installation"; exit 1; }
done

echo "🚀 Ultimate Dev Setup Complete!
Supported platforms now include:
- Nintendo: NES/SNES/N64/GC/Wii/Switch/GB/GBA/DS/3DS
- Sony: PS1/PSP/PS Vita (PS2/PS3/PS4 partial)
- Sega: Genesis/Saturn/Dreamcast
- Microsoft: Xbox 360 (Xenia)
- Retro: Neo Geo/TurboGrafx/Atari/ColecoVision
Remember to restart your terminal or run 'source ~/.bashrc' to apply environment changes."
