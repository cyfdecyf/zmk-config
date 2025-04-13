#!/bin/bash

# This script is used to build ZMK firmware for the C. Dux using local build toolchain.
# export ZMK_DIR to source directory containing the ZMK firmware before running this script.

# set -x
set -e

# Check if ZMK_DIR is set
if [ -z "$ZMK_DIR" ]; then
    echo "Please set ZMK_DIR to the source directory of ZMK firmware."
    exit 1
fi

SRC_DIR=$(cd $(dirname $0); pwd)


# If C_DUX_FIRMWARE_DIR is not set, put under firmware dir under current directory.
C_DUX_FIRMWARE_DIR=${C_DUX_FIRMWARE_DIR:-${SRC_DIR}/firmware}
mkdir -p ${C_DUX_FIRMWARE_DIR}

cd $ZMK_DIR
# To use west installed in local venv inside ZMK_DIR.
export PATH=${PWD}/.venv/bin:$PATH

# Must enter zmk's app directory to build.
cd app

ENABLE_USB_LOGGING=0
if [[ $ENABLE_USB_LOGGING == 1 ]]; then
    LEFT_EXTRA_OPT="-S zmk-usb-logging"
else
    LEFT_EXTRA_OPT="-S studio-rpc-usb-uart"
    LEFT_EXTRA_OPT2="-DCONFIG_ZMK_STUDIO=y"
fi

COMMON_OPT="-DZMK_EXTRA_MODULES='${SRC_DIR}' -DZMK_CONFIG='${SRC_DIR}/config'"
BOARD=nice_nano_v2

build_v1() {
    west build -d build/c_dux_left -b $BOARD $LEFT_EXTRA_OPT -- $COMMON_OPT -DSHIELD="c_dux_left led_indicator" $LEFT_EXTRA_OPT2
    cp -a build/c_dux_left/zephyr/zmk.uf2 ${C_DUX_FIRMWARE_DIR}/c_dux_left.uf2

    west build -d build/c_dux_right -b $BOARD -- $COMMON_OPT -DSHIELD="c_dux_right led_indicator"
    cp -a build/c_dux_right/zephyr/zmk.uf2 ${C_DUX_FIRMWARE_DIR}/c_dux_right.uf2
}

build_v2() {
    west build -d build/c_dux_rev2_left -b $BOARD $LEFT_EXTRA_OPT -- $COMMON_OPT -DSHIELD="c_dux_rev2_left led_indicator" $LEFT_EXTRA_OPT2
    cp -a build/c_dux_rev2_left/zephyr/zmk.uf2 ${C_DUX_FIRMWARE_DIR}/c_dux_rev2_left.uf2

    west build -d build/c_dux_rev2_right -b $BOARD -- $COMMON_OPT -DSHIELD="c_dux_rev2_right led_indicator"
    cp -a build/c_dux_rev2_right/zephyr/zmk.uf2 ${C_DUX_FIRMWARE_DIR}/c_dux_rev2_right.uf2
}

build_settings_reset() {
    west build -d build/settings_reset -b $BOARD -- -DSHIELD=settings_reset
    cp -a build/settings_reset/zephyr/zmk.uf2 ${C_DUX_FIRMWARE_DIR}/settings_reset.uf2
}

#build_settings_reset
#build_v1
build_v2
