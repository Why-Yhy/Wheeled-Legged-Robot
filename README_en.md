# Five-bar Wheel-Legged Robot

[简体中文](README.md) | English

A wheel-legged robot built on a five-bar linkage. Forward kinematics is done; inverse kinematics, balancing control and hardware are still in progress.

## File structure

- [`src`](src): control code in three layers, drivers, control and model, as `motor`, `balance` and `kinematics`
- [`docs`](docs): notes, one topic per file, whiteboard captures in `docs/img`
- [`assets`](assets): diagrams, bill of materials and photos, images in `assets/img`

## Progress

- [x] Forward kinematics: joint angles α, β to wheel axle position
- [ ] Inverse kinematics
- [ ] PID for leg length and wheel speed
- [ ] LQR balancing
- [ ] Hardware bring-up

## References

- Kevin M. Lynch, Frank C. Park. *Modern Robotics: Mechanics, Planning, and Control*. Cambridge University Press, 2017.
- Modern Robotics lecture series (Northwestern University): [playlist](https://www.youtube.com/watch?v=jVu-Hijns70&list=PLggLP4f-rq02vX0OQQ5vrCxbJrzamYDfx) / [single lecture](https://www.youtube.com/watch?v=E_RDCFOlJx4)
