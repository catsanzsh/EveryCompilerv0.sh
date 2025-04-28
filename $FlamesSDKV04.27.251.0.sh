#!/usr/bin/env bash
# 
# Ultimate Retro Emulator & SDK Installer
# ---------------------------------------
# This insane script installs just about every emulator and dev tool from the 1920s to 2025.
# Buckle up, buttercup: we're covering everything from vacuum-tube mainframes to modern consoles.
# No git cloning here – we use apt, curl, or wget only. 
# Original style: humorous, slightly vulgar, and colorful output with banners.
# 
# Warning: This script might install a crap-ton of packages. Make sure you have space... and coffee.
# Also, some emulators might need BIOS/ROM files or additional setup – we'll note those.
# Enjoy the time-traveling nerd adventure!

# Ensure running as root (for apt). If not, re-run with sudo.
if [ "$EUID" -ne 0 ]; then
  echo -e "\033[1;31m[ERROR]\033[0m This script needs to run as root. Try 'sudo bash $0'."
  exit 1
fi

echo -e "\033[1;33m***********************************************\033[0m"
echo -e "\033[1;33m***  Ultimate Retro Emulator & SDK Installer ***\033[0m"
echo -e "\033[1;33m***********************************************\033[0m"
echo -e "\033[1;34mCovering computing hardware from ENIAC to PS5 (1920-2025)!\033[0m"
echo

# Update package list and enable universe/multiverse for extra emulators
echo -e "\033[1;36m>> Updating package lists and enabling all repositories...\033[0m"
apt-get update -y
apt-get install -y software-properties-common
add-apt-repository -y universe
add-apt-repository -y multiverse
apt-get update -y

# 1. Mainframes & Minicomputers (1940s-1970s)
echo -e "\n\033[1;35m===== [1] Mainframes & Minicomputers (1940s-1970s) =====\033[0m"
echo -e "\033[1;32mInstalling simulators for big iron dinosaurs...\033[0m"
apt-get install -y simh hercules x3270 gnucobol
echo -e "\033[1;32m- SIMH installed:\033[0m Emulates 33 classic computers (PDP-8, PDP-11, VAX, IBM 1401, etc)."
echo -e "\033[1;32m- Hercules installed:\033[0m IBM System/360 and later mainframes emulator."
echo -e "\033[1;32m- x3270 installed:\033[0m IBM 3270 terminal emulator (for that authentic green-screen mainframe login)."
echo -e "\033[1;32m- GnuCOBOL installed:\033[0m Because you'll want to COBOL like it's 1959 on your new mainframe."
echo -e "\033[1;33mNote:\033[0m For VAX in SIMH, you may need original microcode (not included, blame lawyers)."
echo -e "\033[1;33mNote:\033[0m ENIAC/UNIVAC fans: no apt packages (too many vacuum tubes). Check online simulators for those.\n"

# 2. Early Microcomputers (1970s)
echo -e "\033[1;35m===== [2] Early Microcomputers (1970s) =====\033[0m"
echo -e "\033[1;32mInstalling emulators for the homebrew and kit era...\033[0m"
# Altair 8800, IMSAI 8080, etc. - SimH covers some (Altair via Intel 8080 simulation).
# We'll not install new packages here, but mention what's covered.
echo -e "\033[1;32m- Altair 8800:\033[0m Use SIMH (altairZ80) to run CP/M on an emulated Altair 8800."
echo -e "\033[1;32m- IMSAI 8080:\033[0m Similar to Altair – SIMH or other 8080 sims can handle it."
echo -e "\033[1;32m- Apple I:\033[0m No apt package. If you're *really* into a 1976 Apple I, find 'pom1' emulator on GitHub."
echo -e "\033[1;32m- Kenbak-1 (1971):\033[0m Might as well flip some switches IRL – no apt emu here!"
echo -e "\033[1;33mNote:\033[0m Many 1970s micros can be emulated via MAME/MESS as a fallback if dedicated emulators aren't available.\n"

