@tool
class_name GridUI extends NinePatchRect

@export var margin:int = 0:
	set(new_margin):
		margin = new_margin
		update_all()

@export var spacing:int = 0:
	set(new_spacing):
		spacing = new_spacing
		update_all()

@export var blocksize:Vector2i = Vector2i(1,1):
	set(new_blocksize):
		blocksize = new_blocksize
		update_all()

@export var selection_ninepatch:NinePatchRect

signal confirmed_cursor(id:String, confirmation: Vector2i)

@export var cursor:Vector2i = Vector2i(0, 0):
	set(new_cursor):
		cursor = new_cursor
		update_all()

@export var grid_size:Vector2i = Vector2i(1, 1):
	set(new_grid_size):
		grid_size = new_grid_size
		update_all()

@export var activated = true

func replace_block_at(new_block:BlockUI, position_grid: Vector2i):
	remove_block_at(position_grid)
	add_block_at(new_block, position_grid)
	update_block_positions()

func add_block(new_block:BlockUI):
	add_child(new_block)

func add_block_at(new_block:BlockUI, position_grid: Vector2i):
	new_block.position_in_grid = position_grid
	add_block(new_block)

func remove_block_at(position_grid: Vector2i):
	var old_block = get_block_at(position_grid)
	if old_block != null:
		remove_child(old_block)
		old_block.queue_free()

func get_block_at(position_grid: Vector2i) -> BlockUI:
	for c in get_children():
		if c is BlockUI:
			if c.position_in_grid == position_grid:
				return c
	return null

func mark_block (position_grid: Vector2i):
	cursor = position_grid
	update_all()

func unmark_block (position_grid: Vector2i):
	cursor = Vector2i(-1, -1)
	update_all()
	
func confirm_block (position_grid: Vector2i):
	var block_id = ""
	if get_block_at(position_grid) != null: block_id = get_block_at(position_grid).id
	emit_signal("confirmed_cursor", block_id,  position_grid)

func _input(event: InputEvent) -> void:
	if not activated: return
	if Input.is_action_just_pressed("ui_left"):
		navigate_horizontal(-1)
	if Input.is_action_just_pressed("ui_right"):
		navigate_horizontal(1)
	if Input.is_action_just_pressed("ui_up"):
		navigate_vertical(-1)
	if Input.is_action_just_pressed("ui_down"):
		navigate_vertical(1)

func navigate_horizontal (amount: int):
	var cur = get_block_at(cursor)
	if cur == null:
		cursor.x += amount
	else:
		cursor.x += amount
		if amount < 0:
			cursor.x -= cur.size_in_blocks.x
		else:
			cursor.x += cur.size_in_blocks.x
	cursor.x % grid_size.x

func navigate_vertical (amount: int):
	var cur = get_block_at(cursor)
	if cur == null:
		cursor.y += amount
	else:
		cursor.y += amount
		if amount < 0:
			cursor.y -= cur.size_in_blocks.y
		else:
			cursor.y += cur.size_in_blocks.y
	cursor.y % grid_size.y

func new_block_position_in_grid(block, pos):
	update_all()

func block_confirmed(block_id, position_in_grid):
	cursor = position_in_grid
	update_all()
	emit_signal("confirmed_cursor", block_id,  position_in_grid)

func connect_signals():
	for c in get_children():
		if c is BlockUI:
			c.connect("block_confirmed", block_confirmed)
			c.connect("new_block_position_in_grid", new_block_position_in_grid)

func _ready() -> void:
	connect_signals()
	selection_ninepatch = $Selection

func calculate_size_generic(size_in_blocks:int, block_size:int) -> int:
	var final_size = block_size * size_in_blocks
	final_size += (size_in_blocks - 1) * spacing
	return final_size

func calculate_size_x(size_in_blocks:Vector2i) -> int:
	return calculate_size_generic(size_in_blocks.x, blocksize.x)

func calculate_size_y(size_in_blocks:Vector2i) -> int:
	return calculate_size_generic(size_in_blocks.y, blocksize.y)

func calculate_size(size_in_blocks)-> Vector2i:
	return Vector2i(calculate_size_x(size_in_blocks), calculate_size_y(size_in_blocks))

func update_block_sizes():
	for block in get_children():
		if block is BlockUI:
			block.size = calculate_size(block.size_in_blocks)

func update_selection_size():
	if selection_ninepatch == null: return
	var margin_left = selection_ninepatch.patch_margin_left
	var margin_right = selection_ninepatch.patch_margin_right
	var margin_top = selection_ninepatch.patch_margin_top
	var margin_bottom = selection_ninepatch.patch_margin_bottom
	selection_ninepatch.size = blocksize
	if get_block_at(cursor) != null:
		selection_ninepatch.size =  calculate_size(get_block_at(cursor).size_in_blocks)
	selection_ninepatch.size += Vector2(margin_left+margin_right, margin_top+margin_bottom)
	
func calculate_position_generic(pos_grid:int, block_size:int) -> int:
	var final_position = margin
	final_position += pos_grid * (spacing + block_size)
	return final_position

func calculate_position_x(pos_grid:Vector2i) -> int:
	return calculate_position_generic(pos_grid.x, blocksize.x)

func calculate_position_y(pos_grid:Vector2i) -> int:
	return calculate_position_generic(pos_grid.y, blocksize.y)

func calculate_position(pos_grid)-> Vector2i:
	return Vector2i(calculate_position_x(pos_grid), calculate_position_y(pos_grid))

func update_selection_position():
	if selection_ninepatch == null: return
	var margin_left = selection_ninepatch.patch_margin_left
	var margin_top = selection_ninepatch.patch_margin_top
	selection_ninepatch.position.x = calculate_position_x(cursor) - margin_left
	selection_ninepatch.position.y = calculate_position_y(cursor) - margin_top

func update_block_positions():
	for block in get_children():
		if block is BlockUI:
			block.position = calculate_position(block.position_in_grid)

func update_blocks():
	update_block_positions()
	update_block_sizes()

func update_selection():
	if selection_ninepatch == null: return
	if cursor == Vector2i(-1, -1):
		selection_ninepatch.visible = false
		return
	selection_ninepatch.visible = true
	update_selection_position()
	update_selection_size()

func update_all():
	update_blocks()
	update_selection()
	custom_minimum_size.x = calculate_size_generic(grid_size.x, blocksize.x) + 2 * margin
	custom_minimum_size.y = calculate_size_generic(grid_size.y, blocksize.y) + 2 * margin

func _process(delta: float) -> void:
	update_all()
