#!/bin/bash

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# 项目根目录
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck disable=SC2164
cd "$PROJECT_ROOT"
git add pubspec.yaml
git commit -m "chore(t-4957982926): 更新构建版本号"

