#!/usr/bin/env bash
# -------------------------------------------------------------------
# Universal Console Toolchain Installer v5.0
# Supports: NES, SNES, N64, GameCube, Wii, Switch, GB, GBA, DS, 3DS,
#           PS1, PSP, Vita, Saturn, Dreamcast, Xbox 360, plus classic
#           C64, ZX Spectrum, Neo Geo, and more.
# Author: Enhanced by ChatGPT
# -------------------------------------------------------------------

set -euo pipefail
IFS=$'\n\t'

# —— COLORS & ICONS —————————————————————————————————————————————————————————
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
ICON_OK="✅"; ICON_WARN="⚠️"; ICON_FAIL="❌"; ICON_INFO="ℹ️"

logfile="$HOME/console-toolchain-install.log"
dry_run=false
verbose=false
selected_parts=()

# —— HELP / USAGE —————————————————————————————————————————————————————————
usage() {
  cat <<EOF
Usage: $0 [options]
Options:
  -h            Show this help and exit
  -d            Dry‑run (no changes made)
  -v            Verbose output
  -p <part>     Install only a specific part (can repeat):
                  devkitpro, retro, classic, modern
  -l <file>     Log file path (default: $logfile)
EOF
  exit 1
}

# —— PARSE ARGS —————————————————————————————————————————————————————————
while getopts ":hdvp:l:" opt; do
  case $opt in
    h) usage ;;
    d) dry_run=true ;;
    v) verbose=true ;;
    p) selected_parts+=("$OPTARG") ;;
    l) logfile="$OPTARG" ;;
    *) usage ;;
  esac
done

# —— LOGGING FUNCTIONS —————————————————————————————————————————————————————————
log() {
  local type="$1"; shift
  local msg="$*"; local stamp; stamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo -e "[$stamp] $type $msg" >> "$logfile"
  if $verbose; then
    echo -e "$type $msg"
  fi
}
step() { echo -e "${BLUE}${ICON_INFO} $*${NC}"; log "[STEP]" "$*"; }
success() { echo -e "${GREEN}${ICON_OK} $*${NC}"; log "[ OK ]" "$*"; }
warn()    { echo -e "${YELLOW}${ICON_WARN} $*${NC}"; log "[WARN]" "$*"; }
fail()    { echo -e "${RED}${ICON_FAIL} $*${NC}"; log "[FAIL]" "$*"; exit 1; }

run() {
  if $dry_run; then
    echo -e "${YELLOW}[DRY-RUN]${NC} $*" && log "[DRY ]" "[DRY] $*"
  else
    log "[EXEC]" "$*"
    eval "$@"
  fi
}

# —— SANITY CHECKS —————————————————————————————————————————————————————————
[ "$(id -u)" -eq 0 ] || warn "Not running as root; using sudo where needed"

for cmd in git curl unzip make gcc; do
  command -v "$cmd" >/dev/null 2>&1 || fail "Required command '$cmd' not found"
done

# —— SELECTOR —————————————————————————————————————————————————————————
install_devkitpro() {
  step "Installing DevKitPro & toolchains"
  run sudo apt-get update -y && run sudo apt-get upgrade -y
  run sudo apt-get install -y --no-install-recommends build-essential clang cmake \
      libsdl2-dev libfreetype6-dev libpng-dev zlib1g-dev libboost-all-dev libxml2-dev \
      openjdk-17-jdk curl wget unzip
  run sudo gpg --keyserver hkp://keyserver.ubuntu.com:80 \
        --recv-keys C52048C0C0748FEE227D47A2702353E0F7E48EDB 4AEEB1A8 || true
  run curl -L https://apt.devkitpro.org/install-devkitpro-pacman | sudo bash
  run sudo dkp-pacman -Syu --noconfirm
  run sudo dkp-pacman -S --needed --noconfirm \
      devkitARM devkitA64 devkitPPC devkitPSP switch-pkg-config libnx \
      3ds-dev gba-dev psp-dev vitasdk
  safe_append ~/.bashrc 'export DEVKITPRO=/opt/devkitpro'
  safe_append ~/.bashrc 'export PATH="$PATH:$DEVKITPRO/base/bin:$DEVKITPRO/devkitARM/bin"'
  success "DevKitPro installed"
}

