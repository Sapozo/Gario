extends Area2D
class_name Bullet

@export var speed: float = 600.0

@onready var screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D


var direction: Vector2 = Vector2.RIGHT
var damage: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_notifier.screen_exited.connect(_on_screen_notifier_exited)
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * speed * delta


func _on_area_entered(area: Area2D):
	if area is HurtBox:
		area.take_hit(damage, global_position)
		queue_free()


func _on_screen_notifier_exited() -> void:
	queue_free()


func _on_body_entered(_node: Node2D) -> void:
		queue_free()


## Configura o tamanho, velocidade e dano do tiro com base no Nível
func setup_charge(tier: int) -> void:
	match tier:
		1: # Tiro Normal
			damage = 1
			scale = Vector2(1.0, 1.0)
		2: # Tiro Médio
			damage = 3
			scale = Vector2(2.2, 2.2)
			speed = 700.0
		3: # Super Tiro (Full Charge)
			damage = 10
			scale = Vector2(3.5 , 3.5)
			speed = 800.0
