extends Area2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# If head eats an apple, delete the apple and send apple eaten signal
func _on_area_entered(area: Area2D):
	if area is Head:
		await area.tween.finished
		SignalBus.apple_eaten.emit()
		queue_free()
	if area is Segment:
		SignalBus.respawn_apple.emit()
		queue_free()
