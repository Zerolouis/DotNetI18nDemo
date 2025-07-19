#!/usr/bin/env bash
set -e

###############################################################################
# ❶ 变量 —— 根据项目实际路径改一下就行
###############################################################################
SRC_DIR="DotNetI18nDemo"        # 源码所在目录（含默认 .resx）
TARGET_ROOT="locales"        # 专门存翻译文件的顶层目录
SRC_LANG="en"                # 默认语言目录名
BRANCH="locales"             # 推到哪个分支（We­blate 用这个）

###############################################################################
# ❷ 清空旧目录，重新收集 .resx
###############################################################################
echo "🧹  clean $TARGET_ROOT/$SRC_LANG"
rm -rf  "$TARGET_ROOT/$SRC_LANG"
mkdir -p "$TARGET_ROOT/$SRC_LANG"

echo "📦  collect .resx from $SRC_DIR …"
# --parents 保留相对目录层级，方便多命名空间/多控件
find "$SRC_DIR" -name '*.resx' \
     -exec cp --parents {} "$TARGET_ROOT/$SRC_LANG/" \;

###############################################################################
# ❸ 提交并强推到 locales 分支
###############################################################################
echo "🚀  commit & push to branch '$BRANCH'"

git config user.name  "CI Bot"
git config user.email "ci@example.com"

git add "$TARGET_ROOT"
if git diff --cached --quiet; then
  echo "⚠️  No resx changes — skipping push."
  exit 0
fi

git commit -m "sync resx $(date -u +%F)"

# ✅ 加这一行：改 origin 远程地址，使用 Personal Access Token 推送
git remote set-url origin https://x-access-token:${BOT_TOKEN}@github.com/${GITHUB_REPOSITORY}.git

# ✅ 使用 Token 身份 push
git push -f origin HEAD:"$BRANCH"
