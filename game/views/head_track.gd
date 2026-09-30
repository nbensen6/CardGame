## Turns a rigged beast's neck and head about the world's up axis, AFTER its
## own animation has posed them, so the idle keeps playing underneath and the
## head still looks where the view points it. combat_3d owns the angle; this
## only applies it. Queue item "The jackal threatens between turns" (2026-09-30).
class_name HeadTrack
extends SkeletonModifier3D

## Radians about world up; + turns the model's +Z toward +X.
var yaw := 0.0
## How much of the turn the neck takes; the head takes the rest on top of it.
var neck_share := 0.4


func _process_modification_with_delta(_delta: float) -> void:
	var sk := get_skeleton()
	if sk == null or absf(yaw) < 0.0001:
		return
	var up := (sk.global_basis.inverse() * Vector3.UP).normalized()
	_turn(sk, "neck", yaw * neck_share, up)
	_turn(sk, "head", yaw * (1.0 - neck_share), up)


static func _turn(sk: Skeleton3D, bone: String, angle: float, up: Vector3) -> void:
	var b := sk.find_bone(bone)
	if b < 0:
		return
	var g := sk.get_bone_global_pose(b)
	g.basis = Basis(up, angle) * g.basis
	sk.set_bone_global_pose(b, g)
