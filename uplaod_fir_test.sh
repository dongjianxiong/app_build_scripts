#!/bin/bash

# 获取上传凭证
response=$(curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "type": "app",
    "bundle_id": "cn.itbox.passenger", // 你的应用的包名
    "api_token": "9d95a7baadebae1050a3dd719ab1a9c8"
  }' \
  https://api.bq04.com/apps)

# 解析返回的 JSON 获取上传凭证
upload_url=$(echo "$response" | jq -r '.cert.binary.upload_url')
# shellcheck disable=SC2086
upload_key=$(echo $response | jq -r '.cert.binary.key')
# shellcheck disable=SC2086
upload_token=$(echo $response | jq -r '.cert.binary.token')

echo -i "upload_url:$upload_url"
echo -i "upload_key:$upload_key"
echo -i "upload_token:$upload_token"

app_path=/Users/itbox_djx/Desktop/app_build/asset-manager/iOS/asset-manager_Profile_2024-06-27日18-51-21秒_1.0.0+37.ipa
app_version="1.0.0"
build_number="37"
app_name="asset_manager"

## 上传应用文件
#curl -F "key=$upload_key" \
#     -F "token=$upload_token" \
#     -F "file=$app_path" \  # 这里是你的应用文件路径
#     -F "x:name=$app_name" \
#     -F "x:version=$app_version" \
#     -F "x:build=$build_number" \
#     -F "x:changelog=your_changelog" \
#     "$upload_url"
