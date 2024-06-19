extends CharacterBody2D

var input_movement = Vector2.ZERO
@export var speed = 70
@onready var animations = $AnimationPlayer
@onready var weapon = $weapon

var lastAnimDirection: String = "Down"
var isAttacking: bool = false


func handleInput():
	input_movement = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_movement != Vector2.ZERO:
		velocity = input_movement * speed
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
			animations.seek(0.6,true)
	else:
		var direction = "Down"
		match [velocity.x, velocity.y]:
			[var x, var y] when x < 0:
				direction = "Left"
			[var x, var y] when x > 0:
				direction = "Right"
			[var x, var y] when y < 0:
				direction = "Up"
			_:
				direction="Down"
		animations.play("move" + direction)
		lastAnimDirection = direction
			
	
func _physics_process(delta):
	handleInput()
	move_and_slide()
	updateAnimation()
