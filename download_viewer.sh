#!/bin/bash
set -e  # 出错时立即停止

# 1. 自动获取最新版本号 (例如 0.30.0)
LATEST_VERSION=$(curl -s https://api.github.com/repos/rerun-io/rerun/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

echo "发现最新版本: $LATEST_VERSION"
echo "正在下载 Rerun Viewer，请稍候..."

# 2. 准备目录
mkdir -p Visualisation/rerun_viewer

# 3. 直接下载 Linux 二进制文件 (注意去掉了 .tar.gz)
DOWNLOAD_URL="https://github.com/rerun-io/rerun/releases/download/${LATEST_VERSION}/rerun-cli-${LATEST_VERSION}-x86_64-unknown-linux-gnu"

# 4. 下载并重命名为 rerun，直接放到目标文件夹
wget -O Visualisation/rerun_viewer/rerun "$DOWNLOAD_URL"

# 5. 赋予执行权限
chmod +x Visualisation/rerun_viewer/rerun

echo "--------------------------------"
echo "下载完成！Viewer 已准备就绪。"
echo "位置: Visualisation/rerun_viewer/rerun"