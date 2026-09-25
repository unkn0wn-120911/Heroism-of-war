extends Control

@onready var title_label: Label = $Panel/Margin/VBox/TitleLabel
@onready var summary_label: Label = $Panel/Margin/VBox/SummaryLabel
@onready var stats_label: Label = $Panel/Margin/VBox/StatsLabel
@onready var replay_button: Button = $Panel/Margin/VBox/ReplayButton
@onready var lobby_button: Button = $Panel/Margin/VBox/LobbyButton

func _ready() -> void:
    replay_button.pressed.connect(_on_replay_pressed)
    lobby_button.pressed.connect(_on_lobby_pressed)
    _apply_result()

func _apply_result() -> void:
    var result = MatchState.get_summary()
    var won = bool(result.get("victory", false))
    var kills = int(result.get("kills", 0))
    var time_value = float(result.get("match_time", 0.0))
    var weapon = String(result.get("weapon_name", "AR-12"))

    if won:
        title_label.text = "Victory Royale"
        summary_label.text = "You survived the final circle and won the match."
    else:
        title_label.text = "Match Over"
        summary_label.text = "You were eliminated. Re-enter the lobby and try again."

    stats_label.text = "Kills: %d\nTime: %02d:%02d\nWeapon: %s" % [kills, int(time_value) / 60, int(time_value) % 60, weapon]

    var profile = AccountManager.get_or_create_profile()
    profile["matches"] = int(profile.get("matches", 0)) + 1
    if won:
        profile["wins"] = int(profile.get("wins", 0)) + 1
        profile["xp"] = int(profile.get("xp", 0)) + 200 + kills * 25
    else:
        profile["xp"] = int(profile.get("xp", 0)) + 50
    AccountManager.save_profile(profile)

func _on_replay_pressed() -> void:
    MatchState.reset()
    get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_lobby_pressed() -> void:
    MatchState.reset()
    get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
