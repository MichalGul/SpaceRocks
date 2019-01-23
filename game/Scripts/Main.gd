extends Node2D

export (PackedScene) var Rock

var screensize



func _ready():
	randomize()
	screensize = get_viewport().get_visible_rect().size
	$Player.screensize = screensize
	for i in range(3):
		spawn_rock(3)

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

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

func _on_Player_shoot(bullet, pos, dir):
	var bull = bullet.instance()
	bull.start(pos, dir)
	add_child(bull)
