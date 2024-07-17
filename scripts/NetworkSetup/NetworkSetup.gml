function CreateNetwork()
{
	with (oInterface)
	{
		if (hostedServer != -1) network_destroy(hostedServer)
		hostedServer = network_create_server(network_socket_tcp, NETWORK_PORT, MAX_PLAYERS)
		hostStatus = $"{playersOnNetwork}/{MAX_PLAYERS} joined"
		playersConnected = true
	}
}

function ConnectToNetwork(address)
{
	with (oInterface)
	{
		var inputIsAddress = network_connect_async(mySocket, address, NETWORK_PORT) >= 0
		if (connectedToNetwork) { clientStatus = $"Disconnected from server"; connectedToNetwork = false; return; }
		if (!inputIsAddress) clientStatus = $"Input is not an address: {address}"
		else clientStatus = $"Connecting to {address}"
	}
}

function ConnectToNetworkFromClipboard()
{
	if (!clipboard_has_text()) oInterface.clientStatus = "Clipboard is empty"
	else ConnectToNetwork(clipboard_get_text())
}

function ConnectToNetworkFromFile()
{
	var filename = get_open_filename_ext("text|*.txt", "", $"{working_directory}servers", "Choose your deck")
	if (filename == "") return;
	var file = file_text_open_read(filename)
	var address = file_text_read_string(file)
	file_text_close(file)
	if (address != "") ConnectToNetwork(address)
}