extends CharacterBody2D

@export var speed = 20
@export var limit = 0.5
@export var endPoint: Marker2D

@onready var animations = $AnimatedSprite2D

var startPos
var endPos

func _ready():
	startPos = position
	endPos = endPoint.global_position

func updateVelocity():
	var moveDirection = endPos - position
	if moveDirection.length() < limit:
		changeDirection()
	velocity = moveDirection.normalized() * speed

func updateAnimation():
	if velocity.length() == 0:
		animations.stop()
		return
		
	var direction = "Down"
	if velocity.y < 0:
		direction = "Up"
	
	animations.play("walk" + direction)
		
	
func changeDirection():
	var tempEnd = endPos
	endPos = startPos
	startPos = tempEnd
	
func _physics_process(delta):
	updateVelocity()
	move_and_slide()
	updateAnimation()
