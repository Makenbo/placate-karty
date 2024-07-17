if (uiState == MENU.COLLECTION)
{
	ds_map_add(loadedSprites, async_load[? "filename"], async_load[? "id"])
	show_debug_message($"loaded {async_load[? "filename"]}")
	DrawCardCollection()
}