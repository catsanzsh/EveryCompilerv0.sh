#!/bin/bash

# ============================================================
# Script: test.sh
# Description: Install a wide range of programming language compilers and toolchains on Ubuntu (e.g., WSL2).
# Note: Run this script with root privileges (e.g., using sudo).
# ============================================================

# Define text styles for vibrant output
BOLD="\033[1m"
RESET="\033[0m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
PURPLE="\033[1;35m"

# Welcome message
echo -e "${PURPLE}=============================================================${RESET}"
echo -e "${PURPLE}🤖 Welcome to the Ultimate Dev Environment Setup Script! 🤖${RESET}"
echo -e "${PURPLE}We're installing compilers & toolchains for all languages. 🚀${RESET}"
echo -e "${PURPLE}=============================================================${RESET}\n"

# Update package list
echo -e "${CYAN}🔄 Updating package lists...${RESET}"
sudo apt-get update
echo -e "${GREEN}✅ Package lists updated.${RESET}\n"

# (Optional) Upgrade packages 
# echo -e "${CYAN}🔄 Upgrading existing packages...${RESET}"
# sudo apt-get upgrade -y
# echo -e "${GREEN}✅ System packages upgraded.${RESET}\n"

# ------------------------------------------------------------
# Essential tools (curl, git, etc.)
# ------------------------------------------------------------
echo -e "${CYAN}📦 Installing essential tools (curl, git)...${RESET}"
sudo apt-get install -y curl git
echo -e "${GREEN}✅ Essential tools installed (curl, git).${RESET}\n"

# ------------------------------------------------------------
# C/C++ Compilers and Build Tools (GCC, G++, Make, CMake)
# ------------------------------------------------------------
echo -e "${CYAN}🔨 Installing C/C++ build tools (GCC, G++, Make) and CMake...${RESET}"
sudo apt-get install -y build-essential cmake
echo -e "${GREEN}✅ C/C++ build tools and CMake installed.${RESET}\n"

# ------------------------------------------------------------
# Clang/LLVM (alternative C/C++ compiler)
# ------------------------------------------------------------
echo -e "${CYAN}🔨 Installing Clang (C/C++ compiler)...${RESET}"
sudo apt-get install -y clang
echo -e "${GREEN}✅ Clang installed.${RESET}\n"

# ------------------------------------------------------------
# Fortran Compiler (GFortran)
# ------------------------------------------------------------
echo -e "${CYAN}🔬 Installing GNU Fortran compiler (gfortran)...${RESET}"
sudo apt-get install -y gfortran
echo -e "${GREEN}✅ GFortran installed.${RESET}\n"

# ------------------------------------------------------------
# Java Development Kit (OpenJDK)
# ------------------------------------------------------------
echo -e "${CYAN}☕ Installing Java Development Kit (OpenJDK)...${RESET}"
sudo apt-get install -y default-jdk
echo -e "${GREEN}✅ OpenJDK installed.${RESET}\n"

# ------------------------------------------------------------
# Python 3 and pip
# ------------------------------------------------------------
echo -e "${CYAN}🐍 Installing Python 3 and pip...${RESET}"
sudo apt-get install -y python3 python3-pip python3-venv
echo -e "${GREEN}✅ Python 3 and pip installed.${RESET}\n"

# ------------------------------------------------------------
# Node.js and npm (JavaScript runtime)
# ------------------------------------------------------------
echo -e "${CYAN}🟢 Installing Node.js and npm...${RESET}"
sudo apt-get install -y nodejs npm
echo -e "${GREEN}✅ Node.js and npm installed.${RESET}\n"

# ------------------------------------------------------------
# Ruby (Ruby Language Interpreter and Gems)
# ------------------------------------------------------------
echo -e "${CYAN}💎 Installing Ruby (and RubyGems)...${RESET}"
sudo apt-get install -y ruby-full
echo -e "${GREEN}✅ Ruby installed.${RESET}\n"

# ------------------------------------------------------------
# Go (Golang compiler and tools)
# ------------------------------------------------------------
echo -e "${CYAN}🐹 Installing Go (Golang)...${RESET}"
sudo apt-get install -y golang
echo -e "${GREEN}✅ Go (Golang) installed.${RESET}\n"

# ------------------------------------------------------------
# Rust (via rustup toolchain installer)
# ------------------------------------------------------------
echo -e "${CYAN}🦀 Installing Rust (via rustup)...${RESET}"
curl -sSf https://sh.rustup.rs | sh -s -- -y
# Ensure Rust is available in current session
source $HOME/.cargo/env
echo -e "${GREEN}✅ Rust installed (rustc & cargo).${RESET}\n"

# ------------------------------------------------------------
# Haskell (GHC compiler and Cabal)
# ------------------------------------------------------------
echo -e "${CYAN}📚 Installing Haskell (GHC & Cabal)...${RESET}"
sudo apt-get install -y ghc cabal-install
echo -e "${GREEN}✅ Haskell (GHC & Cabal) installed.${RESET}\n"

# ------------------------------------------------------------
# Final Summary and Celebration
# ------------------------------------------------------------
echo -e "${PURPLE}=============================================================${RESET}"
echo -e "${PURPLE}🎉 All done! Your development environment is ready to rock! 🎉${RESET}"
echo -e "${PURPLE}=============================================================${RESET}"
echo -e "${BOLD}Installed languages and tools include:${RESET}"
echo -e "  - C/C++ (GCC, G++ and Clang) ${GREEN}✔${RESET}"
echo -e "  - Fortran (GFortran) ${GREEN}✔${RESET}"
echo -e "  - Java (OpenJDK) ${GREEN}✔${RESET}"
echo -e "  - Python 3 (with pip) ${GREEN}✔${RESET}"
echo -e "  - Node.js (with npm) ${GREEN}✔${RESET}"
echo -e "  - Ruby (RubyGems) ${GREEN}✔${RESET}"
echo -e "  - Rust (rustc & cargo) ${GREEN}✔${RESET}"
echo -e "  - Go (Golang) ${GREEN}✔${RESET}"
echo -e "  - Haskell (GHC & Cabal) ${GREEN}✔${RESET}"
echo -e "  - Git ${GREEN}✔${RESET}"
echo -e "\n${BOLD}Now go forth and code something amazing!${RESET} ${YELLOW}🚀${RESET}\n"
