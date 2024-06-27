extends CharacterBody2D

class_name Player

signal hpChange

var input_movement = Vector2.ZERO

@export var stats: Resource
@export var knockbackPower: int = 1000

@onready var animations = $AnimationTree
@onready var weapon = $weapon

var lastAnimDirection: int = 0
var isAttacking: bool = false

@onready var currentHealth: int = stats.max_Hp

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
	animations["parameters/conditions/isAttacking"] = true
	weapon.enable()
	await animations.animation_finished
	weapon.disable()
	animations["parameters/conditions/isAttacking"] = false
		
func updateAnimation():
	if isAttacking: return
	
	if velocity.length() == 0:
		animations["parameters/conditions/isIdle"] = true
		animations["parameters/conditions/isMoving"] = false
	else:
		animations["parameters/conditions/isIdle"] = false
		animations["parameters/conditions/isMoving"] = true
		
		var direction = velocity.normalized()
		
		animations["parameters/Idle/blend_position"] = direction
		animations["parameters/Move/blend_position"] = direction
		animations["parameters/Attack/blend_position"] = direction
	
func _physics_process(_delta):
	handleInput()
	move_and_slide()
	updateAnimation()


func _on_hurt_box_area_entered(area:Area2D):
	if area.name == "hitBox":
		currentHealth -= 1
		if currentHealth < 0:
			currentHealth = stats.max_Hp
		hpChange.emit()
		print_debug(currentHealth)
		knockback(area.get_parent().velocity)

func knockback(enemyVelocity: Vector2):
	var knockbackDirection = (enemyVelocity - velocity).normalized() * knockbackPower
	velocity = knockbackDirection
	move_and_slide()
