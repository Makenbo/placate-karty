if (!surface_exists(guiSurf))
{
	display_set_gui_maximize()		
	guiSurf = surface_create(GUI_W, GUI_H)
	
	switch (uiState)
	{
		case MENU.MAIN:
			ElementsSetPositions(mainMenu,.3,.4)
			RedrawElements(mainMenu)
			break
			
		case MENU.COLLECTION:
			ElementsSetPositions(collectionMenu,.3,.4)
			RedrawElements(collectionMenu)
			break
	}
}

//GUI checking for updates
switch (uiState)
{
	case MENU.MAIN:
		UpdateElements(mainMenu)
		
		// Main title
		draw_set_halign(fa_center)
		draw_set_font(titleFont)
		draw_text(GUI_W/2, GUI_H/2*.35, "Placaté Karty")
		draw_set_font(fntDescription)
		
		// Download status
		draw_set_halign(fa_left)
		draw_text(mainMenu[2].xPos+mainMenu[2].width+PADDING, mainMenu[2].yPos+mainMenu[2].height/2, sheetStateText)
		break
		
	case MENU.COLLECTION:
		UpdateElements(collectionMenu)
		break
}

//Draw GUI surface
if (surface_exists(guiSurf)) draw_surface(guiSurf,0,0)
