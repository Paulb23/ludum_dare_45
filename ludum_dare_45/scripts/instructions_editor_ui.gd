extends ItemList

func get_drag_data(pos):
	var idx =  get_item_at_position(pos)
	var preview = Label.new()
	preview.text = get_item_text(idx)
	set_drag_preview(preview)
	return idx

func can_drop_data(pos, data):
	return true

func drop_data(pos, data):
	move_item(data, get_item_at_position(pos))
