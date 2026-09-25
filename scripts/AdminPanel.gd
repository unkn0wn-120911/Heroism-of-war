extends Control

@onready var map_name_edit: LineEdit = $Panel/Margin/VBox/InputGrid/MapNameEdit
@onready var character_name_edit: LineEdit = $Panel/Margin/VBox/InputGrid/CharacterNameEdit
@onready var event_name_edit: LineEdit = $Panel/Margin/VBox/InputGrid/EventNameEdit
@onready var asset_path_edit: LineEdit = $Panel/Margin/VBox/InputGrid/AssetPathEdit
@onready var map_list: ItemList = $Panel/Margin/VBox/BottomRow/LeftPanel/MapList
@onready var character_list: ItemList = $Panel/Margin/VBox/BottomRow/MidPanel/CharacterList
@onready var event_list: ItemList = $Panel/Margin/VBox/BottomRow/RightPanel/EventList
@onready var status_label: Label = $Panel/Margin/VBox/StatusLabel
@onready var admin_username_edit: LineEdit = $Panel/Margin/VBox/AuthRow/UsernameEdit
@onready var admin_password_edit: LineEdit = $Panel/Margin/VBox/AuthRow/PasswordEdit
@onready var login_button: Button = $Panel/Margin/VBox/AuthRow/LoginButton
@onready var backend_url_edit: LineEdit = $Panel/Margin/VBox/ServerRow/BackendUrlEdit
@onready var publish_button: Button = $Panel/Margin/VBox/ServerRow/PublishButton
@onready var add_map_button: Button = $Panel/Margin/VBox/InputGrid/AddMapButton
@onready var add_character_button: Button = $Panel/Margin/VBox/InputGrid/AddCharacterButton
@onready var add_event_button: Button = $Panel/Margin/VBox/InputGrid/AddEventButton
@onready var import_asset_button: Button = $Panel/Margin/VBox/InputGrid/ImportAssetButton
@onready var save_button: Button = $Panel/Margin/VBox/InputGrid/SaveButton
@onready var back_button: Button = $Panel/Margin/VBox/InputGrid/BackButton
@onready var file_dialog: FileDialog = $FileDialog

var http_request: HTTPRequest
var admin_token: String = ""
var pending_request_type: String = "publish"
const SESSION_PATH := "user://admin_session.json"

var content_manifest: Dictionary = {
    "maps": [],
    "characters": [],
    "events": [],
    "assets": []
}

func _ready() -> void:
    http_request = HTTPRequest.new()
    add_child(http_request)
    http_request.request_completed.connect(_on_request_completed)

    admin_password_edit.secret = true
    backend_url_edit.text = "https://heroism-of-war.vercel.app"
    login_button.pressed.connect(_on_login_pressed)
    add_map_button.pressed.connect(_on_add_map_pressed)
    add_character_button.pressed.connect(_on_add_character_pressed)
    add_event_button.pressed.connect(_on_add_event_pressed)
    import_asset_button.pressed.connect(_on_import_asset_pressed)
    publish_button.pressed.connect(_on_publish_pressed)
    save_button.pressed.connect(_on_save_pressed)
    back_button.pressed.connect(_on_back_pressed)
    file_dialog.file_selected.connect(_on_file_selected)

    load_session()
    load_manifest()
    refresh_lists()
    if admin_token.is_empty():
        status_label.text = "Admin login required before publishing content."
    else:
        status_label.text = "Admin session restored. Content can be published."

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

func _on_login_pressed() -> void:
    var base_url = _get_base_url()
    if base_url.is_empty():
        status_label.text = "Set the backend base URL before login."
        return

    pending_request_type = "login"
    status_label.text = "Signing in to admin panel..."
    var payload = JSON.stringify({
        "username": admin_username_edit.text.strip_edges(),
        "password": admin_password_edit.text
    })
    var err = http_request.request(base_url + "/api/admin/login", ["Content-Type: application/json"], HTTPClient.METHOD_POST, payload)
    if err != OK:
        status_label.text = "Login request failed: %s" % err

func _on_publish_pressed() -> void:
    if admin_token.is_empty():
        status_label.text = "Login required before publishing."
        return

    var url = _get_base_url() + "/api/admin/content/publish"
    if url.is_empty():
        status_label.text = "Set backend URL before publishing."
        return

    pending_request_type = "publish"
    status_label.text = "Publishing content to backend..."
    var headers = ["Content-Type: application/json", "Authorization: Bearer %s" % admin_token]
    var payload = JSON.stringify({
        "version": Time.get_datetime_string_from_system(false),
        "content": content_manifest,
        "updated_by": admin_username_edit.text.strip_edges()
    })
    var err = http_request.request(url, headers, HTTPClient.METHOD_POST, payload)
    if err != OK:
        status_label.text = "Publish request failed: %s" % err

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
    if result != HTTPRequest.RESULT_SUCCESS:
        status_label.text = "Backend request failed. Check server URL and connection."
        return

    var text = body.get_string_from_utf8()
    if text.is_empty():
        text = "OK"

    var parsed = JSON.parse_string(text)
    if pending_request_type == "login":
        if response_code >= 200 and response_code < 300 and typeof(parsed) == TYPE_DICTIONARY and parsed.get("token", "") != "":
            admin_token = String(parsed.get("token", ""))
            save_session()
            status_label.text = "Admin login successful. Session token saved."
            return
        status_label.text = "Login failed: %s" % text
        return

    if response_code >= 200 and response_code < 300:
        status_label.text = "Content uploaded to database successfully."
    else:
        status_label.text = "Upload failed: %s" % text

func _on_back_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _get_base_url() -> String:
    var text = backend_url_edit.text.strip_edges().rstrip("/")
    if text.contains("/api/admin/content/publish"):
        return text.replace("/api/admin/content/publish", "")
    if text.contains("/api/admin/login"):
        return text.replace("/api/admin/login", "")
    if text.contains("/api/content/latest"):
        return text.replace("/api/content/latest", "")
    return text

func save_session() -> void:
    var file = FileAccess.open(SESSION_PATH, FileAccess.WRITE)
    if file == null:
        return
    file.store_string(JSON.stringify({"token": admin_token}))

func load_session() -> void:
    if not FileAccess.file_exists(SESSION_PATH):
        return
    var file = FileAccess.open(SESSION_PATH, FileAccess.READ)
    if file == null:
        return
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) == TYPE_DICTIONARY:
        admin_token = String(parsed.get("token", ""))

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
