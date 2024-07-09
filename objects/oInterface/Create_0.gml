//Better scaling
//application_surface_draw_enable(false)

// GUI
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

// Main menu
mainMenu = [new Button("Collection",, function(){ChangeMenuState(MENU.COLLECTION)}),
			new Button("Multiplayer"),
			new Button("Download", "Downloads Google sheet to memory", DownloadCSV),
			new Button("Exit",,function(){game_end()})
		   ]

sheetStateText = "Idling"

// Collection
collectionMenu = [	new Button("Return to menu",, function(){ChangeMenuState(MENU.MAIN)}),
					new Button("Load deck")
				 ]
















