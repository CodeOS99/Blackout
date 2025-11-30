extends Area3D

func _on_body_exited(body: Node3D) -> void:
	Globals.player.blizzard_shader_rect.visible = true
	$"../BlizzardBg".volume_db = -12

func _on_body_entered(body: Node3D) -> void:
	Globals.player.blizzard_shader_rect.visible = false
	$"../BlizzardBg".volume_db =  -20
