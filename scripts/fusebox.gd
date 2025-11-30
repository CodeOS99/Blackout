extends Node3D

var player_in := false

var max_prog: float = 1.5
var curr_prog: float = 0

func _process(delta: float) -> void:
	if player_in and Input.is_action_pressed("interact"):
		if curr_prog < max_prog:
			curr_prog += delta
			if curr_prog >= max_prog:
				Globals.player.get_generator()
	
	if curr_prog < max_prog:
		$Label3D.text = "Progress: [" + str(floor(curr_prog/max_prog * 100) if curr_prog > 0 else 0) + "%]"
	else:
		$Label3D.text = "Fixed"

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		Globals.player.is_fusebox_in_range(true)
		player_in = true
		Globals.player.can_shovel = false

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		Globals.player.is_fusebox_in_range(false)
		player_in = false
		Globals.player.can_shovel = true
