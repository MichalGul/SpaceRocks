extends Node2D

export (PackedScene) var Rock

var screensize

var level = 0
var score = 0
var playing = false

func new_game():
	for rock in $Rocks.get_children():
		rock.queue_free()
	level = 0
	score = 0
	$HUD.update_score(score)
	$Player.start()
	$HUD.show_message("Get Ready!")
	yield($HUD/MessageTimer, "timeout")
	playing = true
	new_level()

func new_level():
	level += 1
	$HUD.show_message("Wave %s" % level)
	for i in range(level):
		spawn_rock(3)


func _ready():
	randomize()
	screensize = get_viewport().get_visible_rect().size
	$Player.screensize = screensize
	for i in range(3):
		spawn_rock(3)

func _process(delta):
	if playing and $Rocks.get_child_count() == 0:
		new_level()

#UZYC DO GRY
func _input(event):
	if event.is_action_pressed('pause'):
		if not playing:
			return
		get_tree().paused = not get_tree().paused
		if get_tree().paused:
			$HUD/MessageLabel.text = "Paused"
			$HUD/MessageLabel.show()
		else:
			$HUD/MessageLabel.text = ""
			$HUD/MessageLabel.hide()





func spawn_rock(size, pos = null, vel = null):
	if !pos:
		$RockPath/RockSpawn.set_offset(randi()) #get random pos on PathFollow2D
		pos = $RockPath/RockSpawn.position
	if !vel:
		vel = Vector2(1,0).rotated(rand_range(0, 2*PI)) * rand_range(100,150)
		
	var r = Rock.instance()
	r.screensize = screensize
	r.start(pos, vel, size)
	$Rocks.add_child(r)
	
	# manually connect the signal from Rock to Main
	r.connect('exploded', self, '_on_Rock_exploded')
	
	
func _on_Player_shoot(bullet, pos, dir):
	var bull = bullet.instance()
	bull.start(pos, dir)
	add_child(bull)

func _on_Rock_exploded(size, radius, pos, vel):
	#create 2 new smaller rocks tangent to previous rock in two directions 
	if size <=1:
		return
	for offset in [-1, 1]:								#znajdz wektor prostopadly
		var dir = (pos - $Player.position).normalized().tangent() * offset
		var newpos = pos + dir * radius
		var newvel = dir * vel.length() * 1.1
		spawn_rock(size - 1, newpos, newvel) 

func game_over():
	playing = false
	$HUD.game_over()
