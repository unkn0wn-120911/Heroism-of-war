extends Area3D

@export var pickup_type: String = "ammo"
@export var amount: int = 15

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var label: Label3D = $Label3D

func _ready() -> void:
    add_to_group("loot")
    _apply_visuals()
    body_entered.connect(_on_body_entered)

func _apply_visuals() -> void:
    var color := Color(0.2, 0.85, 0.9, 1.0)
    if pickup_type == "medkit":
        color = Color(0.2, 0.9, 0.45, 1.0)
    elif pickup_type == "weapon":
        color = Color(1.0, 0.7, 0.2, 1.0)
    elif pickup_type == "armor":
        color = Color(0.5, 0.7, 1.0, 1.0)

    if mesh != null:
        var mat := StandardMaterial3D.new()
        mat.albedo_color = color
        mat.emission_enabled = true
        mat.emission = color
        mat.emission_energy = 0.6
        mesh.material_override = mat

    if label != null:
        label.text = pickup_type.to_upper()

func _on_body_entered(body: Node3D) -> void:
    if body == null:
        return

    if body.has_method("collect_loot"):
        body.collect_loot(pickup_type, amount)
    queue_free()
