# ZMK Firmware

# Blank Slate
- Default keymap
- [blank-slate-zmk-module](https://github.com/petejohanson/blank-slate-zmk-module)
- ZMK Studio enabled
- PCB available at [keycapsss.com](https://keycapsss.com/keyboard-parts/pcbs/260/blank-slate-ortholinear-wireless-keyboard-pcb-olkb-planck-case-compatible)

# How to Use (Local Compilation)

This project uses a `Makefile` to simplify building ZMK firmware locally using Docker. This ensures a consistent environment matching the CI build.

## Prerequisites
- **Docker**: Ensure Docker is installed and running on your machine.
- **Terminal**: A standard terminal (zsh, bash).

## Quick Start

### 1. Initialize the Environment
If this is your first time, clone the ZMK firmware and initialize the modules:
```bash
make base
```

### 2. Build Firmware
To build the firmware for the **Felerius Blank Slate**:
```bash
make only_felerius_blank_slate
```
This command will:
- Spin up a Docker container.
- Mount your local config.
- Build the firmware using `west`.
- Copy the resulting `.uf2` file to the `firmware/` directory.

To build the standard **LP Galaxy Blank Slate**:
```bash
make only_slate
```

### 3. Clean Build Artifacts
To remove old firmware files and Docker containers/volumes:
```bash
make clean_all
```
