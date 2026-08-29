extends Control
class_name PauseMenu



# Tela escurecida ao fundo do Menu de Pause
@onready var overlay: ColorRect = $Overlay
# 'Resume Game' , retorna ao jogo de onde foi pausado.
@onready var resume_button: Button = $MenuContainer/ResumeButton
# Reinicia a partida do início
@onready var restart_button: Button = $MenuContainer/RestartButton
# Botão de sair da partida e retornar ao menu inicial.
@onready var quit_button: Button = $MenuContainer/QuitButton



func _ready() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	overlay.modulate.a = 0.0
	visible = false
	


func _on_restart_pressed() -> void:
	get_tree().paused = false
	GameState.bgm_player.play()
	GameState.coins = GameState.level_start_coins
	GameState.level_coins = 0
	get_tree().reload_current_scene()


func _on_resume_pressed() -> void:
	toggle_pause()


func _on_quit_pressed() -> void:
	get_tree().quit()


func toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	
	if get_tree().paused == true :
		visible = true
		var fade_in = create_tween()
		fade_in.tween_property(overlay, "modulate:a", 0.7, 0.3).set_trans(Tween.TRANS_SINE)
		restart_button.grab_focus()
	if get_tree().paused == false :
		var fade_out = create_tween()
		fade_out.tween_property(overlay, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await fade_out.finished
		visible = false


func _unhandled_input(_InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()
