extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Ignore collision if World 1 is hidden
	if get_parent() and not get_parent().visible:
		return

	# Check if the colliding object belongs to the 'player' group
	if body.is_in_group("player"):
		print("Player hit spikes in World 1!")
		call_deferred("_reload_scene")

func _reload_scene() -> void:
	get_tree().reload_current_scene()
