extends CharacterBody2D


const BULLET_SCENE := preload("res://scenes/Bullet.tscn")

# Velocidade horizontal em pixels por segundo
@export var speed: float = 250.0
# Força inicial do pulo (negativa porque Y cresce para BAIXO no Godot 2D)
@export var jump_velocity: float = -400.0
# Gravidade aplicada por segundo (positiva porque puxa para BAIXO)
@export var gravity: float = 980.0
# Base do CoyoteTime
@export var coyote_time: float = 0.1
# Base do JumpBuffering
@export var jump_buffer_time: float = 0.1
# Base do Variable Jump Height
@export var jump_cut_multiplier: float = 0.3
# Anti-bug em animação spamável
@export var shoot_anim_time: float = 0.12
# Anti-bug em animação spamável
@export var land_anim_time: float = 0.15
# Configurações do Charge Shot
@export var charge_time_lvl2: float = 1.0  # Tempo para tiro médio
@export var charge_time_lvl3: float = 2.5  # Tempo para tiro carregado máximo
# Tempo para I-FRAMES
@export var invincibility_time: float = 1.0
# KNOCKBACK
@export var knowckback_force: Vector2 = Vector2(150.0, -100.0)


# Referência do nó dentro do código
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
# Referência do cano do canhão
@onready var muzzle: Marker2D = $Muzzle
# HURTBOX
@onready var hurt_box: HurtBox = $HurtBox
# HEALH COMPONENT
@onready var health_component: HealthComponent = $HealthComponent
# SFX dos tiros
@onready var shoot_1: AudioStreamPlayer2D = $SFX/Shoot1
@onready var shoot_2: AudioStreamPlayer2D = $SFX/Shoot2
@onready var shoot_3: AudioStreamPlayer2D = $SFX/Shoot3
@onready var jump: AudioStreamPlayer2D = $SFX/Jump
@onready var land: AudioStreamPlayer2D = $SFX/Land
@onready var hurt: AudioStreamPlayer2D = $SFX/Hurt
@onready var charging: AudioStreamPlayer2D = $SFX/Charging



var coyote_timer: float = 0.0
var buffer_timer: float = 0.0
var was_on_floor: bool = false # Guia para animação 'land'
var is_landing: bool = false # Guia final para animação 'land'
var is_shooting: bool = false # Guia para animação 'shot'
var shoot_timer: float = 0.0 # Auxílio para 'anti-bug' em animação spamável
var land_timer: float = 0.0 # Auxílio para 'anti-bug' em animação spamável
var charge_timer: float = 0.0  # Contabiliza quanto tempo o botão 'K' está segurado
var is_charging: bool = false  # Flag para saber se está carregando
var invincibility_timer: float = 0.0  # Timer para i-frames
var is_invincible: bool = false # I-FRAMES
var is_hurt: bool = false # I-FRAMES ANIMATION
var hurt_anim_time: float = 0.3 # Prioridade para animação
var hurt_timer: float = 0.0 # Timer pro hurt
var is_dead: bool = false



# Função de início da cena
func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finished)
	hurt_box.hurt.connect(_on_hurtbox_hurt)
	health_component.health_changed.connect(_on_health_changed)
	GameState.update_player_health(health_component.current_health, health_component.max_health)
	health_component.died.connect(_on_health_component_died)


## Função de física — executada em intervalos fixos (60x/seg por padrão)
## Ideal para movimento e colisões
func _physics_process(delta: float) -> void:
	_update_shoot_timer(delta)
	_update_invincibility_timer(delta)
	_update_hurt_timer(delta)
	_update_charge_visuals()
	_apply_gravity(delta)
	_handle_jump(delta)
	_handle_movement()
	_handle_shoot()
	move_and_slide()
	_handle_animation()
	_update_land_timer(delta)
	was_on_floor = is_on_floor()


## Aplica gravidade quando o player NÃO está no chão
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


## Detecta o jump buffering, o coyote time, o input de pulo e aplica função de pulo
func _handle_jump(delta: float) -> void:
	if is_dead == true:
		return
	if Input.is_action_pressed("debug_fly"): ## DEBUG CONTROL
		velocity.y = -250.0
	
	buffer_timer = max(0.0, buffer_timer - delta)
	if Input.is_action_just_pressed("jump"):
		buffer_timer = jump_buffer_time
		
	if is_on_floor() and buffer_timer > 0:
		_perform_jump()
		return
	
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = max(0.0, coyote_timer - delta)
		
	if Input.is_action_just_pressed("jump") and coyote_timer > 0:
		_perform_jump()
		
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= jump_cut_multiplier

