extends CharacterBody2D

@export_group("Movement Physics")
@export var speed: float = 250.0
@export var jump_velocity: float = -420.0
@export var acceleration: float = 1800.0
@export var friction: float = 1200.0


var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# False = World 1 (Layer 2) True = World 2 (Layer 3)
var is_world_2: bool = false

@onready var sprite = $Sprite2D
@onready var world_1 = $"../World1"
@onready var world_2 = $"../World2"
@onready var flash_rect = $"../UI/FlashRect"
@onready var world_label = $"../UI/WorldLabel"

func _ready() -> void:
	update_world_state()

func _unhandled_input(event: InputEvent) -> void:
	# Toggle between world 1 and 2
	if event.is_action_pressed("toggle_world"):
		toggle_world()
		
	# Toggle between full screen and not 
	if event.is_action_pressed("toggle_fullscreen"):
		toggle_fullscreen()

func toggle_world() -> void:
	is_world_2 = !is_world_2
	update_world_state()
	trigger_flash()

func update_world_state() -> void:
	if is_world_2:
		# Layer 1 (Neutral) + Layer 3 (World 2) -> Bitmask: 1 + 4 = 5
		collision_mask = 5
		world_1.visible = false
		world_2.visible = true
		world_label.text = "REALITY: OMEGA"
		world_label.modulate = Color(1.0, 0.2, 0.5) # Turns pink/magenta in World 2
	else:
		# Layer 1 (Neutral) + Layer 2 (World 1) -> Bitmask: 1 + 2 = 3
		collision_mask = 3
		world_1.visible = true
		world_2.visible = false
		world_label.text = "REALITY: ALPHA"
		world_label.modulate = Color(0.2, 0.8, 1.0) # Turns cyan in World 1

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jump (Uses Spacebar / UI Accept)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Horizontal Input (Arrow keys or A/D keys)
	var input_dir := Input.get_axis("left", "right")
	
	# Smooth acceleration & braking for clean platformer feel
	if input_dir != 0:
		velocity.x = move_toward(velocity.x, input_dir * speed, acceleration * delta)
		sprite.flip_h = (input_dir < 0) # Flip sprite based on direction
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	move_and_slide()

func toggle_fullscreen() -> void:
	var current_mode = DisplayServer.window_get_mode()
	if current_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN or current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)


func trigger_flash() -> void:
	# Set color to bright flash, full alpha
	flash_rect.color = Color(0.2, 0.8, 1.0, 0.4) # Cyan flash (adjust as you like)

	# Use a tween to quickly fade the flash back to transparent
	var tween = create_tween()
	tween.tween_property(flash_rect, "color:a", 0.0, 0.2) # Fades out in 0.2 seconds
