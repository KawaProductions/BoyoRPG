extends CharacterBody2D

class_name Player

signal hpChange

var input_movement = Vector2.ZERO

@export var stats: Resource
@export var knockbackPower: int = 250
@export var IFRAME: int = 1
var knockback : Vector2 = Vector2.ZERO
var knockbackTween
var playerHit: Area2D = null
var playerIFrame: bool = false

@onready var animations = $AnimationTree
@onready var weapon = $weapon

var lastAnimDirection: int = 0
var isAttacking: bool = false

@onready var currentHealth: int = stats.max_Hp

func _ready():
	animations.active = true

func handleInput():
	input_movement = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	velocity = input_movement * stats.spd + knockback
	
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
	
	if input_movement.length() == 0:
		animations["parameters/conditions/isIdle"] = true
		animations["parameters/conditions/isMoving"] = false
	else:
		animations["parameters/conditions/isIdle"] = false
		animations["parameters/conditions/isMoving"] = true
		
		var direction = input_movement.normalized()
		
		animations["parameters/Idle/blend_position"] = direction
		animations["parameters/Move/blend_position"] = direction
		animations["parameters/Attack/blend_position"] = direction

# On player hit - takes in the enemy velocity to caluclate the knockback direction
# TODO: Customizable knockback power and duration based on the hitBox properties
# TODO: Add invincibility frames
func hit(enemyVelocity: Vector2):
	playerIFrame = true
	currentHealth -= 1
	if currentHealth < 0:
		currentHealth = stats.max_Hp
	hpChange.emit()
	knockback = knockbackPower * (enemyVelocity - velocity).normalized()
	knockbackTween = get_tree().create_tween()
	knockbackTween.parallel().tween_property(self, "knockback", Vector2.ZERO, 0.25)

	$Sprite2D.modulate = Color.RED
	knockbackTween.parallel().tween_property($Sprite2D, "modulate", Color.WHITE, IFRAME)
	await get_tree().create_timer(IFRAME).timeout
	playerIFrame = false

func _physics_process(_delta):
	# In the future, with a state machine this logic will be encapsulated by the state of the player
	if playerHit != null and not playerIFrame:
		hit(playerHit.get_parent().velocity)
	handleInput()
	move_and_slide()
	updateAnimation()

func _on_hurt_box_area_entered(area:Area2D):
	# This is brittle, we should ensure that the hitbox and area that comes in contact with the player is actually an enemy hitBox
	# Might be achievable through collision layers and masks, but requires additional investigation
	if area.name == "hitBox":
		playerHit = area

func _on_hurt_box_area_exited(area:Area2D):
	if area.name == "hitBox":
		playerHit = null
