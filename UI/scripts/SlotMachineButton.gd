extends Control

@export var spin_button: Button

@export var reel_1: VBoxContainer
@export var reel_2: VBoxContainer
@export var reel_3: VBoxContainer

@export var rewards: Array[SlotReward] = []

var rng := RandomNumberGenerator.new()
var slot_grid: Array = []

func _ready() -> void:
	rng.randomize()

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
	print("Spin button pressed")

	if rewards.is_empty():
		print("No rewards assigned.")
		return

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
	await get_tree().create_timer(0.6).timeout
	await check_each_cell()

func check_each_cell() -> void:
	if slot_grid.size() < 3:
		print("slot_grid is not ready")
		return

	for reel_index in 3:
		for row_index in 3:
			var cell = slot_grid[reel_index][row_index]
			var reward_name: String = cell["name"]

			match reward_name:
				"Duck":
					print("Duck found at reel ", reel_index, " row ", row_index)

				"Penguin":
					print("Penguin found at reel ", reel_index, " row ", row_index)

				"Giraffe":
					print("Giraffe found at reel ", reel_index, " row ", row_index)

				_:
					print("Unknown reward: ", reward_name)
			await blink_cell(reel_index, row_index)


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
	
func blink_cell(reel_index: int, row_index: int) -> void:
	var cell = slot_grid[reel_index][row_index]
	var texture_rect: TextureRect = cell["node"]

	for i in 2:
		texture_rect.modulate = Color.GREEN
		await get_tree().create_timer(0.05).timeout

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
