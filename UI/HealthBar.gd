extends ProgressBar

@export var player : Player

func ready():
	player.healthChanged.connect(update)
	update()
	
	
func update():
	value = player.currentHP * 100 / player.maxHP
