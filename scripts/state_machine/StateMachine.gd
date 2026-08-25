extends Node
class_name StateMachine


@export var inicial_state: State

var current_state: State
var states: Dictionary


func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name_to_lower()] = child
			child.transitioned.connect(_on_child_transitioned)
	if inicial_state != null:
		inicial_state.enter()
		current_state = inicial_state


func _process(delta) -> void:
	current_state.update(delta)


func _physics_process(delta: float) -> void:
	current_state.physics_update(delta)


func _on_child_transitioned(state: State, new_state_name: String) -> void:
	if state != current_state:
		return
	var new_state = states.get(new_state_name.to_lower())
	if new_state is not states:
		return
	if current_state:
		current_state.exit()
		new_state.enter()
		current_state = new_state
