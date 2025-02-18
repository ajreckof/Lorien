extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var button = CustomButton.new()
	add_child(button)
