if (array_contains(downloadLocations, ds_map_find_value(async_load, "id")))
{
	if (ds_map_find_value(async_load, "status") == 0)
    {
        //sheetStateText = ds_map_find_value(async_load, "result")
		downloaded++
		sheetStateText = $"Downloaded {downloaded}/{toDownload}"
    }
}