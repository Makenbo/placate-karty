function Card(name_, cost_, image_, expansion_, type_, expNumber_, description_, author_, strength_, rarity_) constructor
{
	name = name_
	cost = cost_
	image = image_
	expansion = expansion_
	type = type_
	expNumber = expNumber_
	description = description_
	author = author_
	strength = strength_
	rarity = rarity_
	id_ = $"{expansion_}{expNumber_}"
}

function CSVsToArray()
{
	ds_map_clear(oInterface.cardDatabase)
	array_resize(oInterface.sortingArray, 0)
	FreeCollectionRenderer()
	
	var count = 0
	for (var i = 0; file_exists($"sheet{i}.csv"); i++)
	{
		var csvGrid = load_csv($"sheet{i}.csv")
		var cardAmount = ds_grid_height(csvGrid) - 1
		for (var j = cardAmount; j >= 1; j--)
		{
			var name =			csvGrid[# 0, j]
			var cost =			csvGrid[# 1, j]
			var image =			csvGrid[# 2, j]
			var expansion =		csvGrid[# 3, j]
			var type =			csvGrid[# 4, j]
			var expNumber =		csvGrid[# 5, j]
			var description =	csvGrid[# 6, j]
			var author =		csvGrid[# 7, j]
			var strength =		csvGrid[# 8, j]
			var rarity =		csvGrid[# 9, j]
			var id_ = $"{csvGrid[# 3, j]}{csvGrid[# 5, j]}"
			var card = new Card(name, cost, image, expansion, type, expNumber, description, author, strength, rarity)
			ds_map_add(oInterface.cardDatabase, id_, card)
			array_push(oInterface.sortingArray, card)
			count++
		}
	}
	
	totalCardAmount = count
	oInterface.sheetStateText = $"{totalCardAmount} cards loaded"
}

function SortCardsByCost()
{
	var sortFunc = function(a, b)
	{
		if (a.cost != b.cost)
			return a.cost - b.cost
		else return a.name > b.name
	}
	
	array_sort(oInterface.sortingArray, sortFunc)
	UpdateCollection(RENDERER.REFRESH)
}

function SortDeck()
{
	var sortFunc = function(a, b)
	{
		if (a.card.cost != b.card.cost) return a.card.cost - b.card.cost
		return a.card.name > b.card.name
	}
	array_sort(oInterface.deckRenders, sortFunc)
}

function SaveCurrentDeckToFile()
{
	var location = get_save_filename_ext("Deck|*.txt", "MyDeck", $"{working_directory}/decks", "Save deck")
	var file = file_text_open_write(location)
	
		var arrLen = array_length(oInterface.deckRenders)
		for (var i = 0; i < arrLen; i++)
		{
			file_text_write_string(file, oInterface.deckRenders[i].idd)
			file_text_writeln(file)
			file_text_write_real(file, oInterface.deckRenders[i].includedTimes)
			if (i != arrLen) file_text_writeln(file)
		}
	
	file_text_close(file)
}

enum DECK
{
	COLLECTION,
	MATCH
}

function LoadDeckFromFile(target = DECK.COLLECTION)
{
	var location = get_open_filename_ext("Deck|*.txt", "", $"{working_directory}decks", "Load deck")
	if (location == "") return;
	var file = file_text_open_read(location)

		FreeDeckRenderer()
		for (var i = 0; !file_text_eof(file); i++)
		{
			var cardID = file_text_read_string(file)
			file_text_readln(file)
			var amount = file_text_read_real(file)
			file_text_readln(file)
			
			var interaction = CARD_INTERACTION.IN_DECK
			if (target == DECK.MATCH) interaction = CARD_INTERACTION.STATIC
			var insert = new CardRenderer(cardID, interaction, CARD_DRAW_TYPE.COMPACT)
			insert.includedTimes = amount
			
			switch (target)
			{
				case DECK.COLLECTION:
					array_push(oInterface.deckRenders, insert)
					break
					
				case DECK.MATCH:
					array_push(oInterface.myDeck, insert)
					break
			}
		}
	
	file_text_close(file)
	
	SortDeck()
	
	if (target == DECK.COLLECTION) DrawCollectionDeck()
	else DrawPreviewDeck()
}

