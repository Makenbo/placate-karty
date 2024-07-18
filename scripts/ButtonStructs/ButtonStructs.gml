enum BUTTON		//Button types
{
	boolOut,
	funcOut
}

#macro mX device_mouse_x_to_gui(0)
#macro mY device_mouse_y_to_gui(0)
#macro GUI_W display_get_gui_width()
#macro GUI_H display_get_gui_height()
#macro WINDOW_SCALAR GUI_W/1366 // Dividing by the default width

function GuiElement()
{
	xPos = GUI_W/2
	yPos = GUI_H/2
	height = 50
	width = 80
	fontSize = font_get_size(fntDescription) + PADDING
}

enum ALIGN
{
	MIDDLE,
	LEFT,
	RIGHT
}

enum ELEMENT_DIR
{
	VERTICAL,
	HORIZONTAL
}

function ElementsSetPositions(elements, multX = .5, multY = .2, dir = ELEMENT_DIR.VERTICAL, alignType = ALIGN.MIDDLE, maxPerLine = -1, maxTotal = infinity, padding = PADDING)
{
	var elementAmount = min(maxTotal, array_length(elements))
	var lineLen = elementAmount
	if (maxPerLine != -1) lineLen = maxPerLine
	
	for (var j = 0; j < ceil(elementAmount / lineLen); j++)
	{
		for (var i = 0; i < lineLen; i++)
		{
			var arrPos = i + lineLen*j
			if (arrPos >= array_length(elements)) break
			
			var xx = GUI_W
			var yy = GUI_H
		
			xx *= multX
			yy *= multY
			
			elements[arrPos].RecalculateSize()
		
			switch (alignType)
			{
				case ALIGN.MIDDLE:
					xx -= elements[arrPos].width / 2
					yy -= elements[arrPos].height / 2
					break
				
				case ALIGN.LEFT:
					break
			}
		
			switch (dir)
			{
				case ELEMENT_DIR.VERTICAL:
					yy += (elements[arrPos].height + padding) * i
					xx += (elements[arrPos].width + padding) * j
					break
				
				case ELEMENT_DIR.HORIZONTAL:
					xx += (elements[arrPos].width + padding) * i
					yy += (elements[arrPos].height + padding) * j
					break
			}
		
			elements[arrPos].xPos = floor(xx)
			elements[arrPos].yPos = floor(yy)
		}
	}
}

#macro UNCLICKABLE_ALPHA .5

function Button(name_ = "temp", func_ = function(){}, description_ = "", clickable_ = true, width_ = -1, color_ = c_yellow) : GuiElement() constructor
{
	variable = false
	name = name_
	description = description_
	height = fontSize
	if (width_ == -1) width = string_width(name) + PADDING
	else width = width_
	func = func_
	clickable = clickable_
	alpha = clickable ? 1 : UNCLICKABLE_ALPHA
	color = color_
	
	static Draw = function()
	{
		var yPosShifted = yPos// + oController.guiScrollOffset
		
		if (yPosShifted > -height and yPosShifted < GUI_H)
		{
			//// Draw general button
			//draw_set_color(c_black)
			//draw_rectangle(round(xPos),round(yPosShifted),round(xPos+width),round(yPosShifted+height),false)
		
			alpha = clickable ? 1 : UNCLICKABLE_ALPHA
			draw_set_alpha(alpha)
			
			draw_set_color(color)
			draw_rectangle(round(xPos),round(yPosShifted),round(xPos+width),round(yPosShifted+height),true)
			
			var centerX = xPos + (width * .5)
			var centerY = yPosShifted + (height * .5)
			draw_set_color(c_white)
			draw_text(centerX,centerY,name)
		}
	}
	
	static Update = function(index,surf)
	{
		//var yPosShifted = yPos //+ oController.guiScrollOffset
		
		if (point_in_rectangle(mX,mY,xPos,yPos,xPos+width,yPos+height) and clickable)
		{
			//Change curor type
			if (oInterface.cursorImage != cr_handpoint)
				oInterface.cursorImage = cr_handpoint
			
			//Hover indicator
			draw_set_alpha(.2)
			draw_rectangle(xPos,yPos,xPos+width,yPos+height,false)
			draw_set_alpha(1)
			
			//Draw button description
			draw_set_halign(fa_right)
			draw_set_valign(fa_bottom)
			draw_text(GUI_W - PADDING, GUI_H - PADDING, description)
			draw_set_valign(fa_middle)
				
			if (INTERACT_PRESS)
			{
				func()
				
				//Redraw the updated button on the surface
				//surface_set_target(surf)
				//self.Draw()
				//surface_reset_target()
			}
		}
	}
	
	function RecalculateSize()
	{
	}
}

enum INTERACTION_AREA
{
	DECK,
	BOARD,
	HAND
}

