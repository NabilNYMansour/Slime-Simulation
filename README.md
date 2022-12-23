# Slime Simulation
![slime_sim](https://user-images.githubusercontent.com/56453977/209243936-14995a89-4f82-4369-b859-c52b235772d8.gif)
-
This is an implementation of slime mold cellular automata.

Inspired by [Sebastian Lague's](https://github.com/SebLague/Slime-Simulation) and [Leterax's](https://github.com/Leterax/slimes) implementations.

The code is written in Python where the [ModernGL](https://github.com/moderngl/moderngl) library is utilized for the GPU integration, [ModernGL window](https://github.com/moderngl/moderngl-window) is utilized for the window management, and [pyimgui](https://github.com/pyimgui/pyimgui) is used for GUI management.

The simulation is implemented in various shaders where the main logic of the slimes is written in `/programs/compute.glsl`.

The purpose of this project is to learn how to utilize compute shaders in an effective manner, and be able to use them in a rendering pipeline.

The following are some images of the various types of slimes that can be made with this application:
