extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var hud: CanvasLayer = $HUD

var enemy_scene = preload("res://scenes/Enemy.tscn")
var vehicle_scene = preload("res://scenes/Vehicle.tscn")
var enemy_count: int = 12
var kill_count: int = 0
var match_time: float = 0.0
var zone_radius: float = 70.0
var zone_damage_per_second: float = 8.0

func _ready() -> void:
    randomize()
    spawn_enemies(enemy_count)
    spawn_vehicle(Vector3(18.0, 0.5, 12.0))
    update_hud()

func _process(delta: float) -> void:
    match_time += delta
    zone_radius = max(12.0, zone_radius - delta * 0.35)
    apply_zone_damage(delta)
    update_hud()

func spawn_enemies(amount: int) -> void:
    for i in range(amount):
        var enemy = enemy_scene.instantiate()
        var x = randf_range(-30.0, 30.0)
        var z = randf_range(-30.0, 30.0)
        enemy.position = Vector3(x, 1.0, z)
        if enemy.position.distance_to(player.position) < 12.0:
            enemy.position += Vector3(14.0, 0.0, 10.0)
        add_child(enemy)

func spawn_vehicle(position: Vector3) -> void:
    var vehicle = vehicle_scene.instantiate()
    vehicle.position = position
    add_child(vehicle)

func apply_zone_damage(delta: float) -> void:
    if player == null:
        return
    var distance = player.position.distance_to(Vector3.ZERO)
    if distance > zone_radius:
        player.take_damage(zone_damage_per_second * delta)

func register_kill() -> void:
    kill_count += 1
    update_hud()

func update_hud() -> void:
    if hud != null and hud.has_method("update_match_info"):
        hud.update_match_info(
            player.health,
            player.armor,
            player.ammo,
            kill_count,
            int(zone_radius),
            match_time,
            player.weapon_name,
            "Combat Zone",
            ""
        )

func _on_player_died() -> void:
    print("Player eliminated. Restarting match...")
    match_time = 0.0
    kill_count = 0
    zone_radius = 70.0
    player.position = Vector3.ZERO
    player.health = 100.0
    player.armor = 35.0
    player.ammo = 30
    for child in get_children():
        if child.is_in_group("enemy"):
            child.queue_free()
    spawn_enemies(enemy_count)
    update_hud()
