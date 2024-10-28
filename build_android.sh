#!/bin/bash

#    1)、打包分支 BranchName（支持选择Branch、Tag）
#    2)、编译环境 PackageType（Debug、Release、Profile）
#    3)、服务环境 IsRelease（是否上线 true-是， false-不是）
#    4)、发布渠道 UploadType：（Fir-fir.im、Android-相应的应用市场）
#    5)、是否更新插件 UpgradePlugin 是否上线 true-是， false-不是）

# sh build_app.sh main Profile false Fir false 235813

BranchName=$1
PackageType=$2
IsRelease=$3
UploadType=$4
UpgradePlugin=$5

PlatformType=Android

echo "打包分支:$BranchName"
echo "打包配置类型:$PackageType"
echo "是否上线：$IsRelease"
echo "上传平台：$UploadType"
echo "是否需要更新三方组件：$UpgradePlugin"


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
EXPORT_PATH=${EXPORT_DIR}/${PROJECT_NAME}_${PackageType}_${BUILD_DATE}_${current_version}.apk


## 创建导出目录
createDir() {
  echo -a "创建文件目录"
  # shellcheck disable=SC2115
  rm -rf "${EXPORT_DIR}"
  if [ ! -d "${EXPORT_DIR}" ]; then
    mkdir -p "${EXPORT_DIR}"
  fi
  # shellcheck disable=SC2028
  echo -a "文件夹创建成功，打包中间产物将全部导出到:${EXPORT_DIR}目录下\n"
}

# android包
buildApk() {
    export ANDROID_SDK_ROOT="${HOME}/Library/Android/sdk"
    export ANDROID_HOME="${HOME}/Library/Android/sdk"
    # 拉取代码
    echo -a "拉取代码：$BranchName"
    sh "$SCRIPT_DIR"/git_pull_request.sh "$BranchName"
    # 更新插件
    flutter clean
    if [ "$UpgradePlugin" == true ]; then
      echo -a 'Flutter 升级插件'
      flutter packages upgrade
    else
      echo -a 'Flutter 升级插件'
      flutter packages get
    fi

    PackingType=''
    if [ "$PackageType" == Debug ]; then
        # shellcheck disable=SC2028
        echo -a "开始打 android Debug 包\n"
        flutter build apk --debug
        PackingType=debug
    elif [ "$PackageType" == Profile ]; then
        # shellcheck disable=SC2028
        echo -a "开始打 android Profile 包\n"
        flutter build apk --profile
        PackingType=profile
    else
        # shellcheck disable=SC2028
        echo -a "开始打 android Release 包\n"
        flutter build apk --release
        PackingType=release
    fi


    # shellcheck disable=SC2028
    mv build/app/outputs/flutter-apk/app-$PackingType.apk "$EXPORT_PATH"
    echo -a "move build/app/outputs/flutter-apk/app-$PackingType.apk to $EXPORT_PATH"

    # shellcheck disable=SC2028
    echo -a "android打包结束\n"
    if [ -f "${EXPORT_PATH}" ]; then
        echo -a "============Export APK SUCCESS============"
        uploadApp
    else
        resetBuildVersion
        echo -e "============Export APK FAIL with no apk============"
        exit 1
    fi
}

uploadApp(){
  # 选择上传
  if [ "$UploadType" == Fir ]; then
    sh "$SCRIPT_DIR"/upload_android_to_fir.sh "$EXPORT_PATH"
    notify_feishu
  elif [ "$UploadType" == Android ]; then
    sh "$SCRIPT_DIR"/upload_android_to_fir.sh "$EXPORT_PATH"
    notify_feishu
  else
    echo -e "Error: Invalid UploadType"
  fi
}

notify_feishu(){
   sh "$SCRIPT_DIR"/notify_feishu.sh "$base_version" "$build_number" "$BUILD_DATE" "$PackageType" "$BranchName" "$PlatformType" $UploadType
}

resetBuildVersion() {
    sh "$SCRIPT_DIR"/reset_build_version.sh
}

createDir
buildApk
uploadApp
