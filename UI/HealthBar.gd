extends TextureProgressBar

@export var player : Player

func _ready():
	player.hpChange.connect(update)
	update()

func update():
	value = player.current_Hp * 100 / player.stats.max_Hp
