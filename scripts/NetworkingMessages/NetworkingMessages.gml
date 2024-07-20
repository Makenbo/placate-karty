function PlayerReady()
{
	if (TESTING)
	{
		StartMatch()
		return;
	}
	
	if (array_length(oInterface.myDeck) == 0)
	{
		LoadDeckFromFile(DECK.MATCH, "Select a deck before starting")
	}
	
	with (oInterface)
	{
		playerReady = !playerReady
		
		if (playerReady)
		{
			multiplayerMenu[0].color = c_aqua
			multiplayerMenu[0].name = "Ready"
			playersReady++
			if (playersReady == MAX_PLAYERS)
			{
				ChangeMenuState(MENU.MATCH)
				MatchSetup()
			}
		}
		else
		{
			multiplayerMenu[0].color = c_red
			multiplayerMenu[0].name = "Not ready"
			playersReady--
		}
		RedrawElements(multiplayerMenu, true, true)
		
		buffer_seek(clientBuffer, buffer_seek_start, 0)
		buffer_write(clientBuffer, buffer_u8, CLIENT_MSG.PLAYER_READY)
		buffer_write(clientBuffer, buffer_bool, playerReady)
		network_send_packet(mySocket, clientBuffer, buffer_tell(clientBuffer))
	}
}

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
		playerReady = false
		playersReady = 0
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
		myDeckBackup = array_copy(myDeckBackup, 0, myDeck, 0, array_length(myDeck))
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

function ClientHoldsCard(xx, yy, networkID, source)
{
	with(oInterface)
	{
		movePacketTimer--
		if (movePacketTimer <= 0)
		{
			movePacketTimer = movePacketFrequency
			ClientMoveCard(xx, yy, networkID, source)
		}
	}
}

function ClientMoveCard(xx, yy, networkID, source)
{
	with (oInterface)
	{
		buffer_seek(clientBuffer, buffer_seek_start, 0)
		buffer_write(clientBuffer, buffer_u8, CLIENT_MSG.MOVE_CARD)
		buffer_write(clientBuffer, buffer_u8, source)
		buffer_write(clientBuffer, buffer_u8, networkID)
		buffer_write(clientBuffer, buffer_u16, round(xx / GUI_W * TWO_BYTES))
		buffer_write(clientBuffer, buffer_u16, round(yy / GUI_H * TWO_BYTES))
		network_send_packet(mySocket, clientBuffer, buffer_tell(clientBuffer))
	}
}

function ClientCardChangeVisibility(revealed, cardID, networkID)
{
	with (oInterface)
	{
		buffer_seek(clientBuffer, buffer_seek_start, 0)
		buffer_write(clientBuffer, buffer_u8, CLIENT_MSG.CARD_CHANGE_VISIBILITY)
		buffer_write(clientBuffer, buffer_u8, networkID)
		//buffer_write(clientBuffer, buffer_bool, revealed)
		buffer_write(clientBuffer, buffer_string, cardID)
		
		network_send_packet(mySocket, clientBuffer, buffer_tell(clientBuffer))
	}
}

function ClientChangeCardArray(transitionMsg, networkID)
{
	with (oInterface)
	{
		buffer_seek(clientBuffer, buffer_seek_start, 0)
		buffer_write(clientBuffer, buffer_u8, transitionMsg)
		if (transitionMsg != CLIENT_MSG.CARD_HAND_TO_HAND)
			buffer_write(clientBuffer, buffer_u8, networkID)
		
		network_send_packet(mySocket, clientBuffer, buffer_tell(clientBuffer))
	}
}

















