cmake_minimum_required(VERSION 3.16)
project(MyProject VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_BUILD_TYPE Release)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# ==========================================
# 1. 链接预编译好的 Rerun 静态库
# ==========================================
# 指向我们刚刚 install 出来的那个文件夹
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_SOURCE_DIR}/Visualisation/rerun_sdk_install")

# 现在 CMake 瞬间就能找到它，不需要再编译了！
find_package(rerun_sdk REQUIRED)

# 编译主程序
add_executable(main test.cpp)

# 链接 SDK
target_link_libraries(main PRIVATE rerun_sdk)

# ==========================================
# 2. 依然保留复制 Viewer 的便捷步骤
# ==========================================
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/Visualisation/rerun_viewer/rerun" 
     DESTINATION "${CMAKE_CURRENT_BINARY_DIR}")