# Schritte:
# 1. make base
# ========================================
# FileName: Makefile
# Date: 16.12.2025
# Author: Marcos Chow Castro
# Email: mctechnology170318@gmail.com
# GitHub: https://github.com/mctechnology17
# Brief: Makefile for ZMK firmware with Docker
# Shields: lpgalaxy_blank_slate
# Boards: nice_nano_v2 puchi_ble_v1 seeeduino_xiao_ble lpgalaxy_blank_slate
# =========================================
#                              ╔═╦═╦═╗
#                       ╔════╗ ║║║║║╔╝
#                       ║╔╗╔╗║ ║║║║║╚╗
#                       ╚╝║║╚╝ ║╠═╩╩═╝
#                         ║╠═╦═╣╚╦═╦╦═╦╗╔═╦═╦╦╗
#                         ║║╩╣═╣║║║║║╬║╚╣╬║╬║║║
#                         ╚╩═╩═╩╩╩╩═╩═╩═╩═╬╗╠╗║
#                                         ╚═╩═╝

### CONFIG ###
config=${PWD}/config
zmk_image=zmkfirmware/zmk-dev-arm:3.5
zmk_studio=-S studio-rpc-usb-uart
extra_modules=-DZMK_EXTRA_MODULES="/boards"
extra_modules_dir=${PWD}
slate=lpgalaxy_blank_slate
default=zmk-base
nice_mount=/Volumes/NICENANO

docker_opts= \
	--interactive \
	--tty \
	--name zmk-$@ \
	--workdir /zmk \
	--volume "${config}:/zmk-config:Z" \
	--volume "${PWD}/zmk:/zmk:Z" \
	--volume "${extra_modules_dir}:/boards:Z" \
	${zmk_image}

### KEYMAP DRAWER ###
keymap_drawer_image=python:3.12-slim
keymap_output_dir=docs/keymaps
ortho_layout={"split": false, "rows": 4, "columns": 12}

### BUILD CONFIG ###
keyboard_name_slate='-DCONFIG_ZMK_KEYBOARD_NAME="SLATE"'
keyboard_name_felerius='-DCONFIG_ZMK_KEYBOARD_NAME="F_SLATE"'

west_build_slate=west build /zmk/app --pristine --board "${slate}"

cmake_args_common=-DCONFIG_ZMK_SLEEP=y \
	-DCONFIG_ZMK_IDLE_TIMEOUT=60000 \
	-DCONFIG_ZMK_IDLE_SLEEP_TIMEOUT=2200000

keymap_slate=lpgalaxy_blank_slate
keymap_felerius=felerius_blank_slate

cmake_args_slate=${cmake_args_common} \
	-DKEYMAP_FILE=/zmk-config/${keymap_slate}.keymap

cmake_args_felerius=${cmake_args_common} \
	-DKEYMAP_FILE=/zmk-config/${keymap_felerius}.keymap \
	-DEXTRA_CONF_FILE=/zmk-config/${keymap_felerius}.conf

artifact_slate=/zmk/build/zephyr/zmk.uf2 firmware/${keymap_slate}.uf2
artifact_felerius=/zmk/build/zephyr/zmk.uf2 firmware/${keymap_felerius}.uf2

### DEFAULT ###
all: only_default_blank_slate only_felerius_blank_slate

### SETUP ###
clone_zmk:
	@if [ ! -d zmk ]; then git clone https://github.com/zmkfirmware/zmk -b v0.3.0; fi

base: clone_zmk
	docker run ${docker_opts} sh -c 'west init -l /zmk/app/; west update'

### BUILD ###
only_default_blank_slate: draw_slate
	docker run --rm ${docker_opts} \
		${west_build_slate} ${zmk_studio} ${extra_modules} \
		${cmake_args_slate} ${keyboard_name_slate}
	@mkdir -p firmware
	docker cp ${default}:${artifact_slate}

only_felerius_blank_slate: draw_felerius
	docker run --rm ${docker_opts} \
		${west_build_slate} ${zmk_studio} ${extra_modules} \
		${cmake_args_felerius} ${keyboard_name_felerius}
	@mkdir -p firmware
	docker cp ${default}:${artifact_felerius}

### KEYMAP SVG ###
draw_felerius:
	@mkdir -p ${keymap_output_dir}
	docker run --rm \
		-v "${config}:/config:ro" \
		-v "${PWD}/${keymap_output_dir}:/output" \
		${keymap_drawer_image} \
		sh -c 'pip install --quiet keymap-drawer && \
			keymap parse -z /config/${keymap_felerius}.keymap | \
			keymap draw --ortho-layout "${ortho_layout}" - -o /output/${keymap_felerius}.svg'

draw_slate:
	@mkdir -p ${keymap_output_dir}
	docker run --rm \
		-v "${config}:/config:ro" \
		-v "${PWD}/${keymap_output_dir}:/output" \
		${keymap_drawer_image} \
		sh -c 'pip install --quiet keymap-drawer && \
			keymap parse -z /config/${keymap_slate}.keymap | \
			keymap draw --ortho-layout "${ortho_layout}" - -o /output/${keymap_slate}.svg'

draw_all: draw_felerius draw_slate

### UTILITIES ###
shell:
	docker run --rm ${docker_opts} /bin/bash

flash_slate:
	@printf "Waiting for bootloader at ${nice_mount}.."
	@while [ ! -d ${nice_mount} ]; do sleep 1; printf "."; done; printf "\n"
	cp -av firmware/${keymap_slate}.uf2 ${nice_mount}

### CLEAN ###
clean_firmware:
	rm -f firmware/*.uf2

clean_zmk:
	@if [ -d zmk ]; then rm -rfv zmk; fi

clean_docker: clean_zmk
	-docker ps -aq --filter name='^zmk' | xargs docker container rm 2>/dev/null
	-docker volume list -q --filter name='zmk' | xargs docker volume rm 2>/dev/null

clean_all: clean clean_firmware

# vim: set ft=make fdm=marker:
