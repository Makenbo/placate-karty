if (ds_map_find_value(async_load, "id") == getCSV)
{
	if ds_map_find_value(async_load, "status") == 0
    {
        statusText = ds_map_find_value(async_load, "result")
    }
    else
    {
		var downloaded = ds_map_find_value(async_load, "sizeDownloaded")
		var total = ds_map_find_value(async_load, "contentLength")
        statusText = "Downloaded " + downloaded + " out of " + total
    }
}