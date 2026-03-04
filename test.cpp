#include <rerun.hpp>
#include <vector>

int main() {
    // 1. 初始化一个记录流
    const auto rec = rerun::RecordingStream("my_cpp_app");
    
    // 2. 启动本地的 Rerun 独立查看器应用
    rec.spawn().exit_on_failure();

    // 3. 准备一些 3D 点云数据
    std::vector<rerun::Position3D> points = {
        {0.0f, 0.0f, 0.0f}, 
        {1.0f, 0.0f, 0.0f}, 
        {0.0f, 1.0f, 0.0f}
    };

    // 4. 将数据记录到 "my_points" 这个空间路径下
    rec.log("my_points", rerun::Points3D(points));

    return 0;
}