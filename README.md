# 五连杆轮腿机器人

简体中文 | [English](README_en.md)

五连杆机构的轮腿式机器人。已完成运动学正解推导，逆解、平衡控制和硬件联调还在做。

## 文件结构

- [`src`](src)：控制代码，按驱动、控制、模型分三层，对应 `motor`、`balance`、`kinematics` 
- [`docs`](docs)：学习笔记，一个主题一篇，板书截图放在 `docs/img`
- [`assets`](assets)：结构图、零件清单和实物照片，图片放在 `assets/img`

## 进度

- [x] 五连杆机构运动学正解：由关节角 α、β 求轮轴中心位置
- [ ] 运动学逆解
- [ ] 腿部与轮速 PID 控制
- [ ] LQR 自平衡
- [ ] 硬件联调

## 参考

- Kevin M. Lynch, Frank C. Park. *Modern Robotics: Mechanics, Planning, and Control*. Cambridge University Press, 2017.
- Modern Robotics 课程视频（Northwestern University）：[播放列表](https://www.youtube.com/watch?v=jVu-Hijns70&list=PLggLP4f-rq02vX0OQQ5vrCxbJrzamYDfx) / [单集](https://www.youtube.com/watch?v=E_RDCFOlJx4)
