class_name CharacterVisual
extends Node3D
## Imported animation changes only the visual subtree, never the solid actor shape.
@export var presentation: Resource = preload("res://assets/characters/cow/presentation.tres")
@export var corpse_pose: bool = false
var _animation: AnimationPlayer
var _last_clip: String = ""
var _base_scale: float = 0.72

func _ready() -> void:
	_base_scale = float(presentation.get_meta("corpse_scale" if corpse_pose else "visual_scale", 0.72))
	scale = Vector3.ONE * _base_scale
	_animation = _find_animation(self)
	if corpse_pose:
		rotation_degrees.z = 90
		position.y = 0.05
		_play("KnockedOut")
		if _animation != null and not _last_clip.is_empty():
			_animation.advance(0)
			_animation.seek(minf(0.4, _animation.current_animation_length), true)
			_animation.pause()

func _process(_delta: float) -> void:
	if corpse_pose:
		return
	var actor := get_parent() as PlayerController
	if actor == null:
		return
	if not actor.alive:
		_play("Hurt")
	elif not actor.is_on_floor():
		_play("Idle")
		# Provisional jump presentation, subject to T024/T044 visual checks.
		scale = Vector3(0.944, 1.1, 0.944) * _base_scale
	else:
		scale = Vector3.ONE * _base_scale
		_play("Move" if Vector2(actor.velocity.x, actor.velocity.z).length() > 0.1 else "Idle")
		# Adapt the existing locomotion pose cosmetically while carrying.
		rotation.z = -0.12 if actor.is_carrying_visual else 0.0
	if actor.facing.length_squared() > 0:
		rotation.y = atan2(actor.facing.x, actor.facing.z)

func _play(clip: String) -> void:
	if _animation == null:
		return
	var key: String = {"Idle": "idle_clip", "Move": "move_clip", "Hurt": "death_clip", "KnockedOut": "corpse_clip"}.get(clip, "")
	var imported_name: String = presentation.get_meta(key, clip)
	for name in _animation.get_animation_list():
		if name == imported_name or name.ends_with("/" + imported_name):
			if _last_clip != name:
				if clip in ["Idle", "Move"]:
					_animation.get_animation(name).loop_mode = Animation.LOOP_LINEAR
				_animation.play(name)
				_last_clip = name
			return

func _find_animation(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var found := _find_animation(child)
		if found != null:
			return found
	return null
