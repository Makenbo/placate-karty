// Testing

//draw_set_font(titleText)
//draw_text(CENTER_X, CENTER_Y, "Title")

surface_set_target(temp)
draw_clear_alpha(c_white, 0)
draw_set_font(descriptionText)
draw_text(CENTER_X, CENTER_Y, statusText)
surface_reset_target()

draw_surface(temp,0,0)
