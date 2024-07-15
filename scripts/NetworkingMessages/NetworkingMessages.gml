function StartMatch()
{
	with (oInterface)
	{
		buffer_seek(serverBuffer, buffer_seek_start, 0)
		buffer_write(serverBuffer, buffer_u8, CLIENT_MSG.MATCH_START)
		for (var i = 0; i < ds_list_size(socketList); i++)
		{
			var socket = socketList[| i]
			network_send_packet(socket, serverBuffer, buffer_tell(serverBuffer))
		}
	}
}

function MatchSetup()
{
	with (oInterface)
	{
		myDeck = array_shuffle(selectedDeckArr, 0, 0)
	}
}