extends StaticBody3D

func _ready() -> void:
	change_x_size(-10)

func change_x_size(amount: float):
	var curr_size = $SnowMesh.get_aabb().size
	$SnowMesh.get_aabb().size.x += amount
	$SnowMesh.translate_object_local(Vector3(amount/2.0, 0, 0))
	$"SnowCollisionShape".shape = $SnowMesh.mesh.create_convex_shape()
	$"SnowCollisionShape".translate_object_local(Vector3(amount/2.0, 0, 0))
