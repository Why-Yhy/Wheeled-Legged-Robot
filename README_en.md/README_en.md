# Five-bar Wheeled-legged Robot

From whiteboard derivations to a running robot - the build log of a five-bar wheeled-legged project.

English | 简体中文 (README.md)

This is a five-bar wheeled-legged robot project: kinematics, balance control, and eventually hardware integration. Still in the theory phase. Done so far:

* Forward kinematics of the five-bar linkage - closed-form solution for the wheel axle point B given alpha and beta, full derivation in docs
Repo skeleton set up - code, notes and materials each in their own folder
Working through the Modern Robotics video serie
Next up: inverse kinematics, leg height and wheel speed PID, LQR balance, then hardware.

## File structure

The project is split into a few folders, each with its own readme for details:

* src: robot code, by module - motor/ drivers, balance/ control, kinematics/ solvers
docs: study notes, one topic per file, whiteboard captures in docs/img
assets: figures, BOM, references and other odds and end
> Still early days - the src folders will fill in as code lands.

## References

* Modern Robotics series (Kevin Lynch, Northwestern Robotics, YouTube): https://www.youtube.com/watch?v=jVu-Hijns70&list=PLggLP4f-rq02vX0OQQ5vrCxbJrzamYDfx
