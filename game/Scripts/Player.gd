extends RigidBody2D

var screensize = Vector2()


enum States {INIT, ALIVE, INVULNERABLE, DEAD}
var state = null

export (int) var engine_power
export (int) var spin_power

var thrust = Vector2()
var rotation_dir = 0

signal shoot
signal dead

export (PackedScene) var Bullet
export (float) var fire_rate

var can_shoot = true 

signal lives_changed
				#okreslenie funkcji ktora ma sie wywolywac gdy zmienna zmienia wartosc
var lives = 0 setget set_lives


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
	change_state(States.INIT)
	screensize = get_viewport().get_visible_rect().size
	$GunTimer.wait_time = fire_rate

func _process(delta):
	get_input()

func set_lives(value):
	lives = value
	emit_signal("lives_changed", lives)

func start():
	$Sprite.show()
	self.lives = 3
	change_state(States.ALIVE)

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
			$Sprite.modulate.a = 0.5
		States.ALIVE:
			$CollisionShape2D.disabled = false
			$Sprite.modulate.a = 1.0
		States.DEAD:
			$CollisionShape2D.disabled = true
			$Sprite.hide()
			linear_velocity = Vector2()
			emit_signal("dead")
		States.INVULNERABLE:
			$CollisionShape2D.disabled = true
			$Sprite.modulate.a = 0.5
			$InvulnerabilityTimer.start()

	state = new_state
	
func _on_GunTimer_timeout():
	can_shoot = true


func _on_InvulnerabilityTimer_timeout():
	change_state(States.ALIVE)


func _on_AnimationPlayer_animation_finished(anim_name):
	$Explosion.hide()


func _on_Player_body_entered(body):
	if body.is_in_group('rocks'):
		body.explode()
		$Explosion.show()
		$Explosion/AnimationPlayer.play("explosion")
		self.lives -= 1
		if lives <= 0:
			change_state(DEAD)
		else:
			change_state(INVULNERABLE)
