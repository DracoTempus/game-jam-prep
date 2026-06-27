extends Control
@export var good_sound: AudioStream
@export var bad_sound: AudioStream

@onready var audio_player := AudioStreamPlayer.new()

@export var shiny_label: Label
@export var spin_button: Button
@export var spin_button_all: Button
var is_spinning: bool = false

@export var reel_1: VBoxContainer
@export var reel_2: VBoxContainer
@export var reel_3: VBoxContainer

@export var rewards: Array[SlotReward] = []

@export var shinies: int = 10

var current_bet = 0
var rng := RandomNumberGenerator.new()
var slot_grid: Array = []

func _ready() -> void:
	rng.randomize()
	add_child(audio_player)
	spin_button.pressed.connect(_on_spin_button_pressed)
	spin_button_all.pressed.connect(_on_spin_button_all_pressed)
	
	update_shiny_label()

func update_shiny_label() -> void:
	shiny_label.text = "Shinies: " + str(shinies)

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

func _on_spin_button_all_pressed() -> void:
	current_bet = shinies
	shinies = 0
	spin()

func _on_spin_button_pressed() -> void:
	shinies -= 1
	current_bet = 1
	spin()
	
func spin() -> void:
	update_shiny_label()
	if is_spinning:
		return
	
	spin_button_all.disabled = true
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
	await check_each_row()
	await check_each_column()
	await check_each_diagonal()
	await get_tree().create_timer(0.25).timeout
	check_shinies()
	is_spinning = false
	spin_button.disabled = false
	spin_button_all.disabled = false

func check_shinies() -> void:
	if shinies <= 0:
		visible = false
	

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
	var total_weight := 0.0

	for reward in rewards:
		total_weight += reward.weight

	var roll := rng.randf_range(0.0, total_weight)
	var current_weight := 0.0

	for reward in rewards:
		if reward.weight <= 0:
			continue

		current_weight += reward.weight

		if roll <= current_weight:
			return reward

	return rewards[rewards.size() - 1]

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
					reward_string = "Fly Speed+ and Nest+"
					GlobalSignalsManager.fly_speed += 6 * current_bet
					GlobalSignalsManager.nest_max_health +=1 * current_bet

				"Penguin":
					reward_string = "Ground Speed++ and Nest+"
					GlobalSignalsManager.ground_speed +=12 * current_bet
					GlobalSignalsManager.nest_max_health +=1 * current_bet
				
				"Parrot":
					reward_string = "Shiny +1"
					shinies +=1
					update_shiny_label()
				
				"Owl":
					reward_string = "Damage+ and Fly Speed+"
					GlobalSignalsManager.fly_speed += 5 * current_bet
					GlobalSignalsManager.attack_damage += .1 * current_bet
					
				"Chicken":
					reward_string = "Damage++"
					GlobalSignalsManager.attack_damage += .3 * current_bet
					
				"Giraffe":
					is_bad = true
					reward_string = "Launch Time+"
					GlobalSignalsManager.launch_off_time += .01 * current_bet
					
				"Buffalo":
					is_bad = true
					reward_string = "Geese Speed+ and Geese Health+"
					GlobalSignalsManager.goose_fly_speed += 5 * current_bet
					GlobalSignalsManager.goose_start_health += 0.25 * current_bet
					
				"Hippo":
					is_bad = true
					reward_string = "Geese Damage+"
					GlobalSignalsManager.goose_peck_damage += .05 * current_bet
					
				"Sloth":
					is_bad = true
					reward_string = "Fly Speed- and Ground Speed-"
					GlobalSignalsManager.fly_speed -= 2 * current_bet
					GlobalSignalsManager.ground_speed -= 3 * current_bet
					
			create_floating_label(cell, reward_string, is_bad)
			await blink_cell(reel_index, row_index, is_bad)

