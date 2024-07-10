function EnterCollection()
{
	ChangeMenuState(MENU.COLLECTION)
	
	for (var i = 0; i < array_length(oInterface.cardRenders); i++)
	{
		oInterface.cardRenders[i].Free()
		delete oInterface.cardRenders[i]
	}
	array_resize(oInterface.cardRenders, 0)
	
	for (var i = 0; i < min(8, array_length(oInterface.sortingArray)); i++)
	{
		array_push(oInterface.cardRenders, new CardRenderer(oInterface.sortingArray[i].id_))
	}
}