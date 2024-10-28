#!/bin/bash

uploadTestFlight(){
  echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>上传到TestFlight"
  #待上传app路径
  appPath=$1
  xcrun altool --validate-app -f $appPath -t ios --apiKey L989R8BU76 --apiIssuer 3b5290c9-b0bb-4be0-9866-327d7a7b2853 --verbose
  xcrun altool --upload-app -f $appPath -t ios --apiKey L989R8BU76 --apiIssuer 3b5290c9-b0bb-4be0-9866-327d7a7b2853 --verbose

#  curl -X POST -H "Content-Type: application/json" -d "{\"msg_type\":\"text\",\"content\":{\"text\":\"app更新提醒\n您的应用已经上传至TestFlight，请20-30分钟后准备测试\n版本信息：${BUNDLESHORTVERSION}(Build ${VERSION})-$ip-$BRANCH-${BUILD_ID}\"}}" https://open.feishu.cn/open-apis/bot/v2/hook/a5c3d5f3-07d6-4232-87d4-13a3abfb3026
  # shellcheck disable=SC2028
  echo "待上传app路径：\n"$appPath
  # shellcheck disable=SC2028
  echo "\n\n\n\n"
}

uploadTestFlight "$1"