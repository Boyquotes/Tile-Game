### ----------------------------------------------------
### Desc
### ----------------------------------------------------
extends Camera2D

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var inputActive:bool = true

export (float) var COOLDOWN_TIME = 0.1
var cooldown:float = 0

export (float) var ZOOM_VALUE = 0.05

# For chunks (MapManager)
var currentElevation:int = 0

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func zoom_camera(value:float):
	if zoom[0] + value < 0.1: return
	if zoom[0] + value > 1:   return
	
	zoom = Vector2(zoom[0]+value, zoom[1]+value)


func move_camera(direction:Vector2):
	if Input.is_action_pressed("LShift"):
		direction *= 2
	
	position += direction
	cooldown = COOLDOWN_TIME


func _process(delta:float) -> void:
	if not inputActive:
		return
	
	if cooldown > 0:
		cooldown -= delta
		return
	
	if Input.is_action_pressed("Up"):
		move_camera(Vector2(0,-16))
	if Input.is_action_pressed("Down"):
		move_camera(Vector2(0,16))
	if Input.is_action_pressed("Left"):
		move_camera(Vector2(-16,0))
	if Input.is_action_pressed("Right"):
		move_camera(Vector2(16,0))


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			zoom_camera(-ZOOM_VALUE)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			zoom_camera(ZOOM_VALUE)
	
	if event is InputEventMouseMotion:
		if event.button_mask == BUTTON_MASK_MIDDLE:
			position -= event.relative * zoom
