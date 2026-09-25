extends Control

@onready var title_label: Label = $Panel/Margin/VBox/TitleLabel
@onready var player_list: ItemList = $Panel/Margin/VBox/PlayerList
@onready var lobby_status: RichTextLabel = $Panel/Margin/VBox/LobbyStatus
@onready var ready_button: Button = $Panel/Margin/VBox/ReadyButton
@onready var deploy_button: Button = $Panel/Margin/VBox/DeployButton

var selected_mode: String = "Squad"
var friends_online: Array = [
    {"name": "Nova", "status": "Ready", "level": 28},
    {"name": "Blaze", "status": "Ready", "level": 30},
    {"name": "Cobra", "status": "Ready", "level": 33},
    {"name": "You", "status": "Ready", "level": 24}
]
var matched_players: Array = [
    {"name": "Shadow", "status": "Ready", "level": 32},
    {"name": "Nova", "status": "Ready", "level": 28},
    {"name": "Blaze", "status": "Ready", "level": 30},
    {"name": "You", "status": "Ready", "level": 24}
]

func _ready() -> void:
    var profile = AccountManager.get_or_create_profile()
    selected_mode = profile.get("last_mode", "Squad")
    title_label.text = "%s Lobby" % selected_mode
    ready_button.pressed.connect(_on_ready_button_pressed)
    deploy_button.pressed.connect(_on_deploy_button_pressed)
    refresh_players()

func refresh_players() -> void:
    player_list.clear()
    var active_players = matched_players
    if selected_mode == "Duo":
        active_players = [
            {"name": "Nova", "status": "Ready", "level": 28},
            {"name": "You", "status": "Ready", "level": 24}
        ]
    elif selected_mode == "Solo":
        active_players = [
            {"name": "You", "status": "Ready", "level": 24}
        ]

    for player in active_players:
        player_list.add_item("%s - %s - Lv.%d" % [player["name"], player["status"], player["level"]])

    var ready_count = 0
    for player in active_players:
        if player["status"] == "Ready":
            ready_count += 1

    var friend_count = 0
    for friend in friends_online:
        if friend["status"] == "Ready":
            friend_count += 1

    lobby_status.text = "[b]Mode:[/b] %s | [b]Squad ready:[/b] %d/%d | [b]Friends online:[/b] %d | [b]Match type:[/b] Battle Royale" % [selected_mode, ready_count, max(1, active_players.size()), friend_count]

func _on_ready_button_pressed() -> void:
    for player in matched_players:
        if player["name"] == "You":
            player["status"] = "Ready"
            break
    refresh_players()

func _on_deploy_button_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/Main.tscn")
