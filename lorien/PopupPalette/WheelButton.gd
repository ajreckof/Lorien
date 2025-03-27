@tool
extends Button
class_name PolygonButton


var resized_polygon : PackedVector2Array
@export var polygon : PackedVector2Array :
	set(value):
		for i in len(value) :
			value[i] = value[i].clamp(Vector2.ZERO, Vector2.ONE)
		polygon = value
		old_size = Vector2.ZERO
		check_resize()
		queue_redraw()
		update_minimum_size()

func _init() -> void:
	flat = true

func _has_point(point: Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(point, polygon)

func multiply_components(a: Vector2, b: Vector2) -> Vector2:
	return Vector2(a.x * b.x, a.y * b.y)

func _draw() -> void:
	if len(polygon) < 3 :
		return
	check_resize()
	var style_box : StyleBox
	match get_draw_mode() :
		DRAW_NORMAL :
			style_box = get_theme_stylebox("normal")
		DRAW_DISABLED :
			style_box = get_theme_stylebox("disabled")
		DRAW_HOVER :
			style_box = get_theme_stylebox("hover")
		DRAW_HOVER_PRESSED :
			style_box = get_theme_stylebox("hover_pressed")
		DRAW_PRESSED :
			style_box = get_theme_stylebox("pressed")
	
	match style_box :
		var style_box_flat when style_box_flat is StyleBoxFlat :
			if style_box_flat is StyleBoxFlat :
				draw_colored_polygon(resized_polygon, style_box_flat.bg_color)
				if style_box_flat.border_width_left :
					var border_polygon = generate_border_polygon(
						resized_polygon, 
						style_box_flat.border_width_left
					)
					if style_box_flat.border_blend :
						var inner_border_color = PackedColorArray()
						inner_border_color.resize(polygon.size()+ 1)
						inner_border_color.fill(style_box_flat.bg_color)
						var outer_border_color = PackedColorArray()
						outer_border_color.resize(polygon.size()+ 1)
						outer_border_color.fill(style_box_flat.border_color)
						draw_polygon(
							border_polygon,
							outer_border_color + inner_border_color,
						)
					else :
						draw_colored_polygon(
							border_polygon, 
							style_box_flat.border_color,
						)
		var style_box_texture when style_box_texture is StyleBoxTexture :
			pass
		var style_box_line when style_box_line is StyleBoxLine :
			pass

func generate_border_polygon(polygon : PackedVector2Array, border_size : float):
	var shifted_polygon : PackedVector2Array
	var previous_direction := (polygon[len(polygon)-2] - polygon[len(polygon)-1]).normalized()
	var next_direction := (polygon[0] - polygon[len(polygon)-1]).normalized()
	var angle := next_direction.angle_to(previous_direction)
	if angle <0 : 
		angle += 2* PI 
	var distance := border_size / absf(sin(angle/2))
	shifted_polygon.append(polygon[-1] + distance * next_direction.rotated(angle/2))
	
	for i in len(polygon)-1 :
		previous_direction = -next_direction
		next_direction = (polygon[i+1] - polygon[i]).normalized()
		angle = next_direction.angle_to(previous_direction)
		if angle <0 : 
			angle += 2* PI 
		distance = border_size / sin(angle/2)
		shifted_polygon.append(polygon[i] + distance * next_direction.rotated(angle/2))
	shifted_polygon.append(shifted_polygon[0])
	polygon.append(polygon[0])
	shifted_polygon.reverse()
	return polygon + shifted_polygon
	



# Example usage
func _ready():
	print(Vector2.DOWN.angle_to(Vector2.RIGHT))


func _validate_property(property: Dictionary) -> void:
	if property.name == "flat" :
		property.usage &= ~PROPERTY_USAGE_EDITOR

var old_size : Vector2
func check_resize():
	if old_size == size :
		return
	old_size = size
	resized_polygon = []
	for x in polygon :
		resized_polygon.append(multiply_components(x,size))
