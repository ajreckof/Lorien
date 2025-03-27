@tool
extends Sprite2D
class_name ImageElement


@export var base_handle: Panel


@export var image : Image : 
	set(value):
		image = value
		if image :
			texture = ImageTexture.create_from_image(image)
		else :
			texture = null
var selected : bool :
	set(value):
		selected = value
		base_handle.visible = selected

func _on_item_rect_changed():
	var image_transform := get_global_transform()
	var rect := get_rect()
	base_handle.rotation = 0
	base_handle.global_position = image_transform.get_origin()
	var transform_no_rotation = image_transform.rotated(- image_transform.get_rotation())
	print(image_transform, rect, transform_no_rotation, base_handle.global_position)
	base_handle.size = transform_no_rotation.basis_xform(rect.size)
	print(base_handle.size)
	base_handle.global_position -= base_handle.size/2
	print(base_handle.global_position)
	base_handle.pivot_offset = base_handle.size/2
	print(base_handle.global_position)
	base_handle.rotation = image_transform.get_rotation()
	print(base_handle.global_position)
	printt("item rect changed, ", base_handle.rotation, base_handle.global_position, image_transform ) 

func _ready() -> void:
	item_rect_changed.connect(_on_item_rect_changed)


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED :
		print("changed")
		_on_item_rect_changed()



func _validate_property(property: Dictionary) -> void:
	if property.name == "texture" :
		property.usage &= ~PROPERTY_USAGE_DEFAULT
