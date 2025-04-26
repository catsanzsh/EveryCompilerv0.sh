#!/usr/bin/env bash
# ============================================================
# Script: test.sh – Ultimate Retro‑to‑Modern Toolchain Installer (optimized)
# Author: ChatGPT (2025‑04‑25)
# Description:
#   Installs and lightly self‑tests a broad set of open‑source
#   console/computer toolchains and SDKs on Ubuntu 22.04+ (WSW2)
#   without using Git, relying on curl for downloads.
#   Supports selective installation, fast mode, custom prefix,
#   and parallel builds.
#   Note: Some modules may require Git submodules and might
#   fail to build without them.
# ============================================================
set -euo pipefail
IFS=$'\n\t'

# -----------------------------------------------------------------------------
# Pretty colours
# -----------------------------------------------------------------------------
BOLD="\033[1m"; RED="\033[0;31m"; GRN="\033[0;32m"; YLW="\033[1;33m";
CYN="\033[1;36m"; MAG="\033[1;35m"; RST="\033[0m"
msg()  { printf "%b\n" "${CYN}▶ $*${RST}"; }
ok()   { printf "%b\n" "${GRN}✓ $*${RST}"; }
warn() { printf "%b\n" "${YLW}⚠ $*${RST}"; }
err()  { printf "%b\n" "${RED}✖ $*${RST}" >&2; }
trap 'err "Error on line ${LINENO}. Exit $?"' ERR

# -----------------------------------------------------------------------------
# Globals & defaults
# -----------------------------------------------------------------------------
PREFIX="/opt"
JOBS="$(nproc)"
FAST=0
TARGETS=()
LOGFILE="/var/log/toolchain_installer.log"

# Supported modules
MODULES=(cc65 sdcc z88dk devkitpro psn00b ps2dev pspdev ps3dev ps4dev vitadev n64 gendev saturn kos nxdk openwatcom simh arm_gcc arduino_cli esp_idf)

# -----------------------------------------------------------------------------
# Usage
# -----------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage: $0 [options] [modules]
Options:
  -h|--help         Show this help and exit
  -f|--fast         Skip heavy source builds (use packages where possible)
  -p|--prefix DIR   Install prefix (default: ${PREFIX})
  -j|--jobs N       Parallel jobs (default: nproc)
  --list            List available modules and exit
Modules:
  Comma-separated list or multiple args (default: all)
  Available: ${MODULES[*]}
EOF
  exit 1
}

# -----------------------------------------------------------------------------
# Argument parsing
# -----------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage ;;      
    -f|--fast) FAST=1; shift ;;    
    -p|--prefix) PREFIX="$2"; shift 2 ;;    
    -j|--jobs) JOBS="$2"; shift 2 ;;    
    --list) echo "Available modules: ${MODULES[*]}"; exit 0 ;;    
    *) TARGETS+=("$1"); shift ;;    
  esac
done

