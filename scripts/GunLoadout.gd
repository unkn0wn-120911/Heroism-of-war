extends Control

@onready var weapon_list: ItemList = $Panel/Margin/VBox/TopRow/LeftPanel/WeaponList
@onready var glow_list: ItemList = $Panel/Margin/VBox/TopRow/RightPanel/GlowList
@onready var collection_list: ItemList = $Panel/Margin/VBox/TopRow/RightPanel/CollectionList
@onready var selected_weapon_label: Label = $Panel/Margin/VBox/SelectedInfo/WeaponValue
@onready var selected_glow_label: Label = $Panel/Margin/VBox/SelectedInfo/GlowValue
@onready var selected_collection_label: Label = $Panel/Margin/VBox/SelectedInfo/CollectionValue
@onready var vault_label: Label = $Panel/Margin/VBox/VaultStatus
@onready var equip_button: Button = $Panel/Margin/VBox/ButtonRow/EquipButton
@onready var back_button: Button = $Panel/Margin/VBox/ButtonRow/BackButton

var weapons: Array = ["AR-12", "M4", "Scout", "Shotgun", "SMG-X"]
var glows: Array = ["Neon Blue", "Crimson Pulse", "Gold Core", "Arc Green"]
var collections: Array = ["Legendary skin pack", "Vehicle skin", "Emote bundle", "Avatar charm", "Battle Pass"]
var selected_weapon: String = "AR-12"
var selected_glow: String = "Neon Blue"
var selected_collection: String = "Legendary skin pack"

func _ready() -> void:
    var profile = AccountManager.get_or_create_profile()
    selected_weapon = profile.get("weapon", selected_weapon)
    selected_glow = profile.get("glow", selected_glow)
    selected_collection = profile.get("collection", selected_collection)

    weapon_list.item_selected.connect(_on_weapon_selected)
    glow_list.item_selected.connect(_on_glow_selected)
    collection_list.item_selected.connect(_on_collection_selected)
    equip_button.pressed.connect(_on_equip_pressed)
    back_button.pressed.connect(_on_back_pressed)

    _populate_lists()
    _refresh_summary()

func _populate_lists() -> void:
    weapon_list.clear()
    glow_list.clear()
    collection_list.clear()

    for item in weapons:
        weapon_list.add_item(item)
    for item in glows:
        glow_list.add_item(item)
    for item in collections:
        collection_list.add_item(item)

    var weapon_index = weapons.find(selected_weapon)
    var glow_index = glows.find(selected_glow)
    var collection_index = collections.find(selected_collection)

    if weapon_index >= 0:
        weapon_list.select(weapon_index)
    if glow_index >= 0:
        glow_list.select(glow_index)
    if collection_index >= 0:
        collection_list.select(collection_index)

func _on_weapon_selected(index: int) -> void:
    selected_weapon = weapons[index]
    _refresh_summary()

func _on_glow_selected(index: int) -> void:
    selected_glow = glows[index]
    _refresh_summary()

func _on_collection_selected(index: int) -> void:
    selected_collection = collections[index]
    _refresh_summary()

func _refresh_summary() -> void:
    selected_weapon_label.text = selected_weapon
    selected_glow_label.text = selected_glow
    selected_collection_label.text = selected_collection
    vault_label.text = "Vault: Urban Case | Collection: %s | Glow: %s" % [selected_collection, selected_glow]

func _on_equip_pressed() -> void:
    var profile = AccountManager.get_or_create_profile()
    profile["weapon"] = selected_weapon
    profile["glow"] = selected_glow
    profile["collection"] = selected_collection
    profile["vault"] = ["Urban Case", "Shadow Set", "Battle Pass"]
    AccountManager.save_profile(profile)
    _refresh_summary()

func _on_back_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
