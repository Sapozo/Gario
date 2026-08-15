extends CharacterBody2D

# Velocidade horizontal em pixels por segundo
@export var speed: float = 300.0
# Força inicial do pulo (negativa porque Y cresce para BAIXO no Godot 2D)
@export var jump_velocity: float = -400.0
# Gravidade aplicada por segundo (positiva porque puxa para BAIXO)
@export var gravity: float = 980.0
# Base do CoyoteTime
@export var coyote_time: float = 0.1

# Referência do nó dentro do código
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var coyote_timer: float = 0.0



## Função de física — executada em intervalos fixos (60x/seg por padrão)
## Ideal para movimento e colisões
func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump(delta)
	_handle_movement()
	move_and_slide()
	_handle_animation()


## Aplica gravidade quando o player NÃO está no chão
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


## Detecta o coyote time, o input de pulo e aplica velocidade vertical
func _handle_jump(delta: float) -> void:
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = max(0.0, coyote_timer - delta)
		
	if Input.is_action_just_pressed("jump") and coyote_timer > 0:
		velocity.y = jump_velocity
		coyote_timer = 0.0


## Movimento lateral baseado no input
func _handle_movement() -> void:
	var direction: float = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed


# Realiza a troca das sprites de forma 'animada' e interativa
func _handle_animation() -> void:
	if is_on_floor():
		if velocity.x != 0:
			animated_sprite.play("walk")
			if velocity.x < 0:
				animated_sprite.flip_h = true
			else:
				animated_sprite.flip_h = false
		else:
			animated_sprite.play("idle")
	else:
		if velocity.y < 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
