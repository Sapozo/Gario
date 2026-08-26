extends State
class_name HurtState


# Tempo stunado
@export var hit_stun: float = 0.1
@export var speed: float = 90.0 # (A velocidade de corrida que você escolheu!).
@export var gravity: float = 980.0

# Stun timer
var stun_timer: float = 0.0



func enter() -> void:
	owner.velocity.x = 0.0
	owner.animated_sprite_2d.self_modulate = Color.TOMATO
	stun_timer = hit_stun


func exit() -> void:
	owner.animated_sprite_2d.self_modulate = Color.WHITE


func physics_update(delta: float) -> void:
	if not owner.is_on_floor():
		owner.velocity.y += gravity * delta
	owner.move_and_slide()
	stun_timer -= delta
	if stun_timer <= 0:
		transitioned.emit(self, "ChaseState")
	
