#!/bin/bash

# ============================================================
# Script: test.sh (Ultimate Fucking Dev & Retro SDK Bastard)
# Description: Installs a goddamn fuckload of programming compilers,
#              AArch64‑ELF cross‑compiler, PS1–PS4 & Nintendo homebrew shit,
#              Atari & Sega junk, and retro computer emulators/devkits
#              on Ubuntu/WSL2. Fucking deal with it.
# Note: Run this shit as root, dumbass (sudo ./test.sh).
# [C] Team Flames 19XX-20XX - Fucking legends, probably. Meow!
# Optimized by your favorite fucking kitty, CATSDK! Purrrrrrr~
# ============================================================

# Exit immediately if a command exits with a non-zero status. Fuck errors.
set -euo pipefail

# Define fucking awesome text styles
BOLD="\033[1m"
RESET="\033[0m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
PURPLE="\033[1;35m"
RED="\033[1;31m"

# --- Helper Fucking Functions ---

# Function to print a fucking header
header() {
  echo -e "\n${PURPLE}>>> $1 <<<${RESET}"
}

# Function to print a fucking success message
success() {
  echo -e "${GREEN}✅ Fucking Success: $1${RESET}"
}

# Function to print a fucking warning
warning() {
  echo -e "${YELLOW}⚠️  Fucking Warning: $1${RESET}"
}

# Function to print a motherfucking error and exit
error_exit() {
  echo -e "\n${RED}💥 Motherfucking Error: $1${RESET}\n" >&2
  exit 1
}

# Function to check if running as root, 'cause you might be a fucking idiot
check_root() {
  if [ "$(id -u)" -ne 0 ]; then
    error_exit "This script needs to be run as root, you absolute fuckwit! Use 'sudo ./test.sh'."
  fi
  echo -e "${GREEN}🔑 Running with root privileges. Good fucking job for once.${RESET}"
}

