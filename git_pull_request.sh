#!/bin/bash

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# 项目根目录
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# 进入项目目录
cd "$PROJECT_ROOT" || exit

# 需要拉取的分支
branchName=$(git rev-parse --abbrev-ref HEAD) # 获取当前分支
echo "打包分支全称：${branchName}"
# 选择分支
SELECTED_BRANCH=${branchName}
echo "拉取git信息 branch:$SELECTED_BRANCH"

# 更新远程分支
git fetch origin

# 选择的分支是否本地存在
if git show-ref --verify --quiet refs/heads/"${SELECTED_BRANCH}"; then
  echo "本地分支存在分支:$SELECTED_BRANCH"
  git checkout "${SELECTED_BRANCH}"
else
  echo "本地不存在这个分支:$SELECTED_BRANCH-${branchName}"
#  git checkout -b "${SELECTED_BRANCH}" "${branchName}"
fi

# 当前分支
currentBranch=$(git symbolic-ref --short -q HEAD)
echo "切换分支完成，当前分支为：${currentBranch}"

git pull origin "${SELECTED_BRANCH}"
echo "拉取最新代码"

echo "当前编译包使用的Git分支为：$(git describe --contains --all HEAD | tr -s '\n')"
echo "当前编译包使用的Git commit短id为：$(git rev-parse --short HEAD)"
gitId=$(git rev-parse HEAD)
echo "当前编译包使用的Git commit完整id为：$gitId"

# 获取最新的 3 条提交信息
gitUpdateInformation=$(git log "$SELECTED_BRANCH" --pretty=format:"%s" -3)
echo "Git更新信息: $gitUpdateInformation"
