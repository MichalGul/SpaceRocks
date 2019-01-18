extends RigidBody2D

var screensize = Vector2()


enum States {INIT, ALIVE, INVULNERABLE, DEAD}
var state = null

export (int) var engine_power
export (int) var spin_power

var thrust = Vector2()
var rotation_dir = 0

signal shoot

export (PackedScene) var Bullet
export (float) var fire_rate

var can_shoot = true 

#export (int) var speed = 100
#var target = Vector2()
#var velocity = Vector2()

#func _input(event):
#    if event.is_action_pressed('click'):	
#        target = get_global_mouse_position()
#
#func _physics_process(delta):
#	look_at(target)
#	velocity = (target - position).normalized() * speed
#    # rotation = velocity.angle()
#	if (target - position).length() > 5:
#		move_and_slide(velocity)


#RIGIDBODY

func _ready():
	change_state(States.ALIVE)
	screensize = get_viewport().get_visible_rect().size
	$GunTimer.wait_time = fire_rate

func _process(delta):
	get_input()


func _integrate_forces(physics_state):
	set_applied_force(thrust.rotated(rotation))
	set_applied_torque(spin_power * rotation_dir)
	#SCREEN WRAPPING
	var xform = physics_state.get_transform()
	if xform.origin.x > screensize.x:
		xform.origin.x = 0
	if xform.origin.x < 0:
		xform.origin.x = screensize.x
	if xform.origin.y > screensize.y:
		xform.origin.y = 0
	if xform.origin.y < 0:
		xform.origin.y = screensize.y
	physics_state.set_transform(xform)
	
	

func get_input():
	thrust = Vector2()
	if state in [States.DEAD, States.INIT]:
		return
	if Input.is_action_pressed("thrust"):
		thrust = Vector2(engine_power,0)
	rotation_dir = 0
	if Input.is_action_pressed("rotate_right"):
		rotation_dir += 1
	if Input.is_action_pressed("rotate_left"):
		rotation_dir -= 1
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()


func shoot():
	if state == INVULNERABLE or state == DEAD:
		return
	emit_signal("shoot", Bullet, $Muzzle.global_position, rotation)
	can_shoot = false
	$GunTimer.start()


func change_state(new_state):
	match new_state:
		States.INIT:
			$CollisionShape2D.disabled = true
		States.ALIVE:
			$CollisionShape2D.disabled = false
		States.DEAD:
			$CollisionShape2D.disabled = true

	state = new_state

func _on_GunTimer_timeout():
	can_shoot = true