# Default to all if none specified
if [[ ${#TARGETS[@]} -eq 0 ]]; then
  TARGETS=("${MODULES[@]}")
else
  # Expand comma-separated in each element
  expanded=()
  for t in "${TARGETS[@]}"; do
    IFS=',' read -ra parts <<< "$t"
    for p in "${parts[@]}"; do
      expanded+=("$p")
    done
  done
  TARGETS=("${expanded[@]}")
fi

# Log output
exec > >(tee -a "$LOGFILE") 2>&1
msg "Logging to $LOGFILE"

# Ensure sudo/root
if (( EUID != 0 )); then
  warn "Re‑running with sudo …"
  exec sudo -E "$0" "$@"
fi

# -----------------------------------------------------------------------------
# Helper: download and extract tarball
# -----------------------------------------------------------------------------
download_and_extract() {
  local url="$1"
  local target_dir="$2"
  local temp_dir=$(mktemp -d)
  local tarball=$(mktemp)

  msg "Downloading $url to $target_dir …"
  curl -fsSL "$url" -o "$tarball" || err "Failed to download $url"
  tar -xzf "$tarball" -C "$temp_dir" || err "Failed to extract tarball"

  # Find the top-level directory
  local extracted_dir=$(ls -1 "$temp_dir" | head -n1)
  if [ -z "$extracted_dir" ]; then
    err "No directory found in tarball"
  fi

  # Remove existing target directory if it exists
  if [ -d "$target_dir" ]; then
    rm -rf "$target_dir"
  fi

  # Move the extracted directory to target
  mv "$temp_dir/$extracted_dir" "$target_dir" || err "Failed to move extracted directory"

  # Clean up
  rm -rf "$temp_dir"
  rm "$tarball"
  ok "Extracted to $target_dir"
}

# -----------------------------------------------------------------------------
# Individual install functions
# -----------------------------------------------------------------------------
install_cc65() {
  msg "Installing cc65 …"
  apt-get install -y cc65 >/dev/null
  ok "cc65 $(cc65 --version | head -n1)"
}

install_sdcc() {
  msg "Installing SDCC …"
  apt-get install -y sdcc >/dev/null
  ok "SDCC $(sdcc --version | head -n1)"
}

install_z88dk() {
  msg "Installing z88dk via apt-get …"
  apt-get install -y z88dk >/dev/null
  ok "z88dk installed"
}

install_devkitpro() {
  msg "Installing devkitPro …"
  if ! command -v dkp-pacman &>/dev/null; then
    echo "deb [arch=amd64] https://downloads.devkitpro.org/packages/debian/ /" > /etc/apt/sources.list.d/devkitpro.list
    curl -fsSL https://downloads.devkitpro.org/devkitpro-pub.gpg | gpg --dearmor -o /usr/share/keyrings/devkitpro.gpg
    apt-get update -qq
    apt-get install -y devkitpro-pacman
  fi
  dkp-pacman -Syu --noconfirm gba-dev nds-dev 3ds-dev gamecube-dev wii-dev switch-dev
  ok "devkitPro toolchains installed"
}

install_psn00b() {
  [[ $FAST -eq 1 ]] && { msg "Skipping psn00b build (fast mode)"; return; }
  local url="https://github.com/Lameguy64/PSn00bSDK/archive/refs/heads/master.tar.gz"
  download_and_extract "$url" "$PREFIX/psn00b"
  pushd "$PREFIX/psn00b" >/dev/null
  cmake . && make -j"$JOBS" && ok "PSn00b SDK built" || err "PSn00b build failed"
  popd >/dev/null
}

install_ps2dev() {
  [[ $FAST -eq 1 ]] && { msg "Skipping ps2dev build (fast mode)"; return; }
  local url="https://github.com/ps2dev/ps2dev/archive/refs/heads/main.tar.gz"
  download_and_extract "$url" "$PREFIX/ps2dev"
  pushd "$PREFIX/ps2dev" >/dev/null
  ./install.sh && ok "PS2Dev installed" || warn "PS2Dev install may have failed (submodules not included)"
  popd >/dev/null
}

install_pspdev() {
  [[ $FAST -eq 1 ]] && { msg "Skipping pspdev build (fast mode)"; return; }
  local url="https://github.com/pspdev/pspdev/archive/refs/heads/main.tar.gz"
  download_and_extract "$url" "$PREFIX/pspdev"
  pushd "$PREFIX/pspdev" >/dev/null
  ./build.sh && ok "PSPDev installed" || warn "PSPDev install may have failed (submodules not included)"
  popd >/dev/null
}

install_ps3dev() {
  [[ $FAST -eq 1 ]] && { msg "Skipping ps3dev build (fast mode)"; return; }
  local url="https://github.com/ps3dev/PS3SDK/archive/refs/heads/master.tar.gz"
  download_and_extract "$url" "$PREFIX/ps3dev"
  pushd "$PREFIX/ps3dev" >/dev/null
  make -j"$JOBS" && ok "PS3Dev installed" || err "PS3Dev install failed"
  popd >/dev/null
}

install_ps4dev() {
  [[ $FAST -eq 1 ]] && { msg "Skipping ps4dev build (fast mode)"; return; }
  local url="https://github.com/OpenOrbis/PS4-SDK/archive/refs/heads/main.tar.gz"
  download_and_extract "$url" "$PREFIX/ps4dev"
  pushd "$PREFIX/ps4dev" >/dev/null
  make -j"$JOBS" && ok "PS4Dev installed" || err "PS4Dev install failed"
  popd >/dev/null
}

install_vitadev() {
  [[ $FAST -eq 1 ]] && { msg "Skipping vitadev build (fast mode)"; return; }
  local url="https://github.com/vitasdk/vita-headers/archive/refs/heads/master.tar.gz"
  download_and_extract "$url" "$PREFIX/vitadev"
  pushd "$PREFIX/vitadev" >/dev/null
  make -j"$JOBS" && ok "VitaDev installed" || err "VitaDev install failed"
  popd >/dev/null
}

install_n64() {
  [[ $FAST -eq 1 ]] && { msg "Skipping n64 build (fast mode)"; return; }
  local url="https://github.com/n64-tools/n64-sdk/archive/refs/heads/main.tar.gz"
  download_and_extract "$url" "$PREFIX/n64"
  pushd "$PREFIX/n64" >/dev/null
  make -j"$JOBS" && ok "N64 SDK installed" || err "N64 SDK install failed"
  popd >/dev/null
}

install_gendev() {
  [[ $FAST -eq 1 ]] && { msg "Skipping gendev build (fast mode)"; return; }
  local url="https://github.com/kubilus1/gendev/archive/refs/heads/master.tar.gz"
  download_and_extract "$url" "$PREFIX/gendev"
  pushd "$PREFIX/gendev" >/dev/null
  make -j"$JOBS" && ok "Sega Genesis Dev installed" || err "Sega Genesis Dev install failed"
  popd >/dev/null
}

install_saturn() {
  [[ $FAST -eq 1 ]] && { msg "Skipping saturn build (fast mode)"; return; }
  local url="https://github.com/saturn-sdk/saturn-sdk/archive/refs/heads/main.tar.gz"
  download_and_extract "$url" "$PREFIX/saturn"
  pushd "$PREFIX/saturn" >/dev/null
  make -j"$JOBS" && ok "Sega Saturn Dev installed" || err "Sega Saturn Dev install failed"
  popd >/dev/null
}

install_kos() {
  [[ $FAST -eq 1 ]] && { msg "Skipping kos build (fast mode)"; return; }
  local url="https://github.com/KallistiOS/KallistiOS/archive/refs/heads/master.tar.gz"
  download_and_extract "$url" "$PREFIX/kos"
  pushd "$PREFIX/kos" >/dev/null
  make -j"$JOBS" && ok "Dreamcast KOS installed" || err "Dreamcast KOS install failed"
  popd >/dev/null
}

install_nxdk() {
  [[ $FAST -eq 1 ]] && { msg "Skipping nxdk build (fast mode)"; return; }
  local url="https://github.com/XboxDev/nxdk/archive/refs/heads/main.tar.gz"
  download_and_extract "$url" "$PREFIX/nxdk"
  pushd "$PREFIX/nxdk" >/dev/null
  make -j"$JOBS" && ok "Xbox NXDK installed" || err "Xbox NXDK install failed"
  popd >/dev/null
}

install_openwatcom() {
  msg "Installing OpenWatcom …"
  apt-get install -y openwatcom >/dev/null || {
    msg "OpenWatcom not in apt, downloading …"
    curl -fsSL https://github.com/open-watcom/open-watcom-v2/releases/download/Current-build/ow-snapshot.tar.gz | tar -xz -C "$PREFIX"
    mv "$PREFIX/openwatcom" "$PREFIX/openwatcom-bin"
  }
  ok "OpenWatcom installed"
}

install_simh() {
  msg "Installing SimH (historical computer simulator) …"
  apt-get install -y simh >/dev/null
  ok "SimH installed"
}

install_arm_gcc() {
  msg "Installing ARM GCC (embedded systems) …"
  apt-get install -y gcc-arm-none-eabi binutils-arm-none-eabi >/dev/null
  ok "ARM GCC installed"
}

install_arduino_cli() {
  msg "Installing Arduino CLI (embedded development) …"
  local version="0.35.3"  # Update to the latest version as needed
  local url="https://downloads.arduino.cc/arduino-cli/arduino-cli_${version}_Linux_64bit.tar.gz"
  local dest="$PREFIX/bin/arduino-cli"
  mkdir -p "$PREFIX/bin"
  curl -fsSL "$url" | tar -xz -C "$PREFIX/bin" arduino-cli
  chmod +x "$dest"
  ok "Arduino CLI installed"
}

install_esp_idf() {
  [[ $FAST -eq 1 ]] && { msg "Skipping esp-idf build (fast mode)"; return; }
  local repo="espressif/esp-idf"
  local url=$(curl -sf "https://api.github.com/repos/$repo/releases/latest" | jq -r '.tarball_url')
  if [ -z "$url" ]; then
    url="https://github.com/$repo/archive/refs/heads/master.tar.gz"
  fi
  download_and_extract "$url" "$PREFIX/esp-idf"
  pushd "$PREFIX/esp-idf" >/dev/null
  apt-get install -y wget flex bison gperf python3 python3-pip python3-venv cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0 >/dev/null
  ./install.sh && ok "ESP-IDF built" || err "ESP-IDF build failed"
  echo "export IDF_PATH=$PREFIX/esp-idf" > /etc/profile.d/esp-idf.sh
  echo "export PATH=\$PATH:\$IDF_PATH/tools" >> /etc/profile.d/esp-idf.sh
  popd >/dev/null
  ok "ESP-IDF installed (source /etc/profile.d/esp-idf.sh to use)"
}

# -----------------------------------------------------------------------------
# Main execution
# -----------------------------------------------------------------------------
main() {
  msg "Starting installation with prefix=$PREFIX, jobs=$JOBS, fast=$FAST"
  apt-get update -qq
  apt-get install -y --no-install-recommends build-essential curl ca-certificates \
    pkg-config autoconf automake libtool bison flex texinfo cmake python3 python3-pip ninja-build \
    libncurses5-dev libreadline-dev zlib1g-dev libssl-dev wget unzip xz-utils gcc g++ clang make gawk \
    libgmp-dev libmpc-dev libmpfr-dev doxygen graphviz tar rsync patch ruby openjdk-17-jre-headless jq file
  ok "Prerequisites installed"

  for module in "${TARGETS[@]}"; do
    fn=install_${module}
    if declare -f "$fn" >/dev/null; then
      "$fn"
    else
      warn "Unknown module: $module"
    fi
  done

  ok "All requested modules processed. Review $LOGFILE for details."
}

prompt_for_targets() {
  echo
  echo "Available modules: ${MODULES[*]}"
  read -rp "Enter modules to install (comma-separated), or 'q' to quit: " input

  # Quit condition
  case "$input" in
    q|quit) 
      echo "Goodbye!"
      exit 0
      ;;
  esac

  # Build TARGETS array
  IFS=',' read -ra TARGETS <<< "$input"
}

# Run main once with command-line args, then enter interactive mode
main
while true; do
  prompt_for_targets
  main
done