# Realiza o pulo
func _perform_jump() -> void:
	velocity.y = jump_velocity
	coyote_timer = 0.0
	buffer_timer = 0.0
	is_landing = false
	land_timer = 0.0
	jump.pitch_scale = randf_range(0.90, 1.10)
	jump.play()


## Movimento lateral baseado no input
func _handle_movement() -> void:
	if is_dead == true:
		velocity.x = 0.0
		return
	if is_hurt == true:
		return
	var direction: float = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed


	## Trata o Input de Tiro e o Acúmulo de Carga
func _handle_shoot() -> void:
	if is_dead == true:
		return
	if is_hurt == true:
		return
	
	# 1. Pressionou 'K' no primeiro frame (Tiro rápido imediato)
	if Input.is_action_just_pressed("shot"):
		_trigger_shot_animation()
		_fire_bullet(1)
		charging.stop()
		shoot_1.pitch_scale = randf_range(0.9, 1.1)
		shoot_1.play()
		charge_timer = 0.0
		is_charging = true
	
	# 2. Segurando 'K' (Acumula o tempo de carga)
	elif Input.is_action_pressed("shot"):
		if is_charging:
			charge_timer += get_physics_process_delta_time()
			# (Futuro: Aqui adicionaremos um efeito visual/piscar do TechMan enquanto carrega!)
			if charging.is_playing():
				return
			else:
				charging.play()
	
	# 3. Soltou 'K' (Dispara o tiro carregado, se houver carga)
	elif Input.is_action_just_released("shot"):
		if is_charging:
			charging.stop()
			if charge_timer >= charge_time_lvl3:
				_trigger_shot_animation()
				_fire_bullet(3) # Dispara Tiro Nível 3!
				shoot_3.play()
				GameState.request_camera_shake(0.4)
				GameState.freeze_time(0.03)
			elif charge_timer >= charge_time_lvl2:
				_trigger_shot_animation()
				_fire_bullet(2) # Dispara Tiro Nível 2!
				shoot_2.play()
			
			# Reseta os controles de carga
			charge_timer = 0.0
			is_charging = false


# Realiza a troca das sprites de forma 'animada' e interativa
func _handle_animation() -> void:
	if is_dead == true:
		return
	# 1. FLIP DE DIREÇÃO (Acontece SEMPRE que houver movimento, mesmo atirando!)
	if velocity.x != 0:
		animated_sprite.flip_h = (velocity.x < 0)
		
	# Se a flag diz "landing", mas a animação atual já não é land, limpa a trava
	if is_landing and animated_sprite.animation != "land":
		is_landing = false
		land_timer = 0.0
	if is_hurt and animated_sprite.animation != "hurt":
		is_hurt = false
		hurt_timer = 0.0

	# 2. SE ESTIVER APANHANDO, ATIRANDO OU ATERRISSANDO, BLOQUEIA APENAS A TROCA DE ANIMAÇÃO BASE (walk/idle/jump)
	if is_hurt:
		return
	
	if is_landing:
		return

	if is_shooting:
		return
		
	# 3. ANIMAÇÕES DE MOVIMENTO (Aéreas e Terrestres)
	if velocity.y != 0:
		if velocity.y < 0:
			if animated_sprite.animation != "jump":
				animated_sprite.play("jump")
	elif is_on_floor():
		if velocity.x != 0:
			animated_sprite.play("walk")
		else:
			animated_sprite.play("idle")
	
	# 4. ATERRISSAGEM
	if not is_landing:
		if is_on_floor() and not was_on_floor:
			animated_sprite.play("land")
			land.pitch_scale = randf_range(0.90, 1.10)
			land.play()
			is_landing = true
			land_timer = land_anim_time


## Instancia e lança o projétil no mundo
func _fire_bullet(tier: int = 1) -> void:
	var bullet = BULLET_SCENE.instantiate()
	var offset: Vector2 = muzzle.position
	bullet.setup_charge(tier)
	
	# Ajusta a direção e o offset da arma dependendo de para onde o TechMan olha
	if animated_sprite.flip_h:
		bullet.direction = Vector2.LEFT
		offset.x = -offset.x # Espelha o Muzzle para a esquerda
		bullet.get_node('AnimatedSprite2D').flip_h = true
	else:
		bullet.direction = Vector2.RIGHT # Muzzle permanece na posição original (direita)
		
	# Adiciona o projétil na cena do Level (como nó irmão do TechMan)
	get_parent().add_child(bullet)
	
	# Posiciona o projétil no local correto do mapa
	bullet.global_position = global_position + offset


