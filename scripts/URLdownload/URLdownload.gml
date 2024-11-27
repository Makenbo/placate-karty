function DownloadCSV()
{
	with (oInterface)
	{
		// Delete existing sheet#.csv files
		for (var i = 0; file_exists($"sheet{i}.csv"); i++)
			file_delete($"sheet{i}.csv")
		
		// Download the files from links from selected text file
		var links = get_open_filename_ext("text file|*.txt", "", working_directory, "Title")
		if (links == "") return;	// Podle dokumentace by mělo fungovat ale nefunguje bruh
									// Ve výsledku na tom nezáleží, protože file nepůjde načíst
		toDownload = 0
		var file = file_text_open_read(links)
		if (file == -1) return;
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