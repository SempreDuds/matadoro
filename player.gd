extends CharacterBody3D

@export var speed = 5.0
@export var run_speed = 15.0
@export var jump_velocity = 6
@export var sensibilidade_mouse = 0.003
@export var max_health = 100

var current_health = 100
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Referências
@onready var pivo_camera = $PivoCamera
@onready var mao = $Mao
@onready var area_espada = $Mao/AreaEspada
@onready var barra_vida = $CanvasLayer/Control/ProgressBar # Vamos criar isso no Passo 3

var is_attacking = false

func _ready():
	# Trava o mouse dentro da janela do jogo
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	current_health = max_health
	atualizar_hud()

func _input(event):
	# Movimento do Mouse (Rotação da Câmera)
	if event is InputEventMouseMotion:
		# Gira o Player inteiro na Horizontal (Y)
		rotate_y(-event.relative.x * sensibilidade_mouse)
		
		# Gira apenas o Pivot da Câmera na Vertical (X)
		pivo_camera.rotate_x(-event.relative.y * sensibilidade_mouse)
		# Limita para não dar cambalhota (clamp entre -90 e 45 graus aprox)
		pivo_camera.rotation.x = clamp(pivo_camera.rotation.x, deg_to_rad(-90), deg_to_rad(45))

	# Tecla ESC para soltar o mouse
	if event.is_action_pressed("sair"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Gravidade
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Pulo
	if Input.is_action_just_pressed("pular") and is_on_floor():
		velocity.y = jump_velocity

	# Velocidade
	var current_speed = speed
	if Input.is_action_pressed("correr"):
		current_speed = run_speed

	# Movimento com WASD (Relativo para onde o player está olhando)
	var input_dir = Input.get_vector("esquerda", "direita", "frente", "tras")
	# transform.basis garante que "frente" é a frente do personagem
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()

	# Ataque
	if Input.is_action_just_pressed("atacar") and not is_attacking:
		atacar()

func atacar():
	is_attacking = true
	var tween = create_tween()
	tween.tween_property(mao, "rotation:x", deg_to_rad(-90), 0.1)
	tween.tween_callback(verificar_hit)
	tween.tween_property(mao, "rotation:x", 0.0, 0.2)
	tween.tween_callback(func(): is_attacking = false)

func verificar_hit():
	var corpos = area_espada.get_overlapping_bodies()
	for corpo in corpos:
		if corpo.is_in_group("inimigo"):
			if corpo.has_method("receber_dano"):
				corpo.receber_dano(10) # Dano fixo de 10

func receber_dano(qtd):
	current_health -= qtd
	atualizar_hud()
	
	if current_health <= 0:
		print("Player Morreu!")
		get_tree().reload_current_scene()

func atualizar_hud():
	# Verifica se a barra existe antes de tentar atualizar (evita erros no inicio)
	if barra_vida:
		barra_vida.value = current_health
