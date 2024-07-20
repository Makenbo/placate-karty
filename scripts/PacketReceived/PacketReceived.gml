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
	var index, cardID, renderer;
	
	switch (msgID)
	{
		case CLIENT_MSG.PLAYER_READY:
			var isReady = buffer_read(buffer, buffer_bool)
			if (isReady) playersReady++
			else playerReady--
			if (playersReady == MAX_PLAYERS) 
			{
				ChangeMenuState(MENU.MATCH)
				MatchSetup()
			}
			break
		
		case CLIENT_MSG.MATCH_START:
			ChangeMenuState(MENU.MATCH)
			MatchSetup()
			break
			
		case CLIENT_MSG.DRAW_CARD:
			index = array_length(opponentHand)
			array_push(opponentHand, new CardRenderer(-1, CARD_INTERACTION.IN_HAND, CARD_DRAW_TYPE.BACKFACE, CARD_HAND_SCALE, index))
			DrawOpponentHand()
			break
			
		case CLIENT_MSG.MOVE_CARD:
			var cardSource = buffer_read(buffer, buffer_u8)
			index = buffer_read(buffer, buffer_u8)
			var xMult = buffer_read(buffer, buffer_u16) / TWO_BYTES
			var yMult = buffer_read(buffer, buffer_u16) / TWO_BYTES
			var xx = xMult * GUI_W
			var yy = (1 - yMult) * GUI_H
			
			switch (cardSource)
			{
				case CARD_INTERACTION.IN_HAND:
					oInterface.opponentHand[index].targetX = round(xx)
					oInterface.opponentHand[index].targetY = round(yy)
					oInterface.opponentHand[index].followTarget = true
					break

				case CARD_INTERACTION.ON_BOARD:
					oInterface.cardsOnBoard[index].targetX = round(xx)
					oInterface.cardsOnBoard[index].targetY = round(yy)
					oInterface.cardsOnBoard[index].followTarget = true
					break
			}
			var dist = point_distance(xMult, yMult, oInterface.cardPrevMultX, oInterface.cardPrevMultY)
			show_debug_message(dist)
			oInterface.cardMoveLerpSpdTarget = max(.15, (dist / 9 / movePacketFrequency * 5) + .1)
			oInterface.cardPrevMultX = xMult
			oInterface.cardPrevMultY = yMult
			break
			
		case CLIENT_MSG.CARD_CHANGE_VISIBILITY:
			index = buffer_read(buffer, buffer_u8)
			//var revealed = buffer_read(buffer, buffer_bool)
			cardID = buffer_read(buffer, buffer_string)
			
			oInterface.cardsOnBoard[index].isHidden = false // revealed
			oInterface.cardsOnBoard[index].drawType = CARD_DRAW_TYPE.FULL
			oInterface.cardsOnBoard[index].ChangeCard(cardID)
			oInterface.cardsOnBoard[index].Draw(true) // Redraw card
			break
			
		case CLIENT_MSG.CARD_BOARD_TO_HAND:
			index = buffer_read(buffer, buffer_u8)
			var heldCard = oInterface.cardsOnBoard[index]
			cardID = array_length(oInterface.opponentHand)
			array_delete(oInterface.cardsOnBoard, index, 1)
			UpdateCardArrIndexes(oInterface.cardsOnBoard)
			renderer = new CardRenderer(heldCard.idd, CARD_INTERACTION.IN_HAND, CARD_DRAW_TYPE.BACKFACE, CARD_HAND_SCALE, cardID)
			array_push(oInterface.opponentHand, renderer)
			DrawOpponentHand()
			break
			
		case CLIENT_MSG.CARD_HAND_TO_BOARD:	// Expects card to be hidden
			index = buffer_read(buffer, buffer_u8)
			cardID = array_length(oInterface.cardsOnBoard)
			var card = oInterface.opponentHand[index]
			array_delete(oInterface.opponentHand, index, 1)
			UpdateCardArrIndexes(oInterface.opponentHand)
			renderer = new CardRenderer(-1, CARD_INTERACTION.ON_BOARD, CARD_DRAW_TYPE.BACKFACE, CARD_ON_BOARD_SCALE, cardID)
			renderer.xPos = card.xPos
			renderer.yPos = card.yPos
			renderer.UpdatePositionScalars()
			array_push(oInterface.cardsOnBoard, renderer)
			DrawOpponentHand()
			renderer.Draw(true)
			break
			
		case CLIENT_MSG.CARD_HAND_TO_HAND:
			DrawOpponentHand()
			break
	}
}













