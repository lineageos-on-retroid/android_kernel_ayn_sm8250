#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

### Customisable variables
export TC_DIR="/media/samsung_ssd/los23/prebuilts/clang/host/linux-x86/clang-r563880c"
export DEFCONFIG="vendor/kona-perf_defconfig"

export KBUILD_OUTPUT=out
export KBUILD_BUILD_USER="$USER"
export KBUILD_BUILD_HOST=$(cat /etc/hostname)
### End

# Set up environment
function envsetup() {
    export ARCH=arm64
    export PATH="$TC_DIR/bin:$PATH"
}

# Wrapper to utilise all available cores
function m() {
    make -j$(nproc) ARCH="$ARCH" DTC_EXT="$(command -v dtc)" LLVM=1 LLVM_IAS=1 CC="clang" "$@"
}

# Pack kernel
function pack() {
    OUT="$KBUILD_OUTPUT"/arch/"$ARCH"/boot/dts/vendor/moorechip

    mkbootimg \
        --header_version 2 \
        --os_version 11.0.0 \
        --os_patch_level 2023-09 \
        --kernel prebuilt/kernel \
        --ramdisk prebuilt/ramdisk \
        --dtb "$OUT"/moorechip.dtb \
        --pagesize 0x00001000 \
        --base 0x00000000 \
        --kernel_offset 0x00008000 \
        --ramdisk_offset 0x01000000 \
        --second_offset 0x00000000 \
        --tags_offset 0x00000100 \
        --dtb_offset 0x0000000001f00000 \
        --board '' \
        --cmdline 'console=ttyMSM0,115200n8 earlycon=msm_geni_serial,0xa90000 androidboot.hardware=qcom androidboot.console=ttyMSM0 androidboot.memcg=1 lpm_levels.sleep_disabled=1 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 service_locator.enable=1 androidboot.usbcontroller=a600000.dwc3 swiotlb=2048 loop.max_part=7 cgroup.memory=nokmem,nosocket reboot=panic_warm buildvariant=user' \
        -o boot.img

    mkdtboimg create dtbo.img --page_size=4096 "$OUT"/retroid-rp5-overlay.dtbo
}

# Regenerate defconfig
function rd() {
    m "$DEFCONFIG" savedefconfig || return
    cp "$KBUILD_OUTPUT"/defconfig arch/"$ARCH"/configs/"$DEFCONFIG"
}

# Build kernel
function mka() {
    rd || return
    m dtbs || return
    pack || return
}

envsetup
