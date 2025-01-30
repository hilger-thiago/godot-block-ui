@tool
class_name BlockUI extends TextureButton

@export var id:String = "1"
@export var label:Label
@export var size_in_blocks:Vector2i = Vector2i(1,1)
@export var position_in_grid:Vector2i = Vector2i(0,0):
	set(new_position):
		position_in_grid = new_position
		emit_signal("new_block_position_in_grid", self, position_in_grid)

signal new_block_position_in_grid(BlockUI, Vector2i)

@export var text_align = HORIZONTAL_ALIGNMENT_CENTER:
	set(new_align):
		text_align = new_align
		if label == null: return
		label.horizontal_alignment = new_align
@export var text_valign = VERTICAL_ALIGNMENT_CENTER:
	set(new_align):
		if label == null: return
		text_valign = new_align
		label.vertical_alignment = new_align
@export var text:String = "":
	set(new_text):
		if label == null: return
		text = new_text
		label.text = new_text

func _ready() -> void:
	label = $Label
	label.horizontal_alignment = text_align
	label.vertical_alignment = text_valign
	pressed.connect(confirm_block)

signal block_confirmed(id, position_in_grid)

func confirm_block():
	emit_signal("block_confirmed", id, position_in_grid)


#var font
#var font_size = 16
#var font_color = 16

#func update_size(new_height: int, new_width: int):
	#set_size(Vector2(new_height, new_width))
#
