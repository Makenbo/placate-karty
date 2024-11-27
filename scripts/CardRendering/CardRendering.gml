#macro CARD_W 200
#macro CARD_H 350
#macro COMPACT_HEIGHT 50
#macro COMPACT_WIDTH 250
#macro COMPACT_X_OFF COMPACT_WIDTH * .65 * WINDOW_SCALAR
#macro NAME_SCALE .6
#macro COST_SCALE 1
#macro DESCRIPTION_SCALE .4
#macro COMPACT_NAME_SCALE .7
#macro HOVERED_SCALE 1.6
#macro HOVERED_MATCH_SCALE 1.3
#macro HELD_SCALE 1
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
	HOLDING,
	ON_BOARD
}

function CardRenderer(id_ = -1, interaction_ = CARD_INTERACTION.COLLECTION, drawType_ = CARD_DRAW_TYPE.FULL, scale_ = .9, networkID_ = 0) : GuiElement() constructor
{
	idd = id_
	scale = scale_
	defaultScale = scale
	card = ds_map_find_value(oInterface.cardDatabase, idd)
	
	sprite = -1
	if (id_ != -1)
	{
		var possibleSprite = oInterface.loadedSprites[? card.image]
		if (!is_undefined(possibleSprite)) sprite = possibleSprite
		else if (file_exists(card.image))
			sprite = sprite_add_ext(card.image, 1, 0, 0, true)
			//sprite = sprite_add(card.image, 1, 0, 0, 0, 0)
	}
	
	spriteX = 0
	spriteY = 0
	spriteScalar = 1
	
	holdState = CARD_STATE.STATIC
	prevHoldState = holdState
	drawType = drawType_
	compactDraw = drawType == CARD_DRAW_TYPE.COMPACT
	interaction = interaction_
	
	width = compactDraw and holdState == CARD_STATE.STATIC ? COMPACT_WIDTH : CARD_W
	height = compactDraw and holdState == CARD_STATE.STATIC ? COMPACT_HEIGHT : CARD_H
	width *= scale * WINDOW_SCALAR
	height *= scale * WINDOW_SCALAR
	
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
	networkID = networkID_ // Network index is also index of the position in the array where this instance is saved
	multX = 0
	multY = 0
	targetX = xPos
	targetY = yPos
	followTarget = false
	
	function DrawCardFull()
	{
		//draw_set_color(c_white)
		//draw_set_alpha(1)
		//draw_rectangle(0,0,width,height,false)
		//draw_set_alpha(1)
		
		draw_clear(c_dkgray)
		var fontSize = font_get_size(fntDescription)
		
		// Image
		if (sprite != -1)
		{
			gpu_set_blendmode_ext(bm_src_alpha, bm_inv_src_alpha)
			spriteScalar = (CARD_H*.45) / sprite_get_height(sprite) // only based on height
			
			var spriteScale = spriteScalar * scale
			spriteX = (sprite_get_width(sprite) / 2) * spriteScale
			spriteY = (sprite_get_height(sprite) / 2) * spriteScale
			draw_sprite_ext(sprite, 0, width*.5-spriteX, height*.38-spriteY,
							spriteScale, spriteScale, 0, c_white, 1)
			gpu_set_blendmode_ext(bm_src_alpha, bm_one)
		}
		
		// Name
		draw_set_valign(fa_middle)
		draw_text_ext_transformed(	width *.4, height*.09, card.name,
									fontSize + LINE_OFF, CARD_W * 2 - PADDING*6,
									scale*NAME_SCALE, scale*NAME_SCALE, 0)	
		// Cost
		draw_set_halign(fa_right)
		draw_set_color(c_aqua)
		draw_text_ext_transformed(	width*.9, height*.09, card.cost,
									fontSize + LINE_OFF, CARD_W * 2 - PADDING*6,
									scale*COST_SCALE, scale*COST_SCALE, 0)
		// Strength
		draw_set_halign(fa_left)
		draw_set_color(c_red)
		draw_text_ext_transformed(	width*.1, height*.93, card.strength,
									fontSize + LINE_OFF, CARD_W * 2 - PADDING*6,
									scale*COST_SCALE, scale*COST_SCALE, 0)
			
		// Description
		draw_set_halign(fa_center)
		draw_set_color(c_white)
		draw_text_ext_transformed(	width*.45, height*.78, card.description,
									fontSize + LINE_OFF, CARD_W * 2 * .9,
									scale*DESCRIPTION_SCALE, scale*DESCRIPTION_SCALE, 0)
		// Type
		draw_text_ext_transformed(	width*.5, height*.65, card.type,
									fontSize + LINE_OFF, CARD_W * 2 - PADDING*5,
									scale*DESCRIPTION_SCALE, scale*DESCRIPTION_SCALE, 0)
		// IDs
		draw_text_ext_transformed(	width*.85, height*.65, card.expNumber,
									fontSize + LINE_OFF, CARD_W * 2 - PADDING,
									scale*DESCRIPTION_SCALE, scale*DESCRIPTION_SCALE, 0)
		draw_text_ext_transformed(	width*.15, height*.65, card.expansion,
									fontSize + LINE_OFF, CARD_W * 2 - PADDING,
									scale*DESCRIPTION_SCALE, scale*DESCRIPTION_SCALE, 0)
		// Author
		draw_text_ext_transformed(	width*.9, height*.78, card.author,
									fontSize + LINE_OFF, CARD_W * 2 - PADDING,
									scale*DESCRIPTION_SCALE, scale*DESCRIPTION_SCALE, 90)
		// Rarity
		draw_set_color(c_yellow)
		draw_text_ext_transformed(	width*.6, height*.93, card.rarity,
									fontSize + LINE_OFF, CARD_W * 2 - PADDING,
									scale*NAME_SCALE, scale*NAME_SCALE, 0)
										
		draw_set_color(c_white)
	}
	
	function DrawCardCompact()
	{
		var fontSize = font_get_size(fntDescription)
		draw_clear(c_dkgray)
		
		// Image
		if (sprite != -1)
		{
			gpu_set_blendmode_ext(bm_src_alpha, bm_inv_src_alpha)
			spriteScalar = COMPACT_WIDTH / sprite_get_width(sprite) // only based on height
			
			var spriteScale = spriteScalar * scale
			spriteX = (sprite_get_width(sprite) / 2) * spriteScale
			spriteY = (sprite_get_height(sprite) / 2) * spriteScale
			draw_sprite_ext(sprite, 0, width*.5-spriteX, height*.5-spriteY,
							spriteScale, spriteScale, 0, c_dkgray, 1)
			gpu_set_blendmode_ext(bm_src_alpha, bm_one)
		}
		
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
		
		scale *= WINDOW_SCALAR
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
					if (holdState == CARD_STATE.HOVERED)
					{
						draw_clear(c_teal)
						draw_text_transformed(width*.5, height*.5, "Hidden", 2, 2, 0)
					}
					else draw_clear(c_green)
					break
			}
			
			if (isHidden and drawType != CARD_DRAW_TYPE.BACKFACE and
			   (interaction == CARD_INTERACTION.ON_BOARD or interaction == CARD_INTERACTION.HOLDING)) // Darken card if it's hidden to the enemy
			{
				gpu_set_blendmode_ext(bm_src_alpha, bm_inv_src_alpha)
				draw_set_color(c_black)
				draw_set_alpha(.3)
				draw_rectangle(0, 0, width, height, false)
				draw_set_color(c_white)
				draw_set_alpha(1)
				if (!singleRedraw) gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha)
			}
			
			//draw_text_ext_transformed(	width*.5, height*.5, networkID,
			//							fontSize + LINE_OFF, CARD_W * 2 - PADDING*6,
			//							scale * 2, scale * 2, 0)
			
		surface_reset_target()
		scale /= WINDOW_SCALAR
		
		if (singleRedraw)
			gpu_set_blendmode_ext(bm_src_alpha, bm_inv_src_alpha)
	}
	
	function Update()
	{
		if (point_distance(xPos, yPos, targetX, targetY) < MOVE_EPSILON)
			followTarget = false
			
		if (followTarget)
		{
			oInterface.cardMoveLerpSpd = lerp(oInterface.cardMoveLerpSpd, oInterface.cardMoveLerpSpdTarget, CARD_LERP_LERP)
			xPos = lerp(xPos, targetX, oInterface.cardMoveLerpSpd)
			yPos = lerp(yPos, targetY, oInterface.cardMoveLerpSpd)
		}
		
		if (interaction == CARD_INTERACTION.HOLDING)
		{
			xPos = mX
			yPos = mY
		}
		
		UpdatePosition(posClamped)
		
		var realHeight = compactDraw ? COMPACT_HEIGHT : CARD_H
		var realWidth = compactDraw ? COMPACT_WIDTH : CARD_W
		realHeight *= defaultScale * WINDOW_SCALAR
		realWidth *= defaultScale * WINDOW_SCALAR
		
		var hovering = point_in_rectangle(mX,mY,xPos-realWidth/2,yPos-realHeight/2,xPos+realWidth/2,yPos+realHeight/2)
		
		if (hovering)
		{
			//Change cursor type
			if (oInterface.cursorImage != cr_handpoint and !opponentsCard)
				oInterface.cursorImage = cr_handpoint
				
			
			if ((!opponentsCard or !isHidden) and !oInterface.hoveringCard and !oInterface.holdingCard and !oInterface.holdingCardPrev)
			{
				oInterface.hoveringCard = true
				holdState = CARD_STATE.HOVERED
			}
			
			if (interaction == CARD_INTERACTION.IN_HAND and drawType != CARD_DRAW_TYPE.BACKFACE) oInterface.handOffTargetY = 0
			
			if (INTERACT_PRESS and drawType != CARD_DRAW_TYPE.BACKFACE)
			{
				followTarget = false
				
				var index = 0
				switch (interaction)
				{
					case CARD_INTERACTION.COLLECTION:
						var findDuplicate = function(element, index)
						{
							return element.idd == idd
						}
						index = array_find_index(oInterface.deckRenders, findDuplicate)
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
						index = array_find_index(oInterface.deckRenders, f)
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
							oInterface.hoveringCard = false
						}
						break
					
					case CARD_INTERACTION.IN_HAND:
						if (oInterface.myTurn and !oInterface.holdingCard and !oInterface.holdingCardPrev)
						{
							interaction = CARD_INTERACTION.HOLDING
							holdState = CARD_STATE.HELD
							oInterface.holdingCard = true
							oInterface.holdingCardIndex = networkID
							oInterface.holdingCardFromBoard = false
						}
						break
						
					case CARD_INTERACTION.ON_BOARD:
						if (oInterface.myTurn and !oInterface.holdingCard and !oInterface.holdingCardPrev)
						{
							interaction = CARD_INTERACTION.HOLDING
							holdState = CARD_STATE.HELD
							oInterface.holdingCard = true
							oInterface.holdingCardIndex = networkID
							oInterface.holdingCardFromBoard = true
						}
						break
						
					case CARD_INTERACTION.HOLDING:
						oInterface.holdingCard = false
						break
						
				}
			}
			
			if (SECONDARY_ACTION_PRESS and drawType != CARD_DRAW_TYPE.BACKFACE and interaction == CARD_INTERACTION.ON_BOARD)
			{
				isHidden = false
				Draw(true)
				ClientCardChangeVisibility(true, idd, networkID)
			}
		}
		else // Reset card state if it isn't hovered
		{
			holdState = CARD_STATE.STATIC
		}
		
		if (holdState == CARD_STATE.HELD)
		{
			if (oInterface.holdingCardFromBoard) ClientHoldsCard(xPos, yPos, networkID, CARD_INTERACTION.ON_BOARD)
			else ClientHoldsCard(xPos, yPos, networkID, CARD_INTERACTION.IN_HAND)
		}
		
		if (holdState != prevHoldState)
		{
			prevHoldState = holdState
			switch (holdState)
			{
				case CARD_STATE.HOVERED:
					onTop = true
					if (oInterface.uiState == MENU.COLLECTION) ChangeScale(HOVERED_SCALE)
					else ChangeScale(HOVERED_MATCH_SCALE)
					posClamped = true
					UpdatePosition(posClamped)
					break
					
				case CARD_STATE.HELD:
					ChangeScale(defaultScale * HELD_SCALE)
					posClamped = false
					UpdatePosition(posClamped)
					break
					
				case CARD_STATE.STATIC:
					oInterface.hoveringCard = false
					onTop = false
					ChangeScale(defaultScale)
					posClamped = false
					UpdatePosition(posClamped)
					break
			}
		}
		
		// Hover
		if (hovering)
		{
			var xOff = 0
			if (drawType == CARD_DRAW_TYPE.COMPACT)
				xOff = COMPACT_X_OFF * scale
			
			var xLeft = clampedX-xOff-width/2
			var yTop = clampedY-height/2
		
			if (drawType == CARD_DRAW_TYPE.COMPACT)
			{
				draw_set_color(c_black)
				draw_set_alpha(.4)
			}
			else
			{
				draw_set_color(c_white)
				draw_set_alpha(.1)
			}
			draw_set_halign(fa_center)
			draw_rectangle(clampedX-xOff-width/2,clampedY-height/2,clampedX-xOff+width/2,clampedY+height/2,false)
			draw_set_alpha(1)
			
			if (drawType == CARD_DRAW_TYPE.COMPACT)
			{
				draw_set_color(c_yellow)
				draw_set_alpha(1)
				draw_text_ext_transformed(	xLeft + width*.5, yTop + height*.5, $"{includedTimes}x",
											fontSize + LINE_OFF, CARD_W * 2 - PADDING,
											scale*1.5*WINDOW_SCALAR, scale*1.5*WINDOW_SCALAR, 0)
			}
			draw_set_color(c_white)
		}
	}
	
	function ChangeCard(newId_)
	{
		idd = newId_
		card = ds_map_find_value(oInterface.cardDatabase, newId_)
		var possibleSprite = oInterface.loadedSprites[? card.image]
		if (!is_undefined(possibleSprite)) sprite = possibleSprite
		else if (file_exists(card.image))
			sprite = sprite_add_ext(card.image, 1, 0, 0, true)
	}
	
	function ChangeScale(scale_)
	{
		scale = scale_
		RecalculateSize()
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
	
	function UpdatePositionScalars()
	{
		multX = xPos / GUI_W
		multY = yPos / GUI_H
		test = GUI_W
		tests = GUI_H
		stests = 5
	}
	
	function UpdatePositionOnScalars()
	{
		xPos = multX * GUI_W
		yPos = multY * GUI_H
		UpdatePosition(false)
	}
	
	function RecalculateSize()
	{
		width = compactDraw and holdState == CARD_STATE.STATIC ? COMPACT_WIDTH : CARD_W
		height = compactDraw and holdState == CARD_STATE.STATIC ? COMPACT_HEIGHT : CARD_H
		width *= scale * WINDOW_SCALAR
		height *= scale * WINDOW_SCALAR
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

function UpdateCardArrIndexes(arr)
{
	for (var i = 0; i < array_length(arr); i++)
	{
		arr[i].networkID = i
	}
}

function DrawCardSurfaces(cards, xOffMult = 0, yOffMult = 0)
{
	for (var i = 0; i < array_length(cards); i++)
	{
		var cardRenderer = cards[i]
		
		if (cardRenderer.onTop) array_push(oInterface.cardsOnTop, cardRenderer)
		else
		{
			if (cardRenderer.holdState == CARD_STATE.HELD) yOffMult = 0 // Bullshit workaround
			
			var xx = (cardRenderer.clampedX-cardRenderer.width/2) + (xOffMult * GUI_W)
			var yy = (cardRenderer.clampedY-cardRenderer.height/2) + (yOffMult * GUI_H)
			draw_surface(cardRenderer.surface, round(xx), round(yy))
		}
	}
}

function DrawOnTopCardSurfaces()
{
	for (var i = 0; i < array_length(oInterface.cardsOnTop); i++)
	{
		var cardRenderer = oInterface.cardsOnTop[i]
		
		var xOff = 0
		if (cardRenderer.drawType == CARD_DRAW_TYPE.COMPACT and cardRenderer.holdState == CARD_STATE.HOVERED) xOff = COMPACT_X_OFF * cardRenderer.scale
		
		draw_surface(cardRenderer.surface, cardRenderer.clampedX-xOff-cardRenderer.width/2, cardRenderer.clampedY-cardRenderer.height/2)
	}
	oInterface.cardsOnTop = array_create(0)
}












