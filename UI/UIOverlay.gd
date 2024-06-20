extends CanvasLayer

@export var player : Player
@onready var healthBar = $HealthBar

func _ready():
	player.hpChange.connect(update)
	update()

func update():
	healthBar.value = player.current_Hp * 100 / player.stats.max_Hp