#!/bin/bash
#
# Copyright � 2016-2017, Akhil Narang "akhilnarang" <akhilnarang.1999@gmail.com>
# Build Script For Custom Kernel for the OnePlus One
#
# This software is licensed under the terms of the GNU General Public
# License version 2, as published by the Free Software Foundation, and
# may be copied, distributed, and modified under those terms.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# Please maintain this if you use this script or any part of it
#

export DEVICE="bacon";
export ARCH="arm"
case $TC_VERSION in
  "4.9-uber")
  export TC_VERSION_DISPLAY="UBER-4.9"
  ;;
  *)
  export TC_VERSION="4.9"
  export TC_VERSION_DISPLAY="GCC-4.9"
  ;;
esac
export TC="arm-linux-androideabi-"
export TOOLCHAIN="${KERNELDIR}/toolchain/${ARCH}/${TC}${TC_VERSION}"
export IMAGE="arch/$ARCH/boot/zImage-dtb"
export ANYKERNEL=$KERNELDIR/anykernel/${DEVICE}
export DEFCONFIG="bacon_defconfig";
export ZIP_DIR="${KERNELDIR}/files/${DEVICE}"
if [ -z ${KRONICVERSION} ]; then
export KRONICVERSION="$(grep "KRONICVERSION ?= " ${KERNELDIR}/bacon/Makefile | awk '{print $3}')";
fi
export ZIPNAME="Kronic-${KRONICVERSION}-${DEVICE}-$(date +%Y%m%d-%H%M)-${TC_VERSION_DISPLAY}.zip"
export FINAL_ZIP="${ZIP_DIR}/${ZIPNAME}"

if [ -f "${TOOLCHAIN}/bin/arm-eabi-gcc" ];
then
export CROSS_COMPILE="${TOOLCHAIN}/bin/arm-eabi-"
elif [ -f "${TOOLCHAIN}/bin/arm-linux-androideabi-gcc" ];
then
export CROSS_COMPILE="${TOOLCHAIN}/bin/arm-linux-androideabi-"
else
echo -e "No suitable arm-eabi- or arm-linux-androideabi- toolchain found in ${TOOLCHAIN}"
fi

[ -d $ZIP_DIR ] || mkdir -p $ZIP_DIR

cd $KERNELDIR/bacon
rm -f $IMAGE

if [[ "$1" =~ "mrproper" ]];
then
make mrproper
fi

if [[ "$1" =~ "clean" ]];
then
make clean
fi

make $DEFCONFIG
START=$(date +"%s")
make -j16
END=$(date +"%s")
DIFF=$(($END - $START))
echo -e "Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.";

if [ ! -f "$IMAGE" ];
then
echo -e "Kernel Compilation Failed!";
echo -e "Fix The Errors!";
else
echo -e "Build Succesful!"

cp -v $IMAGE $ANYKERNEL/zImage
cd -
cd $ANYKERNEL
zip -r9 $FINAL_ZIP *;
cd -
if [ -f "$FINAL_ZIP" ];
then
echo -e "$THUGVERSION zip can be found at $FINAL_ZIP";
else
echo -e "Zip Creation Failed =(";
fi # $FINAL_ZIP found
fi # no $IMAGE found
