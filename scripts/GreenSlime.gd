extends CharacterBody2D

# Velocidade
@export var speed: float = 60.0
# Gravidade
@export var gravity: float = 980.0

# Referência ao node da sprite
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
# Referência ao node do RayCast2D
@onready var edge_detector: RayCast2D = $EdgeDetector
# Referência ao node HurtBox
@onready var hurt_box: HurtBox = $HurtBox
# HEALTH COMPONENT
@onready var health_component: HealthComponent = $Components/HealthComponent
# RANDOM LOOT DROP
@onready var loot_drop_component: LootDropComponent = $Components/LootDropComponent


# Direção
var direction: int = 1



func _ready() -> void:
	edge_detector.position.x = 15 * direction
	edge_detector.force_raycast_update()
	hurt_box.hurt.connect(_on_hurtbox_hurt)
	health_component.died.connect(_die)



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
	
	if is_on_floor() and not edge_detector.is_colliding():
			direction = -direction
	elif is_on_wall():
		direction = -direction


# Função para matar o enemy
func _die() -> void:
	loot_drop_component.drop_loot(global_position)
	queue_free()


# Função que detecta sinal 'hurt' da HurtBox
func _on_hurtbox_hurt(amount: int, _hit_position: Vector2) -> void:
	health_component.take_damage(amount)
