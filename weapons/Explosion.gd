extends Area

export var damage = 40


func Explode():
	$OuterParticles.emitting = true
	$InnerParticles.emitting = true
	var query = PhysicsShapeQueryParameters.new()
	query.set_transform(global_transform)
	query.set_shape($CollisionShape.shape)
	query.collision_mask = collision_mask
	var spaceState = get_world().get_direct_space_state()
	var resultState = spaceState.intersect_shape(query)
	for data in resultState:
		if data.collider.has_method("TakeDamage"):
			data.collider.TakeDamage(
				damage, global_transform.origin.direction_to(data.collider.global_transform.origin)
			)


func _on_DeathTimer_timeout():
	pass  # Replace with function body.
