#!/bin/sh
#
# Build latest stable ARM kernel for QEMU Raspberry Pi 3 Emulation
#
#######################################################
MODEL=rpi3
TOOLCHAIN=aarch64-linux-gnu
COMMIT=$(curl -s https://www.kernel.org | grep -A1 latest_link | tail -n1 | egrep -o '>[^<]+' | egrep -o '[^>]+')
export ARCH=arm64
export CROSS_COMPILE=${TOOLCHAIN}-

curl -L -O -C - "https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$COMMIT.tar.xz" || exit 1

# Kernel Compilation
if [ ! -d linux-$COMMIT ]; then
	tar xf linux-$COMMIT.tar.xz
fi

cd linux-$COMMIT

KERNEL_VERSION=$(make kernelversion)
KERNEL_TARGET_FILE_NAME=qemu-kernel-$MODEL-$KERNEL_VERSION-aarch64
echo "Building Qemu Raspberry Pi kernel qemu-kernel-$KERNEL_VERSION"

# Config
cp arch/arm/configs/vexpress_defconfig arch/arm64/configs
make -j 4 -k CC="ccache ${TOOLCHAIN}-gcc" vexpress_defconfig
scripts/kconfig/merge_config.sh .config ../config

# Compiling
#make CC="ccache ${TOOLCHAIN}-gcc" ARCH=arm64 CROSS_COMPILE=${TOOLCHAIN}- xconfig
make -j 4 -k CC="ccache ${TOOLCHAIN}-gcc" Image.gz

cp arch/arm64/boot/Image.gz ../build/$KERNEL_TARGET_FILE_NAME
