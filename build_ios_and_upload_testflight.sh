#!/bin/bash
# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
#    1)、打包平台类型 PlatformType（Android、iOS、Android_iOS）
#    2)、编译环境 PackageType（Debug、Release、Profile）
#    3)、服务环境 IsRelease（是否上线 true-是， false-不是）
#    4)、发布渠道 UploadType （Fir、TestFlight（iOS）、APPStore（iOS））
#    5)、是否更新插件 UpgradePlugin （是否上线 true-是， false-不是）
#    6)、本机密码 Password,通过外部传入, 示例：sh .build_script/build_and_upload.sh

PlatformType=iOS # Android、iOS、Android_iOS
PackageType=Profile # Debug、Release、Profile
UploadType=TestFlight    # Fir、TestFlight（iOS）、APPStore（iOS）
IsRelease=false  # 是否上线 true-是， false-不是
UpgradePlugin=false # 是否更新插件 true-是， false-不是
Password=$1   # 本机密码


sh "$SCRIPT_DIR"/build_android_and_ios.sh $PlatformType $PackageType $IsRelease $UploadType $UpgradePlugin "$Password"


