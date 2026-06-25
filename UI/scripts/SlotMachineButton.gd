extends Control
@export var good_sound: AudioStream
@export var bad_sound: AudioStream

@onready var audio_player := AudioStreamPlayer.new()

@export var spin_button: Button
var is_spinning: bool = false
@export var reel_1: VBoxContainer
@export var reel_2: VBoxContainer
@export var reel_3: VBoxContainer

@export var rewards: Array[SlotReward] = []

var rng := RandomNumberGenerator.new()
var slot_grid: Array = []

func _ready() -> void:
	rng.randomize()
	add_child(audio_player)
	
	if spin_button:
		spin_button.pressed.connect(_on_spin_button_pressed)
	else:
		push_warning("No spin button assigned.")

func _spin_reel_visual(reel: VBoxContainer, spin_time: float) -> void:
	if reel == null:
		return

	var change_interval := 0.05
	var elapsed := 0.0
	_clear_reel(reel)
	while elapsed < spin_time:
		_spawn_falling_reward(reel,_get_random_reward_symbol())

		await get_tree().create_timer(change_interval).timeout
		elapsed += change_interval

	print("Reel stopped")


func _spawn_falling_reward(reel: Control, reward: SlotReward) -> void:
	var texture_rect := TextureRect.new()
	reel.get_parent().add_child(texture_rect)
	
	texture_rect.texture = reward.texture
	texture_rect.position = Vector2(0,-75)
	texture_rect.size = Vector2(144,144)

	var tween := create_tween()
	tween.tween_property(texture_rect, "position", Vector2(0,364), .15)\
		.set_trans(Tween.TRANS_LINEAR)

	tween.tween_callback(func():
		if is_instance_valid(texture_rect):
			texture_rect.queue_free()
	)


func _on_spin_button_pressed() -> void:
	if is_spinning:
		return
		
	spin_button.disabled = true
	is_spinning = true

	var result: Array[SlotReward] = [
		_get_random_reward_symbol(),
		_get_random_reward_symbol(),
		_get_random_reward_symbol()
	]
	
	var result2: Array[SlotReward] = [
		_get_random_reward_symbol(),
		_get_random_reward_symbol(),
		_get_random_reward_symbol()
	]
	
	var result3: Array[SlotReward] = [
		_get_random_reward_symbol(),
		_get_random_reward_symbol(),
		_get_random_reward_symbol()
	]
	var spin_for: float = rng.randf_range(1.7, 2.5)

	_spin_reel_visual(reel_1,spin_for)
	_spin_reel_visual(reel_2,spin_for)
	_spin_reel_visual(reel_3,spin_for)
	await get_tree().create_timer(spin_for).timeout
	
	slot_grid = [
		_add_rewards_in_reel(reel_1, result),
		_add_rewards_in_reel(reel_2, result2),
		_add_rewards_in_reel(reel_3, result3)
	]

	_animate_reel_drop(reel_1)
	await get_tree().create_timer(0.1).timeout
	_animate_reel_drop(reel_2)
	await get_tree().create_timer(0.1).timeout
	_animate_reel_drop(reel_3)
	await get_tree().create_timer(1).timeout
	await check_each_cell()
	await get_tree().create_timer(1).timeout
	is_spinning = false
	spin_button.disabled = false

