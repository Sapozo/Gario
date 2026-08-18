extends CharacterBody2D

# Velocidade
@export var speed: float = 60.0
# Gravidade
@export var gravity: float = 980.0

# Referência ao node da sprite
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
# Referência ao node do RayCast2D
@onready var edge_detector: RayCast2D = $EdgeDetector

# Direção
var direction: int = 1
# Tratamento para o 'flip-flop' 
var can_change_direction: bool = true



func _ready() -> void:
	edge_detector.position.x = 15 * direction
	edge_detector.force_raycast_update()



func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_change_direction()
	_movement()
	move_and_slide()
		# Inverte a sprite quando necessário
	animated_sprite_2d.flip_h = direction > 0
	


# Aplica gravidade no body
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


# Movimenta lateralmente o body
func _movement() -> void:
	velocity.x = direction * speed


# Detector de beirada
func _change_direction() -> void:
	edge_detector.position.x = 15 * direction
	edge_detector.force_raycast_update()
	
	print("--- CHANGE DIR ---")
	print("direction: ", direction, " | raycast.x: ", edge_detector.position.x)
	print("is_on_floor: ", is_on_floor(), " | is_colliding: ", edge_detector.is_colliding())
	print("global_pos: ", global_position)
	
	if is_on_floor():
		if edge_detector.is_colliding() == false:
			print(">>> INVERTEU por buraco!")
			direction = -direction
	elif is_on_wall():
		print(">>> INVERTEU por parede!")
		direction = -direction
