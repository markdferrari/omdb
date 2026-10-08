class_name SpikeBed
extends Node3D
@export var hazard_id: String = "spikes"

func _ready() -> void:
	$Lethal.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerController:
		body.report_lethal(hazard_id)
