extends Control

@onready var title_label: Label = $Panel/Margin/VBox/TitleLabel
@onready var player_list: ItemList = $Panel/Margin/VBox/PlayerList
@onready var lobby_status: RichTextLabel = $Panel/Margin/VBox/LobbyStatus
@onready var ready_button: Button = $Panel/Margin/VBox/ReadyButton
@onready var deploy_button: Button = $Panel/Margin/VBox/DeployButton

var matched_players: Array = [
    {"name": "Shadow", "status": "Ready", "level": 32},
    {"name": "Nova", "status": "Ready", "level": 28},
    {"name": "Blaze", "status": "Ready", "level": 30},
    {"name": "You", "status": "Ready", "level": 24}
]

func _ready() -> void:
    title_label.text = "Battle Lobby"
    ready_button.pressed.connect(_on_ready_button_pressed)
    deploy_button.pressed.connect(_on_deploy_button_pressed)
    refresh_players()

func refresh_players() -> void:
    player_list.clear()
    for player in matched_players:
        player_list.add_item("%s - %s - Lv.%d" % [player["name"], player["status"], player["level"]])

    var ready_count = 0
    for player in matched_players:
        if player["status"] == "Ready":
            ready_count += 1
    lobby_status.text = "[b]Squad ready:[/b] %d/4  |  [b]Match type:[/b] Battle Royale" % ready_count

func _on_ready_button_pressed() -> void:
    for player in matched_players:
        if player["name"] == "You":
            player["status"] = "Ready"
            break
    refresh_players()

func _on_deploy_button_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/Main.tscn")
