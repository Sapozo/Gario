extends GPUParticles2D

@onready var death_sfx: AudioStreamPlayer2D = $DeathSFX


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	death_sfx.pitch_scale = randf_range(0.9,1.1)
	death_sfx.play()
	finished.connect(queue_free)
	emitting = true
