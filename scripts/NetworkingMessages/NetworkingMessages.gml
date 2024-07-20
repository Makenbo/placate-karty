function PlayerReady(sendPacket = true)
{
	if (TESTING)
	{
		ChangeMenuState(MENU.MATCH)
		MatchSetup()
		return;
	}
	
	if (array_length(oInterface.myDeck) == 0)
	{
		var loadedDeck = LoadDeckFromFile(DECK.MATCH, "Select a deck before starting")
		if (!loadedDeck)
		{
			show_message("You need to choose a deck before being ready")
			return;
		}
	}
	
	with (oInterface)
	{
		playerReady = !playerReady
		
		if (playerReady)
		{
			multiplayerMenu[0].color = c_aqua
			multiplayerMenu[0].name = "Ready"
			playersReady++
		}
		else
		{
			multiplayerMenu[0].color = c_red
			multiplayerMenu[0].name = "Not ready"
			playersReady--
		}
		
		if (surface_exists(guiSurf)) // If window is not focused before pressing button, the surf wont exist
			RedrawElements(multiplayerMenu, true, true)
		
		if (sendPacket) ClientPlayerReady()
		
		if (playerReady and playersReady == MAX_PLAYERS and hostedServer != -1)
		{
			StartMatch()
		}
	}
}

function ClientPlayerReady()
{
	buffer_seek(clientBuffer, buffer_seek_start, 0)
	buffer_write(clientBuffer, buffer_u8, CLIENT_MSG.PLAYER_READY)
	buffer_write(clientBuffer, buffer_bool, playerReady)
	network_send_packet(mySocket, clientBuffer, buffer_tell(clientBuffer))
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
		array_copy(myDeckBackup, 0, myDeck, 0, array_length(myDeck))
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
		buffer_write(clientBuffer, buffer_u8, networkID)
		
		network_send_packet(mySocket, clientBuffer, buffer_tell(clientBuffer))
	}
}

function PassTurn()
{
	with (oInterface)
	{
		if (matchUI[0].color == c_white) ButtonMyTurn()
		else if (myTurn) ButtonEnemyTurn()
		ClientPassTurn()
	}
}

function ButtonEnemyTurn()
{
	with (oInterface)
	{
		myTurn = false
		matchUI[0].name = "Enemy turn"
		matchUI[0].color = c_red
		matchUI[0].clickable = false
		RedrawMatchGUI()
	}
}

function ButtonMyTurn()
{
	with (oInterface)
	{
		myTurn = true
		matchUI[0].name = "Your turn"
		matchUI[0].color = c_aqua
		matchUI[0].clickable = true
		RedrawMatchGUI()
	}
}

function ClientPassTurn()
{
	with (oInterface)
	{
		buffer_seek(clientBuffer, buffer_seek_start, 0)
		buffer_write(clientBuffer, buffer_u8, CLIENT_MSG.CHANGE_TURN)
		buffer_write(clientBuffer, buffer_bool, myTurn)
		network_send_packet(mySocket, clientBuffer, buffer_tell(clientBuffer))
	}
}


function VoteToEndMatch()
{
	with (oInterface)
	{
		votingToEnd = !votingToEnd
		
		if (votingToEnd)
		{
			votesToEnd++
			matchUI[1].name = "Voting to end"
			matchUI[1].color = c_aqua
		}
		else
		{
			votesToEnd--
			matchUI[1].name = "End match"
			matchUI[1].color = c_yellow
		}
		
		RedrawMatchGUI()
		ClientVotesToEnd()
		
		if (votesToEnd == MAX_PLAYERS)
		{
			EndMatch()
		}
	}
}

function ClientVotesToEnd()
{
	with (oInterface)
	{
		buffer_seek(clientBuffer, buffer_seek_start, 0)
		buffer_write(clientBuffer, buffer_u8, CLIENT_MSG.VOTE_TO_END)
		buffer_write(clientBuffer, buffer_bool, votingToEnd)
		network_send_packet(mySocket, clientBuffer, buffer_tell(clientBuffer))
	}
}

function EndMatch()
{
	with (oInterface)
	{
		array_copy(myDeck, 0, myDeckBackup, 0, array_length(myDeckBackup))
		playerReady = false
		playersReady = 0
		multiplayerMenu[0].color = c_red
		multiplayerMenu[0].name = "Not ready"
		cardsOnBoard = []
		friendlyHand = []
		opponentHand = []
		votingToEnd = false
		votesToEnd = 0
		myTurn = false
		matchUI = [	// Stupi aah copy & paste
			new Button("Take turn", PassTurn,,,1.2,c_white),
			new Button("End match", VoteToEndMatch, "Both players need to agree to end match", true, 1.1)
		  ]
		ChangeMenuState(MENU.MULTIPLAYER_SETUP)
	}
}











