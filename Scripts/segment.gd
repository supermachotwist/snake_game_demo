class_name Segment
extends Area2D
@onready var head: Head = $"../Head"

var is_active: bool = false
var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.has_moved.connect(_on_player_moved)

func _on_player_moved(speed: float):
	if not is_active:
		tween = create_tween()
		# Using tween to time active frames of intial spawn (spawn protection)
		tween.tween_property(self, "scale", Vector2(1,1), 1/speed)
		await tween.finished
		is_active = true
	

func _on_area_entered(area: Area2D):
	if area is Head and is_active:
		SignalBus.game_lost.emit()
		
