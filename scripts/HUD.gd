extends CanvasLayer

@onready var health_label: Label = $Margin/Panel/HBox/Stats/HealthValue
@onready var armor_label: Label = $Margin/Panel/HBox/Stats/ArmorValue
@onready var ammo_label: Label = $Margin/Panel/HBox/Stats/AmmoValue
@onready var kill_label: Label = $Margin/Panel/HBox/Stats/KillValue
@onready var zone_label: Label = $Margin/Panel/HBox/Stats/ZoneValue
@onready var timer_label: Label = $Margin/Panel/HBox/Stats/TimerValue
@onready var weapon_label: Label = $Margin/Panel/HBox/Stats/WeaponValue

var status_label: Label
var inventory_label: Label

func _ready() -> void:
    _create_status_labels()

func _create_status_labels() -> void:
    if status_label == null:
        status_label = Label.new()
        status_label.name = "StatusLabel"
        status_label.anchor_left = 0.5
        status_label.anchor_top = 0.0
        status_label.anchor_right = 0.5
        status_label.anchor_bottom = 0.0
        status_label.position = Vector2(-180, 65)
        status_label.size = Vector2(360, 30)
        status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        status_label.add_theme_font_size_override("font_size", 18)
        add_child(status_label)

    if inventory_label == null:
        inventory_label = Label.new()
        inventory_label.name = "InventoryLabel"
        inventory_label.anchor_left = 0.5
        inventory_label.anchor_top = 0.0
        inventory_label.anchor_right = 0.5
        inventory_label.anchor_bottom = 0.0
        inventory_label.position = Vector2(-220, 95)
        inventory_label.size = Vector2(440, 26)
        inventory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        inventory_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        inventory_label.add_theme_font_size_override("font_size", 13)
        add_child(inventory_label)

func update_match_info(health: float, armor: float, ammo: int, kills: int, zone_radius: int, match_time: float, weapon_name: String, match_stage: String = "Combat Zone", result_text: String = "") -> void:
    health_label.text = str(int(health))
    armor_label.text = str(int(armor))
    ammo_label.text = str(ammo)
    kill_label.text = str(kills)
    zone_label.text = str(zone_radius) + "m"
    timer_label.text = "%02d:%02d" % [int(match_time) / 60, int(match_time) % 60]
    weapon_label.text = weapon_name

    if result_text != "":
        status_label.text = result_text
        status_label.modulate = Color(1.0, 0.85, 0.25, 1.0)
    else:
        status_label.text = match_stage
        status_label.modulate = Color(0.75, 0.95, 1.0, 1.0)

    inventory_label.text = "Loadout: %s | Ammo %d | Armor %d" % [weapon_name, ammo, int(armor)]
