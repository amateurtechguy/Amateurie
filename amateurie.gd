extends Node2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var area = $Area2D

var speed = 300.0
var direction = Vector2(1, 0)
var screen_size = Vector2()
var window_size = Vector2(200, 200)

var idle_timer = 0.0
var is_idling = false
var is_dragging = false
var drag_offset = Vector2()
var is_hurt = false


func _ready():
	screen_size = Vector2(DisplayServer.screen_get_size())
	animated_sprite.play("walk")
	area.input_event.connect(_on_area_input)
	randomize()


func _physics_process(delta: float) -> void:
	if is_dragging:
		var mouse_pos = Vector2(DisplayServer.mouse_get_position())
		var new_win_pos = mouse_pos - drag_offset
		DisplayServer.window_set_position(Vector2i(new_win_pos))
		animated_sprite.play("hanging")
		return

	if is_idling:
		idle_timer -= delta
		animated_sprite.play("default")

		if idle_timer <= 0:
			is_idling = false
			speed = 300.0
			direction.x *= -1
			animated_sprite.flip_h = direction.x < 0
			animated_sprite.play("walk")

		return

	animated_sprite.play("walk")

	var window_position = Vector2(DisplayServer.window_get_position())
	window_position += direction * speed * delta

	window_position.x = clamp(
		window_position.x,
		0,
		screen_size.x - window_size.x
	)

	window_position.y = clamp(
		window_position.y,
		0,
		screen_size.y - window_size.y
	)

	DisplayServer.window_set_position(Vector2i(window_position))

	if window_position.x <= 0 or window_position.x >= screen_size.x - window_size.x:
		direction.x *= -1
		animated_sprite.flip_h = direction.x < 0
		maybe_idle()

	if window_position.y <= 0 or window_position.y >= screen_size.y - window_size.y:
		direction.y *= -1
		maybe_idle()


func maybe_idle():
	if randf() < 0.5:
		is_idling = true
		idle_timer = randf_range(1.0, 5.0)
		speed = 0
		animated_sprite.play("default")


func _on_area_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				var mouse_pos = Vector2(DisplayServer.mouse_get_position())
				var win_pos = Vector2(DisplayServer.window_get_position())
				drag_offset = mouse_pos - win_pos
			else:
				is_dragging = false
				animated_sprite.play("walk")
