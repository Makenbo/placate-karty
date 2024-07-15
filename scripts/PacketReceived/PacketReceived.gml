function ServerReceivedPacket(buffer, socket)
{
	for (var i = 0; i < ds_list_size(socketList); i++)
	{
		var currentSocket = socketList[| i]
		if (currentSocket != socket)
		{
			buffer_seek(buffer, buffer_seek_end, 0)
			network_send_packet(currentSocket, buffer, 60)
		}
	}
}

function ClientReceivedPacket(buffer)
{
	var msgID = buffer_read(buffer, buffer_u8)
	
	switch (msgID)
	{
		case CLIENT_MSG.MATCH_START:
			ChangeMenuState(MENU.MATCH)
			MatchSetup()
			break
	}
}













