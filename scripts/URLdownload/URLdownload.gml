function DownloadCSV()
{
	with (oInterface)
	{
		var links = get_open_filename_ext("text file|*.txt", "", working_directory, "Title")
		if (links == "") return;
		
		toDownload = 0
		var file = file_text_open_read(links)
		for (var i = 0; !file_text_eof(file); i++)
		{
			var url = file_text_readln(file)
			var filename = "sheet" + string(i) + ".csv"
			array_push(downloadLocations, http_get_file(url, filename))
			toDownload++
		}
		
		downloaded = 0
		sheetStateText = $"Downloaded 0/{toDownload}"
		loadedSheet = -1
	}
}