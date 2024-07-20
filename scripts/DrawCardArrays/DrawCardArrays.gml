function DrawCardCollection()
{
	ElementsSetPositions(oInterface.collectionRenders, .26, .25, ELEMENT_DIR.HORIZONTAL, ALIGN.LEFT, 4, 8)
	RedrawCards(oInterface.collectionRenders)
	DrawCollectionDeck()
}

function DrawCollectionDeck()
{
	ElementsSetPositions(oInterface.deckRenders, .9, .07, ELEMENT_DIR.VERTICAL, ALIGN.LEFT,,, -1)
	RedrawCards(oInterface.deckRenders)
}

function DrawPreviewDeck()
{
	ElementsSetPositions(oInterface.myDeck, .9, .07, ELEMENT_DIR.VERTICAL, ALIGN.LEFT,,, -1)
	RedrawCards(oInterface.myDeck)
}

function DrawBoard()
{
	CardUpdatePositions(cardsOnBoard)
	RedrawElements(cardsOnBoard, false)
}

function DrawHand()
{
	ElementsSetPositions(oInterface.friendlyHand, .09, .97, ELEMENT_DIR.HORIZONTAL, ALIGN.MIDDLE,,,-1)
	RedrawElements(oInterface.friendlyHand, false)
}

function DrawOpponentHand()
{
	ElementsSetPositions(oInterface.opponentHand, .1, .2, ELEMENT_DIR.HORIZONTAL, ALIGN.MIDDLE,,,-1)
	RedrawElements(oInterface.opponentHand, false)
}

function RedrawMatchGUI()
{
	ElementsSetPositions(matchUI, .9,.5,,ALIGN.MIDDLE,,,250 * WINDOW_SCALAR)
	RedrawElements(matchUI,,true)
	RedrawElements(interactableAreas)
}