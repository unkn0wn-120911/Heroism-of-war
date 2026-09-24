extends Node3D

var speed: float = 50.0
var direction: Vector3 = Vector3.ZERO
var lifetime: float = 2.5
var damage: float = 25.0

func _physics_process(delta: float) -> void:
    global_position += direction * speed * delta
    for enemy in get_tree().get_nodes_in_group("enemy"):
        if enemy.global_position.distance_to(global_position) < 1.2:
            enemy.take_damage(damage)
            queue_free()
            return

    lifetime -= delta
    if lifetime <= 0.0:
        queue_free()
