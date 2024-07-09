if (ds_map_find_value(async_load, "id") == getCSV)
{
	if ds_map_find_value(async_load, "status") == 0
    {
        sheetStateText = ds_map_find_value(async_load, "result")
    }
    //else
    //{
	//	sheetStateText = "Failed"
    //}
}