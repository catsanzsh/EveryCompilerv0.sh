#!/bin/bash
set -eo pipefail

# --- Error handling and cleanup ---
trap 'echo "Error on line $LINENO. Install failed!"; exit 1' ERR

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y
sudo apt-get full-upgrade -y

# --- Dependency List (Deduplicated and Fixed) ---
ESSENTIALS=(
    jq make git curl wget unzip build-essential pkg-config
    cmake autoconf automake libtool ninja-build meson
    p7zip-full lhasa unar cpio cabextract bsdtar tup
    python3 python-is-python3 pipx
    nasm yasm radare2 hexedit
)

COMPILERS=(
    clang llvm-dev libclang-dev
    gcc g++ gcc-multilib g++-multilib
    # gcc-m68k-linux-gnu # Often causes issues, install manually if needed
    gcc-riscv64-unknown-elf
    gcc-msp430 # Corrected name
    gcc-arm-none-eabi
    openjdk-17-jdk default-jdk
    cc65 wla-dx # Corrected name
    pasmo
    nodejs npm ruby rustc golang
    ghc ocaml smlnj clojure leiningen
    kotlin scala fpc open-cobol gfortran
    acme dasm
)

LIBRARIES_CORE=(
    zlib1g-dev libssl-dev libreadline-dev libncurses5-dev
    libboost-all-dev libxml2-dev libcurl4-openssl-dev
    libgmp-dev libmpfr-dev libmpc-dev
    libstdc++-12-dev
    libedit-dev libjsoncpp-dev libuv1-dev libhttp-parser-dev
    libssh-dev libkrb5-dev libpcre2-dev libsqlite3-dev
    libmicrohttpd-dev libsystemd-dev libdbus-1-dev libglib2.0-dev
    libgirepository1.0-dev libsecret-1-dev libnotify-dev
    libpoco-dev libzstd-dev libsnappy-dev liblz4-dev libbz2-dev
    libzmq3-dev libmsgpack-dev libprotobuf-dev protobuf-compiler
    libflatbuffers-dev rapidjson-dev
    libluajit-5.1-dev lua5.1 liblua5.1-0-dev
    libpcap-dev libslirp-dev
    libzip-dev liblzo2-dev librsvg2-dev libcdio-dev
    libjpeg-dev libtiff-dev libsndio-dev libudev-dev
    libbluetooth-dev libogg-dev libvorbis-dev libtheora-dev
    libflac-dev libmodplug-dev libmikmod-dev
    libasound2-dev libsamplerate0-dev libspeexdsp-dev
    libgtest-dev libgmock-dev catch
    libdoxygen-dev graphviz
)

LIBRARIES_GRAPHICS_UI=(
    libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev
    libsdl2-ttf-dev libsdl2-net-dev libsdl2-gfx-dev
    libsdl1.2-dev
    libx11-dev libxext-dev libxrender-dev libxrandr-dev
    libxinerama-dev libxcursor-dev libxi-dev
    libxcomposite-dev libxdamage-dev libxtst-dev
    libxss-dev libxxf86vm-dev libxres-dev libxfixes-dev
    libxv-dev libxvmc-dev libxkbcommon-dev libxkbcommon-x11-dev
    libwayland-bin libwayland-client0 libwayland-cursor0
    libwayland-egl1 libwayland-server0 libx11-xcb-dev libinput-dev libmtdev-dev
    libwacom-dev
    libxcb-render0-dev libxcb-shm0-dev libxcb-xfixes0-dev
    libxcb-keysyms1-dev libxcb-icccm4-dev libxcb-image0-dev
    libxcb-shape0-dev libxcb-util0-dev libxcb-xkb-dev
    libxcb-ewmh-dev libxcb-randr0-dev libxcb-xinerama0-dev
    libxcb-sync-dev libxcb-present-dev libxcb-dri3-dev
    libxcb-util-dev libxcb-composite0-dev libxcb-cursor-dev
    libxcb-damage0-dev libxcb-render-util0-dev libxcb-xinput-dev
    libdrm-dev libgbm-dev libgles2-mesa-dev libegl1-mesa-dev
    libgl1-mesa-dev libglu1-mesa-dev libosmesa6-dev
    libopenvg1-mesa-dev
    libglvnd-dev libgldispatch0-dev libgles1-mesa-dev
    libglx-dev libopengl-dev libepoxy-dev libvulkan-dev
    libgtk-3-dev libgtk2.0-dev
    libfltk1.3-dev libwxgtk3.0-gtk3-dev
    libqt5opengl5-dev qtbase5-dev qtdeclarative5-dev
    qtmultimedia5-dev qttools5-dev qtx11extras5-dev
    libqt6opengl6-dev qt6-base-dev qt6-declarative-dev
    qt6-multimedia-dev qt6-tools-dev qt6-5compat-dev
    freeglut3-dev libglew-dev libglfw3-dev libglm-dev
    libassimp-dev libbullet-dev libode-dev libfreeimage-dev
    libsoil-dev libwebp-dev
    libvte-2.91-dev libappindicator3-dev libindicator3-dev
    libxt-dev libxmu-dev
)

