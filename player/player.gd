extends CharacterBody2D

class_name Player

signal hpChange

var input_movement = Vector2.ZERO

@export var stats: Resource

@onready var animations = $AnimationTree
@onready var weapon = $weapon

var lastAnimDirection: int = 0
var isAttacking: bool = false

@onready var current_Hp: int = stats.max_Hp

func _ready():
	animations.active = true

func handleInput():
	input_movement = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_movement != Vector2.ZERO:
		velocity = input_movement * stats.spd
	else:
		velocity = Vector2.ZERO
	
	if Input.is_action_just_pressed("attack"):
		attack()

func attack():
	##animations.play("attack" + lastAnimDirection)
	isAttacking = true
	weapon.enable()
	##await animations.animation_finished
	weapon.disable()
	isAttacking = false
		
func updateAnimation():
	##if isAttacking: return
	
	if velocity.length() == 0:
		animations.set("parameters/movement/current_state", 0)
	else:
		animations.set("parameters/movement/current_state", 1)
		var direction = 0
		match [velocity.x, velocity.y]:
			[ var x, var _y] when x < 0:
				direction = 1
			[ var x, var _y] when x > 0:
				direction = 2
			[ var _x, var y] when y < 0:
				direction = 3
			_:
				direction = 0
		animations.set("parameters/direction/current_state", direction)
		animations.set("parameters/lastDirection/current_state", direction)

func handleCollision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if (collider.name == "slime"&&current_Hp > 0):
			current_Hp -= 1
			hpChange.emit()
	
func _physics_process(_delta):
	handleInput()
	move_and_slide()
	handleCollision()
	updateAnimation()
