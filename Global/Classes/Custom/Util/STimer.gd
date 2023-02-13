### ----------------------------------------------------
### One time use util timer
### ----------------------------------------------------

extends Reference
class_name STimer

### ----------------------------------------------------
### VARIABLES
### ----------------------------------------------------

var startTime:int

### ----------------------------------------------------
### FUNCTIONS
### ----------------------------------------------------

func _init(sTime:int) -> void:
	startTime = sTime


func get_result():
	return (Time.get_ticks_msec() - startTime)
