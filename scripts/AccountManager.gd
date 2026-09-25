class_name AccountManager
extends Node

const ACCOUNT_PATH := "user://heroism_account.json"

static func get_or_create_profile(default_name: String = "Player_One") -> Dictionary:
    var profile = load_profile()
    if profile.is_empty():
        profile = {
            "name": default_name,
            "coins": 1200,
            "wins": 0,
            "matches": 0,
            "xp": 0,
            "rank": "Bronze",
            "skins": ["Default Outfit"],
            "last_mode": "battle_royale"
        }
        save_profile(profile)
    else:
        if profile.get("name", "").strip_edges().is_empty():
            profile["name"] = default_name
            save_profile(profile)
    return profile

static func load_profile() -> Dictionary:
    if not FileAccess.file_exists(ACCOUNT_PATH):
        return {}

    var file = FileAccess.open(ACCOUNT_PATH, FileAccess.READ)
    if file == null:
        return {}

    var text = file.get_as_text()
    var parsed = JSON.parse_string(text)
    if typeof(parsed) == TYPE_DICTIONARY:
        return parsed
    return {}

static func save_profile(profile: Dictionary) -> bool:
    var file = FileAccess.open(ACCOUNT_PATH, FileAccess.WRITE)
    if file == null:
        return false

    file.store_string(JSON.stringify(profile, "", true))
    return true
