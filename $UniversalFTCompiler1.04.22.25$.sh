#!/bin/bash
set -eo pipefail

# --- Error handling and cleanup ---
trap 'echo "Error on line $LINENO. Install failed!"; exit 1' ERR

# --- System Configuration ---
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y
# Use full-upgrade carefully, might pull in unwanted major version changes
sudo apt-get full-upgrade -y

# --- Dependency List (Deduplicated and Organized) ---
# Note: Many packages listed multiple times in the original request were deduplicated.
# Note: Some packages might not exist in standard repos (e.g., xc8, pceas, potentially older libs)
#       or might conflict. apt will handle this, but be aware.
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
    openjdk-17-jdk default-jdk # Added default-jdk for broader compatibility
    cc65 wla-dx # Corrected name
    pasmo
    nodejs npm ruby rustc golang
    ghc ocaml smlnj clojure leiningen
    kotlin scala fpc open-cobol gfortran
    # xc8 # Removed, typically requires manual install from Microchip
    # pceas # Removed, not standard
    acme dasm
)

LIBRARIES_CORE=(
    zlib1g-dev libssl-dev libreadline-dev libncurses5-dev
    libboost-all-dev libxml2-dev libcurl4-openssl-dev
    libgmp-dev libmpfr-dev libmpc-dev
    libstdc++-12-dev # Specific version, might need adjustment based on distro
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
    libflac-dev libmodplug-dev libmpg1203-dev libmikmod-dev
    libasound2-dev libsamplerate0-dev libspeexdsp-dev
    libgtest-dev libgmock-dev catch # Testing frameworks
    libdoxygen-dev graphviz # Documentation
)

LIBRARIES_GRAPHICS_UI=(
    # SDL
    libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev
    libsdl2-ttf-dev libsdl2-net-dev libsdl2-gfx-dev
    libsdl1.2-dev # For older apps
    # X11/Wayland Base
    libx11-dev libxext-dev libxrender-dev libxrandr-dev
    libxinerama-dev libxcursor-dev libxi-dev
    libxcomposite-dev libxdamage-dev libxtst-dev
    libxss-dev libxxf86vm-dev libxres-dev libxfixes-dev
    libxv-dev libxvmc-dev libxkbcommon-dev libxkbcommon-x11-dev
    libwayland-bin libwayland-client0 libwayland-cursor0
    libwayland-egl1 # Changed from libwayland-egl-backend-dev
    libwayland-server0 libx11-xcb-dev libinput-dev libmtdev-dev
    libwacom-dev
    # XCB
    libxcb-render0-dev libxcb-shm0-dev libxcb-xfixes0-dev
    libxcb-keysyms1-dev libxcb-icccm4-dev libxcb-image0-dev
    libxcb-shape0-dev libxcb-util0-dev libxcb-xkb-dev
    libxcb-ewmh-dev libxcb-randr0-dev libxcb-xinerama0-dev
    libxcb-sync-dev libxcb-present-dev libxcb-dri3-dev
    libxcb-util-dev libxcb-composite0-dev libxcb-cursor-dev
    libxcb-damage0-dev libxcb-render-util0-dev libxcb-xinput-dev
    # OpenGL/Vulkan/Mesa
    libdrm-dev libgbm-dev libgles2-mesa-dev libegl1-mesa-dev
    libgl1-mesa-dev libglu1-mesa-dev libosmesa6-dev
    libopenvg1-mesa-dev # Corrected name
    libglvnd-dev libgldispatch0-dev libgles1-mesa-dev
    libglx-dev libopengl-dev libepoxy-dev libvulkan-dev
    # UI Toolkits
    libgtk-3-dev libgtk2.0-dev # Added GTK2
    libfltk1.3-dev libwxgtk3.2-dev # Adjusted wxWidgets version
    libqt5opengl5-dev qtbase5-dev qtdeclarative5-dev
    qtmultimedia5-dev qttools5-dev qtx11extras5-dev
    libqt6opengl6-dev qt6-base-dev qt6-declarative-dev
    qt6-multimedia-dev qt6-tools-dev qt6-5compat-dev
    # Other Graphics/UI
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
    dosbox dosbox-x # Added dosbox-x
    vice openmsx simh mame mednafen stella atari800
    hatari scummvm fuse gngeo higan nestopia fceux
    vbam mgba desmume mupen64plus # Removed -qt, core package usually enough
    uae fs-uae oricutron xroar
    retroarch
    # virtualbox virtualbox-qt virtualbox-dkms # Often better installed from Oracle website
)

# --- Installation Process ---
echo "⚡ Installing A LOT of development dependencies and emulators..."
# Combine all arrays, use sort -u to deduplicate, then pass to apt-get
ALL_PACKAGES=($(echo "${ESSENTIALS[@]}" "${COMPILERS[@]}" "${LIBRARIES_CORE[@]}" "${LIBRARIES_GRAPHICS_UI[@]}" "${LIBRARIES_AUDIO_MIDI[@]}" "${EMULATORS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

sudo apt-get install -y --no-install-recommends "${ALL_PACKAGES[@]}" || echo "⚠️ Some packages failed to install. Check logs."

# --- Post-install Setup ---
echo "🛠️ Configuring system..."
# Configure Java if multiple versions installed
if command -v update-alternatives &> /dev/null && update-alternatives --query java &> /dev/null; then
    sudo update-alternatives --config java || true
fi
# Update npm to latest
if command -v npm &> /dev/null; then
    sudo npm install -g npm@latest || echo "⚠️ Failed to update npm."
fi
# Install or update rustup
if ! command -v rustup &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    # Add rust to path for current session
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
echo "Many packages were installed. Some might have failed due to conflicts or availability."
echo "Please review any error messages above."
echo -e "\nRestart your shell or run:"
echo "  source ~/.bashrc"
echo "  source \"\$HOME/.cargo/env\" # If Rust was installed"

# --- Optional Pause ---
# This line makes the script wait for a key press before finishing.
read -n 1 -s -r -p $'\n\nPress ANY KEY to continue or CTRL+C to exit...\n'

exit 0 # Explicitly exit with success code after pause