func _animate_reel_drop(reel: Control) -> void:

	var start_position := reel.position
	
	var random_delay := rng.randf_range(0.0, 0.15)
	var random_duration := rng.randf_range(0.25, 0.55)
	var random_offset := rng.randf_range(25.0, 45.0)
	
	reel.position = start_position + Vector2(0, -random_offset)
	var tween := create_tween()

	tween.tween_interval(random_delay)

	tween.tween_callback(func():
		reel.visible = true
	)

	tween.tween_property(reel, "position", start_position, random_duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

func _get_random_reward_symbol() -> SlotReward:
	var index := rng.randi_range(0, rewards.size() - 1)
	return rewards[index]

func _clear_reel(reel: Control) -> void:
	for child in reel.get_children():
		child.queue_free()


func _add_rewards_in_reel(reel: VBoxContainer, reward_list: Array[SlotReward]) -> Array:
	reel.visible = false
	_clear_reel(reel)

	var reel_results: Array = []

	for reward in reward_list:
		var texture_rect := TextureRect.new()
		texture_rect.texture = reward.texture
		texture_rect.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL

		reel.add_child(texture_rect)

		var cell := {
			"node": texture_rect,
			"name": reward.reward_name,
			"reward": reward
		}

		reel_results.append(cell)

	return reel_results


#####CHECK CELLS FOR STUFF#########

func check_each_cell() -> void:
	for reel_index in 3:
		for row_index in 3:
			var cell = slot_grid[reel_index][row_index]
			var reward_name: String = cell["name"]
			var is_bad : bool = false
			var reward_string: String = ""
			match reward_name:
				"Duck":
					print("Duck found at reel ", reel_index, " row ", row_index)
					reward_string = "Duck +10"

				"Penguin":
					print("Penguin found at reel ", reel_index, " row ", row_index)
					reward_string = "Penguin +10"
					
				"Parrot":
					print("Penguin found at reel ", reel_index, " row ", row_index)
					reward_string = "Penguin +10"
					
				"Owl":
					print("Penguin found at reel ", reel_index, " row ", row_index)
					reward_string = "Penguin +10"
					
				"Chicken":
					print("Penguin found at reel ", reel_index, " row ", row_index)
					reward_string = "Penguin +10"

				"Giraffe":
					is_bad = true
					reward_string = "Giraffe -10"
					print("Giraffe found at reel ", reel_index, " row ", row_index)
					
				"Buffalo":
					is_bad = true
					reward_string = "Giraffe -10"
					
				"Hippo":
					is_bad = true
					reward_string = "Giraffe -10"
					
				"Sloth":
					is_bad = true
					reward_string = "Giraffe -10"
				_:
					print("Unknown reward: ", reward_name)
					
			create_floating_label(cell, reward_string, is_bad)
			await blink_cell(reel_index, row_index, is_bad)


func blink_cell(reel_index: int, row_index: int, is_bad: bool) -> void:
	var cell = slot_grid[reel_index][row_index]
	var texture_rect: TextureRect = cell["node"]
	
	if is_bad:
		audio_player.stream = bad_sound
	else:
		audio_player.stream = good_sound

	audio_player.play()
	for i in 2:
		if is_bad:
			texture_rect.modulate = Color.RED
		else :
			texture_rect.modulate = Color.GREEN
			
		await get_tree().create_timer(0.1).timeout

		texture_rect.modulate = Color.WHITE
		await get_tree().create_timer(0.05).timeout

func blink_row(row_index: int) -> void:
	for i in 3:
		for reel_index in 3:
			var cell = slot_grid[reel_index][row_index]
			var texture_rect: TextureRect = cell["node"]
			texture_rect.modulate = Color.RED

		await get_tree().create_timer(0.1).timeout

		for reel_index in 3:
			var cell = slot_grid[reel_index][row_index]
			var texture_rect: TextureRect = cell["node"]
			texture_rect.modulate = Color.WHITE

		await get_tree().create_timer(0.1).timeout

func blink_column(reel_index: int) -> void:
	for i in 3:
		for row_index in 3:
			var cell = slot_grid[reel_index][row_index]
			var texture_rect: TextureRect = cell["node"]
			texture_rect.modulate = Color.RED

		await get_tree().create_timer(0.1).timeout

		for row_index in 3:
			var cell = slot_grid[reel_index][row_index]
			var texture_rect: TextureRect = cell["node"]
			texture_rect.modulate = Color.WHITE

		await get_tree().create_timer(0.1).timeout

func create_floating_label(cell: Dictionary, text: String, is_bad: bool) -> void:
	var texture_rect: TextureRect = cell["node"]

	if texture_rect == null or not is_instance_valid(texture_rect):
		return

	var label := Label.new()
	label.text = text
	
	if is_bad:
		label.modulate = Color(1, 0, 0, 1)
	else :
		label.modulate = Color(0, 1, 0, 1)
		
	label.z_index = 100
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 28)

	add_child(label)

	label.global_position = texture_rect.global_position + Vector2(20, 20)

	var duration := 1.0

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(label, "global_position", label.global_position + Vector2(0, -40), duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

	tween.tween_property(label, "modulate:a", 0.0, duration)

	tween.finished.connect(func():
		if is_instance_valid(label):
			label.queue_free()
	)
