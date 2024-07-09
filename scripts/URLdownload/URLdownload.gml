function DownloadCSV()
{
	with (oInterface)
	{
		var links = get_open_filename_ext("text file|*.txt", "", working_directory, "Title")
		var file = file_text_open_read(links)
		var url = file_text_readln(file)
		var filename = string_lettersdigits(url) + ".csv"
		getCSV = http_get_file(url, filename)
		sheetStateText = "Waiting for download"
		loadedSheet = -1
	}
}