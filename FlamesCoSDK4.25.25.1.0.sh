#!/usr/bin/env bash
# ============================================================
# Script: test.sh – Ultimate Retro‑to‑Modern Toolchain Installer (optimized)
# Author: ChatGPT (2025‑04‑25)
# Description:
#   Installs and lightly self‑tests a broad set of open‑source
#   console/computer toolchains and SDKs on Ubuntu 22.04+ (WSL2).
#   Supports selective installation, fast mode, custom prefix,
#   and parallel builds.
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
MODULES=(cc65 sdcc z88dk devkitpro psn00b ps2dev pspdev ps3dev ps4dev vitadev n64 gendev saturn kos nxdk openwatcom)

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
  # expand comma-separated in each element
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
# Helper: clone or update repo
# -----------------------------------------------------------------------------
clone_or_pull() {
  local repo="$1" dir="$2"
  if [[ -d "$dir/.git" ]]; then
    msg "Updating $dir …" && git -C "$dir" pull --quiet --ff-only || warn "Pull failed – continuing"
  else
    msg "Cloning $repo …" && git clone --depth=1 "$repo" "$dir" --quiet
  fi
}

# -----------------------------------------------------------------------------
# Individual install functions (only key changes shown)
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
  [[ $FAST -eq 1 ]] && { msg "Skipping z88dk build (fast mode)"; return; }
  msg "Building z88dk …"
  clone_or_pull https://github.com/z88dk/z88dk "$PREFIX/z88dk"
  pushd "$PREFIX/z88dk" >/dev/null
  ccache --max-size=5G 2>/dev/null || true
  ./build.sh -j"$JOBS" && ok "z88dk built" || err "z88dk build failed"
  echo "export Z88DK=$PREFIX/z88dk" > /etc/profile.d/z88dk.sh
  popd >/dev/null
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

# ... (repeat for other modules, following same pattern of FAST checks, safe installs, env exports) ...

# -----------------------------------------------------------------------------
# Main execution
# -----------------------------------------------------------------------------
main() {
  msg "Starting installation with prefix=$PREFIX, jobs=$JOBS, fast=$FAST"
  apt-get update -qq
  apt-get install -y --no-install-recommends build-essential git curl ca-certificates \
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

main
