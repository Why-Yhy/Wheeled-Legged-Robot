# Wheel-Legged Robot (Five-Bar Linkage)

[简体中文](README.md) | English


## Contents

- [Overview](#overview)
- [Hardware & Software](#hardware--software)
- [Repository Layout](#repository-layout)
- [Getting Started](#getting-started)
- [Documentation](#documentation)
- [Roadmap](#roadmap)
- [Local Tools](#local-tools)
- [References](#references)

## Overview

Wheel-legged robots combine the efficiency of wheels with the terrain adaptability of legs. This project uses a five-bar closed-chain linkage driven by two motors per leg. Desired leg length and swing angle are mapped to joint torques with Virtual Model Control (VMC), and the whole body is balanced by an LQR controller.

Highlights:

- Closed-form forward and inverse kinematics of the five-bar linkage
- Linearized inverted-pendulum model and LQR gain design
- VMC, cascaded PID, attitude estimation (EKF / Mahony)
- FreeRTOS task framework: chassis control, INS, observer, remote input
- FDCAN driver for DAMIAO DM4310 motors, BMI088 IMU driver

## Hardware & Software

| Item | Spec |
| --- | --- |
| MCU | STM32H723VGT6 (Cortex-M7, 480 MHz) |
| IMU | BMI088 (SPI, 6-axis) |
| Joint motors | DAMIAO DM4310 × 4 (FDCAN) |
| Remote input | Xbox / PS2 controller (UART) |
| RTOS | FreeRTOS |
| HAL | STM32H7 HAL + CMSIS |
| Toolchain | Keil MDK 5, STM32CubeMX |

## Repository Layout

```
.
├─ src/                  firmware project (CubeMX + custom modules)
│  ├─ Core/              peripheral init, main.c, freertos.c, interrupts
│  ├─ User/              application code
│  │  ├─ APP/            tasks: chassis L/R, INS, observer, remote, watchdog
│  │  ├─ Algorithm/      VMC, PID, EKF, Kalman, Mahony
│  │  ├─ Controller/     main controller
│  │  ├─ Devices/        BMI088, DM4310 drivers
│  │  ├─ Bsp/            DWT, PWM, CAN, UART
│  │  └─ Lib/            utilities
│  ├─ Drivers/           ST HAL & CMSIS
│  ├─ Middlewares/       FreeRTOS kernel
│  └─ MDK-ARM/           Keil MDK project
├─ docs/                 notes and derivations (Chinese)
├─ assets/               images
└─ tools/                local automation scripts
```

See [`src/readme.md`](src/readme.md) for details.

## Getting Started

```text
1. Install Keil MDK 5 and the STM32H7 device pack
2. Open src/MDK-ARM/CtrlBoard-H7_IMU.uvprojx
3. F7 to build, F8 to flash (ST-Link / J-Link)
```

To change peripherals, open `src/CtrlBoard-H7_IMU.ioc` in STM32CubeMX and regenerate. Do **not** overwrite the custom code under `src/User/`.

## Documentation

| Document | Topic |
| --- | --- |
| [五连杆轮腿机器人运动学正逆解](docs/五连杆轮腿机器人运动学正逆解.md) | forward / inverse kinematics of the five-bar linkage |
| [LQR-最优反馈与变高度自平衡](docs/LQR-最优反馈与变高度自平衡.md) | LQR design, balance at varying leg length |
| [基于倒立摆推导状态空间方程](docs/基于倒立摆推导状态空间方程.md) | inverted pendulum model and linearization |

(Documents are written in Chinese.)

## Roadmap

- [x] Forward kinematics: joint angles α, β → wheel axis position
- [x] Inverse kinematics
- [x] Leg and wheel speed PID
- [x] LQR balancing
- [x] Virtual Model Control
- [x] Xbox / PS2 remote input
- [ ] Hardware integration and tuning

## Local Tools

Windows-only helper scripts in `tools/` (Git required):

| File | Purpose |
| --- | --- |
| `启动自动同步.cmd` | auto commit & push on every save |
| `打开代码管理.cmd` | Chinese GUI: one-click upload / roll back to any revision |
| `auto-sync.ps1` | engine behind the auto sync |
| `git-gui.ps1` | engine behind the GUI |

## References

- Kevin M. Lynch, Frank C. Park. *Modern Robotics: Mechanics, Planning, and Control*. Cambridge University Press, 2017.
- Modern Robotics course videos (Northwestern University): [playlist](https://www.youtube.com/watch?v=jVu-Hijns70&list=PLggLP4f-rq02vX0OQQ5vrCxbJrzamYDfx)
- [What Is Linear Quadratic Regulator (LQR) Optimal Control? | State Space, Part 4](https://www.youtube.com/watch?v=E_RDCFOlJx4) (MATLAB Tech Talks)

## License

No open-source license has been chosen yet. Please contact the author before reuse.
