extends Node

var victory: bool = false
var kills: int = 0
var match_time: float = 0.0
var weapon_name: String = "AR-12"
var summary_text: String = ""

func reset() -> void:
    victory = false
    kills = 0
    match_time = 0.0
    weapon_name = "AR-12"
    summary_text = ""

func set_result(_victory: bool, _kills: int, _match_time: float, _weapon_name: String) -> void:
    victory = _victory
    kills = _kills
    match_time = _match_time
    weapon_name = _weapon_name
    summary_text = "Victory" if victory else "Defeat"

func get_summary() -> Dictionary:
    return {
        "victory": victory,
        "kills": kills,
        "match_time": match_time,
        "weapon_name": weapon_name,
        "summary_text": summary_text
    }
