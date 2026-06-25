extends Control

@export var spin_button: Button

@export var reel_1: VBoxContainer
@export var reel_2: VBoxContainer
@export var reel_3: VBoxContainer

@export var rewards: Array[SlotReward] = []

var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()

	if spin_button:
		spin_button.pressed.connect(_on_spin_button_pressed)
	else:
		push_warning("No spin button assigned.")


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

	_add_rewards_in_reel(reel_1, result)
	_add_rewards_in_reel(reel_2, result2)
	_add_rewards_in_reel(reel_3, result3)
	_animate_reel_drop(reel_1)
	_animate_reel_drop(reel_2)
	_animate_reel_drop(reel_3)


func _animate_reel_drop(reel: Control) -> void:
	var start_position := reel.position

	reel.visible = false
	reel.position = start_position + Vector2(0, -15)

	reel.visible = true

	var tween := create_tween()
	tween.tween_property(reel, "position", start_position, 0.5)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

func _get_random_reward_symbol() -> SlotReward:
	var index := rng.randi_range(0, rewards.size() - 1)
	return rewards[index]


func _add_rewards_in_reel(reel: VBoxContainer, reward_list: Array[SlotReward]) -> void:
	if reel == null:
		return

	for child in reel.get_children():
		child.queue_free()

	for reward in reward_list:
		var texture_rect := TextureRect.new()
		texture_rect.texture = reward.texture
		texture_rect.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
		reel.add_child(texture_rect)
