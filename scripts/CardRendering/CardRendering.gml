#macro CARD_W 200
#macro CARD_H 350
#macro COMPACT_HEIGHT 50
#macro COMPACT_WIDTH 250
#macro COMPACT_X_OFF COMPACT_WIDTH * .65
#macro NAME_SCALE .6
#macro COST_SCALE 1
#macro DESCRIPTION_SCALE .4
#macro COMPACT_NAME_SCALE .7
#macro HOVERED_SCALE 1.6
#macro LINE_OFF 10

enum CARD_STATE
{
	STATIC,
	HOVERED,
	HELD
}

enum CARD_DRAW_TYPE
{
	FULL,
	COMPACT,
	BACKFACE
}

enum CARD_INTERACTION
{
	STATIC,
	COLLECTION,
	IN_DECK,
	IN_HAND,
	ON_BOARD
}

function CardRenderer(id_, interaction_ = CARD_INTERACTION.COLLECTION, drawType_ = CARD_DRAW_TYPE.FULL, scale_ = .9, networkID_ = 0) : GuiElement() constructor
{
	idd = id_
	scale = scale_
	defaultScale = scale
	card = ds_map_find_value(oInterface.cardDatabase, idd)
	
	holdState = CARD_STATE.STATIC
	prevHoldState = holdState
	drawType = drawType_
	compactDraw = drawType == CARD_DRAW_TYPE.COMPACT
	interaction = interaction_
	
	width = compactDraw ? COMPACT_WIDTH * scale : CARD_W * scale
	height = compactDraw ? COMPACT_HEIGHT * scale : CARD_H * scale
	
	surface = surface_create(width, height)
	
	posClamped = false // Forces the surface to render inside the view
	clampedX = xPos
	clampedY = yPos
	
	onTop = false
	
	// Deck building related
	includedTimes = 0
	
	// Match sppecific
	isHidden = true
	opponentsCard = interaction == CARD_INTERACTION.IN_HAND and drawType == CARD_DRAW_TYPE.BACKFACE
	networkID = networkID_
	
	function DrawCardFull()
	{
		//draw_set_color(c_white)
		//draw_set_alpha(1)
		//draw_rectangle(0,0,width,height,false)
		//draw_set_alpha(1)
		draw_clear(c_dkgray)
		
		var fontSize = font_get_size(fntDescription)
		
		// Name
		draw_set_valign(fa_top)
		draw_text_ext_transformed(	width *.4, height*.05, card.name,
									fontSize + LINE_OFF, CARD_W * 2 - PADDING*6,
									scale*NAME_SCALE, scale*NAME_SCALE, 0)	
		// Cost
		draw_set_halign(fa_right)
		draw_set_color(c_aqua)
		draw_text_ext_transformed(	width*.9, height*.05, card.cost,
									fontSize + LINE_OFF, CARD_W * 2 - PADDING*6,
									scale*COST_SCALE, scale*COST_SCALE, 0)
		// Strength
		draw_set_halign(fa_left)
		draw_set_valign(fa_middle)
		draw_set_color(c_red)
		draw_text_ext_transformed(	width*.1, height*.9, card.strength,
									fontSize + LINE_OFF, CARD_W * 2 - PADDING*6,
									scale*COST_SCALE, scale*COST_SCALE, 0)
			
		// Description
		draw_set_halign(fa_center)
		draw_set_color(c_white)
		draw_text_ext_transformed(	width*.45, height*.75, card.description,
									fontSize + LINE_OFF, CARD_W * 2 * .9,
									scale*DESCRIPTION_SCALE, scale*DESCRIPTION_SCALE, 0)
		// Type
		draw_text_ext_transformed(	width*.5, height*.6, card.type,
									fontSize + LINE_OFF, CARD_W * 2 - PADDING*5,
									scale*DESCRIPTION_SCALE, scale*DESCRIPTION_SCALE, 0)
		// IDs
		draw_text_ext_transformed(	width*.85, height*.6, card.expNumber,
									fontSize + LINE_OFF, CARD_W * 2 - PADDING,
									scale*DESCRIPTION_SCALE, scale*DESCRIPTION_SCALE, 0)
		draw_text_ext_transformed(	width*.15, height*.6, card.expansion,
									fontSize + LINE_OFF, CARD_W * 2 - PADDING,
									scale*DESCRIPTION_SCALE, scale*DESCRIPTION_SCALE, 0)
		// Author
		draw_text_ext_transformed(	width*.9, height*.75, card.author,
									fontSize + LINE_OFF, CARD_W * 2 - PADDING,
									scale*DESCRIPTION_SCALE, scale*DESCRIPTION_SCALE, 90)
		// Rarity
		draw_set_color(c_yellow)
		draw_text_ext_transformed(	width*.6, height*.9, card.rarity,
									fontSize + LINE_OFF, CARD_W * 2 - PADDING,
									scale*NAME_SCALE, scale*NAME_SCALE, 0)
									
		if (interaction == CARD_INTERACTION.IN_DECK)
		{
			draw_text_ext_transformed(	width*.5, height*.4, $"{includedTimes}x",
										fontSize + LINE_OFF, CARD_W * 2 - PADDING,
										scale, scale, 0)
		}
										
		draw_set_color(c_white)
	}
	
	function DrawCardCompact()
	{
		var fontSize = font_get_size(fntDescription)
		draw_clear(c_dkgray)
		// Name
		draw_set_color(c_white)
		draw_text_ext_transformed(	width *.5, height*.5, card.name,
									fontSize + LINE_OFF, CARD_W * 2 - PADDING*6,
									scale * COMPACT_NAME_SCALE, scale * COMPACT_NAME_SCALE, 0)
		// Cost
		draw_set_color(c_aqua)
		draw_text_ext_transformed(	width*.1, height*.5, card.cost,
									fontSize + LINE_OFF, CARD_W * 2 - PADDING*6,
									scale * COMPACT_NAME_SCALE, scale * COMPACT_NAME_SCALE, 0)
		// Amount in deck
		draw_set_color(c_yellow)
		draw_text_ext_transformed(	width*.9, height*.5, $"{includedTimes}x",
									fontSize + LINE_OFF, CARD_W * 2 - PADDING*6,
									scale * COMPACT_NAME_SCALE, scale * COMPACT_NAME_SCALE, 0)
									
		draw_set_color(c_white)
	}
	
	function Draw(singleRedraw = false)
	{
		UpdatePosition(posClamped)
		
		if (!surface_exists(surface))
			surface = surface_create(width, height)
		
		if (singleRedraw)
		{
			gpu_set_blendmode_ext(bm_src_alpha, bm_one) // Somehow fixes text edges
			draw_set_halign(fa_center)
		}
		
		surface_set_target(surface)
			
			switch (drawType)
			{
				case CARD_DRAW_TYPE.FULL:
					DrawCardFull()
					break
					
				case CARD_DRAW_TYPE.COMPACT:
					if (holdState == CARD_STATE.HOVERED) DrawCardFull()
					else DrawCardCompact()
					break
					
				case CARD_DRAW_TYPE.BACKFACE:
					draw_clear(c_green)
					break
			}
			
		surface_reset_target()
		
		if (singleRedraw)
			gpu_set_blendmode_ext(bm_src_alpha, bm_inv_src_alpha)
	}
	
	function Update()
	{
		UpdatePosition(posClamped)
		
		var realHeight = compactDraw ? COMPACT_HEIGHT * defaultScale : CARD_H * defaultScale
		var realWidth = compactDraw ? COMPACT_WIDTH * defaultScale : CARD_W * defaultScale
		
		if (point_in_rectangle(mX,mY,xPos-realWidth/2,yPos-realHeight/2,xPos+realWidth/2,yPos+realHeight/2))
		{
			//Change cursor type
			if (oInterface.cursorImage != cr_handpoint)
				oInterface.cursorImage = cr_handpoint
			
			if (!opponentsCard or !isHidden) holdState = CARD_STATE.HOVERED
			
			if (INTERACT_PRESS)
			{
				switch (interaction)
				{
					case CARD_INTERACTION.COLLECTION:
						var findDuplicate = function(element, index)
						{
							return element.idd == idd
						}
						var index = array_find_index(oInterface.deckRenders, findDuplicate)
						if (index != -1) oInterface.deckRenders[index].includedTimes++
						else
						{
							var insert = new CardRenderer(idd, CARD_INTERACTION.IN_DECK, CARD_DRAW_TYPE.COMPACT)
							insert.includedTimes = 1
							array_push(oInterface.deckRenders, insert)
							SortDeck()
						}
						DrawCollectionDeck()
						break
						
					case CARD_INTERACTION.IN_DECK:
						var f = function(element, index)
						{
							return element.idd == idd
						}
						var index = array_find_index(oInterface.deckRenders, f)
						if (oInterface.deckRenders[index].includedTimes > 1)
						{
							oInterface.deckRenders[index].includedTimes--
							Draw(true)
						}
						else
						{
							array_delete(oInterface.deckRenders, index, 1)
							SortDeck()
							DrawCollectionDeck()
						}
						break
				}
			}
			
			var xOff = 0
			if (interaction == CARD_INTERACTION.IN_DECK)
				xOff = COMPACT_X_OFF * scale
			
			// Hover
			if (interaction == CARD_INTERACTION.IN_DECK) draw_set_color(c_black)
			else draw_set_color(c_white)
			draw_set_alpha(.3)
			draw_rectangle(clampedX-xOff-width/2,clampedY-height/2,clampedX-xOff+width/2,clampedY+height/2,false)
			draw_set_alpha(1)
			draw_set_color(c_white)
		}
		else
		{
			holdState = CARD_STATE.STATIC
		}
		
		if (holdState != prevHoldState)
		{
			prevHoldState = holdState
			switch (holdState)
			{
				case CARD_STATE.HOVERED:
					onTop = true
					ChangeScale(HOVERED_SCALE)
					posClamped = true
					UpdatePosition(posClamped)
					break
					
				case CARD_STATE.STATIC:
					onTop = false
					ChangeScale(defaultScale)
					posClamped = false
					UpdatePosition(posClamped)
					break
			}
		}
	}
	
	function ChangeCard(newId_)
	{
		idd = newId_
		card = ds_map_find_value(oInterface.cardDatabase, newId_)
	}
	
	function ChangeScale(scale_)
	{
		scale = scale_
		width = compactDraw and holdState == CARD_STATE.STATIC ? COMPACT_WIDTH * scale : CARD_W * scale
		height = compactDraw and holdState == CARD_STATE.STATIC ? COMPACT_HEIGHT * scale : CARD_H * scale
		surface_free(surface)
		surface = surface_create(width, height)
		Draw(true)
	}
	
	function UpdatePosition(clamped)
	{
		if (clamped)
		{
			clampedX = clamp(xPos, PADDING + width/2, GUI_W - width/2 - PADDING)
			clampedY = clamp(yPos, PADDING + height/2, GUI_H - height/2 - PADDING)
		}
		else
		{
			clampedX = xPos
			clampedY = yPos
		}
	}
	
	function Free()
	{
		surface_free(surface)
	}
}

