@tool
extends BoneAttachment3D
class_name TwoBoneIKEditor3D

@export var target_node: Node3D :
	set(v):
		target_node = v
		if target_node: update()

@export var skeleton : Skeleton3D :
	set(v):
		skeleton = v
		if skeleton: update()

@export var mid_node: BoneAttachment3D :
	set(v):
		mid_node = v
		if mid_node and tip_node: 
			update()

@export var tip_node: BoneAttachment3D :
	set(v):
		tip_node = v
		if mid_node and tip_node: 
			update()

@export var active: bool = true :
	set(v):
		active = v
		update()

@export var override_skeleton: bool = false :
	set(v):
		if not mid_node or not tip_node:
			printerr("set mid_node and tip_node first")
			return
		override_skeleton = v
		update()

@export var auto_update: bool = true :
	set(v):
		auto_update = v
		update()

@export_range(0, 360) var elbow_swivel: float = 0.0 :
	set(v):
		elbow_swivel = v
		update()


func _ready():
	update()


func _chain_setup():
	if not mid_node:
		mid_node = BoneAttachment3D.new()
	if not tip_node:
		tip_node = BoneAttachment3D.new()
	
	var scene_root = get_tree().edited_scene_root
	
	if mid_node.get_parent():
		mid_node.reparent(self)
	else:
		self.add_child(mid_node)
	mid_node.set_owner(scene_root)
	mid_node.name = "Mid"
	
	if tip_node.get_parent():
		tip_node.reparent(mid_node)
	else:
		mid_node.add_child(tip_node)
	tip_node.set_owner(scene_root)
	tip_node.name = "Tip"
	
	self.use_external_skeleton = true
	mid_node.use_external_skeleton = true
	tip_node.use_external_skeleton = true
	
	self.external_skeleton = self.get_path_to(skeleton)
	mid_node.external_skeleton = mid_node.get_path_to(skeleton)
	tip_node.external_skeleton = tip_node.get_path_to(skeleton)
	
	self.override_pose = override_skeleton
	mid_node.override_pose = override_skeleton
	tip_node.override_pose = override_skeleton


func update():
	if not Engine.is_editor_hint(): return
	_chain_setup()
	set_notify_transform(auto_update)
	set_process(auto_update)
	solve_ik()


func _process(_delta):
	if not Engine.is_editor_hint(): return
	solve_ik()


func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		update()


func solve_ik():
	if not target_node or not mid_node or not tip_node:
		return
	
	# 1. Global position
	var p_root = global_position
	var p_mid_current = mid_node.global_position
	var p_tip_current = tip_node.global_position
	var p_target = target_node.global_position
	
	# 2. Length of bones
	var len_1 = p_root.distance_to(p_mid_current)
	var len_2 = p_mid_current.distance_to(p_tip_current)
	
	if len_1 < 0.001 or len_2 < 0.001: 
		return
	
	# 3. Triangle solve (Law of Cosines)
	# Hypotenuse
	var vec_to_target = p_target - p_root
	var dist_to_target = vec_to_target.length()
	var dist_clamped = clamp(dist_to_target, 0.001, len_1 + len_2 - 0.001)
	
	# shoulder angle (alpha)
	# a^2 = b^2 + c^2 - 2bc * cos(alpha) -> find cos(alpha)
	# a = len_2, b = len_1, c = dist_clamped
	var cos_alpha = (len_1**2 + dist_clamped**2 - len_2**2) / (2.0 * len_1 * dist_clamped)
	var alpha = acos(clamp(cos_alpha, -1.0, 1.0))
	
	# 4. the point where the elbow SHOULD be (P_elbow_goal)
	# basis of the plane of a triangle
	# the Z axis points towards the target.
	var axis_z = vec_to_target.normalized()
	
	# choose the Y (Up) axis arbitrarily, but stably, so you can rotate your elbow.
	# if your arm is vertical, choose Right; otherwise, choose Up.
	var up_temp = Vector3.RIGHT if abs(axis_z.dot(Vector3.UP)) > 0.99 else Vector3.UP
	
	# orthogonal basis
	var axis_x = axis_z.cross(up_temp).normalized()
	var axis_y = axis_x.cross(axis_z).normalized()
	
	# rotate this base around the Z axis by the elbow swivel angle (inspector)
	var swivel_rot = Basis(axis_z, deg_to_rad(elbow_swivel))
	var final_up = swivel_rot * axis_y # Повернутый вектор "вверх"
	
	# coordinate of the elbow in the plane
	var adjacent = len_1 * cos_alpha
	var opposite = len_1 * sin(alpha)
	
	var p_elbow_goal = p_root + (axis_z * adjacent) + (final_up * opposite)
	
	# 5. rotate
	_aim_at(self, mid_node, p_elbow_goal)
	_aim_at(mid_node, tip_node, p_target)
	tip_node.global_rotation = target_node.global_rotation


func _aim_at(parent: Node3D, child: Node3D, target_pos: Vector3):
	var target_dir = (target_pos - parent.global_position).normalized()
	var current_bone_axis = (child.global_position - parent.global_position).normalized()
	if current_bone_axis.distance_squared_to(target_dir) < 0.00001:
		return
		
	var rotation_quat = Quaternion(current_bone_axis, target_dir)
	parent.global_basis = Basis(rotation_quat) * parent.global_basis

