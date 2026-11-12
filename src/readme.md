# src

轮腿机器人控制代码：CubeMX 生成的工程 + 自研模块，STM32H723 + FreeRTOS。

## 目录结构

| 路径 | 说明 |
|---|---|
| `Core/` | CubeMX 生成代码：外设初始化（ADC / DMA / FDCAN / SPI / TIM / USART / GPIO）、中断、`main.c`、`freertos.c`、`FreeRTOSConfig.h` |
| `User/APP/` | 任务层：`chassisL_task` / `chassisR_task` 左右腿控制、`INS_task` 姿态解算、`observe_task` 观测器、`ps2_task` / `xbox_task` 遥控输入、`watch_task` |
| `User/Controller/` | 控制器主体 `controller.c/h` |
| `User/Algorithm/` | 算法库：`VMC`（五连杆虚拟模型控制）、`PID`、`EKF`、`kalman`、`mahony` |
| `User/Devices/` | 器件驱动：`BMI088`（IMU）、`DM_Motor`（达妙 DM4310 电机） |
| `User/Bsp/` | 板级支持：DWT 计时、PWM、CAN、UART |
| `User/Lib/` | 通用工具函数 |
| `Drivers/` | ST 官方 HAL 驱动与 CMSIS，一般不修改 |
| `Middlewares/Third_Party/FreeRTOS/` | FreeRTOS 内核 |
| `MDK-ARM/` | Keil MDK 工程 `CtrlBoard-H7_IMU.uvprojx` |
| `CtrlBoard-H7_IMU.ioc` | CubeMX 配置。改外设后用它重新生成，注意别覆盖 `User/` 下的自研代码 |

## 编译

Keil MDK 打开 `MDK-ARM/CtrlBoard-H7_IMU.uvprojx`，直接 Build。

## 版本管理

以下内容已写进根目录 `.gitignore`，不会进仓库：

- Keil 编译中间产物：`.o` `.crf` `.d` `.axf` `.map` `.lst` `.htm` 等
- 整个 `MDK-ARM/CtrlBoard-H7_IMU/` 输出目录（约 185MB）
- `.uvguix.*`（Keil 界面布局）、`JLinkLog.txt`、`JLinkSettings.ini`

日常改代码后，双击根目录的 `启动自动同步.cmd`，约 10 秒内自动提交并推送。

---

## Layout

Wheel-legged robot control firmware — CubeMX-generated project plus custom modules, STM32H723 + FreeRTOS.

- `Core/` — peripheral init, interrupts, `main.c`, FreeRTOS setup
- `User/APP/` — tasks: chassis L/R, INS, observer, PS2 / Xbox remote, watchdog
- `User/Controller/` — main controller
- `User/Algorithm/` — VMC (five-bar linkage), PID, EKF, Kalman, Mahony
- `User/Devices/` — BMI088 IMU and DM4310 motor drivers
- `User/Bsp/` — DWT timing, PWM, CAN, UART
- `User/Lib/` — shared utilities
- `Drivers/`, `Middlewares/` — ST HAL / CMSIS and FreeRTOS
- `MDK-ARM/` — Keil project, build `CtrlBoard-H7_IMU.uvprojx`

Build artifacts are excluded via `.gitignore`.