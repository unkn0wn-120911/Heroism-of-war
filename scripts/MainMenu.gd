extends Control

@onready var player_name_edit: LineEdit = $Center/Panel/Margin/VBox/PlayerName
@onready var lobby_status: RichTextLabel = $Center/Panel/Margin/VBox/LobbyStatus
@onready var start_button: Button = $Center/Panel/Margin/VBox/StartButton
@onready var quick_button: Button = $Center/Panel/Margin/VBox/QuickMatchButton
@onready var loadout_button: Button = $Center/Panel/Margin/VBox/LoadoutButton
@onready var quit_button: Button = $Center/Panel/Margin/VBox/QuitButton

func _ready() -> void:
    if player_name_edit.text.strip_edges().is_empty():
        player_name_edit.text = "Player_One"

    start_button.pressed.connect(_on_start_match_pressed)
    quick_button.pressed.connect(_on_quick_match_pressed)
    loadout_button.pressed.connect(_on_loadout_pressed)
    quit_button.pressed.connect(_on_quit_pressed)

    update_lobby_status()

func update_lobby_status() -> void:
    var player_name = player_name_edit.text.strip_edges()
    if player_name.is_empty():
        player_name = "Player_One"

    lobby_status.text = "[b]Squad status:[/b] 4 ready | [b]Commander:[/b] %s" % player_name

func _on_start_match_pressed() -> void:
    update_lobby_status()
    get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_quick_match_pressed() -> void:
    update_lobby_status()
    get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_loadout_pressed() -> void:
    lobby_status.text = "[b]Loadout:[/b] AR-12 equipped | Armor kit ready | Vehicle boost online"

func _on_quit_pressed() -> void:
    get_tree().quit()

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
        _on_start_match_pressed()
