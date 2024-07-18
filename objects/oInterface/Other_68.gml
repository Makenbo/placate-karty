var type = ds_map_find_value(async_load, "type")
var socket = -1

switch (type)
{
	case network_type_non_blocking_connect:
		if (ds_map_find_value(async_load, "succeeded"))
		{
			clientStatus = "Connected, waiting for host to start the match"
			connectedToNetwork = true
		}
		else clientStatus = "Connection failed"
		break
		
	case network_type_connect:
		socket = ds_map_find_value(async_load, "socket")
		ds_list_add(socketList, socket)
		hostStatus = $"{++playersOnNetwork}/{MAX_PLAYERS} joined"
		if (playersOnNetwork >= MAX_PLAYERS) // Temp
		{
			multiplayerMenu[0].clickable = true
			RedrawElements(multiplayerMenu)
		}
		show_debug_message("Player Connected")
		break

	case network_type_disconnect:
		socket = ds_map_find_value(async_load, "socket")
		ds_list_delete(socketList, ds_list_find_index(socketList, socket))
		hostStatus = $"{--playersOnNetwork}/{MAX_PLAYERS} joined"
		show_debug_message("Player Disconnected")
		break
		
	case network_type_data:
		var received = ds_map_find_value(async_load, "buffer")
		buffer_seek(received, buffer_seek_start, 0)
		socket = ds_map_find_value(async_load, "id")
		if (socket != mySocket) // Message from client to server
		{
			show_debug_message("Server received data")
			show_debug_message(socket)
			buffer_seek(received, buffer_seek_start, 0)
			ServerReceivedPacket(received, socket)
		}
		else // Message from server to client
		{
			show_debug_message("Client received data")
			show_debug_message(socket)
			buffer_seek(received, buffer_seek_start, 0)
			ClientReceivedPacket(received)
		}
		break
}