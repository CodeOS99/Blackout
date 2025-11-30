extends Area3D

@export var add_text := false
var first := true

func _on_body_exited(body: Node3D) -> void:
	Globals.player.blizzard_shader_rect.visible = true
	$"../BlizzardBg".volume_db = -12
	Globals.snow_steps = true
	if first and add_text:
		first = false
		Globals.player.add_dialogue("...\nWhere is... everything?", 3)
func _on_body_entered(body: Node3D) -> void:
	Globals.player.blizzard_shader_rect.visible = false
	$"../BlizzardBg".volume_db =  -20
	Globals.snow_steps = false
