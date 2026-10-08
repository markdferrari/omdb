extends Node3D
## Cosmetic fragments: no colliders, registry identity, or gameplay timers.
@export var kind: String = "death"
@export var fragment_count: int = 8
var remaining: float = 0.6

func _ready() -> void:
	add_to_group("cosmetic_feedback")
	for index in range(fragment_count):
		var fragment := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.06, 0.06, 0.06)
		fragment.mesh = mesh
		fragment.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = Color(1, 0.1, 0.4) if kind == "death" else Color(0.1, 1, 0.7)
		fragment.material_override = material
		var angle := index * TAU / fragment_count
		fragment.set_meta("velocity", Vector3(cos(angle), 1.3, sin(angle)) * 1.4)
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
