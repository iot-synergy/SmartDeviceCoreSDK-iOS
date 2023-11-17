#!/bin/bash
set -e

TARGETNAME='SmartDeviceCoreSDK'
WORK_TYPE="project" # 有效值 project / workspace (cocoapods项目)
SCHEME_NAME="SmartDeviceCoreSDK"
SCRIPT_PATH=$(cd `dirname $0`; pwd)
SRCROOT=${SCRIPT_PATH}/Pods
WORK_PATH=${SRCROOT}/${TARGETNAME}

rm -rf ${SCRIPT_PATH}/build
rm -rf ${TARGETNAME}.xcframework

BUILD_ROOT=${SCRIPT_PATH}/build
CONFIGURATION="Release"

mkdir ${SCRIPT_PATH}/build
echo "🚀 开始创建${TARGETNAME}.framework"

INSTALL_DIR=${SRCROOT}/Products/${TARGETNAME}.framework
DEVICE_DIR=${BUILD_ROOT}/${CONFIGURATION}-iphoneos/${TARGETNAME}/${TARGETNAME}.framework
DEVICE_DSYM_DIR=${BUILD_ROOT}/${CONFIGURATION}-iphoneos/${TARGETNAME}/${TARGETNAME}.framework.dSYM
DEVICE_SWIFTMODULE_DIR=${DEVICE_DIR}/"Modules"/${TARGETNAME}".swiftmodule"
SIMULATOR_DIR=${BUILD_ROOT}/${CONFIGURATION}-iphonesimulator/${TARGETNAME}/${TARGETNAME}.framework
SIMULATOR_DSYM_DIR=${BUILD_ROOT}/${CONFIGURATION}-iphonesimulator/${TARGETNAME}/${TARGETNAME}.framework.dSYM
XCFRAMEWORK_DIR=${BUILD_ROOT}/${TARGETNAME}.xcframework
SIMULATOR_SWIFTMODULE_DIR=${SIMULATOR_DIR}/"Modules"/${TARGETNAME}".swiftmodule"

echo "🚀 开始编译真机设备"
xcodebuild -${WORK_TYPE} "${SRCROOT}/Pods.xcodeproj" -scheme $SCHEME_NAME -configuration ${CONFIGURATION} -sdk iphoneos

if [ "$?" != 0 ]
then
    echo "❎❎ 真机设备编译失败..."
    exit 0
fi

xcodebuild -${WORK_TYPE} "${SRCROOT}/Pods.xcodeproj" -scheme $SCHEME_NAME -configuration ${CONFIGURATION} -sdk iphonesimulator -arch x86_64

if [ "$?" != 0 ]
then
    echo "❎❎ 模拟器设备编译失败..."
    exit 0
fi

# 如果合并包已经存在，则替换
if [ -d "${INSTALL_DIR}" ]
then
    rm -rf "${INSTALL_DIR}"
fi

mkdir -p "${INSTALL_DIR}"
cp -R "${DEVICE_DIR}/" "${INSTALL_DIR}/"
echo "真机路径: ${DEVICE_DIR}/${TARGETNAME}" 
echo "模拟器路径: ${SIMULATOR_DIR}/${TARGETNAME}"
# 合成 通用的 .xcframework
xcodebuild -create-xcframework -framework ${DEVICE_DIR} -framework ${SIMULATOR_DIR} -output ${TARGETNAME}.xcframework
echo "合并后的xcframework路径是: ${XCFRAMEWORK_DIR}"
# 拷贝对应的 dsym 到 xcframework 文件里
cp -R ${DEVICE_DSYM_DIR} ${TARGETNAME}.xcframework/ios-arm64
cp -R ${SIMULATOR_DSYM_DIR} ${TARGETNAME}.xcframework/ios-x86_64-simulator

ls -lh ${TARGETNAME}.xcframework
du -sh ${TARGETNAME}.xcframework

# 拷贝 xcframework 到组件的 Binary 文件夹下
rm -rf ../SmartDeviceCoreSDK/Binary/
mkdir -p ../SmartDeviceCoreSDK/Binary/
cp -R ${TARGETNAME}.xcframework ../SmartDeviceCoreSDK/Binary/
cp -R ../SmartDeviceCoreSDK/Source/SmartLiveSDK/SmartWebRTC/Frameworks/WebRTC.xcframework ../SmartDeviceCoreSDK/Binary/

# 删除 当前的 xcframework
rm -rf ${TARGETNAME}.xcframework

echo "🚀  ✌️ ✌️ ✌️  ${TARGETNAME}.framework 制作成功"