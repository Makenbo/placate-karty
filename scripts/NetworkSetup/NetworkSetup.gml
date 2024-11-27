function CreateNetwork()
{
	with (oInterface)
	{
		if (hostedServer != -1) network_destroy(hostedServer)
		hostedServer = network_create_server(network_socket_tcp, NETWORK_PORT, MAX_PLAYERS)
		hostStatus = $"{playersOnNetwork}/{MAX_PLAYERS} joined"
		playersConnected = true
		
		ConnectToNetwork("127.0.0.1") // Somehow works? lol idk
	}
}

function ConnectToNetwork(address)
{
	with (oInterface)
	{
		if (connectedToNetwork and hostedServer != -1 and playersOnNetwork > 1)
		{
			show_message("You can't disconnect a server you're hosting, when you have more players on it.")
			return;
		}
		var inputIsAddress = network_connect_async(mySocket, address, NETWORK_PORT) >= 0
		if (connectedToNetwork) { clientStatus = $"Disconnected from server"; connectedToNetwork = false }
		else if (!inputIsAddress) clientStatus = $"Input is not an address: {address}"
		else clientStatus = $"Connecting to {address}"
		
		if (!connectedToNetwork and playerReady)
		{
			multiplayerMenu[0].name = "Not ready"
			multiplayerMenu[0].color = c_red
			PlayerReady()
		}
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
	if (file == -1) return;
	var address = file_text_read_string(file)
	file_text_close(file)
	if (address != "") ConnectToNetwork(address)
}