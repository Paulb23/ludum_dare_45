extends Tree

func get_drag_data(pos):
	var preview = Label.new()
	preview.text = get_selected().get_text(0)
	set_drag_preview(preview)
	return get_selected()

func can_drop_data(pos, data):
	return data is TreeItem

func drop_data(position, data):
	var to_item = get_item_at_position(position)

	var pos = 0
	var child = get_root().get_children()
	while child != null:
		if (child == to_item):
			break
		pos += 1
		child = child.get_next()

	var item = create_item(get_root(), pos + get_drop_section_at_position(position));
	item.set_text(0, data.get_text(0))
	item.add_button(0, load("res://icons/delete_icon.png"))

	get_root().remove_child(data)
