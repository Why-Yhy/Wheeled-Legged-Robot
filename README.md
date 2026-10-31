# 五杆轮腿机器人项目

从白板推导到实机调试，一个轮腿机器人的成长记录

简体中文 | English (README_en.md)

这是一个五杆机构的轮腿式机器人项目，涵盖运动学推导、平衡控制算法，以及后续的硬件联调。目前处于理论打底阶段，已经完成的内容：

* 五杆运动学正解：已知 alpha 和 beta，推出轮轴心 B 点坐标的闭式解，完整推导见 docs 里的 五杆正解.md
* 仓库结构搭好了：代码、笔记、资料分家，每个文件夹里都有说明
* 跟着 Modern Robotics 视频系列学理论，运动学部分已经上路

接下来按顺序推进：运动学逆解，腿高与轮速 PID，LQR 自平衡，最后实机联调。

## 文件结构

整个项目分成下面几个部分，分别在不同文件夹里，内部有更详细的说明，按需看就好：

* src：机器人代码，再按模块分 motor/ 电机驱动、balance/ 平衡控制、kinematics/ 运动学正逆解
* docs：学习笔记，一个主题一篇，板书截图放在 docs/img 里
* assets：资料杂项，结构图、零件清单、参考文献链接都塞在这

> 注：现在还在笔记阶段，代码落地后 src 下的文件夹会逐个补起来
>
> ## 参考
>
> * Modern Robotics 系列（Kevin Lynch，Northwestern Robotics，YouTube）：https://www.youtube.com/watch?v=jVu-Hijns70&list=PLggLP4f-rq02vX0OQQ5vrCxbJrzamYDfx