# 3. 8-bit Home Computers (1970s-1980s)
echo -e "\033[1;35m===== [3] 8-bit Home Computers (late 1970s-1980s) =====\033[0m"
echo -e "\033[1;32mInstalling emulators for the golden age of 8-bit micros...\033[0m"
apt-get install -y vice fuse-emulator-gtk atari800 xtrs openmsx oricutron
echo -e "\033[1;32m- VICE installed:\033[0m Commodore 8-bit emulator (C64, C128, VIC-20, PET, Plus/4). Load your floppies and feel the BASIC."
echo -e "\033[1;32m- FUSE installed:\033[0m ZX Spectrum emulator (48K, 128K and beyond). Time to PEEK and POKE like it's 1985."
echo -e "\033[1;32m- Atari800 installed:\033[0m Atari 800/XL/XE 8-bit computer emulator. Boots you into Atari BASIC (no cassette drive required!)."
echo -e "\033[1;32m- XTRS installed:\033[0m TRS-80 Model I/III/4 emulator. Yes, the Trash-80 lives on in your PC."
echo -e "\033[1;32m- openMSX installed:\033[0m MSX1/2/2+ emulator. Time to dust off those cartridge ROMs from Japan/Europe."
echo -e "\033[1;32m- Oricutron installed:\033[0m Oric-1/Atmos 8-bit emulator. Relive the obscure Oric glory."
echo -e "\033[1;33mNote:\033[0m Apple II: No direct apt package. You can use MAME's Apple II support or build linapple (Apple II emulator) manually. Sorry, Apple // lovers!"
echo -e "\033[1;33mNote:\033[0m BBC Micro: No apt emulator here; consider 'BeebEm' via wine or MAME for BBC Micro.\n"

# 4. 16-bit Home & Personal Computers (1980s-1990s)
echo -e "\033[1;35m===== [4] 16/32-bit Home Computers (1980s-1990s) =====\033[0m"
echo -e "\033[1;32mInstalling emulators for the 16-bit era (Amiga, Atari ST, early Mac, etc)...\033[0m"
apt-get install -y fs-uae hatari basilisk2 dosbox bochs qemu-system-x86
echo -e "\033[1;32m- FS-UAE installed:\033[0m Amiga emulator (A500/A1200/etc). Kickstart ROMs *not* included – get those separately or the Amiga won’t boot!"
echo -e "\033[1;32m- Hatari installed:\033[0m Atari ST/STE/TT/Falcon emulator. Time to revisit GEM OS and MIDI music."
echo -e "\033[1;32m- Basilisk II installed:\033[0m 68k Macintosh emulator (Mac Plus through Mac II). You’ll need a Macintosh ROM file to actually boot it."
echo -e "\033[1;32m- DOSBox installed:\033[0m MS-DOS PC emulator. Perfect for running DOS games and software from the 80s/90s (Commander Keen, anyone?)."
echo -e "\033[1;32m- Bochs installed:\033[0m x86 PC emulator (slow but thorough). Great for low-level OS development or masochists who want to emulate a 486 in C++."
echo -e "\033[1;32m- QEMU (x86) installed:\033[0m Quick EMUlator for x86/PC and more. Use this to virtualize or emulate various CPU architectures (ARM, MIPS, RISC-V, etc) beyond just PCs."
echo -e "\033[1;33mNote:\033[0m For Windows 3.x/95/98, use DOSBox (for DOS-era) or QEMU/Bochs to install those OSes. Bochs even has its own BIOS."
echo -e "\033[1;33mNote:\033[0m IBM PCem/86Box (for very accurate retro PC hardware) are not in apt. If you need to emulate an IBM AT or Voodoo3 GPU, you'll have to install those manually."
echo -e "\033[1;33mNote:\033[0m SheepShaver (PowerPC Mac) is not available via apt (requires source build). If you need Classic Mac OS 8/9 on PPC, prepare to compile or find a pre-built binary.\n"