func check_each_row() -> void:
	for row_index in 3:
		var reward_name: String = slot_grid[0][row_index]["name"]
		var matching_row := true

		for reel_index in range(1, 3):
			var cell = slot_grid[reel_index][row_index]

			if cell["name"] != reward_name:
				matching_row = false
				break

		if matching_row:
			print("Matching row ", row_index, ": ", reward_name)
			var is_bad : bool = false
			var reward_string: String = ""
			match reward_name:
				"Duck":
					reward_string = "Fly Speed++++ and Nest++++"
					GlobalSignalsManager.fly_speed += 66 * current_bet
					GlobalSignalsManager.nest_max_health +=5 * current_bet

				"Penguin":
					reward_string = "Ground Speed+++ and Nest++"
					GlobalSignalsManager.ground_speed +=55 * current_bet
					GlobalSignalsManager.nest_max_health +=3 * current_bet
					
				"Parrot":
					reward_string = "Thrust Power+++ and Flight Time+++"
					GlobalSignalsManager.fly_add_time +=.35 * current_bet
					GlobalSignalsManager.max_fly_time += 1 * current_bet
					
				"Owl":
					reward_string = "Goose Damage--"
					GlobalSignalsManager.goose_peck_damage = min(0.5,GlobalSignalsManager.goose_peck_damage - (0.5  * current_bet))
					
				"Chicken":
					reward_string = "Damage+++"
					GlobalSignalsManager.attack_damage += 1 * current_bet

				"Giraffe":
					is_bad = true
					reward_string = "Goose Health+"
					GlobalSignalsManager.goose_start_health += 2 * current_bet
					
				"Buffalo":
					is_bad = true
					reward_string = "Geese Speed++"
					GlobalSignalsManager.goose_fly_speed += 20 * current_bet
					
				"Hippo":
					is_bad = true
					reward_string = "Geese Damage+++"
					GlobalSignalsManager.goose_peck_damage += 1 * current_bet
					
				"Sloth":
					is_bad = true
					reward_string = "Fly Speed-- and Ground Speed--"
					GlobalSignalsManager.fly_speed -= 10 * current_bet
					GlobalSignalsManager.ground_speed -= 10 * current_bet
				_:
					print("Unknown reward: ", reward_name)
					
			create_floating_label(slot_grid[1][row_index], reward_string, is_bad)
			await blink_row(row_index,is_bad)

func check_each_diagonal() -> void:
	var diagonals := [
		[
			Vector2i(0, 0),
			Vector2i(1, 1),
			Vector2i(2, 2)
		],
		[
			Vector2i(0, 2),
			Vector2i(1, 1),
			Vector2i(2, 0)
		]
	]

	for diagonal in diagonals:
		var first_pos: Vector2i = diagonal[0]
		var reward_name: String = slot_grid[first_pos.x][first_pos.y]["name"]
		var matching_diagonal := true

		for i in range(1, 3):
			var pos: Vector2i = diagonal[i]
			var cell = slot_grid[pos.x][pos.y]

			if cell["name"] != reward_name:
				matching_diagonal = false
				break

		if matching_diagonal:
			var is_bad: bool = false
			var reward_string: String = ""

			match reward_name:
				"Duck":
					reward_string = "Fly Speed++++ and Nest++++"
					GlobalSignalsManager.fly_speed += 55 * current_bet
					GlobalSignalsManager.nest_max_health += 3 * current_bet

				"Penguin":
					reward_string = "Ground Speed+++ and Nest++"
					GlobalSignalsManager.ground_speed += 60 * current_bet
					GlobalSignalsManager.nest_max_health += 5 * current_bet
					
				"Parrot":
					reward_string = "Thrust Power+++ and Flight Time+++"
					GlobalSignalsManager.fly_add_time += 0.25 * current_bet
					GlobalSignalsManager.max_fly_time += 0.5 * current_bet
					
				"Owl":
					reward_string = "Goose Damage--"
					GlobalSignalsManager.goose_peck_damage = min(0.5, GlobalSignalsManager.goose_peck_damage - (0.5 * current_bet))
					
				"Chicken":
					reward_string = "Damage+++"
					GlobalSignalsManager.attack_damage += 1 * current_bet

				"Giraffe":
					is_bad = true
					reward_string = "Goose Health+"
					GlobalSignalsManager.goose_start_health += 2 * current_bet
					
				"Buffalo":
					is_bad = true
					reward_string = "Geese Speed++"
					GlobalSignalsManager.goose_fly_speed += 20 * current_bet
					
				"Hippo":
					is_bad = true
					reward_string = "Geese Damage+++"
					GlobalSignalsManager.goose_peck_damage += 1 * current_bet
					
				"Sloth":
					is_bad = true
					reward_string = "Fly Speed-- and Ground Speed--"
					GlobalSignalsManager.fly_speed -= 20 * current_bet
					GlobalSignalsManager.ground_speed -= 10 * current_bet

				_:
					print("Unknown reward: ", reward_name)

			create_floating_label(slot_grid[1][1], reward_string, is_bad)
			await blink_diagonal(diagonal, is_bad)

