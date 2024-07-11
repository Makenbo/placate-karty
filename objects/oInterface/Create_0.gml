//Better scaling
//application_surface_draw_enable(false)

// GUI -------------------------------------------------------------------------------
#macro INTERACT_PRESS mouse_check_button_pressed(mb_left)
#macro INTERACT_HOLD mouse_check_button(mb_left)
#macro INTERACT_RELEASED mouse_check_button_released(mb_left)
#macro CANCEL mouse_check_button_pressed(mb_right)

#macro PADDING 30

enum MENU
{
	MAIN,
	COLLECTION,
	GAME
}

uiState = MENU.MAIN

titleFont = font_add("external-fonts/arial.ttf", 100, false, false, 32, 128)
font_enable_sdf(titleFont, true)
draw_set_font(fntDescription)

guiSurf = surface_create(1, 1)
surface_free(guiSurf)

cursorImage = cr_default

// Main menu -------------------------------------------------------------------------------
mainMenu = [new Button("Collection",, function(){UpdateCollection(RENDERER.ENTER_COLLECTION)}),
			new Button("Multiplayer"),
			new Button("Download CSV", "Downloads Google sheet to memory", DownloadCSV),
			new Button("Exit",,function(){game_end()})
		   ]

// Sheet sync
sheetStateText = "Found ... files"
toDownload = 0
downloaded = 0
downloadLocations = []
totalCardAmount = 0

// Card Database
cardDatabase = ds_map_create()	// Big boy
sortingArray = []				// Sorting Big boy

// Collection -------------------------------------------------------------------------------
collectionMenu = [	new Button("Return to menu",, function(){ChangeMenuState(MENU.MAIN)}),
					new Button("Load deck")
				 ]
				 
collectionFilters = [	new Button("Sort by cost",, SortCardsByCost)
						//new Button("Return to menu",, function(){ChangeMenuState(MENU.MAIN)})
					]
				 
pageTurner = [	new Button("<",, function(){UpdateCollection(RENDERER.TURN_LEFT)}),
				new Button(">",, function(){UpdateCollection(RENDERER.TURN_RIGHT)})
			 ]
#macro cardsPerPage 8
page = 0
				 
cardRenders = []
deckRenders = []

// Load CSVs from files
CSVsToArray()













