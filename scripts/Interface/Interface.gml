function RedrawElements(elements, transparent = true, clear = false)
{
	surface_set_target(oInterface.guiSurf)
	
		if (clear) draw_clear_alpha(c_white, 0)

		if (transparent) gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha) // Somehow fixes text edges
		else gpu_set_blendmode_ext(bm_src_alpha, bm_one)
		draw_set_halign(fa_center)
		draw_set_valign(fa_middle)
		for (var i = 0; i < array_length(elements); i++)
		{
			elements[i].Draw()
		}
		gpu_set_blendmode_ext(bm_src_alpha, bm_inv_src_alpha)
		draw_set_alpha(1)
	
	surface_reset_target()
}

function UpdateElements(elements)
{
	for (var i = 0; i < array_length(elements); i++)
	{
		elements[i].Update(i, oInterface.guiSurf)
	}
}

function ChangeMenuState(state)
{
	oInterface.uiState = state
	surface_free(oInterface.guiSurf)
}

function UpdateVariable(varIndex)
{
	with (oInterface) inptVars[varIndex] = inputs[varIndex].variable
}