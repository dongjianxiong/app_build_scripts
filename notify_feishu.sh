#!/bin/bash

# 打包操作
# 假设打包输出在 ./build_output 目录

Version=$1
BuildNumber=$2
Date=$3
PackageType=$4
Branch=$5
PlatformType=$6
UploadType=$7

url="https://www.betaqr.com.cn/apps"
if [ "$UploadType" == Fir ]; then
  if [ "$PlatformType" == iOS ]; then
    url="https://fir.xcxwo.com/6wylhx"
  else
    url="https://fir.xcxwo.com/f1gxemaj"
  fi
else
  if [ "$UploadType" == TestFlight ]; then
    url="https://testflight.apple.com/join/COQttuHi"
  elif [ "$UploadType" == AppStore ]; then
    url="https://www.apple.com.cn/app-store/"
  elif [ "$UploadType" == Android ]; then
    url="android 应用市场"
  fi
fi



# 飞书 Webhook URL
WEBHOOK_URL="https://open.feishu.cn/open-apis/bot/v2/hook/05ca51d8-ef3e-49d1-9153-1b72d52fe12f"
#WEBHOOK_URL1="https://open.feishu.cn/open-apis/bot/v2/hook/99ee1249-30fa-44ce-a194-fe3a56d09acd"

info="\n打包版本：$Version($BuildNumber)\n打包分支：$Branch\n打包类型：$PackageType\n打包时间：$Date"

# 消息内容
#PACKAGE_RESULT="打包已完成！请检查打包结果。点击以下链接 \n[Android点击这里](https://fir.xcxwo.com/qy2bxzfr) \n[iOS点击这里](https://fir.xcxwo.com/rq2pscvb) \n查看详情"
PACKAGE_RESULT="$PlatformType 打包已完成！请检查打包结果。$info\n点击($url)查看详情"

# 构建 JSON 消息
JSON_PAYLOAD=$(cat <<EOF
{
    "msg_type": "text",
    "content": {
        "text": "$PACKAGE_RESULT"
    }
}
EOF
)

# 发送消息到飞书
curl -X POST -H "Content-Type: application/json" -d "$JSON_PAYLOAD" "$WEBHOOK_URL"

#### 发送消息到飞书1
#curl -X POST -H "Content-Type: application/json" -d "$JSON_PAYLOAD" "$WEBHOOK_URL1"

echo "Message sent to Feishu group."

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

sh "$SCRIPT_DIR"/commit_build_version.sh

