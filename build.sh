#!/bin/sh

# environment variables
export OPENSSL_VERSION="1.1.1c" # specify the openssl version to use
export PJSIP_VERSION="2.9"
export OPUS_VERSION="1.3.1"
export MACOS_MIN_SDK_VERSION="10.12"
export IOS_MIN_SDK_VERSION="9.0"

# see http://stackoverflow.com/a/3915420/318790
# 返回真实的路径(绝对路径)
function realpath { echo $(cd $(dirname "$1"); pwd)/$(basename "$1"); }

# build.sh 脚本文件的绝对路径
__FILE__=`realpath "$0"`
# build.sh 脚本文件所在的文件夹
__DIR__=`dirname "${__FILE__}"`

# build 文件夹
BUILD_DIR="${__DIR__}/build"
# 如果 build 文件夹不存在，则创建这个文件夹
if [ ! -d ${BUILD_DIR} ]; then
    mkdir ${BUILD_DIR}
fi

# download
function download() {
    "${__DIR__}/download.sh" "$1" "$2" #--no-cache
}

# openssl
# openssl 文件夹
OPENSSL_DIR="${BUILD_DIR}/openssl"

# 是否支持 openssl
OPENSSL_ENABLED=
# openssl 的下载和构建
function openssl() {
  # 如果 openssl 还没有构建 iOS 和 macOS，则创建 openssl 文件夹
    if [ ! -d "${OPENSSL_DIR}/lib/iOS" ] || [ ! -d "${OPENSSL_DIR}/lib/macOS" ]; then
        if [ ! -d "${OPENSSL_DIR}" ]; then
            mkdir -p "${OPENSSL_DIR}"
        fi

        # 使用 openssl 脚本构建 openssl
        "${__DIR__}/openssl/openssl.sh" "--version=${OPENSSL_VERSION}" "--reporoot=${OPENSSL_DIR}" "--macos-min-sdk=${MACOS_MIN_SDK_VERSION}" "--ios-min-sdk=${IOS_MIN_SDK_VERSION}"
    else
        echo "Using OpenSSL..."
    fi
    
    OPENSSL_ENABLED=1
}

# opus
# opus 的路径
OPUS_DIR="${BUILD_DIR}/opus"
# 是否使用 opus
OPUS_ENABLED=
# opus 的下载和构建
function opus() {
  # 检查是否构建成功了，如果没有构建成功则用 opus.sh 构建 opus
    if [ ! -f "${OPUS_DIR}/dependencies/lib/libopus.a" ] || [ ! -d "${OPUS_DIR}/dependencies/include/opus/" ]; then
        "${__DIR__}/opus.sh" "${OPUS_DIR}"
    else
        echo "Using OPUS..."
    fi
    
    OPUS_ENABLED=1
}

# pjsip
# pjsip 的路径
PJSIP_DIR="${BUILD_DIR}/pjproject"
# 使用 pjsip.sh 构建 pjsip
function pjsip() {
#    "${__DIR__}/pjsip.sh" "${PJSIP_DIR}" --with-openssl "${OPENSSL_DIR}" --with-opus "${OPUS_DIR}/dependencies"
#    "${__DIR__}/pjsip.sh" "${PJSIP_DIR}" --with-opus "${OPUS_DIR}/dependencies"
    "${__DIR__}/pjsip.sh" "${PJSIP_DIR}"
}

# 构建 ssl
#openssl
# 构建 opus
#opus
# 构建 pjsip
pjsip
