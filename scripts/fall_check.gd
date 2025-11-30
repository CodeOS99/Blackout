extends Area3D

@onready var player_reset_pos = $PlayerResetPos

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.global_position = player_reset_pos.global_position
		body.add_dialogue("That would be terrible.\nGood thing I won't ever fall off.", 3.0)
