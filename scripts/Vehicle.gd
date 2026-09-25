extends StaticBody3D

var vehicle_name: String = "Buggy"
var boost_power: float = 25.0

func _ready() -> void:
    add_to_group("vehicle")

func use_boost() -> void:
    print("Vehicle boost activated: " + vehicle_name)
