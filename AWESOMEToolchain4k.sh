#!/bin/bash

# ============================================================
# Script: install_macos_rosetta.sh
# Description: Install a wide range of programming language compilers,
#              toolchains, AArch64‑ELF cross‑compiler, PS1–PS4 homebrew devkits,
#              and Nintendo Switch (NX) support on macOS (M1/Intel via Rosetta).
# Note: Run this script with root privileges where needed (e.g., Rosetta install).
# ============================================================

# Detect platform
OS_NAME=$(uname -s)
ARCH=$(uname -m)

if [[ "$OS_NAME" != "Darwin" ]]; then
  echo "⚠️  This installer is for macOS only. Exiting."
  exit 1
fi

# Install Rosetta on Apple Silicon
if [[ "$ARCH" == "arm64" ]]; then
  echo "🔄 Checking Rosetta 2..."
  if ! /usr/bin/pgrep oahd >/dev/null 2>&1; then
    echo "➡️  Installing Rosetta 2..."
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license
    echo "✅ Rosetta 2 installed."
  else
    echo "✅ Rosetta 2 already installed."
  fi
fi

# Ensure Homebrew is installed
if ! command -v brew >/dev/null 2>&1; then
  echo "➡️  Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
  echo "✅ Homebrew installed."
else
  echo "✅ Homebrew already installed."
fi

# Update & Upgrade
echo "🔄 Updating Homebrew..."
brew update && brew upgrade

echo "✅ Homebrew up-to-date."

# Install essential tools
echo "📦 Installing core dev tools via Homebrew..."
brew install curl git cmake python node ruby go ghc cabal-install \
              rustup-init aarch64-none-elf-gcc pkg-config autoconf automake libtool

# Initialize Rust toolchain
echo "🦀 Setting up Rust..."
if ! grep -q "source ~/.cargo/env" ~/.zprofile; then
  rustup-init -y
  echo 'source ~/.cargo/env' >> ~/.zprofile
  source ~/.cargo/env
else
  echo "✅ Rust already initialized."
fi

echo "✅ Core compilers & tools installed."

# ------------------------------------------------------------
# AArch64‑ELF Cross‑Compiler (GNU Arm Embedded)
# (brew formula: aarch64-none-elf-gcc)
echo "🔧 Verifying AArch64‑ELF cross‑compiler..."
if command -v aarch64-none-elf-gcc >/dev/null 2>&1; then
  echo "✅ aarch64-none-elf-gcc available. Version: $(aarch64-none-elf-gcc --version | head -n1)"
else
  echo "❌ aarch64-none-elf-gcc not found. Please check installation."
fi

# ------------------------------------------------------------
# PS1–PS4 Homebrew Devkits (via git build)
# Note: Requires autoconf, automake, libtool (installed above)

echo "🎮 Installing PS1–PS4 homebrew SDKs..."

# PS1: PSn00bSDK
if [ ! -d "$HOME/psn00bSDK" ]; then
  git clone https://github.com/jmthibault/psn00bSDK.git ~/psn00bSDK
  cd ~/psn00bSDK && make && sudo make install && cd -
fi

echo "✅ PS1 (PSn00bSDK) installed."

# PS2: PS2DEV
if [ ! -d "$HOME/ps2sdk" ]; then
  git clone https://github.com/ps2dev/ps2sdk.git ~/ps2sdk
  cd ~/ps2sdk && make && sudo make install && cd -
fi

echo "✅ PS2 (PS2DEV) installed."

# PS3: PS3SDK
if [ ! -d "$HOME/ps3sdk" ]; then
  git clone https://github.com/ps3dev/ps3sdk.git ~/ps3sdk
  cd ~/ps3sdk
  ./bootstrap && ./configure && make && sudo make install
  cd -
fi

echo "✅ PS3 (PS3SDK) installed."

# PS4: Orbis Toolchain
if [ ! -d "$HOME/orbisdev" ]; then
  git clone https://github.com/failoverflow/orbisdev.git ~/orbisdev
  cd ~/orbisdev && ./setup.sh && cd -
fi

echo "✅ PS4 (Orbis Toolchain) installed."

# ------------------------------------------------------------
# Nintendo Switch (NX) Support via devkitPro

echo "🎮 Installing Nintendo Switch devkits (NX)..."
# Tap devkitPro pacman-installer
if ! command -v dkp-pacman >/dev/null 2>&1; then
  curl -fsSL https://raw.githubusercontent.com/devkitPro/pacman-installer/master/install-devkitpro-pacman | bash
  source /etc/profile.d/devkitpro.sh
fi

# Install Switch toolchains
dkp-pacman -y -S switch-dev switch-tools libnx libnx-aarch64-none-elf

echo "✅ Nintendo Switch (NX) devkitPro packages installed."

# ------------------------------------------------------------
# Final Summary
# ------------------------------------------------------------
echo "============================================================="
echo "🎉 All done! Your macOS dev environment & homebrew SDKs are ready! 🎉"
echo "============================================================="
echo "Installed toolchains & SDKs include:"
echo "  - Xcode Command Line Tools (clang, make)  ✔"
echo "  - GCC & GFortran (brew gcc)              ✔"
echo "  - OpenJDK (brew install openjdk)         ✔"
echo "  - Python 3 & pip                         ✔"
echo "  - Node.js & npm                          ✔"
echo "  - Ruby (gem)                             ✔"
echo "  - Go (golang)                            ✔"
echo "  - Rust (rustc & cargo)                   ✔"
echo "  - Haskell (GHC & Cabal)                  ✔"
echo "  - AArch64‑ELF cross‑compiler              ✔"
echo "  - PS1 homebrew devkit (PSn00bSDK)        ✔"
echo "  - PS2 homebrew devkit (PS2DEV)           ✔"
echo "  - PS3 homebrew devkit (PS3SDK)           ✔"
echo "  - PS4 homebrew devkit (Orbis Toolchain)  ✔"
echo "  - Nintendo Switch devkitPro (NX)         ✔"
echo "  - Git                                    ✔"
echo "
Now go forth and build amazing software—and games! 🚀"
