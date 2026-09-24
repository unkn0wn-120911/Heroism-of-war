# Heroism of War

Heroism of War is an original 3D action-adventure shooter prototype inspired by large-scale battle arena gameplay. It combines combat, exploration, vehicle pickups, and a battle royale-style shrinking zone while using Godot 4, C++, and MongoDB for a future multiplayer and persistence layer.

## Core gameplay direction

- 3D third-person shooter combat
- Fast arena battles with enemy squads
- Weapon firing, recoil-like timing, and resource management
- Safe-zone pressure system
- Vehicle pickup and future driving/racing features
- MongoDB-based player profiles, match logs, and progression

## Current prototype features

- 3D arena map with ground and lighting
- character movement and mouse aim
- shooting projectiles with enemy hit detection
- AI enemies that chase and attack the player
- HUD for health, armor, ammo, zone, timer, and kills
- battle-zone damage and spawn reset flow

## Project setup

1. Install Godot 4.x.
2. Open this folder as the project root.
3. Configure the environment for C++ and MongoDB.
4. Open the project in Godot and press F5 to run.
5. For native extension builds, set the `GODOT_CPP_DIR` environment variable before build.

## C++ build

```bash
export GODOT_CPP_DIR=/path/to/godot-cpp
cmake -S cpp -B cpp/build
cmake --build cpp/build
```

## MongoDB Atlas setup

Use the connection string in [.env](.env) or create your own local Atlas database with the same fields.

## Design note

This project is inspired by battle royale mechanics and competitive shooter pacing, but it remains an original prototype. The goal is to build a playable foundation that can later evolve into a full multiplayer action game.
