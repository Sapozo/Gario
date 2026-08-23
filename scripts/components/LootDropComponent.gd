extends Node2D
class_name LootDropComponent

@export var item_1: PackedScene
@export var item_2: PackedScene
@export var item_3: PackedScene



func drop_loot(spawn_position: Vector2) -> void:
	var roll: float = randf()
	var item_to_spawn
	
	if roll > 0.95 and item_1 != null:
		item_to_spawn = item_1.instantiate()
	elif roll > 0.6 and item_2 != null:
		item_to_spawn = item_2.instantiate()
	elif roll > 0.5 and item_3 != null:
		item_to_spawn = item_3.instantiate()
	
	if item_to_spawn != null:
		item_to_spawn.global_position = spawn_position
		spawn_position.y -= 12.0
		print("LootDropComponent: Spawnando ", item_to_spawn.name, " em ", global_position)
		get_tree().current_scene.call_deferred("add_child", item_to_spawn)
