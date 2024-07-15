//Better scaling
//application_surface_draw_enable(false)

// GUI -------------------------------------------------------------------------------
#macro INTERACT_PRESS mouse_check_button_pressed(mb_left)
#macro INTERACT_HOLD mouse_check_button(mb_left)
#macro INTERACT_RELEASED mouse_check_button_released(mb_left)
#macro CANCEL mouse_check_button_pressed(mb_right)
#macro PASTE keyboard_check(vk_control) and keyboard_check_pressed(ord("V"))

#macro PADDING 30
#macro TEXT_OFF 10

enum MENU
{
	MAIN,
	COLLECTION,
	MULTIPLAYER_SETUP,
	MATCH
}

uiState = MENU.MULTIPLAYER_SETUP

titleFont = font_add("external-fonts/arial.ttf", 100, false, false, 32, 128)
font_enable_sdf(titleFont, true)
draw_set_font(fntDescription)

guiSurf = surface_create(1, 1)
surface_free(guiSurf)

cursorImage = cr_default

// Main menu -------------------------------------------------------------------------------
mainMenu = [
			new Button("Multiplayer", function(){ChangeMenuState(MENU.MULTIPLAYER_SETUP)}),
			new Button("Collection", function(){UpdateCollection(RENDERER.ENTER_COLLECTION)}),
			new Button("Download CSV", DownloadCSV, "Downloads Google sheet CSV to memory"),
			new Button("Exit", function(){game_end()}, "Exit application")
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
collectionMenu = [	new Button("Return to menu", function(){ChangeMenuState(MENU.MAIN)}),
					new Button("Save deck", SaveCurrentDeckToFile, "Save current deck to text file"),
					new Button("Load deck", LoadDeckFromFile, "Load saved deck from text file and replace current deck")
				 ]
				 
collectionFilters = [	new Button("Sort by cost", SortCardsByCost)
						//new Button("Return to menu", function(){ChangeMenuState(MENU.MAIN)})
					]
				 
pageTurner = [	new Button("<", function(){UpdateCollection(RENDERER.TURN_LEFT)}),
				new Button(">", function(){UpdateCollection(RENDERER.TURN_RIGHT)})
			 ]
#macro cardsPerPage 8
page = 0
				 
collectionRenders = []
deckRenders = []

// Multiplayer setup menu -------------------------------------------------------------------------------
multiplayerMenu = [	new Button("Start 2 player match", StartMatch,,false),
					//new Button("Start 4 player match",,,false),
					new Button("Select deck", function(){LoadDeckFromFile(DECK.MATCH)}),
					new Button("Join server from file", ConnectToNetworkFromFile),
					new Button("Host server", CreateNetwork),
					new Button("Return to menu", function(){ChangeMenuState(MENU.MAIN)})
				  ]
selectedDeckArr = []
				  
// The Match -------------------------------------------------------------------------------
interactableAreas = [
						new InteractableArea(.8, .3, 150, 80, INTERACTION_AREA.DECK, "Deck", .8, false),
						new InteractableArea(.8, .7, 150, 80, INTERACTION_AREA.DECK, "Deck", .8, true)
					]
myDeck = []
friendlyHand = []
opponentHand = []
cardsOnBoard = []

// Networking
#macro NETWORK_PORT 6510
#macro MAX_PLAYERS 2

enum CLIENT_MSG
{
	MATCH_START
}

hostedServer = -1
playersOnNetwork = 0
mySocket = network_create_socket(network_socket_tcp)
socketList = ds_list_create()
hostStatus = ""
connectedToNetwork = false
clientStatus = "Not connected"

clientBuffer = buffer_create(2, buffer_grow, 1)
serverBuffer = buffer_create(2, buffer_grow, 1)

p1x = 100
p2x = 300

// Load CSVs from files
CSVsToArray()













