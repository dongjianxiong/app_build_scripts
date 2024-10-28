#!/bin/bash

#    1)、打包分支 BranchName（支持选择Branch、Tag）
#    2)、编译环境 PackageType（Debug、Release、Profile）
#    3)、服务环境 IsRelease（是否上线 true-是， false-不是）
#    4)、发布渠道 UploadType：（Fir-fir.im、TestFlight、AppStore）
#    5)、是否更新插件 UpgradePlugin 是否上线 true-是， false-不是）
#    6)、是否更新插件 Password

# sh build_app.sh main Profile false Fir false peng624634

BranchName=$1
PackageType=$2
IsRelease=$3
UploadType=$4
UpgradePlugin=$5
Password=$6

PlatformType=iOS

echo "打包分支:$BranchName"
echo "打包配置类型:$PackageType"
echo "是否上线：$IsRelease"
echo "上传平台：$UploadType"
echo "是否需要更新三方组件：$UpgradePlugin"
echo "本机密码：$Password"

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# 项目根目录
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

#获取当前文件夹作为项目名称
PROJECT_NAME=$(basename "$PROJECT_ROOT")

pubspec_file=$PROJECT_ROOT/pubspec.yaml

# 读取文件中的版本号
version_line=$(grep 'version:' "$pubspec_file")
# shellcheck disable=SC2001
current_version=$(echo "$version_line" | sed 's/version: //')
# 分割版本号
base_version=$(echo "$current_version" | cut -d'+' -f1)
build_number=$(echo "$current_version" | cut -d'+' -f2)

#开始打包时间
BUILD_DATE=$(date +"%F日%H-%M-%S秒")

#导出文件路径，这里设置在桌面
EXPORT_DIR=$HOME/Desktop/app_build/${PROJECT_NAME}/$PlatformType
# shellcheck disable=SC2153
# 导出apk文件地址
EXPORT_PATH=${EXPORT_DIR}/${PROJECT_NAME}_${PackageType}_${BUILD_DATE}_${current_version}.ipa
# ARCHIVE 包地址
ARCHIVE_PATH=${EXPORT_DIR}/${PROJECT_NAME}_${PackageType}_${BUILD_DATE}_${current_version}.xcarchive
##创建文件夹
createDir() {
  echo "创建文件目录"
  # shellcheck disable=SC2115
  rm -rf "${EXPORT_DIR}"
  if [ ! -d "${EXPORT_DIR}" ]; then
    mkdir -p "${EXPORT_DIR}"
  fi
  # shellcheck disable=SC2028
  echo -i "文件夹创建成功，打包中间产物将全部导出到:${EXPORT_DIR}目录下\n"
}

# ios包
buildIpa() {
    # 在编译之前解锁钥匙串，p后面"******"是你的mac的登陆密码
    security unlock-keychain -p "$Password" ~/Library/Keychains/login.keychain
    echo -i "============ iOS 打包============"
    export LANG=en_US.UTF-8
    export LANGUAGE=en_US.UTF-8
    export LC_ALL=en_US.UTF-8

    # 进入iOS工程目录
     # shellcheck disable=SC2164
    cd "$PROJECT_ROOT"/ios

    SCHEME=Runner
    WORKSPACE=${SCHEME}.xcworkspace
    iOS_PACKING_TYPE="development" #development/debugging
    if [ "$UploadType" == "Fir" ] ; then
      iOS_PACKING_TYPE="ad-hoc"
    elif [ "$UploadType" == "AppStore" ] ; then
        iOS_PACKING_TYPE="app-store"
    elif [ "$UploadType" == "TestFlight" ] ; then
        iOS_PACKING_TYPE="app-store"
    fi

    EXPORT_OPTIONS_PLIST=$SCRIPT_DIR/ExportProfiles/${iOS_PACKING_TYPE}.plist

    echo -i "============Begin Build Clean============"
#    rm -rf Pods
    rm -rf Podfile.lock
    rm -rf build
    pod cache clean --all
    xcodebuild clean -workspace $WORKSPACE -scheme ${SCHEME} -configuration "$PackageType"
    pod install
    echo -i "============   Build Archive  ============"
    xcodebuild archive -workspace ${WORKSPACE} -scheme ${SCHEME} -destination "generic/platform=iOS" -archivePath "$ARCHIVE_PATH" -configuration "$PackageType"

    if [ -e "${ARCHIVE_PATH}" ]; then
      echo -i "=========Build Archive Success=========="
    else
      pwd
      resetBuildVersion
      echo -e "============Archive FAIL with no ${ARCHIVE_PATH}============"
      exit 1
    fi

    echo -i "============Export IPA============"
    xcodebuild -exportArchive -archivePath "$ARCHIVE_PATH" -exportPath "${EXPORT_DIR}" -exportOptionsPlist "${EXPORT_OPTIONS_PLIST}"

   # 遍历指定目录中的所有 .ipa 文件
   for file in "$EXPORT_DIR"/*.ipa; do
     if [ -e "$file" ]; then
       # 重命名文件
       mv "$file" "$EXPORT_PATH"
       echo -i "Renamed $file to $EXPORT_PATH"
     else
       resetBuildVersion
       echo -e "No .ipa files found in the specified directory."
     fi
   done

    if [ -f "${EXPORT_PATH}" ]; then
        echo -i "============Export IPA SUCCESS============"
    else
      resetBuildVersion
        echo -e "============Export IPA FAIL with no ipa============"
        exit 1
    fi

    # shellcheck disable=SC2034
    END_DATE="$(date +'%Y%m%d_%H%M')"
    echo -i "============Export end :${BUILD_DATE}============"
}

uploadApp(){
  if [ "$UploadType" == Fir ]; then
    # 上传到fir.im
    sh "$SCRIPT_DIR"/upload_ios_to_fir.sh "$EXPORT_PATH"
    notify_feishu
  elif [ "$UploadType" == TestFlight ]; then
    # 上传到testflight
    sh "$SCRIPT_DIR"/upload_ios_to_testflight.sh "$EXPORT_PATH"
    notify_feishu
  elif [ "$UploadType" == AppStore ]; then
    # 上传到AppStore
    sh "$SCRIPT_DIR"/upload_ios_to_app_store.sh "$EXPORT_PATH"
    notify_feishu
  else
    echo "Error: Invalid UploadType"
  fi
}

notify_feishu(){
   sh "$SCRIPT_DIR"/notify_feishu.sh "$base_version" "$build_number" "$BUILD_DATE" "$PackageType" "$BranchName" "$PlatformType" $UploadType
}

resetBuildVersion() {
    sh "$SCRIPT_DIR"/reset_build_version.sh
}

createDir
buildIpa
uploadApp
