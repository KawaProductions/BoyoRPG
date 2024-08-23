extends Node2D
#Initialize hurtbox of weapon
var weapon: Area2D
#Initialize weapon appearing
func _ready():
	if get_children().is_empty(): return
	
	weapon = get_children()[0]
#Activate weapon for attack animation
func enable():
	if !weapon: return
	visible = true #Weapon appears
	weapon.enable() #Hurtbox appears
#Deactivate weapon to end attack animation
func disable():
	if !weapon: return
	visible = false #Weapon disappears
	weapon.disable() #Hurtbox disappears
