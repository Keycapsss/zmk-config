# ZMK Firmware

### Blank Slate
- Default keymap
- [blank-slate-zmk-module](https://github.com/petejohanson/blank-slate-zmk-module)
- ZMK Studio enabled
- PCB available at [keycapsss.com](https://keycapsss.com/keyboard-parts/pcbs/260/blank-slate-ortholinear-wireless-keyboard-pcb-olkb-planck-case-compatible)

### Local Build (Dev Container)

1. Open folder in VS Code with **Dev Containers** extension.
2. Select **Reopen in Container** when prompted.
3. Run build command in terminal:
   ```bash
   west build -b lpgalaxy_blank_slate -- -DZMK_KEYMAP="config/felerius_blank_slate.keymap"
   ```
