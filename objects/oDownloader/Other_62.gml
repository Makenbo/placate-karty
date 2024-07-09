if (ds_map_find_value(async_load, "id") == getCSV)
{
	if ds_map_find_value(async_load, "status") == 0
    {
        statusText = ds_map_find_value(async_load, "result")
    }
    else
    {
		loadedSheet = ds_map_find_value(async_load, "result")
    }
}