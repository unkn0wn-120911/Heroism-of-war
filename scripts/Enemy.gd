extends CharacterBody3D

@export var move_speed: float = 4.5
@export var health: float = 100.0

var player: Node3D

func _ready() -> void:
    add_to_group("enemy")
    player = get_parent().get_node("Player")

func _physics_process(_delta: float) -> void:
    if player == null:
        return

    var to_player = player.global_position - global_position
    to_player.y = 0.0
    if to_player.length() > 0.1:
        var direction = to_player.normalized()
        velocity.x = direction.x * move_speed
        velocity.z = direction.z * move_speed
        look_at(player.global_position, Vector3.UP)
    else:
        velocity.x = 0.0
        velocity.z = 0.0

    move_and_slide()

func take_damage(amount: float) -> void:
    health -= amount
    if health <= 0:
        if get_parent().has_method("register_kill"):
            get_parent().register_kill()
        queue_free()
