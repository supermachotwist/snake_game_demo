extends Node

signal has_moved(speed: float) # Player has moved
signal game_lost # Player has lost the game
signal apple_eaten # Apple has been eaten
signal respawn_apple # Respawn apple to avoid spawning inside snake
