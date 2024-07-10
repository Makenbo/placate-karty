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
mainMenu = [new Button("Collection",, EnterCollection),
			new Button("Multiplayer"),
			new Button("Download CSV", "Downloads Google sheet to memory", DownloadCSV),
			new Button("Exit",,function(){game_end()})
		   ]

// Sheet sync
sheetStateText = "Found ... files"
toDownload = 0
downloaded = 0
downloadLocations = []

// Card Database
cardDatabase = ds_map_create() // Big boy
sortingArray = [] // Sorting Big boy

// Collection -------------------------------------------------------------------------------
collectionMenu = [	new Button("Load deck"),
					new Button("Return to menu",, function(){ChangeMenuState(MENU.MAIN)})
				 ]
				 
cardRenders = []

// Load CSVs from files
CSVsToArray()













