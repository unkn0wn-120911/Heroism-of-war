extends CanvasLayer

@onready var health_label: Label = $Margin/Panel/HBox/Stats/HealthValue
@onready var armor_label: Label = $Margin/Panel/HBox/Stats/ArmorValue
@onready var ammo_label: Label = $Margin/Panel/HBox/Stats/AmmoValue
@onready var kill_label: Label = $Margin/Panel/HBox/Stats/KillValue
@onready var zone_label: Label = $Margin/Panel/HBox/Stats/ZoneValue
@onready var timer_label: Label = $Margin/Panel/HBox/Stats/TimerValue
@onready var weapon_label: Label = $Margin/Panel/HBox/Stats/WeaponValue

func update_match_info(health: float, armor: float, ammo: int, kills: int, zone_radius: int, match_time: float, weapon_name: String) -> void:
    health_label.text = str(int(health))
    armor_label.text = str(int(armor))
    ammo_label.text = str(ammo)
    kill_label.text = str(kills)
    zone_label.text = str(zone_radius) + "m"
    timer_label.text = "%02d:%02d" % [int(match_time) / 60, int(match_time) % 60]
    weapon_label.text = weapon_name
