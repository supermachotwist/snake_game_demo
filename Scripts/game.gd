extends Node2D

@onready var snake: Node2D = $Snake
@onready var head: Head = $Snake/Head
@onready var game_over: CanvasLayer = $GameOver
@onready var apples: Node2D = $Apples
@onready var score_ui: Label = $UI/Score
@onready var timer: Timer = $UI/Time/Timer
@onready var time: Label = $UI/Time
@onready var end_time: Label = $"GameOver/VBoxContainer/End Time"
@onready var end_score: Label = $"GameOver/VBoxContainer/End Score"

var score: int
var tween: Tween
var initial_segments: int = 4

var minutes: int = 0
var seconds: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.has_moved.connect(_on_head_moved)
	SignalBus.game_lost.connect(_on_game_lost)
	SignalBus.apple_eaten.connect(_on_apple_eaten)
	SignalBus.respawn_apple.connect(_spawn_apple)
	
	score = 0
	for i in initial_segments:
		_spawn_segment()
	
	_spawn_apple()

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("restart_game"):
		get_tree().reload_current_scene()
	# Spawn segment using space for debug purposes
	if event.is_action_pressed("debug_spawn_segment"):
		_spawn_segment()

# moves the segments towards the head
func _on_head_moved(speed: float):
	tween = create_tween().set_parallel()
	# if snake has one of more segments besides head
	if snake.get_child_count() > 1:
		for seg_index in snake.get_child_count():
			var cur_seg = snake.get_child(seg_index)
			if cur_seg is Segment:
				# move the segment to the next segment ahead of it
				tween.tween_property(cur_seg, "position", snake.get_child(seg_index-1).position, 1/speed)
			
# spawn new segment
func _spawn_segment():
	var segment = preload("res://Scenes/Segment.tscn").instantiate()
	 # move segment behind position of last segment
	segment.position = snake.get_children().back().position
	# add segment to snake
	snake.call_deferred("add_child", segment)

func _on_borders_area_entered(area: Area2D):
	if area is Head:
		SignalBus.game_lost.emit()
		
func _on_game_lost():
	end_time.text = time.text
	end_score.text = score_ui.text
	score_ui.hide()
	time.hide()
	# show game over screen
	game_over.show()
	if tween:
		tween.stop()
		head.tween.stop()
	timer.stop()
		
# Spawn a new apple on the grid (apple script takes care of spawn on top of snake)
func _spawn_apple():
	var apple = preload("res://Scenes/apple.tscn").instantiate()
	
	var tmp_x = randi_range(144, 624)
	var tmp_y = randi_range(144, 624)
	
	# Snap the apple to the grid
	apple.position.x = snapped(tmp_x, head.grid_size)
	apple.position.y = snapped(tmp_y, head.grid_size)
	apples.add_child(apple)
		
func _on_apple_eaten():
	score += 1
	score_ui.text = "Score: " + str(score)
	
	_spawn_apple()
	_spawn_segment()

func _on_timer_timeout():
	seconds += 1
	if seconds >= 60:
		minutes += 1
	var two_digit_format = "%0*d"
	time.text = "Time: " + two_digit_format % [2,minutes] + ":" + two_digit_format % [2,seconds]
	
