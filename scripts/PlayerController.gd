extends CharacterBody3D

@export var move_speed: float = 12.0
@export var acceleration: float = 8.0
@export var jump_velocity: float = 6.5
@export var gravity: float = 20.0
@export var mouse_sensitivity: float = 0.0025
@export var health: float = 100.0
@export var armor: float = 35.0
@export var ammo: int = 30
@export var weapon_name: String = "AR-12"

@onready var camera: Camera3D = $Camera3D
@onready var muzzle: Marker3D = $Camera3D/Muzzle

var projectile_scene = preload("res://scenes/Projectile.tscn")
var fire_timer: float = 0.0
var boost_timer: float = 0.0
var boost_cooldown: float = 0.0

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * mouse_sensitivity)
        camera.rotation.x = clamp(camera.rotation.x - event.relative.y * mouse_sensitivity, deg_to_rad(-80), deg_to_rad(80))

    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_ESCAPE:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
    fire_timer = max(0.0, fire_timer - delta)
    boost_timer = max(0.0, boost_timer - delta)
    boost_cooldown = max(0.0, boost_cooldown - delta)

    var current_speed = move_speed
    if boost_timer > 0.0:
        current_speed += 8.0
    elif Input.is_action_pressed("boost") and boost_cooldown <= 0.0 and is_near_vehicle():
        boost_timer = 2.5
        boost_cooldown = 5.0
        current_speed += 8.0

    var direction = Vector3.ZERO
    var input_forward = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
    var input_right = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

    direction = ((transform.basis.x * input_right) + (transform.basis.z * input_forward)).normalized()

    if direction.length() > 0:
        velocity.x = lerp(velocity.x, direction.x * current_speed, acceleration * delta)
        velocity.z = lerp(velocity.z, direction.z * current_speed, acceleration * delta)
    else:
        velocity.x = lerp(velocity.x, 0.0, acceleration * delta)
        velocity.z = lerp(velocity.z, 0.0, acceleration * delta)

    if not is_on_floor():
        velocity.y -= gravity * delta
    elif Input.is_action_just_pressed("jump"):
        velocity.y = jump_velocity

    if Input.is_action_just_pressed("shoot") and fire_timer <= 0.0:
        fire()

    move_and_slide()

    if health <= 0.0:
        get_parent()._on_player_died()

func is_near_vehicle() -> bool:
    for vehicle in get_tree().get_nodes_in_group("vehicle"):
        if global_position.distance_to(vehicle.global_position) < 2.8:
            return true
    return false

func fire() -> void:
    if ammo <= 0:
        ammo = 30
        return

    ammo -= 1
    fire_timer = 0.12

    var projectile = projectile_scene.instantiate()
    projectile.global_transform.origin = muzzle.global_position
    projectile.direction = -camera.global_transform.basis.z.normalized()
    projectile.damage = 25.0
    get_parent().add_child(projectile)

func take_damage(amount: float) -> void:
    if armor > 0.0:
        var absorbed = min(armor, amount)
        armor -= absorbed
        amount -= absorbed
    health -= amount
    if health < 0.0:
        health = 0.0
