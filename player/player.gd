extends CharacterBody2D

class_name Player
#Detects change in current health
signal hpChange
#Reads player movement
var input_movement = Vector2.ZERO
#Variables that can be affected/changed outside of script
@export var stats: Resource #Attribute values that script accesses
@export var knockbackPower: int = 250 #Distance targets are sent when hit by player(?)
@export var IFRAME: int = 1 #Time player recovers post-hit
#Initialize other variables
var knockback : Vector2 = Vector2.ZERO
var knockbackTween
#Player states
var playerHit: Area2D = null #When hit
var playerIFrame: bool = false #Post-hit recovery invulerability
var isAttacking: bool = false #When hitting
#Initialize animations from nodes in player scene
@onready var animations = $AnimationTree
@onready var weapon = $weapon

##var lastAnimDirection: int = 0 Commented out. Not sure if this is being used
#Initialize health to full
@onready var currentHealth: int = stats.max_Hp
#Start animation
func _ready():
	animations.active = true
#Receive user input
func handleInput():
	#Arrow keys to move
	input_movement = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#Movement speed calculation
	velocity = input_movement * stats.spd + knockback
	#Space button to start attack
	if Input.is_action_just_pressed("attack"):
		attack()
#Attack animation
func attack():
	#Begin attack animation
	animations["parameters/conditions/isAttacking"] = true
	weapon.enable() #Player weapon appears
	await animations.animation_finished #Plays out animation
	weapon.disable() #Player weapon disappears
	animations["parameters/conditions/isAttacking"] = false #End animation
#Animation flag checking
func updateAnimation():
	#Check if attacking
	if isAttacking: return
	#Check if not moving
	if input_movement.length() == 0:
		animations["parameters/conditions/isIdle"] = true
		animations["parameters/conditions/isMoving"] = false
	else: #When moving
		animations["parameters/conditions/isIdle"] = false
		animations["parameters/conditions/isMoving"] = true
		#Take vector of movement
		var direction = input_movement.normalized()
		#Apply movement vector to movement blend space
		animations["parameters/Idle/blend_position"] = direction
		animations["parameters/Move/blend_position"] = direction
		animations["parameters/Attack/blend_position"] = direction

# On player hit - takes in the enemy velocity to caluclate the knockback direction
# TODO: Customizable knockback power and duration based on the hitBox properties
# TODO: Add invincibility frames
func hit(enemyVelocity: Vector2):
	#Activate invicibility frames when hit
	playerIFrame = true
	#Reduce player health by 1. TODO: Change it to reduce by enemies damage value
	currentHealth -= 1
	#When player health reaches 0, reset to max health
	if currentHealth < 0:
		currentHealth = stats.max_Hp
	#Send signal to UI to update player health bar
	hpChange.emit()
	#Knockback player
	knockback = knockbackPower * (enemyVelocity - velocity).normalized()
	#Moves player away from source of damage
	knockbackTween = get_tree().create_tween()
	knockbackTween.parallel().tween_property(self, "knockback", Vector2.ZERO, 0.25)
	#Highlight player red to visually indicate damage and IFrame being active
	$Sprite2D.modulate = Color.RED
	#Gradually change red highlight to a traansparent white to return to predamaged state
	knockbackTween.parallel().tween_property($Sprite2D, "modulate", Color.WHITE, IFRAME)
	await get_tree().create_timer(IFRAME).timeout #Waits for IFrame time to end 
	playerIFrame = false #No longer invincible
#Ticks in game
func _physics_process(_delta):
	# In the future, with a state machine this logic will be encapsulated by the state of the player
	if playerHit != null and not playerIFrame:
		hit(playerHit.get_parent().velocity)
	#Check user input
	handleInput()
	#Movement of player entity
	move_and_slide()
	#Update animation flags
	updateAnimation()
#Area detection where damage sources may come in contact on player entity to damage player
func _on_hurt_box_area_entered(area:Area2D):
	# This is brittle, we should ensure that the hitbox and area that comes in contact with the player is actually an enemy hitBox
	# Might be achievable through collision layers and masks, but requires additional investigation
	if area.name == "hitBox":
		playerHit = area
#Area detection where player may come in contact with vulnerable entities to damage them
func _on_hurt_box_area_exited(area:Area2D):
	if area.name == "hitBox":
		playerHit = null