function RedrawCards(elements)
{
	gpu_set_blendmode_ext(bm_src_alpha, bm_one) // Somehow fixes text edges
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	for (var i = 0; i < array_length(elements); i++)
	{
		elements[i].Draw()
	}
	gpu_set_blendmode_ext(bm_src_alpha, bm_inv_src_alpha)
}

function DrawCardSurfaces(cards)
{
	for (var i = 0; i < array_length(cards); i++)
	{
		var cardRenderer = cards[i]
		
		if (cardRenderer.onTop) array_push(oInterface.cardsOnTop, cardRenderer)
		else draw_surface(cardRenderer.surface, cardRenderer.clampedX-cardRenderer.width/2, cardRenderer.clampedY-cardRenderer.height/2)
	}
}

function DrawOnTopCardSurfaces()
{
	for (var i = 0; i < array_length(oInterface.cardsOnTop); i++)
	{
		var cardRenderer = oInterface.cardsOnTop[i]
		
		var xOff = 0
		if (cardRenderer.interaction == CARD_INTERACTION.IN_DECK and cardRenderer.holdState == CARD_STATE.HOVERED) xOff = COMPACT_X_OFF * cardRenderer.scale
		
		draw_surface(cardRenderer.surface, cardRenderer.clampedX-xOff-cardRenderer.width/2, cardRenderer.clampedY-cardRenderer.height/2)
	}
	oInterface.cardsOnTop = array_create(0)
}












