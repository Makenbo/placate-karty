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
			ElementsSetPositions(collectionMenu,.015,.1,,ALIGN.LEFT)
			ElementsSetPositions(pageTurner, .015, .8, ELEMENT_DIR.HORIZONTAL,ALIGN.LEFT)
			ElementsSetPositions(collectionFilters, .015, .6, ELEMENT_DIR.HORIZONTAL,ALIGN.LEFT)
			RedrawElements(collectionMenu)
			RedrawElements(pageTurner)
			RedrawElements(collectionFilters)
			DrawCardCollection()
			break
			
		case MENU.MULTIPLAYER_SETUP:
			ElementsSetPositions(multiplayerMenu, .2,,,ALIGN.LEFT)
			RedrawElements(multiplayerMenu)
			DrawPreviewDeck()
			break

		case MENU.MATCH:
			RedrawElements(interactableAreas)
			DrawHand()
			DrawOpponentHand()
			break
	}
}

// Draw static GUI surface
if (surface_exists(guiSurf)) draw_surface(guiSurf,0,0)

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
		DrawCardSurfaces(collectionRenders)
		DrawCardSurfaces(deckRenders)
		DrawOnTopCardSurfaces()
		UpdateElements(collectionMenu)
		UpdateElements(collectionFilters)
		UpdateElements(pageTurner)
		UpdateElements(collectionRenders)
		UpdateElements(deckRenders)
		draw_set_halign(fa_center)
		draw_text(GUI_W * .05, GUI_H * .75, $"Page {page+1}")
		break
		
	case MENU.MULTIPLAYER_SETUP:
		if (PASTE) ConnectToNetworkFromClipboard()
		DrawCardSurfaces(myDeck)
		DrawOnTopCardSurfaces()
		UpdateElements(multiplayerMenu)
		UpdateElements(myDeck)
		draw_set_halign(fa_left)
		draw_text(multiplayerMenu[2].xPos+multiplayerMenu[2].width+PADDING, multiplayerMenu[2].yPos+multiplayerMenu[2].height/2, clientStatus)
		draw_text(multiplayerMenu[3].xPos+multiplayerMenu[3].width+PADDING, multiplayerMenu[3].yPos+multiplayerMenu[3].height/2, hostStatus)
		if (hostedServer != -1)
		{
			draw_text(GUI_W * .6, GUI_H * .7, "Connected players:")
			for (var i = 0; i < ds_list_size(socketList); i++)
			{
				draw_text(GUI_W * .6, GUI_H * .7 + PADDING * (i+1), socketList[| i])
			}
		}
		break
		
	case MENU.MATCH:
		DrawCardSurfaces(friendlyHand)
		DrawCardSurfaces(opponentHand)
		DrawOnTopCardSurfaces()
		UpdateElements(interactableAreas)
		UpdateElements(friendlyHand)
		UpdateElements(opponentHand)
		break
}

window_set_cursor(cursorImage)