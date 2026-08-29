extends State
class_name PatrolState

# Velocidade de caminhada
@export var speed: float = 60.0

# Detector 'anti-abismo'
@onready var detector: RayCast2D = $"../../EdgeDetector"

# Direção ( 1 pra DIREITA e -1 pra ESQUERDA )
var direction: int = -1
# Gravidade ( positivo = pra baixo / negativo = pra cima)
var gravity: float = 980.0
# Timer de colisão do RayCast antes de nova checagem e mudança de direção
var edge_grace: float = 0.1
# Timer de conferência do 'anti-abismo'
var edge_grace_timer: float



func enter() -> void:
	owner.animated_sprite_2d.play("walk")
	owner.vision_area.body_entered.connect(_on_vision_body_entered)
	edge_grace_timer = edge_grace

func exit() -> void:
	owner.vision_area.body_entered.disconnect(_on_vision_body_entered)



func update(_delta: float) -> void:
		pass


func physics_update(delta: float) -> void:
	_apply_gravity(delta)
	_edge_detector(delta)
	_anti_wall()
	
	
	owner.velocity.x = direction * speed
	owner.move_and_slide()
	owner.animated_sprite_2d.flip_h = direction > 0

func _apply_gravity(delta: float) -> void:
	if not owner.is_on_floor():
		owner.velocity.y += gravity * delta


func _edge_detector(delta: float) -> void:
	detector.position.x = 15 * direction
	if detector.is_colliding():
		edge_grace_timer = edge_grace
	if owner.is_on_floor() and not detector.is_colliding():
		edge_grace_timer = max(0, edge_grace_timer - delta)
		if edge_grace_timer == 0:
			owner.velocity.x = 0.0
			_change_direction()


func _anti_wall() -> void:
	if not owner.is_on_wall():
		pass
	if owner.is_on_wall():
		_change_direction()


func _on_vision_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		transitioned.emit(self, "ChaseState")


func _change_direction() -> void:
	direction = -direction
	owner.animated_sprite_2d.flip_h = direction > 0
