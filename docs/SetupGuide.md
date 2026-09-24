# Heroism of War Setup Guide

## 1. Install Godot 4

Download Godot 4.x from the official site and open this project folder as a project.

## 2. Prepare the C++ environment

Install:
- CMake
- C++17 compiler
- Git

Then set the Godot C++ bindings path:

```bash
export GODOT_CPP_DIR=/path/to/godot-cpp
```

## 3. Install MongoDB driver

If you want to enable the native MongoDB integration, install the MongoDB C++ driver:

```bash
sudo apt-get install libmongocxx-dev libbsoncxx-dev
```

Or use a custom build from the official MongoDB C++ driver source.

## 4. Build the native extension

```bash
cmake -S cpp -B cpp/build
cmake --build cpp/build
```

## 5. Configure `.env`

Use the provided `.env` file with your real Atlas connection details. The project expects a MongoDB Atlas URI string.

## 6. Run the game

Open the project in Godot and press F5.

## 7. Expand the game loop

Recommended next upgrades:
- rifle, shotgun, sniper weapons
- enemy squad AI
- safe-zone shrinking mechanic
- vehicle pickup and driving
- backend player profile sync with MongoDB
- online multiplayer lobby
