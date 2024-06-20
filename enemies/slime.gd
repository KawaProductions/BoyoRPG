extends CharacterBody2D

@export var stats: Resource
@export var limit = 0.5
@export var endPoint: Marker2D

@onready var animations = $AnimatedSprite2D

var startPos
var endPos
var player_chase = false
var player: CharacterBody2D = null
var isDead: bool = false

func _ready():
	startPos = position
	endPos = endPoint.global_position

func updateVelocity():
	var moveDirection
	if player_chase:
		moveDirection = player.position - position
	else:
		moveDirection = endPos - position
	if moveDirection.length() < limit:
		changeDirection()
	velocity = moveDirection.normalized() * stats.spd

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
	
func _physics_process(_delta):
	if isDead: return
	updateVelocity()
	move_and_slide()
	updateAnimation()

func _on_detection_area_body_entered(body):
	player = body
	player_chase = true

func _on_detection_area_body_exited(_body):
	player = null
	player_chase = false

func _on_hurt_box_area_entered(_area):
	animations.play("deathEffect")
	$CollisionShape2D.set_deferred("disabled", true)
	isDead = true
	await animations.animation_finished
	queue_free()
