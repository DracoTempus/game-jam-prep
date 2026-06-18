@tool
extends EditorPlugin

var inspector_plugin: SideBySideNumbersInspector

func _enable_plugin() -> void:
	# Add autoloads here.
	pass

func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	inspector_plugin = SideBySideNumbersInspector.new()
	add_inspector_plugin(inspector_plugin)
	pass


func _exit_tree() -> void:
	remove_inspector_plugin(inspector_plugin)
	pass


class SideBySideNumbersInspector:
	extends EditorInspectorPlugin
	
	var hide_that_next_property := false
	
	func _can_handle(object: Object) -> bool:
		hide_that_next_property = false
		return true

	func _parse_property(
		object: Object,
		type: Variant.Type,
		name: String,
		hint_type: PropertyHint,
		export_string: String,
		usage_flags: int,
		wide: bool
	) -> bool:
		if hide_that_next_property:
			hide_that_next_property = false
			return true

		if export_string == "SideBySideNumbers":
			if type != TYPE_INT and type != TYPE_FLOAT:
				print("SideBySideNumbers error: Only works with number Properties : ", name, " type: ", type)
				return false
			var property_list := object.get_property_list()
			var index := property_list.find_custom(func(property): return property.name == name)

			var next_property = property_list[index + 1]
			var next_property_name: String = next_property["name"]

			if next_property["type"] != type:
				print("SideBySideNumbers error: both properties have to be the same type. First one is type: ",type,", but next one is ",next_property["type"])
				return false

			var editor := SideBySideNumbers.new(name, next_property_name)
			add_property_editor(name, editor)
			hide_that_next_property = true
			return true

		if export_string.begins_with("RangeSlider"):
			if type != TYPE_INT and type != TYPE_FLOAT:
				print("RangeSlider error: Only works with number Properties : ", name, " type: ", type)
				return false
			var property_list := object.get_property_list()
			var index := property_list.find_custom(func(property): return property.name == name)
		
			var next_property = property_list[index + 1]
			var next_property_name: String = next_property["name"]

			if next_property["type"] != type:
				print("RangeSlider error: both properties have to be the same type. First one is type: ",type,", but next one is ",next_property["type"])
				return false

			var settings := get_range_slider_settings(export_string,name)
			var editor := RangeSliderEditor.new(
				name,
				next_property_name,
				settings["min"],
				settings["max"],
				settings["buffer"]
			)

			add_property_editor(name, editor, false, settings["name"])
			hide_that_next_property = true
			return true

		#This wasn't special
		return false

	func get_range_slider_settings(export_string: String, defaultName: String) -> Dictionary:
		var settings := {
			"min": -1000.0,
			"max": 1000.0,
			"buffer": 0.0,
			"name":defaultName
		}

		var parts := export_string.split(":")
		if parts.size() < 2:
			return settings

		var numbers := parts[1].split(",")

		if numbers.size() >= 1:
			settings["min"] = numbers[0].to_float()

		if numbers.size() >= 2:
			settings["max"] = numbers[1].to_float()

		if numbers.size() >= 3:
			settings["buffer"] = numbers[2].to_float()
		
		if numbers.size() >= 4:
			settings["name"] = numbers[3]

		return settings
	

#--------------------------------------#
#             CLASSES                  #
#--------------------------------------#
class SideBySideNumbers:
	extends EditorProperty

	var first_property: String
	var second_property: String

	var first_SpinBox: SpinBox
	var second_SpinBox: SpinBox

	var updating := false

	func _init(new_first_property: String, new_second_property: String) -> void:
		first_property = new_first_property
		second_property = new_second_property


	func _ready() -> void:
		var row := HBoxContainer.new()
		first_SpinBox = SpinBox.new()
		first_SpinBox.min_value = -999999
		first_SpinBox.max_value = 999999
		first_SpinBox.step = 1
		first_SpinBox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		second_SpinBox = SpinBox.new()
		second_SpinBox.min_value = -999999
		second_SpinBox.max_value = 999999
		second_SpinBox.step = 1
		second_SpinBox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(first_SpinBox)
		row.add_child(second_SpinBox)
		add_child(row)
		first_SpinBox.value_changed.connect(_on_first_changed)
		second_SpinBox.value_changed.connect(_on_second_changed)


	func _update_property() -> void:
		updating = true
		first_SpinBox.value = get_edited_object().get(first_property)
		second_SpinBox.value = get_edited_object().get(second_property)
		updating = false


	func _on_first_changed(value: float) -> void:
		if updating:
			return

		emit_changed(first_property, value)


	func _on_second_changed(value: float) -> void:
		if updating:
			return

		emit_changed(second_property, value)


