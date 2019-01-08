extends RigidBody2D

var screensize = Vector2()


enum States {INIT, ALIVE, INVULNERABLE, DEAD}
var state = null

export (int) var engine_power
export (int) var spin_power

var thrust = Vector2()
var rotation_dir = 0



func _ready():
	change_state(States.ALIVE)
	screensize = get_viewport().get_visible_rect().size

func _process(delta):
	get_input()


func _physics_process(delta):
	set_applied_force(thrust.rotated(rotation))
	set_applied_torque(spin_power * rotation_dir)

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



func change_state(new_state):
	match new_state:
		States.INIT:
			$CollisionShape2D.disabled = true
		States.ALIVE:
			$CollisionShape2D.disabled = false
		States.DEAD:
			$CollisionShape2D.disabled = true
			
	state = new_state