extends Control

@onready var map_name_edit: LineEdit = $Panel/Margin/VBox/InputGrid/MapNameEdit
@onready var character_name_edit: LineEdit = $Panel/Margin/VBox/InputGrid/CharacterNameEdit
@onready var event_name_edit: LineEdit = $Panel/Margin/VBox/InputGrid/EventNameEdit
@onready var asset_path_edit: LineEdit = $Panel/Margin/VBox/InputGrid/AssetPathEdit
@onready var map_list: ItemList = $Panel/Margin/VBox/BottomRow/LeftPanel/MapList
@onready var character_list: ItemList = $Panel/Margin/VBox/BottomRow/MidPanel/CharacterList
@onready var event_list: ItemList = $Panel/Margin/VBox/BottomRow/RightPanel/EventList
@onready var status_label: Label = $Panel/Margin/VBox/StatusLabel
@onready var add_map_button: Button = $Panel/Margin/VBox/InputGrid/AddMapButton
@onready var add_character_button: Button = $Panel/Margin/VBox/InputGrid/AddCharacterButton
@onready var add_event_button: Button = $Panel/Margin/VBox/InputGrid/AddEventButton
@onready var import_asset_button: Button = $Panel/Margin/VBox/InputGrid/ImportAssetButton
@onready var save_button: Button = $Panel/Margin/VBox/InputGrid/SaveButton
@onready var back_button: Button = $Panel/Margin/VBox/InputGrid/BackButton
@onready var file_dialog: FileDialog = $FileDialog

var content_manifest: Dictionary = {
    "maps": [],
    "characters": [],
    "events": [],
    "assets": []
}

func _ready() -> void:
    add_map_button.pressed.connect(_on_add_map_pressed)
    add_character_button.pressed.connect(_on_add_character_pressed)
    add_event_button.pressed.connect(_on_add_event_pressed)
    import_asset_button.pressed.connect(_on_import_asset_pressed)
    save_button.pressed.connect(_on_save_pressed)
    back_button.pressed.connect(_on_back_pressed)
    file_dialog.file_selected.connect(_on_file_selected)

    load_manifest()
    refresh_lists()
    status_label.text = "Admin ready. Add new maps, characters, events, or imported visuals."

func _on_add_map_pressed() -> void:
    var map_name = map_name_edit.text.strip_edges()
    if map_name.is_empty():
        status_label.text = "Map name required."
        return

    content_manifest["maps"].append({
        "name": map_name,
        "type": "battle_royale",
        "scene": "res://maps/%s.tscn" % map_name.to_snake_case(),
        "description": "Custom map imported from admin panel"
    })
    map_name_edit.clear()
    refresh_lists()
    status_label.text = "Map added: %s" % map_name

func _on_add_character_pressed() -> void:
    var character_name = character_name_edit.text.strip_edges()
    if character_name.is_empty():
        status_label.text = "Character name required."
        return

    content_manifest["characters"].append({
        "name": character_name,
        "role": "hero",
        "model": "res://characters/%s.glb" % character_name.to_snake_case(),
        "skin": "default"
    })
    character_name_edit.clear()
    refresh_lists()
    status_label.text = "Character added: %s" % character_name

func _on_add_event_pressed() -> void:
    var event_name = event_name_edit.text.strip_edges()
    if event_name.is_empty():
        status_label.text = "Event name required."
        return

    content_manifest["events"].append({
        "name": event_name,
        "type": "live_event",
        "start_time": "2026-01-01T00:00:00Z",
        "reward": "battle_pass"
    })
    event_name_edit.clear()
    refresh_lists()
    status_label.text = "Event added: %s" % event_name

func _on_import_asset_pressed() -> void:
    file_dialog.popup_centered_ratio(0.7)
    status_label.text = "Select an asset to import to the content pack."

func _on_file_selected(path: String) -> void:
    var asset_name = path.get_file()
    if asset_name.is_empty():
        return

    content_manifest["assets"].append({
        "name": asset_name,
        "path": path,
        "type": "visual_asset",
        "category": "scene_or_character"
    })
    asset_path_edit.text = path
    refresh_lists()
    status_label.text = "Asset imported: %s" % asset_name

func _on_save_pressed() -> void:
    var path = "user://content_manifest.json"
    var file = FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        status_label.text = "Unable to save content manifest."
        return

    file.store_string(JSON.stringify(content_manifest, "\t"))
    status_label.text = "Content manifest saved to %s" % path

func _on_back_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func load_manifest() -> void:
    var path = "user://content_manifest.json"
    if not FileAccess.file_exists(path):
        return

    var file = FileAccess.open(path, FileAccess.READ)
    if file == null:
        return

    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) == TYPE_DICTIONARY:
        content_manifest = parsed

func refresh_lists() -> void:
    map_list.clear()
    character_list.clear()
    event_list.clear()

    for item in content_manifest["maps"]:
        map_list.add_item(String(item.get("name", "Map")))
    for item in content_manifest["characters"]:
        character_list.add_item(String(item.get("name", "Character")))
    for item in content_manifest["events"]:
        event_list.add_item(String(item.get("name", "Event")))
