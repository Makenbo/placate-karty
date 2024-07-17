function DrawCardCollection()
{
	ElementsSetPositions(oInterface.collectionRenders, .26, .25, ELEMENT_DIR.HORIZONTAL, ALIGN.LEFT, 4, 8)
	RedrawCards(oInterface.collectionRenders)
	DrawCollectionDeck()
}

function DrawCollectionDeck()
{
	ElementsSetPositions(oInterface.deckRenders, .9, .07, ELEMENT_DIR.VERTICAL, ALIGN.LEFT,,, 0)
	RedrawCards(oInterface.deckRenders)
}

function DrawPreviewDeck()
{
	ElementsSetPositions(oInterface.myDeck, .9, .07, ELEMENT_DIR.VERTICAL, ALIGN.LEFT,,, 0)
	RedrawCards(oInterface.myDeck)
}

function DrawHand()
{
	ElementsSetPositions(oInterface.friendlyHand, .1, .96, ELEMENT_DIR.HORIZONTAL, ALIGN.MIDDLE,,,2)
	RedrawElements(oInterface.friendlyHand, false)
}

function DrawOpponentHand()
{
	ElementsSetPositions(oInterface.opponentHand, .1, .2, ELEMENT_DIR.HORIZONTAL, ALIGN.MIDDLE,,,2)
	RedrawElements(oInterface.opponentHand, false)
}