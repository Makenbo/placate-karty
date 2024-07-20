/// @description Async rerender deck

switch (uiState)
{
	case MENU.COLLECTION:
		DrawCardCollection()
		break
		
	case MENU.MULTIPLAYER_SETUP:
		DrawPreviewDeck()
		break
		
	case MENU.MATCH:
		DrawOpponentHand() // Temp
		break
}


