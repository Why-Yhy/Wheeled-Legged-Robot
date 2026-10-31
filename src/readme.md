# src

控制代码，按驱动、控制、模型三层划分。

- `motor/`：电机驱动。通信、使能，以及电流环和速度环
- `balance/`：平衡与运动控制。轮速环、腿长环、LQR
- `kinematics/`：运动学。五连杆机构的正解与逆解

---

Control code, in three layers: drivers, control and model.

- `motor/`: motor drivers — communication, enable, current and velocity loops
- `balance/`: balance and motion control — wheel speed, leg length, LQR
- `kinematics/`: kinematics — five-bar forward and inverse solutions
