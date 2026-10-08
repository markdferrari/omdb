extends Node3D
## Cosmetic fragments only. No physics nodes or registry identity.
var remaining: float = 0.6
func _ready() -> void:
	for index in range(12):
		var fragment := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.07, 0.07, 0.07)
		fragment.mesh = mesh
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = Color(0.1, 1, 0.7) if index % 2 == 0 else Color(1, 0.1, 0.4)
		fragment.material_override = material
		fragment.set_meta("velocity", Vector3(cos(index * TAU / 12), 1.5, sin(index * TAU / 12)) * 2)
		add_child(fragment)
func _process(delta: float) -> void:
	remaining -= delta
	for fragment in get_children():
		var velocity: Vector3 = fragment.get_meta("velocity")
		fragment.position += velocity * delta
		velocity.y -= 6 * delta
		fragment.set_meta("velocity", velocity)
		fragment.scale = Vector3.ONE * maxf(0.05, remaining / 0.6)
	if remaining <= 0:
		queue_free()