LIBRARIES_AUDIO_MIDI=(
    libopenal-dev libalut-dev libportmidi-dev libportaudio-dev
    libsndfile-dev libmpg123-dev libopus-dev
    libavdevice-dev libswresample-dev libpostproc-dev
    fluid-soundfont-gm
)

EMULATORS=(
    qemu-system-x86 qemu-system-arm qemu-system-mips qemu-system-ppc
    qemu-system-sparc qemu-system-s390x qemu-utils
    dosbox dosbox-x
    vice openmsx simh mame mednafen stella atari800
    hatari scummvm fuse gngeo higan nestopia fceux
    vbam mgba desmume mupen64plus
    uae fs-uae oricutron xroar
    retroarch
)

# --- Installation Process ---
echo "⚡ Installing a massive set of development dependencies and emulators..."

ALL_PACKAGES=($(echo "${ESSENTIALS[@]}" "${COMPILERS[@]}" "${LIBRARIES_CORE[@]}" "${LIBRARIES_GRAPHICS_UI[@]}" "${LIBRARIES_AUDIO_MIDI[@]}" "${EMULATORS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

FAILED_PKGS=()
for pkg in "${ALL_PACKAGES[@]}"; do
    if ! sudo apt-get install -y --no-install-recommends "$pkg"; then
        echo "⚠️  Package failed: $pkg"
        FAILED_PKGS+=("$pkg")
    fi
done

# --- Post-install Setup ---
echo "🛠️ Configuring system..."
if command -v update-alternatives &> /dev/null && update-alternatives --query java &> /dev/null; then
    sudo update-alternatives --config java || true
fi
if command -v npm &> /dev/null; then
    sudo npm install -g npm@latest || echo "⚠️ Failed to update npm."
fi
if ! command -v rustup &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    source "$HOME/.cargo/env"
else
    rustup update || echo "⚠️ Failed to update rustup."
fi

# --- Cleanup ---
echo "🧹 Cleaning up..."
sudo apt-get autoremove -y
sudo apt-get clean

# --- Completion ---
echo -e "\n\n"
echo "HDR Development Environment v0.0.1 (Attempted) Ready!"
if [ "${#FAILED_PKGS[@]}" -ne 0 ]; then
    echo "⚠️ The following packages could not be installed and may require manual intervention:"
    printf '  - %s\n' "${FAILED_PKGS[@]}"
    echo "Some packages (like pceas, xc8, wla-65816, etc.) are not in Ubuntu repos and must be built or installed manually."
fi
echo -e "\nRestart your shell or run:"
echo "  source ~/.bashrc"
echo "  source \"\$HOME/.cargo/env\" # If Rust was installed"

read -n 1 -s -r -p $'\n\nPress ANY KEY to continue or CTRL+C to exit...\n'

exit 0
