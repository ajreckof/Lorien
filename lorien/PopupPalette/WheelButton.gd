@tool
extends BaseButton
class_name PolygonButton

@export var polygon : PackedVector2Array :
	set(value):
		polygon = value
		convex_envelop.set_point_cloud(polygon)
		queue_redraw()
		update_minimum_size()

var convex_envelop := ConvexPolygonShape2D.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(func(): print(name))


func _has_point(point: Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(point, convex_envelop.points)


func _draw() -> void:
	draw_colored_polygon(polygon, Color.BLACK)

func _get_minimum_size() -> Vector2:
	print("test")
	return convex_envelop.get_rect().size
