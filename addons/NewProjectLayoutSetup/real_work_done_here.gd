@tool
extends EditorPlugin

var layout_erase_check_popup: ConfirmationDialog
var input_erase_check_popup: ConfirmationDialog

func _enter_tree() -> void:
	add_tool_menu_item("Quick Layout Setup", _on_select_me_layout)
	layout_erase_check_popup = ConfirmationDialog.new()
	layout_erase_check_popup.title = "Start layout process?"
	layout_erase_check_popup.dialog_text = "This will erase all existing nodes in the current scene and create them in my image.\n\nContinue?"
	layout_erase_check_popup.ok_button_text = "Erase and Create"
	layout_erase_check_popup.cancel_button_text = "Cancel"
	layout_erase_check_popup.confirmed.connect( _on_do_the_Magic_layout)
	get_editor_interface().get_base_control().add_child(layout_erase_check_popup)
	
	#I need to fix this
	#add_tool_menu_item("Quick Input Setup", _on_select_me_input)
	#input_erase_check_popup = ConfirmationDialog.new()
	#input_erase_check_popup.title = "Start Input process?"
	#input_erase_check_popup.dialog_text = "This will erase all existing inputs and create them in my image.\n\nContinue?"
	#input_erase_check_popup.ok_button_text = "Erase and Create Input"
	#input_erase_check_popup.cancel_button_text = "Cancel"
	#input_erase_check_popup.confirmed.connect( _on_do_the_Magic_input)
	#get_editor_interface().get_base_control().add_child(input_erase_check_popup)


func _exit_tree() -> void:
	remove_tool_menu_item("Quick Layout Setup")

func _on_select_me_input() -> void:
	input_erase_check_popup.popup_centered()

func _on_select_me_layout() -> void:
	layout_erase_check_popup.popup_centered()

func _on_do_the_Magic_input() -> void:
	print("This one doesn't work at the moment.")
	
	##for action_name in InputMap.get_actions():
		##if !action_name.begins_with("ui_"):
			##print("Erase " + action_name)
			##InputMap.erase_action(action_name)
	#
	#InputMap.add_action("move_left")
	#InputMap.add_action("move_right")
	#InputMap.add_action("move_up")
	#InputMap.add_action("move_down")
	#InputMap.add_action("action")
	#InputMap.add_action("pause")
	#
	#var move_left := InputEventKey.new()
	#move_left.keycode = KEY_A
	#InputMap.action_add_event("move_left", move_left)
#
	#var move_right := InputEventKey.new()
	#move_right.keycode = KEY_D
	#InputMap.action_add_event("move_right", move_right)
#
	#var move_up := InputEventKey.new()
	#move_up.keycode = KEY_W
	#InputMap.action_add_event("move_up", move_up)
#
	#var move_down := InputEventKey.new()
	#move_down.keycode = KEY_S
	#InputMap.action_add_event("move_down", move_down)
#
	#var action := InputEventMouseButton.new()
	#action.button_index = MOUSE_BUTTON_LEFT
	#InputMap.action_add_event("action", action)
#
	#var pause := InputEventKey.new()
	#pause.keycode = KEY_ESCAPE
	#InputMap.action_add_event("pause", pause)


func _on_do_the_Magic_layout() -> void:
	print("Starting Restructuring")

	var root := get_editor_interface().get_edited_scene_root()

	if root == null:
		push_warning("No scene is currently open.")
		return

	root.name = "WorldRoot"

	for child in root.get_children():
		root.remove_child(child)
		child.queue_free()

	var systemNode := Node.new()
	systemNode.name = "Systems"
	root.add_child(systemNode)
	systemNode.owner = root
	
	var worldNode := Node2D.new()
	worldNode.name = "World"
	root.add_child(worldNode)
	worldNode.owner = root
	
	var Level := Node2D.new()
	Level.name = "Level"
	worldNode.add_child(Level)
	Level.owner = root
	
	var Entities := Node2D.new()
	Entities.name = "Entities"
	worldNode.add_child(Entities)
	Entities.owner = root
	
	var Effects := Node2D.new()
	Effects.name = "Effects"
	worldNode.add_child(Effects)
	Effects.owner = root
	
	var HudLayer := CanvasLayer.new()
	HudLayer.name = "HUDLayer"
	root.add_child(HudLayer)
	HudLayer.owner = root
	
	var HudRoot := Control.new()
	HudRoot.name = "HudRoot"
	HudLayer.add_child(HudRoot)
	HudRoot.owner = root
	
	var PauseLayer := CanvasLayer.new()
	PauseLayer.name = "PauseLayer"
	root.add_child(PauseLayer)
	PauseLayer.owner = root
	
	var PauseRoot := Control.new()
	PauseRoot.name = "PauseRoot"
	PauseLayer.add_child(PauseRoot)
	PauseRoot.owner = root
	
	var TransitionLayer := CanvasLayer.new()
	TransitionLayer.name = "TransitionLayer"
	root.add_child(TransitionLayer)
	TransitionLayer.owner = root
	
	var TransitionRoot := Control.new()
	TransitionRoot.name = "TransitionRoot"
	TransitionLayer.add_child(TransitionRoot)
	TransitionRoot.owner = root
	
	var DebugLayer := CanvasLayer.new()
	DebugLayer.name = "DebugLayer"
	root.add_child(DebugLayer)
	DebugLayer.owner = root
	
	var DebugRoot := Control.new()
	DebugRoot.name = "DebugRoot"
	DebugLayer.add_child(DebugRoot)
	DebugRoot.owner = root
	
	get_editor_interface().mark_scene_as_unsaved()

func _enable_plugin() -> void:
	pass


func _disable_plugin() -> void:

	pass
