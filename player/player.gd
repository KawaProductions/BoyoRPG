extends CharacterBody2D

class_name Player

signal hpChange

var input_movement = Vector2.ZERO

@export var stats: Resource

@onready var animations = $AnimationPlayer
@onready var weapon = $weapon

var lastAnimDirection: String = "Down"
var isAttacking: bool = false

@onready var current_Hp: int = stats.max_Hp

func handleInput():
	input_movement = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_movement != Vector2.ZERO:
		velocity = input_movement * stats.spd
	else:
		velocity = Vector2.ZERO
	
	if Input.is_action_just_pressed("attack"):
		attack()

func attack():
	animations.play("attack" + lastAnimDirection)
	isAttacking = true
	weapon.enable()
	await animations.animation_finished
	weapon.disable()
	isAttacking = false
		
func updateAnimation():
	if isAttacking: return
	
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
			animations.seek(0.6, true)
	else:
		var direction = "Down"
		match [velocity.x, velocity.y]:
			[ var x, var _y] when x < 0:
				direction = "Left"
			[ var x, var _y] when x > 0:
				direction = "Right"
			[ var _x, var y] when y < 0:
				direction = "Up"
			_:
				direction = "Down"
		animations.play("move" + direction)
		lastAnimDirection = direction

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