func check_each_column() -> void:
	for reel_index in 3:
		var reward_name: String = slot_grid[reel_index][0]["name"]
		var matching_column := true

		for row_index in range(1, 3):
			var cell = slot_grid[reel_index][row_index]

			if cell["name"] != reward_name:
				matching_column = false
				break

		if matching_column:
			var is_bad : bool = false
			var reward_string: String = ""
			match reward_name:
				"Duck":
					reward_string = "Fly Speed++++ and Nest++++"
					GlobalSignalsManager.fly_speed += 45 * current_bet
					GlobalSignalsManager.nest_max_health +=5 * current_bet

				"Penguin":
					reward_string = "Ground Speed+++ and Nest++"
					GlobalSignalsManager.ground_speed +=32 * current_bet
					GlobalSignalsManager.nest_max_health +=3 * current_bet
					
				"Parrot":
					reward_string = "Thrust Power+++ and Flight Time+++"
					GlobalSignalsManager.fly_add_time +=.25 * current_bet
					GlobalSignalsManager.max_fly_time +=.5 * current_bet
					
				"Owl":
					reward_string = "Goose Damage--"
					GlobalSignalsManager.goose_peck_damage = min(0.5,GlobalSignalsManager.goose_peck_damage - (0.5 * current_bet))
					
				"Chicken":
					reward_string = "Damage+++"
					GlobalSignalsManager.attack_damage += 1 * current_bet

				"Giraffe":
					is_bad = true
					reward_string = "Goose Health+"
					GlobalSignalsManager.goose_start_health += 2 * current_bet
					
				"Buffalo":
					is_bad = true
					reward_string = "Geese Speed++"
					GlobalSignalsManager.goose_fly_speed += 20 * current_bet
					
				"Hippo":
					is_bad = true
					reward_string = "Geese Damage+++"
					GlobalSignalsManager.goose_peck_damage += 1 * current_bet
					
				"Sloth":
					is_bad = true
					reward_string = "Fly Speed-- and Ground Speed--"
					GlobalSignalsManager.fly_speed -= 20 * current_bet
					GlobalSignalsManager.ground_speed -= 10 * current_bet
				_:
					print("Unknown reward: ", reward_name)
					
			create_floating_label(slot_grid[reel_index][1], reward_string, is_bad)
			await blink_column(reel_index,is_bad)

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
			
		await get_tree().create_timer(0.09).timeout

		texture_rect.modulate = Color.WHITE
		await get_tree().create_timer(0.045).timeout

func blink_row(row_index: int, is_bad: bool) -> void:
	if is_bad:
		audio_player.stream = bad_sound
	else:
		audio_player.stream = good_sound
	
	for i in 3:
		for reel_index in 3:
			var cell = slot_grid[reel_index][row_index]
			var texture_rect: TextureRect = cell["node"]
			audio_player.play()
			
			if is_bad:
				texture_rect.modulate = Color.RED
			else :
				texture_rect.modulate = Color.GREEN

		await get_tree().create_timer(0.15).timeout

		for reel_index in 3:
			var cell = slot_grid[reel_index][row_index]
			var texture_rect: TextureRect = cell["node"]
			texture_rect.modulate = Color.WHITE

		await get_tree().create_timer(0.05).timeout

func blink_column(reel_index: int,is_bad: bool) -> void:
	if is_bad:
		audio_player.stream = bad_sound
	else:
		audio_player.stream = good_sound
	
	for i in 3:
		for row_index in 3:
			var cell = slot_grid[reel_index][row_index]
			var texture_rect: TextureRect = cell["node"]
			audio_player.play()
			
			if is_bad:
				texture_rect.modulate = Color.RED
			else :
				texture_rect.modulate = Color.GREEN

		await get_tree().create_timer(0.15).timeout

		for row_index in 3:
			var cell = slot_grid[reel_index][row_index]
			var texture_rect: TextureRect = cell["node"]
			texture_rect.modulate = Color.WHITE

		await get_tree().create_timer(0.05).timeout

func blink_diagonal(diagonal: Array, is_bad: bool) -> void:
	if is_bad:
		audio_player.stream = bad_sound
	else:
		audio_player.stream = good_sound
		
	for i in 3:
		for pos in diagonal:
			audio_player.play()
			var cell = slot_grid[pos.x][pos.y]
			var texture_rect: TextureRect = cell["node"]

			if is_bad:
				texture_rect.modulate = Color.RED
			else:
				texture_rect.modulate = Color.GREEN

		await get_tree().create_timer(0.15).timeout

		for pos in diagonal:
			var cell = slot_grid[pos.x][pos.y]
			var texture_rect: TextureRect = cell["node"]
			texture_rect.modulate = Color.WHITE

		await get_tree().create_timer(0.05).timeout
		
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
