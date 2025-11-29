extends MeshInstance3D

func change_x_size(amount: float):
	var curr_size = get_aabb().size
	get_aabb().size.x += amount
	translate_object_local(Vector3(amount/2.0, 0, 0))
