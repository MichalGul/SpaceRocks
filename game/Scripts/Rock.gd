extends RigidBody2D

var screensize = Vector2()
var size
var radius
var scale_factor = 0.2 

signal exploded

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func start (pos, vel , _size):
	position = pos
	size = _size
	mass = 1.5 * size
	
	$Sprite.scale = Vector2(1,1) * scale_factor * size
	radius = int($Sprite.texture.get_size().x / 2 * scale_factor * size)
	var shape = CircleShape2D.new()
	shape.radius = radius
	
	$CollisionShape2D.shape = shape
	linear_velocity = vel
	angular_velocity = rand_range(-1.5, 1.5)
	
	$Explosion.scale = Vector2(0.75, 0.75) * size
	
	
func _integrate_forces(physics_state):
	var xform = physics_state.get_transform()
	if xform.origin.x > screensize.x + radius:
		xform.origin.x = 0 - radius
	if xform.origin.x < 0 - radius:
		xform.origin.x = screensize.x + radius
	if xform.origin.y > screensize.y + radius:
		xform.origin.y = 0 - radius
	if xform.origin.y < 0 - radius:
		xform.origin.y = screensize.y + radius
	physics_state.set_transform(xform)
	
		
func explode():
	layers = 0
	$Sprite.hide()
	$Explosion/AnimationPlayer.play("explosion")
	#Let  know Main scene to spawn smaller rocks
	emit_signal("exploded", size, radius, position, linear_velocity)
	linear_velocity = Vector2()
	angular_velocity = 0
	
		

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