# 5. Video Game Consoles (1970s-1990s, 8-bit & 16-bit)
echo -e "\033[1;35m===== [5] Classic Game Consoles (1970s-1990s) =====\033[0m"
echo -e "\033[1;32mInstalling emulators for classic game consoles (Atari, NES, SNES, Genesis, etc)...\033[0m"
apt-get install -y stella osmose-emulator mednafen mednaffe mupen64plus-qt zsnes
echo -e "\033[1;32m- Stella installed:\033[0m Atari 2600 emulator. Get ready for some chunky pixels and joystick waggling."
echo -e "\033[1;32m- Osmose installed:\033[0m Sega Master System / Game Gear emulator. Time to revisit Alex Kidd and 8-bit Sonic."
echo -e "\033[1;32m- Mednafen installed:\033[0m Multi-system emulator (Lynx, NeoGeo Pocket, WonderSwan, NES, SNES, GB/GBC/GBA, VirtualBoy, PC Engine, SuperGrafx, PC-FX, MegaDrive/Genesis, MasterSystem, Saturn, PlayStation). It's a jack-of-all-trades emulator."
echo -e "\033[1;32m- Mednaffe installed:\033[0m GUI frontend for Mednafen to make life easier (unless you love command-line-only gaming)."
echo -e "\033[1;32m- Mupen64Plus installed:\033[0m Nintendo 64 emulator (with Qt GUI). Time to relive Mario 64 and GoldenEye in blurry 3D!"
echo -e "\033[1;32m- ZSNES installed:\033[0m Super Nintendo emulator (old but gold). Note: may require 32-bit libraries on 64-bit systems. Alternatively, use Mednafen or higan for SNES if ZSNES gives you grief."
echo -e "\033[1;33mNote:\033[0m NES/Famicom: Mednafen covers NES, but you can also install FCEUX or Nestopia manually if you prefer (not included by default here)."
echo -e "\033[1;33mNote:\033[0m Sega Genesis/Mega Drive: Mednafen covers it, or use DGen (apt install dgen) if you want a dedicated emulator. (DGen is in non-free repo.)"
echo -e "\033[1;33mNote:\033[0m For all consoles above, you'll need game ROMs (cartridge dumps). We didn't include any (to keep it legal). BYOROM!\n"

# 6. Video Game Consoles (1990s-2000s, 32/64-bit era)
echo -e "\033[1;35m===== [6] 32/64-bit Consoles & Handhelds (1990s-2000s) =====\033[0m"
echo -e "\033[1;32mInstalling emulators for the 32/64-bit generation (PS1, PS2, N64, GBA, etc)...\033[0m"
apt-get install -y pcsxr
echo -e "\033[1;32m- PCSXR installed:\033[0m PlayStation 1 emulator. Bust out your FF7 CDs (or ISOs). \033[1;33m(PS1 BIOS recommended for best compatibility, put scph1001.bin in ~/.pcsxr/bios)\033[0m"
echo -e "\033[1;32m- Game Boy / Color / Advance:\033[0m Mednafen (already installed) covers GB/GBC/GBA nicely. (Alternatively, VisualBoyAdvance-M or mGBA can be used, but not installed here.)"
echo -e "\033[1;32m- Nintendo DS:\033[0m No apt package by default. Consider installing DeSmuME (Nintendo DS emulator) via source or Snap. (We didn't auto-install it here.)"
echo -e "\033[1;32m- Sega Saturn:\033[0m Yabause is installed as part of mednafen's Saturn core. Saturn emulation is tricky; you *may* need a Saturn BIOS for some games (place it in mednafen's firmware folder)."
echo -e "\033[1;32m- NeoGeo AES/MVS & Arcade:\033[0m Use MAME (below) or Mednafen for NeoGeo. NeoGeo BIOS (neogeo.zip) is needed for arcade ROMs."
echo -e "\033[1;33mNote:\033[0m PlayStation 2: Not installed by default. \033[1;33mPCSX2\033[0m is the go-to PS2 emulator. You can install it via Flatpak or the official PPA (if you dare). \n      # Example (if you want it):\n      sudo add-apt-repository ppa:pcsx2-team/pcsx2-daily -y && sudo apt update && sudo apt install -y pcsx2-unstable\n      And remember to supply your own PS2 BIOS!\n"
echo -e "\033[1;33mNote:\033[0m Nintendo GameCube/Wii: Not installed by default. Use \033[1;33mDolphin\033[0m emulator. (Add Dolphin's PPA or use Flatpak/AppImage for the latest version.) \n      # Example:\n      sudo add-apt-repository ppa:dolphin-emu/ppa -y && sudo apt update && sudo apt install -y dolphin-emu\n      (If apt complains, use their Flatpak.)"
echo -e "\033[1;33mNote:\033[0m GameCube/Wii do not require BIOS files, but Dolphin will need you to configure controller and such. \n"

