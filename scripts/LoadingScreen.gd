extends Control

@onready var title_label: Label = $Center/Panel/VBox/TitleLabel
@onready var status_label: Label = $Center/Panel/VBox/StatusLabel
@onready var progress_bar: ProgressBar = $Center/Panel/VBox/ProgressBar

var elapsed: float = 0.0

func _ready() -> void:
    title_label.text = "Heroism of War"
    status_label.text = "Loading battle lobby..."
    progress_bar.min_value = 0.0
    progress_bar.max_value = 100.0
    progress_bar.value = 0.0

func _process(delta: float) -> void:
    elapsed += delta
    var value = clamp((elapsed / 2.0) * 100.0, 0.0, 100.0)
    progress_bar.value = value

    if elapsed < 0.75:
        status_label.text = "Loading account data..."
    elif elapsed < 1.5:
        status_label.text = "Connecting to battle server..."
    elif elapsed < 2.0:
        status_label.text = "Preparing lobby..."
    else:
        get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
