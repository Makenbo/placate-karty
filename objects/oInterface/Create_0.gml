//Better scaling
application_surface_draw_enable(false)

randomize()

#macro TESTING false

// GUI -------------------------------------------------------------------------------
#macro INTERACT_PRESS mouse_check_button_pressed(mb_left)
#macro INTERACT_HOLD mouse_check_button(mb_left)
#macro INTERACT_RELEASED mouse_check_button_released(mb_left)
#macro SECONDARY_ACTION_PRESS mouse_check_button_pressed(mb_right)
#macro CANCEL mouse_check_button_pressed(mb_right)
#macro PASTE keyboard_check(vk_control) and keyboard_check_pressed(ord("V"))

#macro PADDING 30
#macro TEXT_OFF 10

#macro TWO_BYTES 65535 // Starting from 0

enum MENU
{
	MAIN,
	COLLECTION,
	MULTIPLAYER_SETUP,
	MATCH
}

uiState = MENU.MAIN
if (TESTING) uiState = MENU.MULTIPLAYER_SETUP

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
loadedSprites = ds_map_create()

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
cardsOnTop = []

// Multiplayer setup menu -------------------------------------------------------------------------------
multiplayerMenu = [
					new Button("Not ready", PlayerReady, "The match will begin when both players are ready",false,,c_red),
					//new Button("Start 4 player match",,,false),
					new Button("Select deck", function(){LoadDeckFromFile(DECK.MATCH)}, "Choose a saved deck to use in the match"),
					new Button("Connect to server from file", ConnectToNetworkFromFile, "Join someone's server based on their server address saved in a file.\nYou can also connect by copying the address and pressing Ctrl+V in this window"),
					new Button("Host server", CreateNetwork, "Create and join local server"),
					new Button("Return to menu", function(){ChangeMenuState(MENU.MAIN)})
				  ]
playerReady = false
playersReady = 0
				  
// The Match -------------------------------------------------------------------------------
interactableAreas = [
						new InteractableArea(.9, .3, 150, 80, INTERACTION_AREA.DECK, "Deck", .8, false),
						new InteractableArea(.9, .7, 150, 80, INTERACTION_AREA.DECK, "Deck", .8, true),
						new InteractableArea(.2, .9, 175, 670, INTERACTION_AREA.HAND, "") // Hand area
					]
					
friendlyHand = []
opponentHand = []
#macro HAND_OFF_DEFAULT .11
handOffY = HAND_OFF_DEFAULT
handOffTargetY = handOffY

cardsOnBoard = []
matchUI = [
			new Button("Take turn", PassTurn,,,1.2,c_white),
			new Button("End match", VoteToEndMatch, "Both players need to agree to end match", true, 1.1)
		  ]
			
myDeck = []
myDeckBackup = []
			
votesToEnd = 0
votingToEnd = false
			
holdingCard = false
holdingCardIndex = -1
holdingCardFromBoard = false
holdingCardPrev = oInterface.holdingCard
hoveringCard = false

myTurn = false

// Networking
#macro NETWORK_PORT 6510
#macro MAX_PLAYERS 2
#macro CARD_HAND_SCALE .5
#macro CARD_ON_BOARD_SCALE .5

cardMoveLerpSpd = .1
#macro CARD_LERP_LERP .2
#macro MOVE_EPSILON .001
cardPrevMultX = 0
cardPrevMultY = 0

enum CLIENT_MSG
{
	PLAYER_READY,
	MATCH_START,
	CHANGE_TURN,
	VOTE_TO_END,
	
	DRAW_CARD,
	MOVE_CARD,
	CARD_CHANGE_VISIBILITY,
	
	CARD_BOARD_TO_HAND,	//
	CARD_HAND_TO_BOARD, // These move card between arrays
	CARD_HAND_TO_HAND   //
}

hostedServer = -1
playersOnNetwork = 0
mySocket = network_create_socket(network_socket_tcp)
socketList = ds_list_create()
hostStatus = ""
connectedToNetwork = false
clientStatus = "Not connected"
//currentCardID = 0

clientBuffer = buffer_create(2, buffer_grow, 1)
serverBuffer = buffer_create(2, buffer_grow, 1)

movePacketFrequency = 4
movePacketTimer = 0

p1x = 100
p2x = 300

// Load CSVs from files
CSVsToArray()








