extends Node

@export var current_version: String = "1.0.0"
@export var manifest_url: String = "https://example.com/heroism_of_war/manifest.json"
@export var apk_download_url: String = "https://example.com/heroism_of_war/HeroismOfWar.apk"

var http_request: HTTPRequest
var latest_version: String = ""
var update_ready: bool = false

func _ready() -> void:
    http_request = HTTPRequest.new()
    add_child(http_request)
    http_request.request_completed.connect(_on_manifest_loaded)

func check_for_updates() -> void:
    if manifest_url == "":
        return
    var err = http_request.request(manifest_url)
    if err != OK:
        print("Update check failed: %s" % err)

func _on_manifest_loaded(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
    if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
        print("Update manifest unavailable.")
        return

    var text = body.get_string_from_utf8()
    var parsed = JSON.parse_string(text)
    if typeof(parsed) != TYPE_DICTIONARY:
        print("Update manifest invalid.")
        return

    latest_version = String(parsed.get("version", current_version))
    apk_download_url = String(parsed.get("apk_url", apk_download_url))

    if _is_newer_version(latest_version, current_version):
        update_ready = true
        print("Update available: %s -> %s" % [current_version, latest_version])
        _start_apk_download()
    else:
        print("Game is up to date.")

func _is_newer_version(candidate: String, current: String) -> bool:
    var a = candidate.split(".")
    var b = current.split(".")
    for i in range(max(a.size(), b.size())):
        var av = int(a[i]) if i < a.size() and a[i].is_valid_int() else 0
        var bv = int(b[i]) if i < b.size() and b[i].is_valid_int() else 0
        if av > bv:
            return true
        if av < bv:
            return false
    return false

func _start_apk_download() -> void:
    if OS.get_name() != "Android":
        print("OTA update ready. Download from: %s" % apk_download_url)
        return

    var uri = apk_download_url
    if uri.is_empty():
        return
    if not uri.begins_with("http"):
        return
    OS.shell_open(uri)
    print("Android update download started: %s" % uri)
