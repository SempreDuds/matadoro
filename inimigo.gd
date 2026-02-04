extends CharacterBody3D

@export var speed = 3.5
@export var damage = 5
@export var health = 30

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var player = null # Vai guardar a referência do jogador

func _ready():
	# Tenta encontrar o player na cena principal
	# Nota: Isso assume que o player é o único nó no grupo "player" na cena
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta):
	# Gravidade
	if not is_on_floor():
		velocity.y -= gravity * delta

	if player:
		# Lógica simples de perseguição
		var direcao = (player.global_position - global_position).normalized()
		
		# Ignora o eixo Y para ele não tentar voar ou cavar
		direcao.y = 0 
		
		velocity.x = direcao.x * speed
		velocity.z = direcao.z * speed
		
		# Faz o inimigo olhar para o player
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	move_and_slide()
	
	# Verificar se encostou no player para dar dano
	verificar_ataque()

func verificar_ataque():
	# Usamos a AreaAtaque para saber se o player está perto
	var corpos = $AreaAtaque.get_overlapping_bodies()
	for corpo in corpos:
		if corpo.is_in_group("player"):
			if corpo.has_method("receber_dano"):
				corpo.receber_dano(damage)
				# Empurra o inimigo para trás para não dar dano infinito instantâneo
				velocity = -transform.basis.z * 10 

func receber_dano(qtd):
	health -= qtd
	print("Inimigo tomou ", qtd, " de dano. Vida: ", health)
	
	# Efeito visual de hit (piscar ou pular)
	position.y += 0.5 
	
	if health <= 0:
		morrer()

func morrer():
	print("Inimigo morreu!")
	queue_free() # Remove o inimigo do jogo
