class_name Serializer

# TODO: !IMPORTANT! all of this needs validation
# TODO: !IMPORTANT! all of this needs validation
# TODO: !IMPORTANT! all of this needs validation

# -------------------------------------------------------------------------------------------------
const BRUSH_STROKE = preload("res://BrushStroke/BrushStroke.tscn")
const COMPRESSION_METHOD = FileAccess.COMPRESSION_DEFLATE
const POINT_ELEM_SIZE := 3

const VERSION_NUMBER := 1
const TYPE_BRUSH_STROKE := 0
const TYPE_ERASER_STROKE_DEPRECATED := 1 # Deprecated since v0; will be ignored when read; structually the same as normal brush stroke
const TYPE_IMAGE := 2

# -------------------------------------------------------------------------------------------------
static func save_project(project: Project) -> void:
	
	var start_time := Time.get_ticks_msec()
	
	# Open file
	var file := FileAccess.open_compressed(project.filepath, FileAccess.WRITE, COMPRESSION_METHOD)
	if file == null:
		print_debug("Failed to open file for writing: %s" % project.filepath)
		return
	
	# Meta data
	file.store_32(VERSION_NUMBER)
	file.store_pascal_string(_dict_to_metadata_str(project.meta_data))
	
	# Stroke data
	for element: Node2D in project.strokes:
		if element is BrushStroke :
			# Type
			file.store_8(TYPE_BRUSH_STROKE)
			
			# Color
			file.store_8(element.color.r8)
			file.store_8(element.color.g8)
			file.store_8(element.color.b8)
			
			# Brush size
			file.store_16(int(element.size))
			
			# Number of points
			file.store_16(element.points.size())
			
			# Points
			var p_idx := 0
			for p in element.points:
				# Add global_position offset which is != 0 when moved by move tool; but mostly it should just add 0
				file.store_float(p.x + element.global_position.x)
				file.store_float(p.y + element.global_position.y)
				var pressure: int = clamp(int(element.pressures[p_idx] * 255), 0, 255)
				file.store_8(pressure)
				p_idx += 1
		if element is ImageElement :
			# Type
			file.store_8(TYPE_IMAGE)
			
			var image = element.image
			#Image width and height
			file.store_32(image.get_width())
			file.store_32(image.get_height())
			
			#Image Format
			file.store_8(image.get_format())
			
			#Image data size then value
			var raw_data = image.get_data()
			file.store_64(len(raw_data))
			for byte in raw_data :
				file.store_8(byte)
			
			#Image element size global_position and rotation
			file.store_var(element.transform)
	# Done
	file.close()
	print("Saved %s in %d ms" % [project.filepath, (Time.get_ticks_msec() - start_time)])




# -------------------------------------------------------------------------------------------------
static func load_project(project: Project) -> void:
	var start_time := Time.get_ticks_msec()




	# Open file
	var file := FileAccess.open_compressed(project.filepath, FileAccess.READ, COMPRESSION_METHOD)
	if file == null:
		print_debug("Failed to load file: %s" % project.filepath)
		return
	
	# Clear potential previous data
	project.strokes.clear()
	project.meta_data.clear()
	
	# Meta data
	var _version_number := file.get_32()
	var meta_data_str := file.get_pascal_string()
	project.meta_data = _metadata_str_to_dict(meta_data_str)
	
	# Brush strokes
	while true:
		# Type
		var type := file.get_8()
		
		match type:
			TYPE_BRUSH_STROKE, TYPE_ERASER_STROKE_DEPRECATED:
				var brush_stroke: BrushStroke = BRUSH_STROKE.instantiate()
				
				# Color
				var r := file.get_8()
				var g := file.get_8()
				var b := file.get_8()
				brush_stroke.color = Color(r/255.0, g/255.0, b/255.0, 1.0)
				
				# Brush size
				brush_stroke.size = file.get_16()
					
				# Number of points
				var point_count := file.get_16()

				# Points
				for i: int in point_count:
					var x := file.get_float()
					var y := file.get_float()
					var pressure := float(file.get_8()) / 255.0
					brush_stroke.points.append(Vector2(x, y))
					brush_stroke.pressures.append(pressure)
				
				if type == TYPE_ERASER_STROKE_DEPRECATED:
					print("Skipped deprecated eraser stroke: %d points" % point_count)
				else:
					project.strokes.append(brush_stroke)
			TYPE_IMAGE :
				
				#Image width and height
				var width = file.get_32()
				var height = file.get_32()
				
				#Image Format
				var format = file.get_8()
				
				#Image data size then value ,
						 
				var data_size = file.get_64()
				var raw_data : PackedByteArray

				for i in data_size:
					raw_data.append(file.get_8())
				
				#Image element size global_position and rotation
				var element_transform : Transform2D = file.get_var()
				
				var image_element := ImageElement.new()
				image_element.image = Image.create_from_data(width, height, true, format, raw_data)
				image_element.transform = element_transform
				project.strokes.append(image_element)
			_:
				printerr("Invalid type")
		
		# are we done yet?
		if file.get_position() >= file.get_length()-1 || file.eof_reached():
			break
	
	# Done
	file.close()
	print("Loaded %s in %d ms" % [project.filepath, (Time.get_ticks_msec() - start_time)])

# -------------------------------------------------------------------------------------------------
static func _dict_to_metadata_str(d: Dictionary) -> String:
	var meta_str := ""
	for k: Variant in d.keys():
		var v: Variant = d[k]
		if k is String && v is String:
			meta_str += "%s=%s," % [k, v]
		else:
			print_debug("Metadata should be String key-value pairs only!")
	return meta_str

# -------------------------------------------------------------------------------------------------
static func _metadata_str_to_dict(s: String) -> Dictionary:
	var meta_dict := {}
	for kv: String in s.split(",", false):
		var kv_split: PackedStringArray = kv.split("=", false)
		if kv_split.size() != 2:
			print_debug("Invalid metadata key-value pair: %s" % kv)
		else:
			meta_dict[kv_split[0]] = kv_split[1]
	return meta_dict
