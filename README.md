# Wheeled-Legged-Robot | 轮腿式机器人

中文: 基于五杆机构的轮腿式机器人项目。从连杆运动学推导起步, 逐步实现腿高与位姿控制、轮式自平衡 (PID / LQR), 先吃透原理, 再动手写代码。

English: A five-bar wheeled-legged robot project. From linkage kinematics to leg height and pose control and self-balancing (PID / LQR) - understand the theory first, then ship the code.

## 目录结构 | Structure (规划中)

src/ - 代码 Code

docs/ - 学习笔记 Notes (运动学与控制)

assets/ - 资料 Materials (图示与参考文献)

## 路线 | Roadmap

已完成: 五杆运动学正解 Forward kinematics (已知 alpha、beta 求轮轴心 B 点坐标)

待做: 运动学逆解 Inverse kinematics

待做: 腿高与轮速 PID 控制

待做: LQR 自平衡

待做: 实机联调 Hardware integration

## 参考 | References

Modern Robotics 系列 (Kevin Lynch, Northwestern Robotics, YouTube)

https://www.youtube.com/watch?v=jVu-Hijns70&list=PLggLP4f-rq02vX0OQQ5vrCxbJrzamYDfx

Brunton and Kutz, Data-Driven Science and Engineering
