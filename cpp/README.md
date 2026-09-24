# Native C++ integration for Heroism of War

This folder holds the Godot C++ extension skeleton and the MongoDB integration entry points.

## Required dependencies

- Godot 4 C++ bindings (godot-cpp)
- CMake
- C++17 compiler
- MongoDB C++ driver (`mongocxx` and `bsoncxx`)

## Example environment configuration

```bash
export GODOT_CPP_DIR=/path/to/godot-cpp
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH}
```

## Build steps

```bash
cmake -S cpp -B cpp/build
cmake --build cpp/build
```

The compiled extension should be placed in the folder expected by `HeroismOfWar.gdextension` before running the project in Godot.

## MongoDB usage

The C++ layer is structured to support a future service class that connects to MongoDB via `mongocxx` and stores player profile records, battle logs, and match history.