class RangeSliderEditor:
	extends EditorProperty

	var slider_min: float = -1000.0
	var slider_max: float = 1000.0
	var buffer: float = 0.0

	const STEP := 1.0

	var first_property: String
	var second_property: String

	var first_slider: HSlider
	var second_slider: HSlider
	var first_box: SpinBox
	var second_box: SpinBox

	var updating := false


	func _init(
		new_first_property: String,
		new_second_property: String,
		new_slider_min: float,
		new_slider_max: float,
		new_buffer: float = 0.0
	) -> void:
		first_property = new_first_property
		second_property = new_second_property
		slider_min = new_slider_min
		slider_max = new_slider_max
		buffer = new_buffer


	func _ready() -> void:
		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.28, 0.28, 0.28, 1.0)
		style.content_margin_top = 12
		style.content_margin_bottom = 12
		style.content_margin_left = 3
		style.content_margin_right = 3
		
		panel.add_theme_stylebox_override("panel", style)
		add_child(panel)
		
		var column := VBoxContainer.new()
		panel.add_child(column)
		
		var slider_row := VBoxContainer.new()
		column.add_child(slider_row)
		
		first_slider = HSlider.new()
		first_slider.min_value = slider_min
		first_slider.max_value = slider_max
		first_slider.step = STEP
		first_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		second_slider = HSlider.new()
		second_slider.min_value = slider_min
		second_slider.max_value = slider_max
		second_slider.step = STEP
		second_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		slider_row.add_child(first_slider)
		slider_row.add_child(second_slider)
		
		var box_row := HBoxContainer.new()
		column.add_child(box_row)
		
		first_box = SpinBox.new()
		first_box.min_value = slider_min
		first_box.max_value = slider_max
		first_box.step = STEP
		first_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		second_box = SpinBox.new()
		second_box.min_value = slider_min
		second_box.max_value = slider_max
		second_box.step = STEP
		second_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		box_row.add_child(first_box)
		box_row.add_child(second_box)
		
		first_slider.value_changed.connect(_on_first_changed)
		second_slider.value_changed.connect(_on_second_changed)
		first_box.value_changed.connect(_on_first_changed)
		second_box.value_changed.connect(_on_second_changed)


	func _update_property() -> void:
		var object := get_edited_object()
		if object == null:
			return
			
		updating = true
		var first_slider_value: float = object.get(first_property)
		var second_slider_value: float = object.get(second_property)
		
		first_slider.value = first_slider_value
		second_slider.value = second_slider_value
		first_box.value = first_slider_value
		second_box.value = second_slider_value

		updating = false


	func _on_first_changed(value: float) -> void:
		if updating:
			return
			
		var object := get_edited_object()
		if object == null:
			return
			
		var effective_buffer := minf(buffer, slider_max - slider_min)
		var first_slider_value: float = clampf(value, slider_min, slider_max)
		var second_slider_value: float = object.get(second_property)

		if first_slider_value + effective_buffer > second_slider_value:
			second_slider_value = first_slider_value + effective_buffer
			if second_slider_value > slider_max:
				second_slider_value = slider_max
				first_slider_value = second_slider_value - effective_buffer
		emit_changed(first_property, first_slider_value)
		emit_changed(second_property, second_slider_value)
		_update_property()

	func _on_second_changed(value: float) -> void:
		if updating:
			return

		var object := get_edited_object()
		if object == null:
			return
		var effective_buffer := minf(buffer, slider_max - slider_min)

		var first_slider_value: float = object.get(first_property)
		var second_slider_value: float = clampf(value, slider_min, slider_max)
		if second_slider_value - effective_buffer < first_slider_value:
			first_slider_value = second_slider_value - effective_buffer

			if first_slider_value < slider_min:
				first_slider_value = slider_min
				second_slider_value = first_slider_value + effective_buffer
			
		emit_changed(first_property, first_slider_value)
		emit_changed(second_property, second_slider_value)

		_update_property()
