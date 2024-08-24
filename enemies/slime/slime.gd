extends CharacterBody2D
#Variables that are able to be changed via inspector
@export var stats: Resource
@export var limit = 0.5
@export var endPoint: Marker2D
#Initialize animation tree
@onready var animations = $AnimatedSprite2D
#Patrol points
var startPos
var endPos
#Flag for attack behavior
var player_chase = false
var player: CharacterBody2D = null #Behavior target
var isDead: bool = false #Flag for entity death
#Set patrol points on start
func _ready():
	startPos = position #Spawn position
	endPos = endPoint.global_position #End of path
#Change of movement speed
func updateVelocity():
	var moveDirection
	if player_chase: #When chasing
		moveDirection = player.position - position
	else: #When not chasing
		moveDirection = endPos - position
	if moveDirection.length() < limit: #When reached end point
		changeDirection()
	velocity = moveDirection.normalized() * stats.spd #Set speed
#Change animation
func updateAnimation():
	#When not moving
	if velocity.length() == 0:
		animations.stop() #Stop playing moving animation
		return
		
	var direction = "Down" #Animation set to moving down
	if velocity.y < 0: #When movement velocity is set upward
		direction = "Up" #Animation set to moving up
	#Play animation
	animations.play("walk" + direction)
#Change direction
func changeDirection():
	#Swap beginning and ending positions
	var tempEnd = endPos
	endPos = startPos
	startPos = tempEnd
#Game ticks
func _physics_process(_delta):
	if isDead: return #Check if dead
	updateVelocity() #Change movement speed
	move_and_slide() #Move sprite
	updateAnimation() #Change animation
#When player enters detection radius
func _on_detection_area_body_entered(body):
	player = body #Set player as targert
	player_chase = true #Follow target
#When player leaves detection radius
func _on_detection_area_body_exited(_body):
	player = null #Remove player as target
	player_chase = false #Do not follow target
#Area on entity that the player can damage if hitbox comes into contact
func _on_hurt_box_area_entered(area):
	if area.get_parent().is_in_group("enemy"): #Checks if entity is an enemy
		return #Does not take damage
	animations.play("deathEffect") #Entity dies if in contact with player hitbox
	disableCollisions() #Sprite no longer tangible
	isDead = true #Sets to dead
	await animations.animation_finished #finish death animation
	queue_free() #Remove entity

#Disables relavent areas
func disableCollisions():
	$CollisionShape2D.set_deferred("disabled", true)
	$hitBox.set_deferred("monitorable", false)
	$hitBox.set_deferred("monitoring", false)
