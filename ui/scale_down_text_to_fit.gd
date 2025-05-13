class_name ScaleDownTextToFit extends RichTextLabel

func set_text_scaled(new_text: String) -> void:
	var font = theme.default_font
	text = new_text

	var font_size = theme.default_font_size

	while font.get_string_size(get_parsed_text(), 0, -1, font_size).x > self.size.x or font.get_string_size(get_parsed_text(), 0, -1, font_size).y > self.size.y:
		font_size -= 1

	text = "[font_size=" + str(font_size) + "]" + new_text 
