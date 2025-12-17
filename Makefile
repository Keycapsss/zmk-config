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
zmk_studio= -S studio-rpc-usb-uart
extra_modules_dir=${PWD}
# add a submodule automatic :)
# git submodule add https://github.com/petejohanson/blank-slate-zmk-module.git module/blank-slate-zmk-module
extra_modules= -DZMK_EXTRA_MODULES="/boards"
extra_snippet= /boards/snippets
config=${PWD}/config
nice_mount=/Volumes/NICENANO
puchi_mount=/Volumes/NRF52BOOT
xiao_mount=/Volumes/XIAO-SENSE
zmk_image=zmkfirmware/zmk-dev-arm:3.5
nice=nice_nano_v2
puchi=puchi_ble_v1
xiao=seeeduino_xiao_ble
slate=lpgalaxy_blank_slate
default=zmk-base
docker_opts= \
	--interactive \
	--tty \
	--name zmk-$@ \
	--workdir /zmk \
	--volume "${config}:/zmk-config:Z" \
	--volume "${PWD}/zmk:/zmk:Z" \
	--volume "${extra_modules_dir}:/boards:Z" \
	${zmk_image}

### KEYBOARD NAME ###
keyboard_name_slate= '-DCONFIG_ZMK_KEYBOARD_NAME="SLATE"'
keyboard_name_felerius_blank_slate= '-DCONFIG_ZMK_KEYBOARD_NAME="F_SLATE"'

### WEST ###
west_built_puchi= \
	    west build /zmk/app \
	    --pristine --board "${puchi}"

west_built_nice= \
	    west build /zmk/app \
	    --pristine --board "${nice}"

west_built_xiao= \
	    west build /zmk/app \
	    --pristine --board "${xiao}"

west_built_slate= \
	    west build /zmk/app \
	    --pristine --board "${slate}"

### SHIELDS ###
shield_settings_reset= \
	    -- -DSHIELD="settings_reset" -DZMK_CONFIG="/zmk-config"

### ARTIFACT ###
artifact_name_slate=/zmk/build/zephyr/zmk.uf2 \
				firmware/blank-slate.uf2
artifact_name_felerius_blank_slate=/zmk/build/zephyr/zmk.uf2 \
			       firmware/felerius_blank_slate.uf2

clone_zmk:
	if [ ! -d zmk ]; then git clone https://github.com/zmkfirmware/zmk -b v0.3.0; fi

base: clone_zmk
	docker run ${docker_opts} sh -c '\
		west init -l /zmk/app/; \
		west update'

### BASE START
extra_cmake_args_slate= -DCONFIG_ZMK_SLEEP=y \
			-DCONFIG_ZMK_IDLE_TIMEOUT=60000 \
			-DCONFIG_ZMK_IDLE_SLEEP_TIMEOUT=2200000 \
			-DKEYMAP_FILE=/zmk-config/lpgalaxy_blank_slate.keymap

extra_cmake_args_felerius_blank_slate= -DCONFIG_ZMK_SLEEP=y \
				       -DCONFIG_ZMK_IDLE_TIMEOUT=60000 \
				       -DCONFIG_ZMK_IDLE_SLEEP_TIMEOUT=2200000 \
				       -DKEYMAP_FILE=/zmk-config/felerius_blank_slate.keymap \
				       -DEXTRA_CONF_FILE=/zmk-config/felerius_blank_slate.conf

only_slate:
	docker run --rm ${docker_opts} \
		${west_built_slate} \
		${zmk_studio} \
		${extra_modules} ${extra_cmake_args_slate} \
		${keyboard_name_slate}
	@mkdir -p firmware
	docker cp ${default}:${artifact_name_slate}

only_felerius_blank_slate:
	docker run --rm ${docker_opts} \
		${west_built_slate} \
		${zmk_studio} \
		${extra_modules} ${extra_cmake_args_felerius_blank_slate} \
		${keyboard_name_felerius_blank_slate}
	@mkdir -p firmware
	docker cp ${default}:${artifact_name_felerius_blank_slate}

my_slate: only_slate \
	only_felerius_blank_slate

### OPEN A SHELL WITHIN THE ZMK ENVIRONMENT ###
shell:
	docker run --rm ${docker_opts} /bin/bash

### FLASH THE APPROPRIATE FIRMWARE TO THE BOOTLOADER ###
flash_slate:
	@ printf "Waiting for ${slate} bootloader to appear at ${nice_mount}.."
	@ while [ ! -d ${nice_mount} ]; do sleep 1; printf "."; done; printf "\n"
	cp -av firmware/blank-slate.uf2 ${nice_mount}

### CLEAN ###
clean_firmware:
	rm -f firmware/*.uf2

clean_zmk:
	if [ -d zmk ]; then rm -rfv zmk; fi

clean: clean_zmk
	-docker ps -aq --filter name='^zmk' | xargs docker container rm 2>/dev/null
	-docker volume list -q --filter name='zmk' | xargs docker volume rm 2>/dev/null

clean_all: clean clean_firmware
	@echo "cleaning all"

# vim: set ft=make fdm=marker:
