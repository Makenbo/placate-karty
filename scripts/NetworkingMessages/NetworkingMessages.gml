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
		myDeck = array_shuffle(myDeck)
	}
}

//function NetworkCardID(offset)
//{
//	with (oInterface)
//	{
//		currentCardID++
//		return currentCardID + mySocket * 1234
//	}
//}

function ClientDrewCard()
{
	with (oInterface)
	{
		buffer_seek(clientBuffer, buffer_seek_start, 0)
		buffer_write(clientBuffer, buffer_u8, CLIENT_MSG.DRAW_CARD)
		network_send_packet(mySocket, clientBuffer, buffer_tell(clientBuffer))
	}
}




















