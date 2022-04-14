#!/bin/sh
CWD=$(pwd)
KERNEL_VAR_FILE=${CWD}/kernel-vars

if [ ! -f ${KERNEL_VAR_FILE} ]; then
    echo "Kernel variable file '${KERNEL_VAR_FILE}' does not exist, run ./build_kernel.sh first"
    exit 1
fi

. ${KERNEL_VAR_FILE}

DRIVER_DIR="vyos-realtek-r8125"
DRIVER_NAME="r8125"
DRIVER_VERSION="9.008.00"
DRIVER_VERSION_EXTRA="1"
DRIVER_OPTS="ENABLE_MULTIPLE_TX_QUEUE=y ENABLE_RSS_SUPPORT=y"

# Build up Debian related variables required for packaging
DEBIAN_ARCH=$(dpkg --print-architecture)
DEBIAN_DIR="${CWD}/vyos-realtek-${DRIVER_NAME}_${DRIVER_VERSION}-${DRIVER_VERSION_EXTRA}_${DEBIAN_ARCH}"
DEBIAN_CONTROL="${DEBIAN_DIR}/DEBIAN/control"

echo "I: Compile Kernel module for realtek ${DRIVER_NAME} driver"
make -C ${KERNEL_DIR} \
    M=${CWD}/${DRIVER_DIR}/src \
    INSTALL_MOD_PATH=${DEBIAN_DIR} \
    $DRIVER_OPTS \
    modules modules_install

mkdir -p $(dirname "${DEBIAN_CONTROL}")
cat << EOF >${DEBIAN_CONTROL}
Package: vyos-realtek-${DRIVER_NAME}
Version: ${DRIVER_VERSION}-${DRIVER_VERSION_EXTRA}
Section: kernel
Priority: extra
Architecture: ${DEBIAN_ARCH}
Maintainer: Youyuan <youyuanluo@126.com>
Description: Vendor based driver for realtek ${DRIVER_NAME}
Depends: linux-image-${KERNEL_VERSION}${KERNEL_SUFFIX}
EOF

# delete non required files which are also present in the kernel package
find ${DEBIAN_DIR} -name "modules.*" | xargs rm -f

# build Debian package
echo "I: Building Debian package vyos-realtek-${DRIVER_NAME}"
fakeroot dpkg-deb --build ${DEBIAN_DIR}


echo "I: Cleanup ${DRIVER_NAME} source"
cd ${CWD}
if [ -d ${DRIVER_DIR} ]; then
    rm -rf ${DRIVER_DIR}
fi
if [ -d ${DEBIAN_DIR} ]; then
    rm -rf ${DEBIAN_DIR}
fi
