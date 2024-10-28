#!/bin/bash

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# 项目根目录
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# 项目的pubspec.yaml文件
pubspec_file=$PROJECT_ROOT/pubspec.yaml

# 读取文件中的版本号
version_line=$(grep 'version:' "$pubspec_file")
# shellcheck disable=SC2001
current_version=$(echo "$version_line" | sed 's/version: //')

# 分割版本号
base_version=$(echo "$current_version" | cut -d'+' -f1)
build_number=$(echo "$current_version" | cut -d'+' -f2)

# 自减版本号
new_build_number=$((build_number - 1))
new_version="${base_version}+${new_build_number}"

# 替换文件中的版本号
sed -i '' "s/version: $current_version/version: $new_version/" "$pubspec_file"
