# rerun-cpp-portable 🚀

**一个开箱即用、免安装的 Rerun C++ 离线便携模板。**

`rerun-cpp-portable` 是专为 C++ 开发者打造的 Rerun 可视化脚手架。它通过“本地化 (Vendor)”的方式集成了 Rerun SDK 与 Viewer 渲染器，彻底解决了官方默认配置下**编译极慢**和**依赖系统环境**的痛点。

### ✨ 核心亮点：

* ⚡ **秒级编译**：采用预编译静态库接入。彻底告别每次 `rm -rf build` 后漫长的 Apache Arrow 底层库编译等待，主项目只需极速链接。
* 📦 **纯便携免安装**：Viewer 可执行文件直接内嵌于项目，CMake 自动将其拷贝到输出目录。无需配置环境变量，不污染系统环境。
* 🔌 **离线友好**：所有依赖均本地化管理，即使在无网络环境下也能顺利 `make`。
* 🛠️ **极简接入**：提供了一套结构清晰的 `CMakeLists.txt` 范例，只需几行代码即可无缝融入你现有的计算机视觉 / 机器人项目中。

---

# Rerun C++ SDK 本地集成指南

本指南介绍了如何将 Rerun C++ SDK 和 Viewer 渲染器以“本地化（Vendor）”的方式集成到项目中。
**优势**：实现免联网编译、统一团队开发环境，并彻底解决每次清理 `build` 目录后都需要缓慢重新编译 Apache Arrow 底层库的痛点。

## 📁 1. 推荐的项目目录结构

在开始之前，请确保你的项目目录结构如下（所有依赖均统一放在 `third_party` 文件夹中）：

```text
MyProject/
├── CMakeLists.txt
├── main.cpp
└── third_party/
    ├── rerun_cpp_sdk/       <-- [步骤2] 从官方 Releases 下载的源码解压至此
    ├── rerun_sdk_install/   <-- [步骤3] 编译后的静态库和头文件会自动安装到这里
    └── rerun_viewer/
        └── rerun            <-- [步骤2] 下载的官方 Viewer 可执行文件 (需加可执行权限)

```

## 📦 2. 准备工作 (下载与放置)

1. **下载 Rerun SDK 源码包**：
* 前往 [Rerun GitHub Releases](https://github.com/rerun-io/rerun/releases) 页面。
* 下载 `rerun_cpp_sdk.zip`。
* 将其解压到 `third_party/rerun_cpp_sdk/` 目录下。


2. **下载 Rerun Viewer (渲染器)**：
* 在同一个 Releases 页面，下载对应系统架构的 CLI 文件（例如：`rerun-cli-x.x.x-x86_64-unknown-linux-gnu.tar.gz`）。
* 解压出可执行文件，将其**重命名**为 `rerun`，并放入 `third_party/rerun_viewer/` 目录下。
* **重要**：赋予其可执行权限：
```bash
cd third_party/rerun_viewer/
chmod +x rerun

```





## 🔨 3. 编译 SDK 为静态库 (仅需执行一次！)

为了避免主项目每次 `rm -rf build` 后都要重新编译庞大的 Arrow 库，我们首先将 Rerun SDK 单独编译并“局部安装”为静态库。

打开终端，在项目根目录下依次执行：

```bash
# 1. 进入 SDK 源码目录
cd third_party/rerun_cpp_sdk

# 2. 创建临时构建目录
mkdir build && cd build

# 3. 配置 CMake (指定编译为 Release，并将安装出口重定向到外层的 rerun_sdk_install 目录)
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../../rerun_sdk_install

# 4. 多线程编译 (首次编译会自动拉取 Arrow C++ 库，请耐心等待几分钟)
make -j8

# 5. 执行安装 (将头文件和 .a 库文件提取到指定目录)
make install

# 6. (可选) 清理临时构建文件
cd .. && rm -rf build

```

*(注：如果你希望团队其他成员免去编译这步，可以直接将生成的 `third_party/rerun_sdk_install` 文件夹提交到 Git 仓库中。)*

## ⚙️ 4. CMakeLists.txt 配置指南

在主项目的 `CMakeLists.txt` 中，通过指定 `CMAKE_PREFIX_PATH` 让 CMake 瞬间找到预编译好的静态库，并自动将 Viewer 复制到编译输出目录。

```cmake
cmake_minimum_required(VERSION 3.16)
project(MyProject VERSION 1.0 LANGUAGES CXX)

# Rerun SDK 强制要求 C++17 或以上标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_BUILD_TYPE Release)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# ==========================================
# 1. 配置并链接 Rerun SDK (预编译静态库)
# ==========================================
# 指向我们刚 install 出来的本地目录
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_SOURCE_DIR}/third_party/rerun_sdk_install")
find_package(rerun_sdk REQUIRED)

add_executable(main main.cpp)

# 链接 Rerun SDK (与其他库如 OpenCV 并列即可)
target_link_libraries(main PRIVATE rerun_sdk::rerun_sdk)

# ==========================================
# 2. 配置 Rerun Viewer (自动拷贝)
# ==========================================
# 告诉 CMake：在每次配置时，把免安装的 viewer 自动复制到编译输出的 build 文件夹中
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/third_party/rerun_viewer/rerun" 
     DESTINATION "${CMAKE_CURRENT_BINARY_DIR}")

```

## 💻 5. C++ 调用示例

由于我们将 Viewer 拷贝到了程序的同级目录，我们需要在 C++ 代码中显式指定 Viewer 可执行文件的路径，否则它会去系统 `PATH` 中寻找。

```cpp
#include <rerun.hpp>
#include <vector>

int main() {
    // 1. 初始化记录流
    const auto rec = rerun::RecordingStream("my_awesome_project");
    
    // 2. 配置 Viewer 路径并启动
    rerun::SpawnOptions spawn_opts;
    spawn_opts.executable_name = "./rerun"; // 精确指向同目录下的 viewer 文件
    rec.spawn(spawn_opts).exit_on_failure();

    // 3. 发送测试数据
    std::vector<rerun::Position3D> points = {
        {0.0f, 0.0f, 0.0f}, 
        {1.0f, 0.0f, 0.0f}, 
        {0.0f, 1.0f, 0.0f}
    };
    rec.log("my_points", rerun::Points3D(points));

    return 0;
}

```

---

**日常开发流程**：
现在，你的主项目在每次 `mkdir build && cd build && cmake .. && make` 时，将会在一秒内完成链接，并且运行 `./main` 就能直接弹出 3D 渲染窗口！