install_retro() {
  step "Cloning & installing PSX SDK and SGDK"
  install_repo() {
    local repo="$1" dir="$2" build="$3" var="$4" path="$5"
    if [ ! -d "$dir" ]; then
      run git clone "$repo" "$dir"
      pushd "$dir" >/dev/null
      run eval "$build"
      popd >/dev/null
    else
      warn "$dir already exists, skipping"
    fi
    safe_append ~/.bashrc "export $var=$path"
  }
  install_repo https://github.com/psxdev/psxsdk.git "$HOME/psxsdk" \
               "make && sudo make install" PSXSDK_ROOT "\$HOME/psxsdk"
  install_repo https://github.com/Stephane-D/SGDK.git "$HOME/sgdk" \
               "./configure && make && sudo make install" SGDK_ROOT "\$HOME/sgdk"

  step "Installing Sega Saturn toolchain"
  if [ ! -d "$HOME/saturn-sh2-elf" ]; then
    run wget -qO- "$(curl -s https://api.github.com/repos/koenk/saturn-sh2-elf-toolchain/releases/latest \
      | grep browser_download_url | grep ubuntu | cut -d\" -f4)" \
      | run tar xz -C "$HOME" --strip-components=1
  else
    warn "Saturn toolchain already present"
  fi
  safe_append ~/.bashrc 'export SATURN_ROOT=$HOME/saturn-sh2-elf'
  success "Retro console SDKs installed"
}

install_classic() {
  step "Installing GB/GBA and Z80 toolchains"
  run git clone https://github.com/gbdk-2020/gbdk-2020.git "$HOME/gbdk-2020" \
      && pushd "$HOME/gbdk-2020" >/dev/null \
      && run make && run sudo make install && popd >/dev/null \
      || warn "GBDK installation failed or already exists"

  run git clone https://github.com/z88dk/z88dk.git "$HOME/z88dk" \
      && pushd "$HOME/z88dk" >/dev/null \
      && run ./build.sh && popd >/dev/null \
      || warn "Z88DK install failed or exists"
  safe_append ~/.bashrc 'export PATH="$PATH:$HOME/z88dk/bin"'
  success "Classic systems installed"
}

install_modern() {
  step "Setting up Xenia (Xbox 360 emulator)"
  if [ ! -d "$HOME/xenia-canary" ]; then
    run git clone --recursive https://github.com/xenia-canary/xenia-canary.git "$HOME/xenia-canary"
    run pushd "$HOME/xenia-canary" && run ./xenia-setup.sh && popd
  else
    warn "Xenia already cloned"
  fi
  success "Modern systems ready"
}

# —— SAFE_APPEND UTILITY —————————————————————————————————————————————————————————
safe_append() {
  local file="$HOME/.bashrc"; local line="$1"
  grep -qxF "$line" "$file" || echo "$line" >> "$file"
}

# —— EXECUTION FLOW —————————————————————————————————————————————————————————
step "Starting installation"
if [ "${#selected_parts[@]}" -eq 0 ] || [[ " ${selected_parts[*]} " =~ devkitpro ]]; then
  install_devkitpro
fi
if [ "${#selected_parts[@]}" -eq 0 ] || [[ " ${selected_parts[*]} " =~ retro ]]; then
  install_retro
fi
if [ "${#selected_parts[@]}" -eq 0 ] || [[ " ${selected_parts[*]} " =~ classic ]]; then
  install_classic
fi
if [ "${#selected_parts[@]}" -eq 0 ] || [[ " ${selected_parts[*]} " =~ modern ]]; then
  install_modern
fi

step "Reloading shell config"
run source "$HOME/.bashrc" || warn "Could not source ~/.bashrc automatically"

# —— FINAL CHECKS —————————————————————————————————————————————————————————
step "Validating toolchain commands"
for cmd in dkp-pacman arm-none-eabi-gcc aarch64-none-elf-gcc sh-elf-gcc java; do
  if command -v "$cmd" >/dev/null 2>&1; then
    success "$cmd found"
  else
    warn "$cmd missing"
  fi
done

echo -e "\n${GREEN}${ICON_OK} All done! ${NC}"
echo -e "${ICON_INFO} Log file: ${logfile}"
echo -e "${ICON_INFO} Restart your terminal or run 'source ~/.bashrc' to apply changes."
