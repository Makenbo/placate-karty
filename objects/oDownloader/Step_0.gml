if (keyboard_check_pressed(ord("S")))
{
	var file = get_save_filename_ext("deck|*.ini", "saved", working_directory, "Some title")
	if (file != "")
	{
		ini_open(file)
		ini_write_string("A", "B", "asdasdasdasdasd")
		ini_close()
	}
}