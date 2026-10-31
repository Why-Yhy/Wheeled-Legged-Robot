# 五杆轮腿机器人


这是一个基于五杆机构的轮腿式机器人项目，包含运动学推导、平衡控制算法，以及后续的硬件联调。已完成以下内容：

* 推导了五杆机构的运动学正解：已知关节角 alpha 和 beta，求轮轴中心的位置，完整推导记录在 docs 里的 五杆正解.md
* 搭好了项目目录结构，代码、笔记、资料分别放在不同文件夹
* 跟着 Modern Robotics 视频系列学习理论

后续待完成：运动学逆解、腿高与轮速 PID 控制、LQR 自平衡控制、硬件联调。

## 文件结构

* src：机器人代码，细分 motor/ 电机驱动、balance/ 平衡控制、kinematics/ 运动学正逆解
* docs：学习笔记，一个主题一篇，板书截图存放在 docs/img
* assets：资料，包括结构图、零件清单和参考文献

## 参考

* Modern Robotics 视频系列（Kevin Lynch，Northwestern Robotics，YouTube）：https://www.youtube.com/watch?v=jVu-Hijns70&list=PLggLP4f-rq02vX0OQQ5vrCxbJrzamYDfx
