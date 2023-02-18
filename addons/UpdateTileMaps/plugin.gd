### ----------------------------------------------------
# Plugin is used t update TileMaps
### ----------------------------------------------------

tool
extends EditorPlugin

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const MainPanel = preload("res://addons/UpdateTileMaps/Panel/Panel.tscn")
var MainPanelInstance

### ----------------------------------------------------
# SCRIPTS
### ----------------------------------------------------

func _enter_tree() -> void:
	MainPanelInstance = MainPanel.instance()
	get_editor_interface().get_editor_viewport().add_child(MainPanelInstance)
	make_visible(false)

func _exit_tree() -> void:
	if MainPanelInstance: MainPanelInstance.queue_free()

func has_main_screen():
	return true

func make_visible(visible: bool) -> void:
	if MainPanelInstance: MainPanelInstance.visible = visible

func get_plugin_name() -> String:
	return "UpdateTileMaps"

func get_plugin_icon() -> Texture:
	return get_editor_interface().get_base_control().get_icon("TileMap", "EditorIcons")
