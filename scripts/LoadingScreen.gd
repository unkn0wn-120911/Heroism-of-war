extends Control

@onready var title_label: Label = $Center/Panel/VBox/TitleLabel
@onready var status_label: Label = $Center/Panel/VBox/StatusLabel
@onready var progress_bar: ProgressBar = $Center/Panel/VBox/ProgressBar

var elapsed: float = 0.0
var content_url: String = "https://example.com/api/content/latest"
var http_request: HTTPRequest
var loading_config: Dictionary = {
    "title": "Heroism of War",
    "status": "Loading battle lobby...",
    "background_color": "#0A0F1A",
    "accent_color": "#5EC8FF",
    "animation": "pulse"
}

func _ready() -> void:
    http_request = HTTPRequest.new()
    add_child(http_request)
    http_request.request_completed.connect(_on_loading_config_loaded)

    title_label.text = loading_config["title"]
    status_label.text = loading_config["status"]
    progress_bar.min_value = 0.0
    progress_bar.max_value = 100.0
    progress_bar.value = 0.0

    _apply_background_color(loading_config.get("background_color", "#0A0F1A"))
    _load_remote_config()

func _load_remote_config() -> void:
    if content_url.is_empty():
        return
    var err = http_request.request(content_url)
    if err != OK:
        print("Loading config fetch failed: %s" % err)

func _on_loading_config_loaded(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
    if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
        return

    var text = body.get_string_from_utf8()
    var parsed = JSON.parse_string(text)
    if typeof(parsed) == TYPE_DICTIONARY:
        var loading = parsed.get("loading", {})
        if typeof(loading) == TYPE_DICTIONARY:
            loading_config = loading
            title_label.text = String(loading_config.get("title", "Heroism of War"))
            status_label.text = String(loading_config.get("status", "Loading battle lobby..."))
            _apply_background_color(String(loading_config.get("background_color", "#0A0F1A")))

func _apply_background_color(color_hex: String) -> void:
    if has_node("Background"):
        var bg = get_node("Background") as ColorRect
        if bg != null:
            var color = Color(color_hex)
            bg.color = color

func _process(delta: float) -> void:
    elapsed += delta
    var value = clamp((elapsed / 2.0) * 100.0, 0.0, 100.0)
    progress_bar.value = value

    if elapsed < 0.75:
        status_label.text = String(loading_config.get("status", "Loading account data..."))
    elif elapsed < 1.5:
        status_label.text = "Connecting to battle server..."
    elif elapsed < 2.0:
        status_label.text = "Preparing lobby..."
    else:
        get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
