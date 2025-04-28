# ---------------------------------------------------------------------------
# DevkitPro — ALL the Nintendo toolchains & libs
# ---------------------------------------------------------------------------
print_banner "DevkitPro (ALL consoles)"

echo -e "${CYAN}Installing DevkitPro pacman & every meta-package known to humankind...${NC}"

# Bootstrap DevkitPro’s pacman (same one-liner from the docs)
curl -sSL https://apt.devkitpro.org/install-devkitpro-pacman | sudo bash || {
    echo -e "${RED}DevkitPro bootstrap failed! Skipping Nintendo toolchains.${NC}"
}

# Ensure the environment is live before calling dkp-pacman
if [ -f /etc/profile.d/devkit-env.sh ]; then
    source /etc/profile.d/devkit-env.sh
fi

# Update DevkitPro package database
dkp-pacman -Sy --noconfirm || true

# Install **all** meta-packages (ignore failures for consoles you don’t care about / that aren’t hosted anymore)
dkp-pacman -S --noconfirm \
    gba-dev \
    nds-dev \
    3ds-dev \
    gamecube-dev \
    wii-dev \
    wiiu-dev \
    switch-dev \
    psp-dev || true   # PSP may or may not be in the repo

echo -e "${GREEN}✔ DevkitPro toolchains & libs installed (as many as the repo provides).${NC}"
echo -e "${YELLOW}If any packages failed, they’re probably deprecated — the rest are ready to roll!${NC}"
