extends State
class_name ChaseState

@export var speed: float = 90.0 # (A velocidade de corrida que você escolheu!).
@export var gravity: float = 980.0
var target: Node2D = null # (Guarda a referência do TechMan enquanto estiver na visão).
var last_known_x: float = 0.0 # (A coordenada X para onde o Slime deve correr!).
# Direção ( 1 pra DIREITA e -1 pra ESQUERDA )
var direction: int = -1



func enter() -> void:
	if target == null:
		last_known_x = owner.global_position.x
	
	for body in owner.vision_area.get_overlapping_bodies():
		if body.is_in_group("player"):
			target = body
			break
	
	owner.vision_area.body_exited.connect(_on_vision_body_exited)


func exit() -> void:
	owner.vision_area.body_exited.disconnect(_on_vision_body_exited)


func update(_delta: float) -> void:
		pass


func physics_update(delta: float) -> void:
	if not owner.is_on_floor():
		owner.velocity.y += gravity * delta
	
	if target != null:
		last_known_x = target.global_position.x
	
	if last_known_x > owner.global_position.x:
		direction = 1
	if  last_known_x < owner.global_position.x:
		direction = -1
	
	owner.get_node("EdgeDetector").position.x = 15 * direction
	owner.animated_sprite_2d.flip_h = direction > 0
	owner.velocity.x = direction * speed
	if owner.is_on_floor() and not owner.get_node("EdgeDetector").is_colliding():
			owner.velocity.x = 0.0
			if target == null:
				transitioned.emit(self, "PatrolState")
	
	owner.move_and_slide()
	
	if abs(owner.global_position.x - last_known_x)  < 5 and target == null:
		transitioned.emit(self, "PatrolState")


func _on_vision_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
