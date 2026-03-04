#!/bin/bash
# 下载 Rerun Viewer 到指定目录
echo "正在下载 Rerun Viewer (约 180MB)，请稍候..."
wget -O rerun-cli.tar.gz https://github.com/rerun-io/rerun/releases/download/0.30.0/rerun-cli-0.30.0-x86_64-unknown-linux-gnu.tar.gz

echo "正在解压..."
tar -xzf rerun-cli.tar.gz
mv rerun Visualisation/rerun_viewer/rerun
chmod +x Visualisation/rerun_viewer/rerun

# 清理垃圾
rm rerun-cli.tar.gz
echo "下载完成！Viewer 已准备就绪。"