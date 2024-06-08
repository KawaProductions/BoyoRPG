extends CharacterBody2D

var input_movement = Vector2.ZERO
@export var speed = 70
@onready var animations = $AnimationPlayer

func handleInput():
	input_movement = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_movement != Vector2.ZERO:
		velocity = input_movement * speed
	else:
		velocity = Vector2.ZERO
		
func updateAnimation():
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
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
			
	
func _physics_process(delta):
	handleInput()
	move_and_slide()
	updateAnimation()
