# Slime Simulation
![slime_sim](https://github.com/NabilNYMansour/Slime-Simulation/blob/main/demo/slime_sim.gif)
## The project
This is an implementation of slime mold cellular automata.

Inspired by [Sebastian Lague's](https://github.com/SebLague/Slime-Simulation) and [Leterax's](https://github.com/Leterax/slimes) implementations.

The code is written in Python where the [ModernGL](https://github.com/moderngl/moderngl) library is utilized for the GPU integration, [ModernGL window](https://github.com/moderngl/moderngl-window) is utilized for the window management, and [pyimgui](https://github.com/pyimgui/pyimgui) is used for GUI management.

The simulation is implemented in various shaders where the main logic of the slimes is written in `/programs/compute.glsl`.

## Running the App
To run the application, make sure you have the aforementioned libraries installed, then:
1. Clone or download this repository.
2. Run `python3 main.py`

Note that the GUI does not handle resolution changes. In case you want that, simply edit `main.py` at line `10` and `11`.

## Pictures
The following are some images of the various types of slimes that can be made with this application:
<p float="left">
  <img src="https://github.com/NabilNYMansour/Slime-Simulation/blob/main/demo/ss1.png" alt="electro_slime" width="350"/>
  <img src="https://github.com/NabilNYMansour/Slime-Simulation/blob/main/demo/ss2.png" alt="cell_slime" width="350"/>
  <img src="https://github.com/NabilNYMansour/Slime-Simulation/blob/main/demo/ss3.png" alt="planet_slime" width="350"/>
  <img src="https://github.com/NabilNYMansour/Slime-Simulation/blob/main/demo/ss4.png" alt="chaos_slime" width="350"/>
</p>

## Aim
The purpose of this project is to learn how to utilize compute shaders in an effective manner, and be able to use them in a rendering pipeline.

##

Thank you for your time :)
