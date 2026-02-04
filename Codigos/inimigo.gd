extends CharacterBody3D

@export var speed = 3.5
@export var damage = 10
@export var health = 50

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var player = null
@onready var texto_vida = $Label3D # Referência ao texto

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	atualizar_texto_vida()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if player:
		var direcao = (player.global_position - global_position).normalized()
		direcao.y = 0 
		
		velocity.x = direcao.x * speed
		velocity.z = direcao.z * speed
		
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	move_and_slide()
	verificar_ataque()

func verificar_ataque():
	var corpos = $AreaAtaque.get_overlapping_bodies()
	for corpo in corpos:
		if corpo.is_in_group("player"):
			if corpo.has_method("receber_dano"):
				# Empurrão para trás para dar tempo ao jogador
				var empurrao = (global_position - corpo.global_position).normalized() * 10
				velocity += empurrao
				corpo.receber_dano(damage)

func receber_dano(qtd):
	health -= qtd
	atualizar_texto_vida()
	
	# Efeito visual (pulinho ao tomar dano)
	velocity.y = 3 
	
	if health <= 0:
		morrer()

func atualizar_texto_vida():
	# Muda o texto do Label3D
	if texto_vida:
		texto_vida.text = "HP: " + str(health)

func morrer():
	queue_free()