function InteractableArea(xMult_, yMult_, height_, width_, interaction_, text_ = "Template", textScale_ = 1, interactable_ = true, isVisible_ = true) : GuiElement() constructor
{
	xMult = xMult_
	yMult = yMult_
	xPos = GUI_W * xMult
	yPos = GUI_H * yMult
	height = height_
	width = width_
	text = text_
	textScale = textScale_
	interactable = interactable_
	interaction = interaction_
	isVisible = isVisible_
	
	function Draw()
	{
		if (isVisible)
		{
			// Update position
			xPos = GUI_W * xMult
			yPos = GUI_H * yMult
			
			// Draw thyself!
			var drawX = xPos - width/2
			var drawY = yPos - height/2
		
			draw_set_alpha(.15)
			draw_set_color(c_white)
			draw_rectangle(round(xPos-width/2),round(yPos-height/2),round(xPos+width/2),round(yPos+height/2),false)

			draw_set_alpha(1)
			draw_text(xPos,yPos,text)
		}
	}
	
	function Update()
	{
		var drawX = xPos - width/2
		var drawY = yPos - height/2
		if (point_in_rectangle(mX,mY,drawX,drawY,drawX+width,drawY+height) and interactable)
		{
			//Change curor type
			if (interaction == INTERACTION_AREA.DECK and global.holdingCard == false)
				if (oInterface.cursorImage != cr_handpoint)
					oInterface.cursorImage = cr_handpoint
			
			if (isVisible)
			{
				//Hover indicator
				draw_set_alpha(.2)
				draw_rectangle(drawX,drawY,drawX+width,drawY+height,false)
				draw_set_alpha(1)
			}
			
			// Big interaction switches
			if (INTERACT_PRESS)
			{
				// Draw a card
				if (interaction == INTERACTION_AREA.DECK and global.holdingCard == false and array_length(oInterface.myDeck) > 0)
				{
					var card = array_pop(oInterface.myDeck).card
					var cardID = array_length(oInterface.friendlyHand)
					array_push(	oInterface.friendlyHand,
								new CardRenderer(card.id_, CARD_INTERACTION.IN_HAND, CARD_DRAW_TYPE.FULL, CARD_HAND_SCALE, cardID))
					DrawHand()
					ClientDrewCard()
				}
			}
		}
	}
	
	function RecalculateSize()
	{
	}
}

/*
function Slider(minNum_,maxNum_,length_,name_ = "temp",description_ = "Description not available",isInt_ = false) : GuiElement() constructor
{
	variable = 0
	minNum = minNum_
	maxNum = maxNum_
	isInt = isInt_
	
	name = name_
	description = description_
	height = fontSize
	width = length_
	
	sliderActive = false
	
	mousePosOnClick = 0
	sliderValOnClick = 0
	
	static Draw = function()
	{
		var yPosShifted = yPos + oDownloader.guiScrollOffset
		
		if (yPosShifted > -height and yPosShifted < GUI_H)
		{
			var sliderX = (variable - minNum) / (maxNum - minNum)
		
			//Clear behind rectangle
			draw_set_color(c_black)
			draw_rectangle(xPos,yPosShifted,xPos+width,yPosShifted+height,false)
		
			//Draw slider position
			draw_set_color(c_white)
			draw_set_alpha(.6)
			draw_rectangle(xPos,yPosShifted,xPos + lerp(0,width,sliderX),yPosShifted+height,false)
			draw_set_alpha(1)
		
			//Draw slider button
			draw_rectangle(xPos,yPosShifted,xPos+width,yPosShifted+height,true)
			var centerX = xPos + (width * .5)
			var centerY = yPosShifted + (height * .5)
			draw_set_color(c_white)
			draw_text(centerX,centerY,name + "   " + string(variable))
		}
	}
	
	static Update = function(index,surf)
	{
		var yPosShifted = yPos + oDownloader.guiScrollOffset
		if (yPosShifted > -height and yPosShifted < GUI_H)
		{
			if (point_in_rectangle(mX,mY,xPos,yPosShifted,xPos+width,yPosShifted+height) or sliderActive)
			{
				//Change curor type
				if (oInterface.cursorImage != cr_size_we)
					oInterface.cursorImage = cr_size_we
				
				//Hover indicator
				draw_set_alpha(.2)
				draw_rectangle(xPos,yPosShifted,xPos+width,yPosShifted+height,false)
				draw_set_alpha(1)
			
				//Draw button description
				draw_text(GUI_W * .85, GUI_H * .85, description)
			
				if (keyboard_check_pressed(vk_backspace))
				{
					variable = variableDef
					UpdateVariable(index)
					surface_set_target(surf)
					self.Draw()
					surface_reset_target()
				}
			
				if (INTERACT_PRESS)
				{
					sliderActive = true
					mousePosOnClick = mX
					sliderValOnClick = variable
				}
				
				if (sliderActive)
				{
					var mXclamped = mX
					if (keyboard_check(vk_shift)) mXclamped = lerp(mX,mousePosOnClick,.95)
					mXclamped = clamp(mXclamped,xPos,xPos+width)
					var newPos = (mXclamped - xPos) / width
				
					variable = lerp(minNum,maxNum,newPos)
					if (isInt or keyboard_check(vk_control)) variable = round(variable)
					if (CANCEL)
					{
						variable = sliderValOnClick
						sliderActive = false
					}
					UpdateVariable(index)
			
					surface_set_target(surf)
					self.Draw()
					surface_reset_target()
			
					if (INTERACT_RELEASED) sliderActive = false
				}
			}
		}
	}
}

function Display(name_ = "temp", description_ = "Description not available", isInt_ = false) : GuiElement() constructor
{
	variable = 0
	isInt = isInt_
	
	name = name_
	description = description_
	height = fontSize
	width = string_width(name) + 30
	
	static Draw = function()
	{
		var yPosShifted = yPos + oDownloader.guiScrollOffset
		
		if (yPosShifted > -height and yPosShifted < GUI_H)
		{
		
			//Clear behind rectangle
			draw_set_color(c_black)
			draw_rectangle(xPos,yPosShifted,xPos+width,yPosShifted+height,false)
		
			//Draw slider button
			draw_rectangle(xPos,yPosShifted,xPos+width,yPosShifted+height,true)
			var centerX = xPos + (width * .5)
			var centerY = yPosShifted + (height * .5)
			draw_set_color(c_white)
			draw_text(centerX,centerY,name + ": " + string(variable))
		}
	}
	
	static Update = function(index,surf)
	{
		var yPosShifted = yPos + oDownloader.guiScrollOffset
		//variable = oController.inptVars[variableIndex]
		
		UpdateVariable(index)
		surface_set_target(surf)
		self.Draw()
		surface_reset_target()
	}
}