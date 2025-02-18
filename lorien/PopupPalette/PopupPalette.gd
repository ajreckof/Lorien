extends AspectRatioContainer

@export var button_list : Array
@export var start_angle :float
@export var finish_angle :float
@export var start_distance :float
@export var end_distance :float


func _generate_buttons():
	var arrengement = find_best_arrengement()


func _create_wheel_button(start_angle : float, finish_angle : float, start_distance : float, finish_distance :float):
	var button = PolygonButton.new()
	button.polygon = generate_polyline_circle(finish_distance, start_angle, finish_angle, true) + generate_polyline_circle(start_distance, start_angle, finish_angle, false)



func generate_polyline_circle(distance, start_angle, finish_angle, is_clockwise):
	pass

func find_best_arrengement():
	pass
