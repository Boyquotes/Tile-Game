### ----------------------------------------------------
### Controls camera movement in the editor
### Key inputs:
### 	WASD         - Move in a direction by 16 pixels
### 	Shift + WASD - Move in a direction faster
### 	Scroll Up    - Zoom camera out
### 	Scroll Down  - Zoom camera in
### 	-            - Minus elevation
### 	=            - Add elevation
### ----------------------------------------------------

extends Camera2D

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var inputActive:bool = true

export (float) var COOLDOWN_TIME = 0.1
var cooldown:float = 0

export (float) var ZOOM_VALUE = 0.05



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
	
	global_position += direction
	cooldown = COOLDOWN_TIME


func _process(delta:float) -> void:
	if not inputActive: return
	
	if cooldown > 0:
		cooldown -= delta
		return
	
	if Input.is_action_pressed(INPUT.TR["W"]):
		move_camera(Vector2(0,-DATA.Map.BASE_SCALE))
	if Input.is_action_pressed(INPUT.TR["S"]):
		move_camera(Vector2(0,DATA.Map.BASE_SCALE))
	if Input.is_action_pressed(INPUT.TR["A"]):
		move_camera(Vector2(-DATA.Map.BASE_SCALE,0))
	if Input.is_action_pressed(INPUT.TR["D"]):
		move_camera(Vector2(DATA.Map.BASE_SCALE,0))


func _input(event: InputEvent) -> void:
	if not inputActive: return
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			zoom_camera(-ZOOM_VALUE)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			zoom_camera(ZOOM_VALUE)
	
	if event is InputEventMouseMotion:
		if event.button_mask == BUTTON_MASK_MIDDLE:
			position -= event.relative * zoom
