#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# 项目根目录
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
#    1)、打包平台类型 PlatformType（Android、iOS、Android_iOS）
#    2)、编译环境 PackageType（Debug、Release、Profile）
#    3)、服务环境 IsRelease（是否上线 true-是， false-不是）
#    4)、发布渠道 UploadType：测试环境（Firm、iOS内测还可以通过TestFlight）， 线上环境（iOS-AppStore， Android-相应的应用市场）
#    5)、是否更新插件 UpgradePlugin
#    6)、本机密码 Password

# sh build_app.sh iOS main Profile false Fir false 11111

PlatformType=$1
PackageType=$2
IsRelease=$3
UploadType=$4
UpgradePlugin=$5
Password=$6
BranchName=$(git rev-parse --abbrev-ref HEAD) # 获取当前分支


sh "$SCRIPT_DIR"/auto_increment_build_version.sh
sh "$SCRIPT_DIR"/git_pull_request.sh

#
## 环境变量路径
#FILE_PATH="$PROJECT_ROOT/lib/config/app_env_config.dart"
#
## 替换成 `true`
#echo "Setting isRelease to true..."
#sed -i '' 's/static bool isRelease = false;/static bool isRelease = true;/g' "$FILE_PATH"
#
## 检查是否替换成功
#if grep -q 'static bool isRelease = true;' "$FILE_PATH"; then
#    echo "isRelease set to true successfully."
#else
#    echo "Failed to set isRelease to true."
#    exit 1
#fi
#
## 执行打包脚本
#echo "Running build script..."
#./build_script.sh
#
## 打包完成后将 `true` 改回 `false`
#echo "Reverting isRelease to false..."
#sed -i '' 's/static bool isRelease = true;/static bool isRelease = false;/g' "$FILE_PATH"
#
## 检查是否还原成功
#if grep -q 'static bool isRelease = false;' "$FILE_PATH"; then
#    echo "isRelease reverted to false successfully."
#else
#    echo "Failed to revert isRelease to false."
#    exit 1
#fi
#
#echo "Build and revert process completed."


# 判断是否打线上包
checkIsReleaseConfig() {
  if [ "$IsRelease" == true ]; then
    # 如果是线上包，PackageType强制转为Release环境
    PackageType=Release
#    # 如果是iOS线上包，强制改为上传至AppStore
#    if [ "$PlatformType" == iOS ]; then
#      UploadType=AppStore
#    fi
    cp "$PROJECT_ROOT"/lib/common/config/app_env_config.dart "$PROJECT_ROOT"/tempConfig.dart
    cp "$PROJECT_ROOT"/lib/common/config/app_release_env_config.dart "$PROJECT_ROOT"/lib/common/config/app_env_config.dart
    echo '正在打线上包'
  else
    echo '正在打测试包'
  fi
}

build_app(){
  if [ "$PlatformType" == iOS ]; then
    sh "$SCRIPT_DIR"/build_ios.sh "$BranchName" "$PackageType" "$IsRelease" "$UploadType" "$UpgradePlugin" "$Password"
  elif [ "$PlatformType" == Android ]; then
    sh "$SCRIPT_DIR"/build_android.sh "$BranchName" "$PackageType" "$IsRelease" "$UploadType" "$UpgradePlugin"
  else
    sh "$SCRIPT_DIR"/build_android.sh "$BranchName" "$PackageType" "$IsRelease" "$UploadType" "$UpgradePlugin"
    sh "$SCRIPT_DIR"/build_ios.sh "$BranchName" "$PackageType" "$IsRelease" "$UploadType" "$UpgradePlugin" "$Password"
  fi
}

# 还原中间产物
resetConfig() {
  echo "还原中间产物"
  if [ -f "$PROJECT_ROOT/tempConfig.dart" ]; then
    cp "$PROJECT_ROOT"/tempConfig.dart "$PROJECT_ROOT"/lib/common/config/app_env_config.dart
    rm -f "$PROJECT_ROOT"/tempConfig.dart
  fi
}

checkIsReleaseConfig
build_app
resetConfig

