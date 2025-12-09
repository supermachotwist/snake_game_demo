class_name Head
extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var input_dir: Dictionary = {
	"move_left": Vector2.LEFT,
	"move_right": Vector2.RIGHT,
	"move_up": Vector2.UP,
	"move_down": Vector2.DOWN
}

var tween: Tween
var current_dir: Vector2
var previous_dir: Vector2
#setting starting direction due to direction of head sprite
var starting_dir: Vector2 = input_dir["move_up"]
@export var move_speed: float = 10.0
var grid_size: int = 32
@onready var turn: AudioStreamPlayer = $Turn


var can_move: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_dir = starting_dir
	previous_dir = current_dir
	animated_sprite_2d.play()
	
func _unhandled_input(event):
	#check with direction has been pressed
	for key in input_dir:
		if event.is_action_pressed(key):
			if current_dir != input_dir[key] and current_dir * -1 != input_dir[key]:
				turn.play()
			current_dir = input_dir[key]
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if can_move:
		#make sure to only run the tween once
		can_move = false
		SignalBus.has_moved.emit(move_speed)
		var tmp_rot: float
		# We lock the direction the snake moves in case cur_dir changes while moving 
		var move_dir: Vector2 = current_dir
		
		tween = create_tween().set_parallel()
		#make sure that the snake cannot turn in opposite direction
		if previous_dir * -1 == current_dir:
			current_dir = previous_dir
			move_dir = previous_dir 
			
		#move the snake head in currently pressed direction
		tween.tween_property(self, "position", position + move_dir * grid_size, 1/move_speed)
		#rotate the snake head in currently pressed direction
		#make sure that head doesn't rotate more than PI radians or it looks weird
		tmp_rot = starting_dir.angle_to(current_dir)
		var rot_diff: float = rotation - tmp_rot
		if (abs(rot_diff)) > PI:
			if (rot_diff > 0):
				tween.tween_property(self, "rotation", tmp_rot + (2*PI), 1/move_speed).set_ease(Tween.EASE_OUT
					).set_trans(Tween.TRANS_CUBIC)
			else:
				tween.tween_property(self, "rotation", tmp_rot - (2*PI), 1/move_speed).set_ease(Tween.EASE_OUT
					).set_trans(Tween.TRANS_CUBIC)
		else:
			tween.tween_property(self, "rotation", tmp_rot, 1/move_speed).set_ease(Tween.EASE_OUT
				).set_trans(Tween.TRANS_CUBIC)
		await tween.finished
		previous_dir = move_dir
		rotation = tmp_rot
		can_move = true
	
	
	
	
