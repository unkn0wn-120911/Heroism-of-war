extends Node3D

@export var enemy_limit: int = 8
@export var wave_size_step: int = 2
@export var loot_spawn_interval: float = 8.0
@onready var player: CharacterBody3D = $Player
var enemy_scene = preload("res://scenes/Enemy.tscn")
var vehicle_scene = preload("res://scenes/Vehicle.tscn")
var loot_scene = preload("res://scenes/LootPickup.tscn")
var hud: CanvasLayer
var kill_count: int = 0
var match_time: float = 0.0
var zone_radius: float = 70.0
var current_wave: int = 1
var active_vehicle: Node3D = null
var loot_timer: float = 0.0
var result_label: Label

func _ready() -> void:
    setup_input_map()
    randomize()

    if not has_node("HUD"):
        var hud_scene = load("res://scenes/HUD.tscn")
        hud = hud_scene.instantiate()
        add_child(hud)
    else:
        hud = $HUD

    spawn_wave()
    spawn_vehicle()
    spawn_loot_pack(Vector3(8, 0.5, 8), "ammo", 20)
    spawn_loot_pack(Vector3(-7, 0.5, -12), "medkit", 25)
    print("Heroism of War battle arena started")
    update_hud()

func setup_input_map() -> void:
    var actions = [
        "move_forward", "move_back", "move_left", "move_right",
        "jump", "shoot", "boost"
    ]
    for action in actions:
        if not InputMap.has_action(action):
            InputMap.add_action(action)

    if not InputMap.action_has_event("move_forward", InputEventKey.new()):
        var key_w = InputEventKey.new(); key_w.physical_keycode = KEY_W; InputMap.action_add_event("move_forward", key_w)
        var key_s = InputEventKey.new(); key_s.physical_keycode = KEY_S; InputMap.action_add_event("move_back", key_s)
        var key_a = InputEventKey.new(); key_a.physical_keycode = KEY_A; InputMap.action_add_event("move_left", key_a)
        var key_d = InputEventKey.new(); key_d.physical_keycode = KEY_D; InputMap.action_add_event("move_right", key_d)
        var key_space = InputEventKey.new(); key_space.physical_keycode = KEY_SPACE; InputMap.action_add_event("jump", key_space)
        var mouse_b = InputEventMouseButton.new(); mouse_b.button_index = MOUSE_BUTTON_LEFT; InputMap.action_add_event("shoot", mouse_b)
        var key_shift = InputEventKey.new(); key_shift.physical_keycode = KEY_SHIFT; InputMap.action_add_event("boost", key_shift)

func _process(delta: float) -> void:
    if Input.is_action_just_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

    match_time += delta
    loot_timer += delta
    zone_radius = max(12.0, zone_radius - delta * 0.2)
    apply_zone_damage(delta)
    check_wave_progress()
    if loot_timer >= loot_spawn_interval:
        loot_timer = 0.0
        spawn_loot_pack(random_loot_position(), random_loot_type(), randi_range(10, 30))
    update_hud()

func spawn_wave() -> void:
    var enemy_count = enemy_limit + (current_wave - 1) * wave_size_step
    for i in range(enemy_count):
        var enemy = enemy_scene.instantiate()
        var x = randf_range(-30.0, 30.0)
        var z = randf_range(-30.0, 30.0)
        enemy.position = Vector3(x, 1.0, z)
        if enemy.position.distance_to(player.position) < 12.0:
            enemy.position += Vector3(14.0, 0.0, 10.0)
        add_child(enemy)

func spawn_vehicle() -> void:
    if active_vehicle != null:
        return

    var vehicle = vehicle_scene.instantiate()
    vehicle.position = Vector3(randf_range(-20.0, 20.0), 0.6, randf_range(-20.0, 20.0))
    add_child(vehicle)
    active_vehicle = vehicle

func apply_zone_damage(delta: float) -> void:
    if player == null:
        return
    if player.position.distance_to(Vector3.ZERO) > zone_radius:
        player.take_damage(8.0 * delta)

func register_kill() -> void:
    kill_count += 1
    update_hud()

func check_wave_progress() -> void:
    var required_kills = current_wave * 4
    if kill_count >= required_kills:
        current_wave += 1
        spawn_wave()
        spawn_vehicle()

func _on_player_died() -> void:
    if player == null:
        return

    print("Player eliminated. Respawning in the safe zone.")
    player.health = 100.0
    player.armor = 35.0
    player.ammo = 30
    player.position = Vector3(0.0, 1.2, 0.0)
    player.velocity = Vector3.ZERO
    player.rotation = Vector3.ZERO
    update_hud()

func random_loot_position() -> Vector3:
    return Vector3(randf_range(-24.0, 24.0), 0.5, randf_range(-24.0, 24.0))

func random_loot_type() -> String:
    var types = ["ammo", "medkit", "armor", "weapon"]
    return types[randi() % types.size()]

func spawn_loot_pack(pos: Vector3, item_type: String, amount: int) -> void:
    var loot = loot_scene.instantiate()
    loot.position = pos
    loot.pickup_type = item_type
    loot.amount = amount
    add_child(loot)

func update_hud() -> void:
    if hud != null and hud.has_method("update_match_info") and player != null:
        hud.update_match_info(
            player.health,
            player.armor,
            player.ammo,
            kill_count,
            int(zone_radius),
            match_time,
            player.weapon_name
        )

func add_score(amount: int) -> void:
    kill_count += amount
    update_hud()
