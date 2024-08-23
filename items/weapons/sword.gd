extends Area2D
#Initialize weapon sprite
@onready var shape = $CollisionShape2D
#When weapon is called
func enable():
	shape.disabled = false #Sprite appears
#When weapon is not called
func disable():
	shape.disabled = true #Sprite disappears
