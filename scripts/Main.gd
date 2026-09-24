extends Node3D

@export var enemy_limit: int = 12
@onready var player: CharacterBody3D = $Player
var enemy_scene = preload("res://scenes/Enemy.tscn")
var hud: CanvasLayer
var kill_count: int = 0
var match_time: float = 0.0
var zone_radius: float = 70.0

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
    print("Heroism of War prototype started")
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
    zone_radius = max(12.0, zone_radius - delta * 0.35)
    apply_zone_damage(delta)
    update_hud()

func spawn_wave() -> void:
    for i in range(enemy_limit):
        var enemy = enemy_scene.instantiate()
        var x = randf_range(-30.0, 30.0)
        var z = randf_range(-30.0, 30.0)
        enemy.position = Vector3(x, 1.0, z)
        if enemy.position.distance_to(player.position) < 12.0:
            enemy.position += Vector3(14.0, 0.0, 10.0)
        add_child(enemy)

func apply_zone_damage(delta: float) -> void:
    if player == null:
        return
    if player.position.distance_to(Vector3.ZERO) > zone_radius:
        player.take_damage(8.0 * delta)

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
            player.weapon_name
        )

func add_score(amount: int) -> void:
    kill_count += amount
    update_hud()
