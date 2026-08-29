extends Control
class_name MainMenu

@onready var overlay: ColorRect = $Overlay
@onready var start_game: Button = $MainMenu/MenuContainer/StartGame
@onready var quit: Button = $MainMenu/MenuContainer/Quit
@onready var main_menu: Control = $MainMenu



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_menu.visible = false
	start_game.pressed.connect(_on_start_game_pressed)
	quit.pressed.connect(_on_quit_pressed)
	GameState.apex_sprint.play()
	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 0, 5.0)
	await tween.finished
	main_menu.visible = true
	start_game.grab_focus()


func _on_start_game_pressed() -> void:
	GameState.apex_sprint.stop()  
	GameState.victory.play()
	SceneTransition.change_scene_with_fade("res://levels/Level01.tscn", 1.5)


func _on_quit_pressed() -> void:
	get_tree().quit()
