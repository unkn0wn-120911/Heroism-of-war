extends Control

@onready var player_name_edit: LineEdit = $Center/Panel/Margin/VBox/PlayerName
@onready var lobby_status: RichTextLabel = $Center/Panel/Margin/VBox/LobbyStatus
@onready var start_button: Button = $Center/Panel/Margin/VBox/StartButton
@onready var quick_button: Button = $Center/Panel/Margin/VBox/QuickMatchButton
@onready var loadout_button: Button = $Center/Panel/Margin/VBox/LoadoutButton
@onready var quit_button: Button = $Center/Panel/Margin/VBox/QuitButton

var selected_mode: String = "Squad"
var available_modes: Array = ["Solo", "Duo", "Squad"]
var friends: Array = [
    {"name": "Nova", "status": "Online", "level": 28},
    {"name": "Blaze", "status": "Ready", "level": 31},
    {"name": "Jade", "status": "In Match", "level": 26},
    {"name": "Cobra", "status": "Online", "level": 33},
    {"name": "Rin", "status": "Ready", "level": 24}
]
var vault_items: Array = ["Urban Case", "Shadow Set", "Battle Pass", "Glider Pack", "Treasure Case"]
var collection_items: Array = ["Legendary skin pack", "Vehicle skin", "Emote bundle", "Avatar charm"]
var gun_catalog: Array = ["AR-12", "M4", "Scout", "Shotgun", "SMG-X"]
var glow_catalog: Array = ["Neon Blue", "Crimson Pulse", "Gold Core", "Arc Green"]
var info_panel: RichTextLabel

func _ready() -> void:
    var profile = AccountManager.get_or_create_profile()
    if player_name_edit.text.strip_edges().is_empty():
        player_name_edit.text = profile.get("name", "Player_One")

    selected_mode = profile.get("last_mode", "Squad")
    _build_mode_buttons()
    _build_info_panel()

    start_button.pressed.connect(_on_start_match_pressed)
    quick_button.pressed.connect(_on_quick_match_pressed)
    loadout_button.pressed.connect(_on_loadout_pressed)
    quit_button.pressed.connect(_on_quit_pressed)
    player_name_edit.text_submitted.connect(_on_player_name_submitted)

    save_account_profile()
    update_lobby_status()

func _build_mode_buttons() -> void:
    var mode_row = HBoxContainer.new()
    mode_row.name = "ModeRow"
    mode_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    mode_row.alignment = BoxContainer.ALIGNMENT_CENTER
    mode_row.add_theme_constant_override("separation", 10)

    for mode in available_modes:
        var mode_name = mode
        var button = Button.new()
        button.text = mode_name
        button.pressed.connect(func() -> void: _set_mode(mode_name))
        mode_row.add_child(button)

    if not has_node("ModeRow"):
        add_child(mode_row)
        move_child(mode_row, get_child_count() - 2)

    if selected_mode == "":
        selected_mode = "Squad"
    start_button.text = "Start %s Match" % selected_mode
    quick_button.text = "Quick %s" % selected_mode

func _build_info_panel() -> void:
    if get_node_or_null("InfoPanel") != null:
        info_panel = get_node("InfoPanel")
        return

    info_panel = RichTextLabel.new()
    info_panel.name = "InfoPanel"
    info_panel.bbcode_enabled = true
    info_panel.fit_content = true
    info_panel.scroll_active = false
    info_panel.text = "[b]Vault:[/b] Urban Case | [b]Collection:[/b] Legendary skin pack | [b]Guns:[/b] AR-12 | [b]Glow:[/b] Neon Blue"
    add_child(info_panel)
    move_child(info_panel, get_child_count() - 2)

func _set_mode(mode: String) -> void:
    selected_mode = mode
    var profile = AccountManager.load_profile()
    profile["last_mode"] = mode
    AccountManager.save_profile(profile)
    start_button.text = "Start %s Match" % mode
    quick_button.text = "Quick %s" % mode
    update_lobby_status()

func update_lobby_status() -> void:
    var player_name = player_name_edit.text.strip_edges()
    if player_name.is_empty():
        player_name = "Player_One"

    var profile = AccountManager.load_profile()
    var rank = profile.get("rank", "Bronze")
    var online_friend_count = 0
    for friend in friends:
        if friend["status"] == "Online" or friend["status"] == "Ready":
            online_friend_count += 1

    lobby_status.text = "[b]Mode:[/b] %s | [b]Squad status:[/b] 4 ready | [b]Commander:[/b] %s | [b]Rank:[/b] %s | [b]Friends:[/b] %d online" % [selected_mode, player_name, rank, online_friend_count]

    if info_panel != null:
        info_panel.text = "[b]Vault:[/b] %s | [b]Collection:[/b] %s | [b]Guns:[/b] %s | [b]Glow:[/b] %s" % [
            vault_items[0],
            collection_items[0],
            gun_catalog[0],
            glow_catalog[0]
        ]

func save_account_profile() -> void:
    var profile = AccountManager.get_or_create_profile(player_name_edit.text.strip_edges())
    profile["name"] = player_name_edit.text.strip_edges()
    profile["rank"] = profile.get("rank", "Bronze")
    profile["last_mode"] = selected_mode
    AccountManager.save_profile(profile)

func _on_player_name_submitted(_new_text: String) -> void:
    save_account_profile()
    update_lobby_status()

func _on_start_match_pressed() -> void:
    save_account_profile()
    update_lobby_status()
    get_tree().change_scene_to_file("res://scenes/Lobby.tscn")

func _on_quick_match_pressed() -> void:
    save_account_profile()
    update_lobby_status()
    get_tree().change_scene_to_file("res://scenes/Lobby.tscn")

func _on_loadout_pressed() -> void:
    save_account_profile()
    if info_panel != null:
        info_panel.text = "[b]Loadout:[/b] %s | [b]Vault:[/b] %s | [b]Active glow:[/b] %s | [b]Friends squad:[/b] %d online" % [
            gun_catalog[0],
            vault_items[1],
            glow_catalog[1],
            4
        ]
    lobby_status.text = "[b]Loadout ready:[/b] %s | [b]Vault:[/b] %s | [b]Mode:[/b] %s" % [gun_catalog[0], vault_items[1], selected_mode]

func _on_quit_pressed() -> void:
    get_tree().quit()

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
        _on_start_match_pressed()
