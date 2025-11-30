extends Node3D

var player_in := false

func _process(delta: float) -> void:
	if player_in and Input.is_action_pressed("interact"):
		Globals.player.get_shovel()
		self.queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		Globals.player.is_shovel_in_range(true)
		player_in = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		Globals.player.is_shovel_in_range(false)
		player_in = false
