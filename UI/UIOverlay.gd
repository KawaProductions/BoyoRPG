extends CanvasLayer
#Variable that reaches for objects outside of scope
@export var player : Player
#Initialize health bar UI
@onready var healthBar = $HealthBar
#Initialize UI
func _ready():
	player.hpChange.connect(update) #Waits for change in player health
	update() #Change player health bar accordingly
#Change UI based on player health
func update():
	healthBar.value = player.currentHealth * 100 / player.stats.max_Hp