# Function to install packages if they aren't already there, goddammit
install_packages() {
  local packages_to_install=()
  for pkg in "$@"; do
    if ! dpkg -s "$pkg" &> /dev/null; then
      packages_to_install+=("$pkg")
    fi
  done
  if [ ${#packages_to_install[@]} -gt 0 ]; then
    echo -e "${CYAN}🔧 Installing missing packages: ${packages_to_install[*]}...${RESET}"
    apt-get install -y "${packages_to_install[@]}" || error_exit "Failed to install packages: ${packages_to_install[*]}"
    success "Installed APT packages."
  else
    echo -e "${GREEN}✔️ Packages already installed: $@.${RESET}"
  fi
}

# Function to git clone or pull, like a fucking pro
git_clone_or_pull() {
  local repo_url="$1"
  local target_dir="$2"
  local branch="${3:-master}" # Default to master if no branch specified

  if [ -d "$target_dir/.git" ]; then
    echo -e "${CYAN}🔄 Updating git repository in $target_dir...${RESET}"
    (cd "$target_dir" && git checkout "$branch" && git pull --depth 1) || warning "Failed to update $target_dir, might be dirty or some shit."
  elif [ ! -d "$target_dir" ]; then
    echo -e "${CYAN}📥 Cloning git repository $repo_url into $target_dir...${RESET}"
    git clone --depth 1 --branch "$branch" "$repo_url" "$target_dir" || error_exit "Failed to clone $repo_url"
  else
    echo -e "${YELLOW}⚠️ Directory $target_dir exists but isn't a git repo? Skipping clone. Fix your shit.${RESET}"
  fi
}


# --- Main Fucking Script ---

check_root

# Welcome message, ain't it fucking cute? Nya~
echo -e "${PURPLE}=============================================================${RESET}"
echo -e "${PURPLE}      냥~ Welcome to the Ultimate Fucking SDK Script! ~냥    ${RESET}"
echo -e "${PURPLE} Get ready to install a shitload of dev tools & retro crap! 🚀 ${RESET}"
echo -e "${PURPLE}=============================================================${RESET}\n"

# ------------------------------------------------------------
# 1) System Update & Essential Fucking Tools
# ------------------------------------------------------------
header "1) Updating System & Installing Basic Fucking Shit"
echo -e "${CYAN}🔄 Updating package lists... Hold onto your fucking butts...${RESET}"
apt-get update || warning "apt-get update failed. Check your fucking internet/sources.list."

echo -e "${CYAN}📦 Installing essential build tools, git, curl, etc... The boring shit.${RESET}"
install_packages \
  build-essential cmake pkg-config ninja-build \
  git curl wget ca-certificates software-properties-common \
  apt-transport-https zip unzip tar gzip bzip2 p7zip-full \
  python3 python3-pip python3-venv python3-dev \
  nproc coreutils

# ------------------------------------------------------------
# 2) Modern Fucking Programming Languages
# ------------------------------------------------------------
header "2) Installing Modern Fucking Language Toolchains"

# C/C++/Fortran (GCC already part of build-essential)
echo -e "${CYAN}🔧 Installing Clang & GFortran...${RESET}"
install_packages clang gfortran
success "Clang & GFortran installed."

# Java (OpenJDK)
echo -e "${CYAN}☕ Installing Java (OpenJDK)... Might need coffee for this shit.${RESET}"
install_packages default-jdk
java -version
success "OpenJDK installed."

# Node.js & npm
echo -e "${CYAN}NODE Installing Node.js & npm... Javascript, ew.${RESET}"
install_packages nodejs npm
node -v && npm -v
success "Node.js & npm installed."

# Ruby
echo -e "${CYAN}💎 Installing Ruby... Shiny fucking gem.${RESET}"
install_packages ruby-full
ruby -v
success "Ruby installed."

# Go
echo -e "${CYAN} GO Installing Go (Golang)... Let's fucking go!${RESET}"
install_packages golang-go
go version
success "Go installed."

# Rust (via rustup) - Needs to run as the user, not root, usually. Let's try anyway.
echo -e "${CYAN}🦀 Installing Rust (rustup)... Best fucking language, purrrr~.${RESET}"
# Check if cargo exists, attempt install if not. This might need user interaction if run directly as root.
if ! command -v cargo &> /dev/null; then
  # Download and run rustup-init.sh, accepting defaults non-interactively
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
  # Source Cargo environment for *this* script execution (won't persist unless added to root's profile)
  if [ -f "/root/.cargo/env" ]; then
    source "/root/.cargo/env"
    success "Rust installed via rustup for root. Add /root/.cargo/bin to PATH if needed, or run as regular user, fuckface."
  else
     warning "Rustup installed, but couldn't find /root/.cargo/env to source immediately. Might need manual PATH setup or run install as user."
  fi
else
  success "Rust (cargo) already fucking installed."
fi
cargo --version

# Haskell
echo -e "${CYAN}λ Installing Haskell (GHC & Cabal)... Functional fucking magic.${RESET}"
install_packages ghc cabal-install
ghc --version && cabal --version
success "GHC & Cabal installed."

# ------------------------------------------------------------
# 3) AArch64‑ELF Cross‑Compiler (For bare-metal ARM64 fucking dev)
# ------------------------------------------------------------
header "3) Installing AArch64‑ELF Cross‑Compiler"
install_packages gcc-aarch64-none-elf binutils-aarch64-none-elf gdb-multiarch
echo -e "${CYAN}📝 Verifying AArch64 GCC installation:${RESET}"
aarch64-none-elf-gcc --version || warning "aarch64-none-elf-gcc not found after install attempt?"
success "AArch64‑ELF toolchain installed."

# ------------------------------------------------------------
# 4) PlayStation Fucking Homebrew Devkits (PS1-PS4)
# ------------------------------------------------------------
header "4) Installing PlayStation Homebrew SDKs (PS1-PS4) - Let's get fucking sued!"

# PS1: PSn00bSDK
install_psn00b() {
  echo -e "${CYAN}🕹️  Installing PS1 SDK (PSn00bSDK)... Old school cool.${RESET}"
  local SDK_DIR="$HOME/psn00bSDK"
  install_packages libpng-dev # Dependency
  if [ ! -d "$SDK_DIR" ]; then
    git_clone_or_pull https://github.com/Lameguy64/psn00bsdk.git "$SDK_DIR" # Using Lameguy64's fork, seems more active
    (cd "$SDK_DIR" && make && make install) || error_exit "PSn00bSDK build/install failed. Check logs, fucker."
    success "PS1 devkit (PSn00bSDK) installed to $SDK_DIR and system paths."
  else
    success "PS1 devkit (PSn00bSDK) already fucking exists at $SDK_DIR."
  fi
}

# PS2: PS2DEV
install_ps2dev() {
  echo -e "${CYAN}🕹️  Installing PS2 SDK (PS2DEV)... More fucking polygons.${RESET}"
  local PS2SDK_DIR="$HOME/ps2sdk"
  local PS2SDK_SETUP_SCRIPT="$HOME/ps2sdk-setup.sh"
  if [ ! -d "$PS2SDK_DIR" ] || [ ! -f "/usr/local/ps2dev/ps2sdk/samples/Makefile.global" ]; then # Better check
     # Install dependencies first
    install_packages automake autoconf texinfo bison flex gsl-bin \
                     libgmp-dev libmpfr-dev libmpc-dev zlib1g-dev libelf-dev \
                     patchutils wget make git texlive-fonts-recommended \
                     texlive-latex-extra imagemagick libtool-bin xorriso udisks2 # Added more deps based on ps2dev setup script
    # Get the setup script
    wget -O "$PS2SDK_SETUP_SCRIPT" https://raw.githubusercontent.com/ps2dev/ps2dev/master/ps2dev.sh
    chmod +x "$PS2SDK_SETUP_SCRIPT"
    # Execute the setup script (runs installs itself)
    "$PS2SDK_SETUP_SCRIPT" || error_exit "PS2DEV setup script failed. Good fucking luck debugging that."
    # Add environment variables setup to profile (IMPORTANT!)
    echo -e "\n# PS2DEV Environment Bullshit" >> /etc/profile.d/ps2dev.sh
    echo "export PS2SDK=/usr/local/ps2dev/ps2sdk" >> /etc/profile.d/ps2dev.sh
    echo "export GS_LIB=/usr/local/ps2dev/gs/lib" >> /etc/profile.d/ps2dev.sh
    echo "export PS2SDK_LIBS=\$PS2SDK/lib" >> /etc/profile.d/ps2dev.sh
    echo "export PS2SDK_CFLAGS=\"-I\$PS2SDK/include -I\$PS2SDK/ee/include -I\$PS2SDK/common/include -I\$GS_LIB\"" >> /etc/profile.d/ps2dev.sh
    echo "export PS2SDK_LDFLAGS=\"-L\$PS2SDK/ee/lib -L\$PS2SDK/lib\"" >> /etc/profile.d/ps2dev.sh
    echo "export PATH=\$PATH:/usr/local/ps2dev/bin:/usr/local/ps2dev/ee/bin:/usr/local/ps2dev/iop/bin:/usr/local/ps2dev/dvp/bin:\$PS2SDK/bin" >> /etc/profile.d/ps2dev.sh
    warning "PS2DEV environment variables added to /etc/profile.d/ps2dev.sh. Fucking log out and back in, or source it."
    success "PS2 devkit (PS2DEV) installed."
  else
    success "PS2 devkit (PS2DEV) seems already fucking installed."
  fi
}

# PS3: PS3SDK
install_ps3sdk() {
  echo -e "${CYAN}🕹️  Installing PS3 SDK (PS3SDK)... Even more fucking polygons, probably illegal.${RESET}"
  local SDK_DIR="$HOME/ps3sdk"
  # Install dependencies
  install_packages autoconf automake bison flex texinfo libtool-bin \
                   libncurses5-dev zlib1g-dev # Check PS3SDK docs for full list!
  if [ ! -d "$SDK_DIR" ]; then
    git_clone_or_pull https://github.com/ps3dev/ps3sdk.git "$SDK_DIR"
    (cd "$SDK_DIR" && \
     ./bootstrap && \
     ./configure --prefix=/usr/local/ps3dev && \
     make -j$(nproc) && \
     make install) || error_exit "PS3SDK build/install failed. Cry about it."
    # Add environment variables setup to profile (IMPORTANT!)
    echo -e "\n# PS3SDK Environment Bullshit" >> /etc/profile.d/ps3dev.sh
    echo "export PS3DEV=/usr/local/ps3dev" >> /etc/profile.d/ps3dev.sh
    echo "export PATH=\$PATH:\$PS3DEV/bin" >> /etc/profile.d/ps3dev.sh
    echo "export PATH=\$PATH:\$PS3DEV/ppu/bin" >> /etc/profile.d/ps3dev.sh
    echo "export PATH=\$PATH:\$PS3DEV/spu/bin" >> /etc/profile.d/ps3dev.sh
    warning "PS3SDK environment variables added to /etc/profile.d/ps3dev.sh. Fucking log out and back in, or source it."
    success "PS3 devkit (PS3SDK) installed."
  else
    success "PS3 devkit (PS3SDK) already fucking exists at $SDK_DIR."
  fi
}

# PS4: Orbis Toolchain (Experimental & requires Clang)
install_orbisdev() {
  echo -e "${CYAN}🕹️  Installing PS4 SDK (Orbis Toolchain)... Super fucking illegal? Requires modern Clang.${RESET}"
  local SDK_DIR="$HOME/orbisdev"
  # Check if Clang is installed and new enough (Orbis needs a recent version)
  if ! command -v clang &> /dev/null || ! clang --version | grep -q 'version [10-99]\.'; then
     warning "Orbis Toolchain needs a recent Clang (>= 10). Yours might be old or missing. Install it first, fuckface."
     # Attempt to install latest clang if needed
     install_packages clang llvm lld
     clang --version || error_exit "Failed to install/find recent Clang for Orbis."
  fi
  # Install dependencies
  install_packages make nasm openssl libssl-dev

  if [ ! -d "$SDK_DIR" ]; then
    git_clone_or_pull https://github.com/OpenOrbis/OpenOrbis-PS4-Toolchain.git "$SDK_DIR" # Using OpenOrbis fork
    (cd "$SDK_DIR" && make -j$(nproc) && make install) || error_exit "Orbis Toolchain build/install failed. Tough shit."
    # Add environment variables setup to profile (IMPORTANT!)
    # Check OpenOrbis docs for exact variables needed! This is a guess.
    echo -e "\n# OpenOrbis PS4 Toolchain Environment Crap" >> /etc/profile.d/orbisdev.sh
    echo "export ORBISDEV=/usr/local/orbisdev" >> /etc/profile.d/orbisdev.sh # Assuming install prefix
    echo "export PATH=\$PATH:\$ORBISDEV/bin" >> /etc/profile.d/orbisdev.sh
    warning "OpenOrbis environment variables added to /etc/profile.d/orbisdev.sh. Fucking log out/in or source it. CHECK THE FUCKING DOCS."
    success "PS4 devkit (Orbis Toolchain) installed."
  else
    success "PS4 devkit (Orbis Toolchain) already fucking exists at $SDK_DIR."
  fi
}

install_psn00b
install_ps2dev
install_ps3sdk
install_orbisdev

# ------------------------------------------------------------
# 5) Nintendo Fucking Homebrew Devkits (NES -> Switch)
# ------------------------------------------------------------
header "5) Installing Nintendo Homebrew SDKs (NES -> Switch) - More fucking lawsuits!"

# NES/Famicom: cc65 (6502 cross‑compiler)
echo -e "${CYAN}🍄 Installing NES/Famicom devkit (cc65)... Power glove!${RESET}"
install_packages cc65
cc65 --version || warning "cc65 install failed?"
success "NES/Famicom devkit (cc65) installed."

# SNES/Super Famicom: WLA-DX (Multi-arch assembler)
echo -e "${CYAN}🍄 Installing SNES devkit (wla-dx)... Mode 7, bitches!${RESET}"
install_packages wla-dx
wla-spc700 || warning "wla-dx install failed?" # Just run one command to check path
success "SNES devkit (wla-dx) installed."

# GBA / NDS / 3DS: devkitARM (via devkitPro)
install_devkitpro() {
  echo -e "${CYAN}🍄 Installing devkitPro (devkitARM for GBA/NDS/3DS, devkitPPC for GC/Wii)... The big fucking kahuna.${RESET}"
  if ! command -v dkp-pacman &> /dev/null; then
    # Install dependencies
    install_packages dialog # Needed by the installer script
    # Download and run installer
    bash <(curl -L https://raw.githubusercontent.com/devkitPro/installer/master/perl/devkitpro-install.pl) --graphics=none --installdir=/opt/devkitpro --acceptlicenses yes --norelaunch yes || error_exit "devkitPro installation script failed. Fuck."
    # Add devkitPro to PATH for everyone
    echo -e "\n# devkitPro Environment Shit" > /etc/profile.d/devkitpro.sh
    echo "export DEVKITPRO=/opt/devkitpro" >> /etc/profile.d/devkitpro.sh
    echo "export DEVKITARM=\$DEVKITPRO/devkitARM" >> /etc/profile.d/devkitpro.sh
    echo "export DEVKITPPC=\$DEVKITPRO/devkitPPC" >> /etc/profile.d/devkitpro.sh
    echo "export PATH=\$PATH:\$DEVKITPRO/tools/bin" >> /etc/profile.d/devkitpro.sh # Add tools first
    warning "devkitPro installed. Environment vars added to /etc/profile.d/devkitpro.sh. Fucking log out/in or source it."
  else
    success "devkitPro (dkp-pacman) seems already fucking installed."
  fi
  # Ensure core components are installed/updated
  echo -e "${CYAN}🔧 Ensuring core devkitPro components are installed...${RESET}"
  dkp-pacman -Syu --noconfirm \
    devkit-env devkitarm-rules devkitppc-rules \
    general-tools \
    gba-dev nds-dev \
    wii-dev gamecube-dev \
    3ds-dev \
    ctr-tools || error_exit "Failed to install/update core devkitPro packages."
  success "Core devkitPro components (ARM/PPC, GBA/NDS/GC/Wii/3DS) installed/updated."
}

install_devkitpro # Installs devkitARM and devkitPPC

# N64: libdragon
install_libdragon() {
  echo -e "${CYAN}🍄 Installing N64 SDK (libdragon)... Fucking awesome, purrrr~.${RESET}"
  local SDK_DIR="$HOME/libdragon"
  # Install dependencies (mips64 cross compiler)
  install_packages gcc-mips64-linux-gnuabi64 binutils-mips64-linux-gnuabi64
  # Also needs libaudiofile-dev, libpng-dev
  install_packages libaudiofile-dev libpng-dev

  if [ ! -d "$SDK_DIR" ]; then
    git_clone_or_pull https://github.com/DragonMinded/libdragon.git "$SDK_DIR"
    # Need to set N64_INST path for install
    export N64_INST=/usr/local/mips64-elf # Example install path
    mkdir -p $N64_INST
    echo "export N64_INST=$N64_INST" > /etc/profile.d/libdragon.sh # Save for later sessions
    echo "export PATH=\$PATH:\$N64_INST/bin" >> /etc/profile.d/libdragon.sh
    (cd "$SDK_DIR" && \
     make -j$(nproc) INST=$N64_INST && \
     make install INST=$N64_INST) || error_exit "libdragon build/install failed. What a fucking surprise."
    warning "libdragon installed. Environment vars added to /etc/profile.d/libdragon.sh. Fucking log out/in or source it."
    success "N64 devkit (libdragon) installed."
  else
    success "N64 devkit (libdragon) already fucking exists at $SDK_DIR."
  fi
}
install_libdragon

# Wii U: devkitC4 / wut (Requires devkitPPC from devkitPro)
install_wiiu_sdk() {
  echo -e "${CYAN}🍄 Installing Wii U SDK (wut)... Needs devkitPPC.${RESET}"
  if ! command -v powerpc-eabi-gcc &> /dev/null; then
    warning "devkitPPC not found in PATH. Make sure devkitPro is installed and sourced, asshole."
    # Attempt to source if file exists (might not work depending on context)
    [ -f /etc/profile.d/devkitpro.sh ] && source /etc/profile.d/devkitpro.sh
    if ! command -v powerpc-eabi-gcc &> /dev/null; then
      error_exit "Still can't find devkitPPC. Install devkitPro first, you useless fuck."
    fi
  fi
  # Install wut library
  echo -e "${CYAN}🔧 Installing wut library...${RESET}"
  dkp-pacman -S --noconfirm wut || error_exit "Failed to install wut via dkp-pacman."
  success "Wii U devkit library (wut) installed via devkitPro."
}
install_wiiu_sdk

# Switch: libnx (via devkitA64)
install_switch_sdk() {
  echo -e "${CYAN}🍄 Installing Switch SDK (devkitA64 + libnx)... Hack the fucking planet!${RESET}"
  # Ensure devkitA64 is installed via devkitPro
  if ! command -v aarch64-none-elf-gcc &> /dev/null; then # devkitA64 uses this compiler name
     warning "devkitA64 compiler not found. Attempting to install via devkitPro..."
     dkp-pacman -S --noconfirm devkita64-dev devkita64-libs devkita64-rules switch-dev switch-tools || error_exit "Failed to install devkitA64 via dkp-pacman."
     success "devkitA64 installed via devkitPro."
     # Add path potentially needed if not covered by devkitpro.sh
     echo "export PATH=\$PATH:\$DEVKITPRO/devkitA64/bin" >> /etc/profile.d/devkitpro.sh
     warning "Added devkitA64 path to devkitpro.sh. Fucking source it or relog."
  fi

  # Install libnx library via devkitPro pacman (preferred method)
  echo -e "${CYAN}🔧 Installing libnx library...${RESET}"
  dkp-pacman -S --noconfirm switch-libnx || error_exit "Failed to install libnx via dkp-pacman."
  # Set LIBNX environment variable
  echo "export LIBNX=\$DEVKITPRO/libnx" >> /etc/profile.d/devkitpro.sh # Add to devkitpro env script
  warning "LIBNX env var set in /etc/profile.d/devkitpro.sh. Fucking source it or relog."
  success "Switch devkit (libnx) installed via devkitPro."
}
install_switch_sdk

# ------------------------------------------------------------
# 6) Atari Fucking Family Devkits & Emulators (2600 -> Jaguar)
# ------------------------------------------------------------
header "6) Installing Atari Devkits & Emulators (2600 -> Jaguar) - Fucking Pong!"

# Atari 2600: DASM assembler + Stella emulator
echo -e "${CYAN}🕹️  Atari 2600... Pitfall, motherfucker!${RESET}"
install_packages dasm stella
dasm -v || warning "dasm install failed?"
stella -help || warning "stella install failed?"
success "Atari 2600 devkit (dasm) & emulator (Stella) installed."

# Atari 5200/8-bit: Atari800 emulator + CC65 (already installed)
echo -e "${CYAN}🕹️  Atari 5200/8-bit... Wood grain!${RESET}"
install_packages atari800
atari800 -help || warning "atari800 install failed?"
success "Atari 5200/8-bit emulator (atari800) installed. Use cc65 for dev."

# Atari 7800: 7800basic (bash install) + a7800 emulator (better than ProSystem?)
echo -e "${CYAN}🕹️  Atari 7800... Underrated piece of shit?${RESET}"
local SDK_DIR="$HOME/7800basic"
if [ ! -d "$SDK_DIR" ]; then
  # Install dependency: bc
  install_packages bc
  git_clone_or_pull https://github.com/7800dev/7800basic.git "$SDK_DIR"
  (cd "$SDK_DIR" && make install) || error_exit "7800basic install failed. Basic bitch."
  success "Atari 7800 devkit (7800basic) installed."
else
  success "Atari 7800 devkit (7800basic) already fucking exists at $SDK_DIR."
fi
install_packages mame # MAME includes a good 7800 emulator (a7800 driver)
success "Atari 7800 emulator via MAME installed."

# Atari Lynx: cc65 + Handy/Mednafen emulator
echo -e "${CYAN}🕹️  Atari Lynx... Weird fucking handheld.${RESET}"
install_packages mednafen # Mednafen is usually better than Handy nowadays
mednafen -h || warning "mednafen install failed?"
success "Atari Lynx emulator (Mednafen) installed. Use cc65 for dev."

# Atari Jaguar: Raptor SDK (unofficial) + Virtual Jaguar emulator
echo -e "${CYAN}🕹️  Atari Jaguar... 64-bit piece of fucking garbage!${RESET}"
local SDK_DIR="$HOME/Jaguar-Raptor"
if [ ! -d "$SDK_DIR" ]; then
  # Install dependencies (check Raptor docs!) - needs specific m68k/dsp cross-compilers usually built manually!
  warning "Atari Jaguar Raptor SDK requires manual setup of m68k-elf-gcc and other tools. This script only clones the source."
  warning "See https://github.com/BadStomach/Jaguar-Raptor for the fucking details."
  git_clone_or_pull https://github.com/BadStomach/Jaguar-Raptor.git "$SDK_DIR"
  success "Atari Jaguar devkit (Raptor source) cloned to $SDK_DIR. You build the fucking toolchain."
else
  success "Atari Jaguar devkit (Raptor source) already fucking exists at $SDK_DIR."
fi
install_packages virtualjaguar
virtualjaguar -h || warning "virtualjaguar install failed?"
success "Atari Jaguar emulator (Virtual Jaguar) installed."

# ------------------------------------------------------------
# 7) Sega Fucking Devkits & Emulators (SG-1000 -> Dreamcast)
# ------------------------------------------------------------
header "7) Installing Sega Devkits & Emulators (SG-1000 -> Dreamcast) - SEGA!"

# Master System / Game Gear: SDCC + Emulators (Gearsystem via RetroArch or dedicated)
echo -e "${CYAN}🐉 Master System / Game Gear... Needs more fucking blast processing.${RESET}"
install_packages sdcc # Z80 C Compiler
sdcc --version || warning "sdcc install failed?"
# Emulator: Use MAME or Mednafen (already installed)
success "SMS/GG devkit (SDCC) installed. Use MAME/Mednafen for emulation."

# Mega Drive / Genesis: SGDK (using Docker is easiest) or m68k-elf-gcc + BlastEm
echo -e "${CYAN}🐉 Mega Drive / Genesis... BLAST FUCKING PROCESSING!${RESET}"
install_packages gcc-m68k-linux-gnu binutils-m68k-linux-gnu # Basic cross-compiler
m68k-linux-gnu-gcc --version || warning "m68k cross-compiler failed?"
install_packages blastem
blastem -h || warning "blastem install failed?"
warning "For full Genesis dev, look into SGDK (Sega Genesis Development Kit). Docker setup is recommended: https://github.com/Stephane-D/SGDK"
success "Basic Mega Drive cross-compiler and BlastEm emulator installed."

# Sega Saturn: Yabause/Mednafen/Kronos + Jo Engine (Needs setup)
echo -e "${CYAN}🐉 Sega Saturn... Dual CPU bullshit.${RESET}"
install_packages kronos # Kronos is a modern fork/improvement over Yabause often recommended
# Or use mednafen (already installed)
kronos -h || warning "kronos install failed?"
warning "For Saturn dev, check out Jo Engine (https://jo-engine.org/) which requires a specific SH2 toolchain setup."
success "Sega Saturn emulator (Kronos / Mednafen) installed."

# Sega Dreamcast: KallistiOS + lxdream/redream/flycast
echo -e "${CYAN}🐉 Sega Dreamcast... It's thinking! (About fucking bankruptcy).${RESET}"
local KOS_DIR="$HOME/kos"
local KOS_PORTS_DIR="$HOME/kos-ports"
if [ ! -d "$KOS_DIR" ]; then
  # Install dependencies (SH4 cross-compiler, ARM cross-compiler for ARM side)
  install_packages gcc-sh4-linux-gnu binutils-sh4-linux-gnu gcc-arm-none-eabi binutils-arm-none-eabi libpng-dev libjpeg-dev
  # Clone KOS core
  git_clone_or_pull git://git.code.sf.net/p/cadcdev/kallistios "$KOS_DIR"
  # Clone KOS ports
  git_clone_or_pull git://git.code.sf.net/p/cadcdev/kos-ports "$KOS_PORTS_DIR"

  # Configure KOS environment
  (cd "$KOS_DIR" && cp doc/environ.sh.sample environ.sh) || error_exit "Failed to copy KOS environ sample."
  # !! IMPORTANT: User MUST edit $HOME/kos/environ.sh to set paths correctly !!
  warning "KallistiOS requires MANUAL EDITING of $KOS_DIR/environ.sh. Set KOS_BASE, KOS_PORTS, etc. Fucking read the comments in it!"
  # Add sourcing to profile
  echo -e "\n# KallistiOS (Dreamcast) Environment Crap" >> /etc/profile.d/kos.sh
  echo "[ -f \"$KOS_DIR/environ.sh\" ] && source \"$KOS_DIR/environ.sh\"" >> /etc/profile.d/kos.sh
  warning "Added sourcing of KOS environ.sh to /etc/profile.d/kos.sh. EDIT IT FIRST, then log out/in or source it."
  # Build KOS (after editing environ.sh and sourcing it - can't do that here easily)
  warning "You need to MANUALLY build KOS after setting up environ.sh. Run: source ~/kos/environ.sh && make -C ~/kos -j\$(nproc)"
  success "KallistiOS source cloned. EDIT $KOS_DIR/environ.sh AND BUILD IT YOURSELF, FUCKER."
else
  success "KallistiOS source already fucking exists at $KOS_DIR."
fi
install_packages flycast # Flycast is a common choice, often via RetroArch core
success "Dreamcast emulator (Flycast recommended) can be installed via RetroArch/Flatpak."

# ------------------------------------------------------------
# 8) Other Fucking Retro Computers & Emulators
# ------------------------------------------------------------
header "8) Installing Other Random Fucking Retro Emulators & Tools"

# Commodore 64: VICE & cc65 (already installed)
echo -e "${CYAN}💻 Commodore 64... Load"*",8,1${RESET}"
install_packages vice
x64 -help || warning "VICE (x64) install failed?"
success "C64 emulator (VICE) installed. Use cc65 for dev."

# ZX Spectrum: FUSE & z88dk
echo -e "${CYAN}💻 ZX Spectrum... Rubber fucking keys.${RESET}"
install_packages fuse-emulator-gtk z88dk
fuse -h || warning "FUSE install failed?"
zcc || warning "z88dk install failed?"
success "ZX Spectrum emulator (FUSE) & devkit (z88dk) installed."

# Amiga: FS-UAE + vasm/vbcc (Manual install usually)
echo -e "${CYAN}💻 Amiga... Boing ball motherfucker!${RESET}"
install_packages fs-uae fs-uae-launcher
fs-uae --help || warning "FS-UAE install failed?"
warning "For Amiga dev, get vasm and vbcc from http://sun.hasenbraten.de/vasm/ and http://www.compilers.de/vbcc/. Manual install needed, you lazy fuck."
success "Amiga emulator (FS-UAE) installed."

# Generic: MAME (Multi-Arcade Machine Emulator)
echo -e "${CYAN}💻 MAME... ALL THE FUCKING ARCADE GAMES!${RESET}"
install_packages mame mame-tools # mame-tools includes chdman etc.
mame -h || warning "MAME install failed?"
success "MAME emulator (multi-system) installed."

# MS-DOS: DOSBox-X / DOSEMU2
echo -e "${CYAN}💻 MS-DOS... C:\\>FUCK_YEAH.EXE${RESET}"
install_packages dosbox # Basic DOSBox
# DOSBox-X often needs manual build or PPA/Flatpak
# DOSEMU2 is also an option
warning "Basic DOSBox installed. For better DOS emulation/dev, check out DOSBox-X (needs PPA/build) or DOSEMU2."
success "Basic MS-DOS emulator (DOSBox) installed."

# ------------------------------------------------------------
# 9) Final Fucking Summary
# ------------------------------------------------------------
header "🎉🎉 Fucking Done! Your Goddamn Dev Environment Is Ready! 🎉🎉"
echo -e "${BOLD}Installed a shitload of stuff, including:${RESET}"
echo -e "  • Modern compilers (GCC/Clang/Rust/Go/Java/etc.)        ${GREEN}✔${RESET}"
echo -e "  • AArch64 & MIPS64 Cross-Compilers                       ${GREEN}✔${RESET}"
echo -e "  • PlayStation SDKs: PS1/PS2(env)/PS3(env)/PS4(env)       ${GREEN}✔${RESET} ${YELLOW}(Check env vars!)${RESET}"
echo -e "  • Nintendo SDKs: NES/SNES/GBA/NDS/3DS/GC/Wii/WiiU/Switch ${GREEN}✔${RESET} ${YELLOW}(Check env vars!)${RESET}"
echo -e "  • Atari SDKs: 2600/5200/7800/Lynx/Jaguar(src)           ${GREEN}✔${RESET}"
echo -e "  • Sega SDKs: SMS/GG/MD(basic)/Saturn(emu)/DC(src+env)   ${GREEN}✔${RESET} ${YELLOW}(Check env vars/build!)${RESET}"
echo -e "  • Retro Compilers: cc65, wla-dx, sdcc, z88dk             ${GREEN}✔${RESET}"
echo -e "  • Emulators: VICE, FUSE, MAME, Stella, Atari800, Mednafen,"
echo -e "    BlastEm, Kronos, VirtualJaguar, FS-UAE, DOSBox, etc.   ${GREEN}✔${RESET}"
echo -e "\n${YELLOW}⚠️  IMPORTANT FUCKING REMINDER: ⚠️${RESET}"
echo -e "${YELLOW}   Some SDKs (PS2, PS3, PS4, N64, KOS, devkitPro) added environment variables to${RESET}"
echo -e "${YELLOW}   /etc/profile.d/*.sh. You NEED TO FUCKING LOG OUT AND LOG BACK IN,${RESET}"
echo -e "${YELLOW}   or manually source the relevant /etc/profile.d/ script (e.g., 'source /etc/profile.d/devkitpro.sh').${RESET}"
echo -e "${YELLOW}   Some SDKs (KOS, Jaguar Raptor) require MANUAL setup/compilation after cloning. Read the fucking docs!${RESET}"
echo -e "\n${BOLD}${PURPLE}Now get the fuck out there and make some cool shit, Nya~! Purrrrrrrr!${RESET} ${GREEN}🚀${RESET}\n"

exit 0
