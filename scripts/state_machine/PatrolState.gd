extends State
class_name PatrolState

# Velocidade de caminhada
@export var speed: float = 60.0

# Direção ( 1 pra DIREITA e -1 pra ESQUERDA )
var direction: int = -1
# Gravidade ( positivo = pra baixo / negativo = pra cima)
var gravity: float = 980.0



func enter() -> void:
	owner.animated_sprite_2d.play("walk")
	owner.vision_area.body_entered.connect(_on_vision_body_entered)

func exit() -> void:
	owner.vision_area.body_entered.disconnect(_on_vision_body_entered)



func update(_delta: float) -> void:
		pass


func physics_update(delta: float) -> void:
	if not owner.is_on_floor():
		owner.velocity.y += gravity * delta
	else:
		if not owner.get_node("EdgeDetector").is_colliding():
			direction = -direction
			owner.get_node("EdgeDetector").position.x = 15 * direction
			owner.animated_sprite_2d.flip_h = direction > 0
	
	if owner.is_on_wall():
		direction = -direction
		owner.get_node("EdgeDetector").position.x = 15 * direction
		owner.animated_sprite_2d.flip_h = direction > 0
	
	owner.velocity.x = direction * speed
	owner.move_and_slide()


func _on_vision_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		transitioned.emit(self, "ChaseState")
