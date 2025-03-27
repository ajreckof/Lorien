@tool
extends Control

signal button_pressed(button_name : String)
@export var button_list : Array[ButtonDef] :
	set(value):
		print(value)
		for i in len(value):
			if value[i] == null :
				value[i] = ButtonDef.new()
		button_list = value
		mark_dirty()
		
@export_range(-360, 360, 10, "radians_as_degrees") var start_angle := -PI/2 :
	set(value):
		start_angle = value
		mark_dirty()
@export_range(-360, 360, 10, "radians_as_degrees") var finish_angle := PI/2 :
	set(value):
		finish_angle = value
		mark_dirty()
@export_range(0,1,0.01) var start_distance := 1/3. :
	set(value):
		start_distance = clampf(value, 0, 1)
		mark_dirty()
@export_range(0,1,0.01) var end_distance := 2/3. :
	set(value):
		end_distance = clampf(value, 0, 1)
		mark_dirty()
@export_range(1, 10, 0.1, "radians_as_degrees") var angle_resolution := PI/36 :
	set(value):
		angle_resolution = value
		mark_dirty()
@export_range(0,0.1,0.001) var radial_separation := 0.05 :
	set(value):
		radial_separation = value
		mark_dirty()
@export_range(0, 10, 0.1, "radians_as_degrees") var angle_separation := PI/36 :
	set(value):
		angle_separation = value
		mark_dirty()

func _ready() -> void:
	resized.connect(_generate_buttons)
	_generate_buttons()

func _generate_buttons():
	for child in get_children():
		child.queue_free()
		remove_child(child)
	
	var arrengement : Array[Array] = find_best_arrengement(button_list)
	var row_size := (end_distance - start_distance) / len(arrengement)
	var row_start := start_distance
	printt("important :", row_start, row_size, end_distance, start_distance, len(arrengement))
	for row : Array[ButtonDef] in arrengement :
		var angle_size := (finish_angle - start_angle) / row.size()
		var angle_button_start := start_angle
		printt("one :", finish_angle, start_angle, angle_size, angle_button_start)
		for button_def in row:
			var button := _create_wheel_button(row_start, row_start + row_size, angle_button_start, angle_button_start + angle_size)
			button.icon = button_def.icon
			button.pressed.connect(_on_button_pressed.bind(button_def.name))
			angle_button_start += angle_size
		row_start += row_size

func _create_wheel_button(start_distance : float, finish_distance :float, start_angle : float, finish_angle : float) -> PolygonButton:
	printt("reached here :", start_distance, finish_distance)

	finish_distance -= radial_separation / 2
	start_distance += radial_separation / 2
	start_angle += angle_separation / 2
	finish_angle -= angle_separation / 2
	printt("test :",start_distance, finish_distance,  radial_separation)
	var button = PolygonButton.new()
	var polygon = generate_polyline_arc(finish_distance , start_angle, finish_angle, true) + generate_polyline_arc(start_distance, finish_angle, start_angle, false)
	button.polygon = polygon
	add_child(button)
	button.owner = owner
	button.position = size/2
	return button


func generate_polyline_arc(distance : float, start_angle : float, finish_angle : float, is_clockwise := true) -> PackedVector2Array:
	if not is_clockwise :
		var ret := generate_polyline_arc(distance, finish_angle, start_angle)
		ret.reverse()
		return ret
	
	while finish_angle < start_angle :
		finish_angle += 2 * PI
	
	var ret := PackedVector2Array()
	while start_angle < finish_angle :
		ret.append(Vector2.ONE/2 + distance * Vector2.from_angle(start_angle)/2)
		start_angle += angle_resolution
	ret.append(Vector2.ONE/2 + distance * Vector2.from_angle(finish_angle)/2)
	return ret


func find_best_arrengement(button_list : Array[ButtonDef])-> Array[Array]:
	return [button_list]

func _on_button_pressed(button_name: String):
	print(button_name)
	button_pressed.emit(name)

func mark_dirty():
	_generate_buttons()