# Confere se a animação de aterrizagem terminou
func _on_animation_finished():
	if animated_sprite.animation == "land":
		is_landing = false
		land_timer = 0.0


# Atualiza o status 'is_shooting' anti spam bug
func _update_shoot_timer(delta) -> void:
	if shoot_timer > 0.0:
		shoot_timer = max(0.0, shoot_timer - delta)
		if shoot_timer == 0.0:
			is_shooting = false


# Atualiza o status 'is_landing' anti spam bug
func _update_land_timer(delta) -> void:
	if land_timer > 0.0:
		land_timer = max(0.0, land_timer - delta)
		if land_timer == 0.0:
			is_landing = false


## Auxiliar para disparar a animação e travar o estado de tiro
func _trigger_shot_animation() -> void:
	is_landing = false
	land_timer = 0.0
	is_shooting = true
	shoot_timer = shoot_anim_time
	animated_sprite.stop()
	animated_sprite.play("shot")


## Função para alternar a cor da sprite
func _update_charge_visuals() -> void:
	if is_invincible:
		return
	if is_charging == false:
		animated_sprite.self_modulate = Color.WHITE
		return
	else:
		if charge_timer >= charge_time_lvl3:
			if sin(Time.get_ticks_msec() * 0.025) > 0:
				animated_sprite.self_modulate = Color.YELLOW
			else:
				animated_sprite.self_modulate = Color.LIGHT_CORAL
		elif charge_timer >= charge_time_lvl2:
			if sin(Time.get_ticks_msec() * 0.015) > 0:
				animated_sprite.self_modulate = Color.CYAN
			else:
				animated_sprite.self_modulate = Color.CORNFLOWER_BLUE
		else:
			animated_sprite.self_modulate = Color.WHITE


func _on_hurtbox_hurt(amount: int, hit_position: Vector2) -> void:
	if is_invincible == true:
		return
	else:
		charging.stop()
		health_component.take_damage(amount)
		is_invincible = true
		invincibility_timer = invincibility_time
		is_hurt = true
		hurt_timer = hurt_anim_time
		animated_sprite.stop()
		animated_sprite.play("hurt")
		hurt.pitch_scale = randf_range(0.90, 1.10)
		hurt.play()
		is_charging = false
		is_shooting = false
		GameState.request_camera_shake(0.6)
		GameState.freeze_time(0.05)
	
	if is_dead == false:
		var dir: float = 1.0
		if global_position.x < hit_position.x:
			dir = -dir
		velocity.x = dir * knowckback_force.x
		velocity.y = knowckback_force.y
	
	
	if is_dead == true and not animated_sprite.animation == "die":
		animated_sprite.play("die")
		return


func _update_invincibility_timer(delta: float) -> void:
	if invincibility_timer > 0.0:
		invincibility_timer = max(0, invincibility_timer - delta)
		if sin(Time.get_ticks_msec() * 0.015) > 0:
			animated_sprite.self_modulate = Color.TRANSPARENT
		else:
			animated_sprite.self_modulate = Color.TOMATO
		if invincibility_timer == 0.0:
			is_invincible = false
			animated_sprite.self_modulate = Color.WHITE


func _update_hurt_timer(delta) -> void:
	if hurt_timer > 0:
		hurt_timer = max(0.0, hurt_timer - delta)
		if hurt_timer == 0:
			is_hurt = false


func _on_health_changed(new_health: int) -> void:
	GameState.update_player_health(new_health, health_component.max_health)


func _on_health_component_died() -> void:
	charging.stop()
	is_dead = true
	velocity = Vector2.ZERO
	hurt_box.set_deferred("monitorable", false)
	animated_sprite.stop()
	animated_sprite.play("die")
	await get_tree().create_timer(2.5).timeout
	get_tree().reload_current_scene()
	GameState.coins = GameState.level_start_coins
	GameState.level_coins = 0


# Cura o TechMan
func heal(amount: int) -> bool:
	return health_component.heal(amount)
