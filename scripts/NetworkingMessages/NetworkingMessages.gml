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
		for (var i = 0; i < array_length(myDeck); i++)
		{
			var cardAmount = myDeck[i].includedTimes
			if (cardAmount > 1)
			{
				repeat (cardAmount-1)
				{
					array_push(myDeck, new CardRenderer(myDeck[i].idd, CARD_INTERACTION.STATIC))
				}
			}
		}
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




















