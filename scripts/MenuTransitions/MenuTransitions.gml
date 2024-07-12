function FreeCollectionRenderer()
{
	for (var i = 0; i < array_length(oInterface.collectionRenders); i++)
	{
		oInterface.collectionRenders[i].Free()
		delete oInterface.collectionRenders[i]
	}
	array_resize(oInterface.collectionRenders, 0)
}

function FreeDeckRenderer()
{
	for (var i = 0; i < array_length(oInterface.deckRenders); i++)
	{
		oInterface.deckRenders[i].Free()
		delete oInterface.deckRenders[i]
	}
	array_resize(oInterface.deckRenders, 0)
}

enum RENDERER
{
	ENTER_COLLECTION,
	REFRESH,
	TURN_RIGHT,
	TURN_LEFT
}

function UpdateCollection(action)
{
	switch (action)
	{
		case RENDERER.ENTER_COLLECTION:
			ChangeMenuState(MENU.COLLECTION)
			break
			
		case RENDERER.TURN_LEFT:
			if (oInterface.page <= 0) return;
			oInterface.page--
			break
			
		case RENDERER.TURN_RIGHT:
			if (oInterface.page >= floor(oInterface.totalCardAmount / cardsPerPage)) return;
			oInterface.page++
			break
	}
	
	FreeCollectionRenderer()
	
	var startPos = oInterface.page * cardsPerPage
	var endPos = startPos + cardsPerPage
	for (var i = startPos; i < min(endPos, oInterface.totalCardAmount); i++)
	{
		array_push(oInterface.collectionRenders, new CardRenderer(oInterface.sortingArray[i].id_))
	}
	
	if (action != RENDERER.ENTER_COLLECTION) DrawCardCollection()
}