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

#macro CARD_W 200
#macro CARD_H 350
#macro NAME_SCALE .6
#macro COST_SCALE 1
#macro DESCRIPTION_SCALE .4
#macro OFF 10

enum CARD_STATE
{
	STATIC,
	HOVERED,
	HELD
}

function CardRenderer(id_, scale_ = 1) : GuiElement() constructor
{
	idd = id_
	scale = scale_
	card = ds_map_find_value(oInterface.cardDatabase, id_)
	
	width = CARD_W * scale
	height = CARD_H * scale
	
	surface = surface_create(width * scale, height * scale)
	
	posClamped = false // Forces the surface to render inside the view
	clampedX = xPos
	clampedY = yPos
	
	holdState = CARD_STATE.STATIC
	prevHoldState = holdState
	
	onTop = false
	
	function Draw(singleRedraw = false)
	{
		if (!surface_exists(surface))
			surface = surface_create(width, height)
		
		if (singleRedraw)
		{
			gpu_set_blendmode_ext(bm_src_alpha, bm_one) // Somehow fixes text edges
			draw_set_halign(fa_center)
		}
		
		surface_set_target(surface)
			
			//draw_set_color(c_white)
			//draw_set_alpha(1)
			//draw_rectangle(0,0,width,height,false)
			//draw_set_alpha(1)
			draw_clear(c_dkgray)
		
			var fontSize = font_get_size(fntDescription)
		
			// Name
			draw_set_valign(fa_top)
			draw_text_ext_transformed(	width *.4, height*.05, card.name,
										fontSize + OFF, CARD_W * 2 - PADDING*6,
										scale*NAME_SCALE, scale*NAME_SCALE, 0)	
			// Cost
			draw_set_halign(fa_right)
			draw_set_color(c_aqua)
			draw_text_ext_transformed(	width - PADDING/2, height / PADDING/2, card.cost,
										fontSize + OFF, CARD_W * 2 - PADDING*6,
										scale*COST_SCALE, scale*COST_SCALE, 0)
			// Strength
			draw_set_halign(fa_left)
			draw_set_valign(fa_middle)
			draw_set_color(c_red)
			draw_text_ext_transformed(	width*.1, height*.9, card.strength,
										fontSize + OFF, CARD_W * 2 - PADDING*6,
										scale*COST_SCALE, scale*COST_SCALE, 0)
			
			// Description
			draw_set_halign(fa_center)
			draw_set_color(c_white)
			draw_text_ext_transformed(	width*.45, height*.75, card.description,
										fontSize + OFF, CARD_W * 2 * .9,
										scale*DESCRIPTION_SCALE, scale*DESCRIPTION_SCALE, 0)
			// Type
			draw_text_ext_transformed(	width*.5, height*.6, card.type,
										fontSize + OFF, CARD_W * 2 - PADDING,
										scale*DESCRIPTION_SCALE, scale*DESCRIPTION_SCALE, 0)
			// IDs
			draw_text_ext_transformed(	width*.85, height*.6, card.expNumber,
										fontSize + OFF, CARD_W * 2 - PADDING,
										scale*DESCRIPTION_SCALE, scale*DESCRIPTION_SCALE, 0)
			draw_text_ext_transformed(	width*.15, height*.6, card.expansion,
										fontSize + OFF, CARD_W * 2 - PADDING,
										scale*DESCRIPTION_SCALE, scale*DESCRIPTION_SCALE, 0)
			// Author
			draw_text_ext_transformed(	width*.9, height*.75, card.author,
										fontSize + OFF, CARD_W * 2 - PADDING,
										scale*DESCRIPTION_SCALE, scale*DESCRIPTION_SCALE, 90)
			// Rarity
			draw_set_color(c_yellow)
			draw_text_ext_transformed(	width*.6, height*.9, card.rarity,
										fontSize + OFF, CARD_W * 2 - PADDING,
										scale*NAME_SCALE, scale*NAME_SCALE, 0)
										
			draw_set_color(c_white)
			
		surface_reset_target()
		
		if (singleRedraw)
			gpu_set_blendmode_ext(bm_src_alpha, bm_inv_src_alpha)
	}
	
	function Update()
	{
		UpdatePosition(posClamped)
		
		if (point_in_rectangle(mX,mY,xPos-width/2/scale,yPos-height/2/scale,xPos+width/2/scale,yPos+height/2/scale))
		{
			holdState = CARD_STATE.HOVERED
			
			//Change curor type
			if (oInterface.cursorImage != cr_handpoint)
				oInterface.cursorImage = cr_handpoint
			
			// Hover
			draw_set_color(c_white)
			draw_set_alpha(.5)
			draw_rectangle(clampedX-width/2,clampedY-height/2,clampedX+width/2,clampedY+height/2,false)
			draw_set_alpha(1)
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
					ChangeScale(1.6)
					posClamped = true
					break
					
				case CARD_STATE.STATIC:
					onTop = false
					ChangeScale(1)
					posClamped = false
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
		width = CARD_W * scale
		height = CARD_H * scale
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

function RedrawCards()
{
	gpu_set_blendmode_ext(bm_src_alpha, bm_one) // Somehow fixes text edges
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	for (var i = 0; i < array_length(oInterface.cardRenders); i++)
	{
		cardRenders[i].Draw()
	}
	gpu_set_blendmode_ext(bm_src_alpha, bm_inv_src_alpha)
}

function DrawCardSurfaces()
{
	var drawOnTop = []
	for (var i = 0; i < array_length(oInterface.cardRenders); i++)
	{
		var cardRenderer = oInterface.cardRenders[i]
		
		if (cardRenderer.onTop) array_push(drawOnTop, cardRenderer)
		else draw_surface(cardRenderer.surface, cardRenderer.clampedX-cardRenderer.width/2, cardRenderer.clampedY-cardRenderer.height/2)
	}
	
	for (var i = 0; i < array_length(drawOnTop); i++)
	{
		var cardRenderer = drawOnTop[i]
		
		draw_surface(cardRenderer.surface, cardRenderer.clampedX-cardRenderer.width/2, cardRenderer.clampedY-cardRenderer.height/2)
	}
}

function CSVsToArray()
{
	ds_map_clear(oInterface.cardDatabase)
	array_resize(oInterface.sortingArray, 0)
	for (var i = 0; i < array_length(oInterface.cardRenders); i++)
	{
		oInterface.cardRenders[i].Free()
		delete oInterface.cardRenders[i]
	}
	array_resize(oInterface.cardRenders, 0)
	
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
			show_debug_message(id_)
		}
	}
	
	oInterface.sheetStateText = $"{array_length(oInterface.sortingArray)} cards loaded"
}