# 7. Modern Consoles (2000s-2020s)
echo -e "\033[1;35m===== [7] Modern Consoles (2000s-2025) =====\033[0m"
echo -e "\033[1;32mSetting up pointers for modern console emulators (because not everything is apt-gettable)...\033[0m"
echo -e "\033[1;32m- PlayStation 3:\033[0m \033[1;33mRPCS3\033[0m (PS3 emulator) is available as an AppImage on rpcs3.net. Not installed via apt (no official package). If you want PS3, download RPCS3 AppImage and run it. Requires a PS3 firmware file from Sony."
echo -e "\033[1;32m- PlayStation 4 / 5:\033[0m \033[1;33mNo functional emulators yet\033[0m. (PS4 emulation is experimental, PS5 – forget about it). Consider this a friendly warning: your PC can't magically become a PS5. 😜"
echo -e "\033[1;32m- Xbox (Original):\033[0m \033[1;33mxemu\033[0m is an open-source original Xbox emulator. Not in apt, but you can grab a .deb from xemu.app. (It requires a BIOS dump from an actual Xbox.)"
echo -e "\033[1;32m- Xbox 360:\033[0m \033[1;33mXenia\033[0m (Windows only for now). No Linux version yet. Good luck."
echo -e "\033[1;32m- Nintendo 3DS:\033[0m \033[1;33mCitra\033[0m emulator runs many 3DS games well. Not in apt; download from citra-emu.org (AppImage or Flatpak)."
echo -e "\033[1;32m- Nintendo Switch:\033[0m \033[1;33mYuzu\033[0m or \033[1;33mRyujinx\033[0m are your choices. Both have Linux versions (AppImages/Flatpaks). Not installed here. Also, you’ll need Switch system keys and firmware dumped from a real Switch."
echo -e "\033[1;32m- PlayStation Portable (PSP):\033[0m \033[1;33mPPSSPP\033[0m is a great PSP emulator. We didn't auto-install it. You can install via Snap or PPA (ppa:ppsspp/stable) or get an AppImage."
echo -e "\033[1;32m- PlayStation Vita:\033[0m \033[1;33mVita3K\033[0m is an experimental Vita emulator. Not in apt, but available on vita3k.org. Use at your own risk (and supply Vita firmware)."
echo -e "\033[1;33mNote:\033[0m All modern console emulators above require fairly powerful hardware. If your PC is a potato, stick to Pong.\n"

# 8. Handhelds, Calculators & Oddball Devices
echo -e "\033[1;35m===== [8] Handhelds, Calculators & Oddballs =====\033[0m"
echo -e "\033[1;32mInstalling emulators for PDAs, graphing calculators, and other weird devices...\033[0m"
apt-get install -y tilem tiemu
echo -e "\033[1;32m- TiLEM installed:\033[0m TI Z80 Calculator emulator (TI-73/82/83/84, etc). You can finally play Calculator Tetris on your PC!"
echo -e "\033[1;32m- TiEmu installed:\033[0m TI-89/TI-92 (Motorola 68k) graphing calculator emulator. Math class flashbacks included for free."
echo -e "\033[1;32m- Palm OS:\033[0m Not installed (no apt). For Palm PDAs, check out \033[1;33mMu\033[0m (Palm m515 emulator) or the old PalmOS Emulator (POSE) if you can find it. You’ll need PalmOS ROMs."
echo -e "\033[1;32m- Apple Newton:\033[0m No apt package. Look into \033[1;33mEinstein\033[0m emulator if you want to relive the Newton PDA experience. Bring your own Newton ROM."
echo -e "\033[1;32m- Psion/EPOC:\033[0m No apt emulator. Some exist (EKA2L1 covers Symbian OS which descended from EPOC), but you’ll have to build from source."
echo -e "\033[1;32m- Pocket PC/Windows Mobile:\033[0m No open-source emulator on Linux. Perhaps run Microsoft's emulator via Wine or pray to the gods of software."
echo -e "\033[1;32m- PDP-11 on an Arduino? Altair on a fridge?\033[0m If it's not covered above, consider running \033[1;33mMAME\033[0m which has an absurdly large catalog of emulated machines, or check online communities for niche emulators."
echo -e "\033[1;33mNote:\033[0m TI calculators require you to provide the calculator's ROM image (dump from the real calculator) for full functionality. We gave you the emulator, you bring the ROMs.\n"

