enum BUTTON		//Button types
{
	boolOut,
	funcOut
}

#macro mX device_mouse_x_to_gui(0)
#macro mY device_mouse_y_to_gui(0)
#macro GUI_W display_get_gui_width()
#macro GUI_H display_get_gui_height()

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

function ElementsSetPositions(elements, multX = .5, multY = .5, dir = ELEMENT_DIR.VERTICAL, alignType = ALIGN.MIDDLE, maxPerLine = -1, padding = PADDING)
{
	var elementAmount = array_length(elements)
	var lineLen = elementAmount
	if (maxPerLine != -1) lineLen = maxPerLine
	
	for (var j = 0; j < ceil(elementAmount / lineLen); j++)
	{
		for (var i = 0; i < lineLen; i++)
		{
			var xx = GUI_W
			var yy = GUI_H
		
			xx *= multX
			yy *= multY
		
			switch (alignType)
			{
				case ALIGN.MIDDLE:
					xx -= elements[i].width / 2
					yy -= elements[i].height / 2
					break
				
				case ALIGN.LEFT:
					break
			}
		
			switch (dir)
			{
				case ELEMENT_DIR.VERTICAL:
					yy += (elements[i].height + padding) * i
					xx += (elements[i].width + padding) * j
					break
				
				case ELEMENT_DIR.HORIZONTAL:
					xx += (elements[i].width + padding) * i
					yy += (elements[i].height + padding) * j
					break
			}
		
			elements[i + lineLen*j].xPos = xx
			elements[i + lineLen*j].yPos = yy
		}
	}
}

function Button(name_ = "temp", description_ = "Temp description", func_ = function(){}, width_ = -1) : GuiElement() constructor
{
	variable = false
	name = name_
	description = description_
	height = fontSize
	if (width_ == -1) width = string_width(name) + PADDING
	else width = width_
	func = func_
	
	static Draw = function()
	{
		var yPosShifted = yPos// + oController.guiScrollOffset
		
		if (yPosShifted > -height and yPosShifted < GUI_H)
		{
			//Draw general button
			//draw_set_color(c_black)
			//draw_rectangle(round(xPos),round(yPosShifted),round(xPos+width),round(yPosShifted+height),false)
		
			draw_set_color(c_yellow)
			draw_rectangle(round(xPos),round(yPosShifted),round(xPos+width),round(yPosShifted+height),true)
			
			var centerX = xPos + (width * .5)
			var centerY = yPosShifted + (height * .5)
			draw_set_color(c_white)
			draw_text(centerX,centerY,name)
		}
	}
	
	static Update = function(index,surf)
	{
		var yPosShifted = yPos //+ oController.guiScrollOffset
		
		if (yPosShifted > -height and yPosShifted < GUI_H)
		{
			if (point_in_rectangle(mX,mY,xPos,yPosShifted,xPos+width,yPosShifted+height))
			{
				//Change curor type
				if (oInterface.cursorImage != cr_handpoint)
					oInterface.cursorImage = cr_handpoint
			
				//Hover indicator
				draw_set_alpha(.2)
				draw_rectangle(xPos,yPosShifted,xPos+width,yPosShifted+height,false)
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
	}
}

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