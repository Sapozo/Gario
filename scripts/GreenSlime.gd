extends CharacterBody2D


# Partículas de morte
@export var slime_death_effect: PackedScene

# Referência ao node da sprite
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
# Referência ao node HurtBox
@onready var hurt_box: HurtBox = $HurtBox
# HEALTH COMPONENT
@onready var health_component: HealthComponent = $Components/HealthComponent
# RANDOM LOOT DROP
@onready var loot_drop_component: LootDropComponent = $Components/LootDropComponent
# Visão do inimigo
@onready var vision_area: Area2D = $VisionArea
# FiniteStateMachine (FSM)
@onready var state_machine: StateMachine = $StateMachine



func _ready() -> void:
	hurt_box.hurt.connect(_on_hurtbox_hurt)
	health_component.died.connect(_die)


# Função para matar o enemy
func _die() -> void:
	loot_drop_component.drop_loot(global_position)
	if slime_death_effect != null:
		var effect = slime_death_effect.instantiate()
		effect.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", effect)
		GameState.request_camera_shake(0.2)
		GameState.freeze_time(0.03)
		queue_free()


# Função que detecta sinal 'hurt' da HurtBox
func _on_hurtbox_hurt(amount: int, _hit_position: Vector2) -> void:
	health_component.take_damage(amount)
	if health_component.current_health > 0:
		state_machine.transition_to("HurtState")
