#!/bin/bash
#  # 获取脚本所在目录的绝对路径
#  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
#  # 项目根目录
#  PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
#
  echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>上传蒲公英"
  # 待上传app路径
  appPath=$1
  # 构建信息
  updateInformation=$2
  # 蒲公英上传结果
  result=''
  # 蒲公英key
  AKEY="1963f3a3016786d4fc09358fc5b78315"
  UKEY="bb5b5581c302109dc779e461096ad42d"
  echo "开始上传蒲公英"
#  curl -F"file=@$appPath"-F"uKey=$UKEY"-F"_api_key=$AKEY" https://www.pgyer.com/apiv2/app/upload

  # shellcheck disable=SC2154
  # shellcheck disable=SC2034
  result="$(curl -F "file=@$appPath" -F "uKey=$UKEY" -F "buildUpdateDescription=$updateInformation" -F "_api_key=$AKEY" -F 'buildInstallType=1' -F 'buildPassword=000000' https://www.pgyer.com/apiv2/app/upload)"
  # shellcheck disable=SC2028
  echo "app详细信息：\n""$result"
  echo "结束上传蒲公英"
  echo "\n\n\n\n"