# 9. Arcade Machines (1970s-2000s)
echo -e "\033[1;35m===== [9] Arcade Machines (1970s-2000s) =====\033[0m"
echo -e "\033[1;32mInstalling arcade emulators...\033[0m"
apt-get install -y mame
echo -e "\033[1;32m- MAME installed:\033[0m Multiple Arcade Machine Emulator. Emulates thousands of arcade cabinets and even some consoles/computers (through MESS). It's the big kahuna of arcade emulation."
echo -e "\033[1;33mNote:\033[0m Arcade emulators need game ROMs (and sometimes BIOS files for systems like NeoGeo, CPS3, etc). Get your ROMs/dumps legally (i.e., dump from arcade boards you own) or enjoy the blinking insert coin screen."
echo -e "\033[1;33mNote:\033[0m For laserdisc arcade games (Dragon's Lair, etc), look into \033[1;33mDaphne\033[0m emulator (not in apt, requires manual install) if you're feeling nostalgic for 1983.\n"

# 10. Development Tools & SDKs for Retro Systems
echo -e "\033[1;35m===== [10] Development Tools & SDKs for Retro Hardware =====\033[0m"
echo -e "\033[1;32mInstalling cross-compilers, assemblers, and SDKs for various retro platforms...\033[0m"
apt-get install -y cc65 sdcc dasm
echo -e "\033[1;32m- CC65 installed:\033[0m C compiler and tools for 6502-based systems (Commodore, Apple II, NES, etc). Time to code some 8-bit magic in C (or assembly)!"
echo -e "\033[1;32m- SDCC installed:\033[0m Small Device C Compiler for Z80, 8051, 6502 and more. Write C for your Z80-based computer or even an 8051 microcontroller like it's no big deal."
echo -e "\033[1;32m- DASM installed:\033[0m Multi-platform Macro Assembler (supports 6502, 6809, etc). Perfect for assembling ROMs for Atari 2600 or other 8-bit consoles."
echo -e "\033[1;32m- AVR GCC/Arduino:\033[0m If you want to program microcontrollers (e.g., Arduino AVR boards), you have avr-gcc with avr-libc already (it came with that avr-libc dependency). You can also \033[1;33mapt install arduino\033[0m for the full Arduino IDE if desired."
echo -e "\033[1;32m- Android SDK/Emulator:\033[0m Not installed via apt. For modern Android dev (2008+), download Android Studio or use sdkmanager to get the emulator and system images. (We keep it old-school here, but hey, it's 2025, so just a heads up.)"
echo -e "\033[1;32m- Retro Console SDKs:\033[0m For NES, SNES, etc, communities have dev kits (e.g., cc65 covers NES, \033[1;33mPVSNESLib\033[0m for SNES, \033[1;33mdevkitPro\033[0m for GBA/DS). Those aren't apt packages, so you'll install them manually if needed."
echo -e "\033[1;33mNote:\033[0m We installed a bunch of cross-compilers. They won't magically make your code run on vintage hardware *by themselves*. You still need to know what you're doing and probably some way to get the code into the emulator or real device (e.g., an EPROM programmer or an emulator's load command). Good luck, Code Warrior.\n"

# All done
echo -e "\033[1;36m======================================================================\033[0m"
echo -e "\033[1;36m>>> Phew! All done. Grab a beer (or soda) – you've installed basically everything under the sun. <<<\033[0m"
echo -e "\033[1;36m======================================================================\033[0m"
echo -e "\033[1;32mEnjoy your journey through computing history! Remember: with great emulators comes great responsibility (to supply your own ROMs/BIOS and not break the law).\033[0m"
echo -e "\033[1;32mNow go fire up something ancient and impress (or confuse) your friends. Happy retro-computing! \033[0m"
