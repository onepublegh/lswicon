extends Control

var mask_1 = preload("res://Assets/mask_1.png")
var mask_2 = preload("res://Assets/mask_2.png")
var mask_3 = preload("res://Assets/mask_3.png")
var mask_4 = preload("res://Assets/mask_4.png")
var icon_white = preload("res://Assets/icon_white.png")
var icon_white_512 = preload("res://Assets/icon_white_512.png")
var original = false
var image_type = 0

onready var line_edit = $Settings/Icon/MarginContainer/GridContainer/IconColour/LineEdit
onready var icon = $Control/Icon
onready var icon_sprite = $Control/IconSprite
onready var icon_mask = $Control/IconMask
onready var mask = $Control/Mask
onready var icon_mask_light = $Control/IconMaskLight
onready var pos_x = $Settings/Icon/MarginContainer/GridContainer/XPos/HSlider
onready var pos_y = $Settings/Icon/MarginContainer/GridContainer/YPos/HSlider
onready var pos_xl = $Settings/Icon/MarginContainer/GridContainer/XPos/Label
onready var pos_yl = $Settings/Icon/MarginContainer/GridContainer/YPos/Label
onready var icon_scale_input = $Settings/Icon/MarginContainer/GridContainer/Scale/LineEdit
onready var mask_scale_input = $Settings/Mask/MarginContainer/GridContainer/Scale/LineEdit
onready var rot = $Settings/Mask/MarginContainer/GridContainer/Angle/HSlider
onready var type = $Settings/Mask/MarginContainer/GridContainer/Type/HSlider

func _ready():
	get_tree().get_root().set_transparent_background(true)

func _process(_delta):
	if Input.is_action_just_pressed("close"):
		get_tree().quit()
	if line_edit.text.length() > 5:
		icon.modulate = Color(line_edit.text)
	else:
		icon.modulate = Color(1,1,1)
	
	if type.value == 1:
		mask.texture = mask_1
	elif type.value == 2:
		mask.texture = mask_2
	elif type.value == 3:
		mask.texture = mask_3
	else:
		mask.texture = mask_4
	
	pos_xl.text = "X Position: "+str(pos_x.value)
	pos_yl.text = "Y Position: "+str(pos_y.value)
	if original:
		icon_sprite.scale = Vector2(float(icon_scale_input.text)*.25, float(icon_scale_input.text)*.25)
		icon_sprite.position = Vector2(pos_x.value*.25, pos_y.value*.25)
		icon_mask.scale = Vector2(float(mask_scale_input.text)*.25, float(mask_scale_input.text)*.25)
	else:
		icon_sprite.scale = Vector2(float(icon_scale_input.text), float(icon_scale_input.text))
		icon_sprite.position = Vector2(pos_x.value, pos_y.value)
		icon_mask.scale = Vector2(float(mask_scale_input.text), float(mask_scale_input.text))
	$Settings/Mask/MarginContainer/GridContainer/Type/Label.text = "Type: "+str(type.value)
	$Settings/Mask/MarginContainer/GridContainer/Angle/Label.text = "Angle: "+str(rot.value)+"°"
	mask.rotation_degrees = rot.value

func _on_Blue_pressed():
	line_edit.text = "0370FF"

func _on_Green_pressed():
	line_edit.text = "21C600"

func _on_Import_pressed():
	image_type = 0
	$FileDialog.popup()

func _on_Icon_Mask_Import_pressed():
	image_type = 1
	$FileDialog.popup()

func _on_CheckButton_toggled(button_pressed):
	mask.enabled = button_pressed

func _on_Icon_Mask_CheckButton_toggled(button_pressed):
	icon_mask_light.enabled = button_pressed
	icon_mask.visible = button_pressed

func _on_Original_CheckButton_toggled(button_pressed):
	if button_pressed:
		original = true
		icon.texture = icon_white
		
		icon.position = Vector2(64,64)
		icon_mask_light.texture = icon_white
		icon_mask_light.position = Vector2(64,64)
		icon_sprite.position = Vector2(64,64)
		icon_mask.position = Vector2(64,64)
		mask.position = Vector2(64,64)
		mask.scale = Vector2(0.25,0.25)
		$Control.rect_size = Vector2(128,128)
		$Control.rect_scale = Vector2(3,3)
	else:
		original = false
		icon.texture = icon_white_512
		icon.position = Vector2(256,256)
		icon_mask_light.texture = icon_white_512
		icon_mask_light.position = Vector2(256,256)
		icon_sprite.position = Vector2(256,256)
		icon_mask.position = Vector2(256,256)
		mask.position = Vector2(256,256)
		mask.scale = Vector2(1,1)
		$Control.rect_size = Vector2(512,512)
		$Control.rect_scale = Vector2(0.75,0.75)

func _on_FileDialog_file_selected(path):
	var image = Image.new()
	image.load(path)
	var texture = ImageTexture.new()
	texture.create_from_image(image, 7)
	if image_type == 0:
		icon_sprite.texture = texture
	elif image_type == 1:
		icon_mask.texture = texture

func _on_Render_pressed():
	$Control.rect_scale = Vector2(1,1)
	$Settings.visible = false
	$Label.visible = false
	$FileDialog2.popup()

func _on_FileDialog2_file_selected(path):
	yield(get_tree().create_timer(0.5), "timeout")
	save_to(path)
	if original:
		$Control.rect_scale = Vector2(3,3)
	else:
		$Control.rect_scale = Vector2(0.75,0.75)
	$Settings.visible = true
	$Label.visible = true

func _on_FileDialog2_popup_hide():
	yield(get_tree().create_timer(0.5), "timeout")
	if original:
		$Control.rect_scale = Vector2(3,3)
	else:
		$Control.rect_scale = Vector2(0.75,0.75)
	$Settings.visible = true
	$Label.visible = true

export(NodePath) var viewport_path = null

onready var target_viewport = get_node(viewport_path) if viewport_path else get_tree().root.get_viewport()

func save_to(path):
	var img = target_viewport.get_texture().get_data()
	img.flip_y()
	if original:
		img.crop(128,128)
	else:
		img.crop(512,512)
	img.convert(Image.FORMAT_RGBA8)
	return img.save_png(path)
