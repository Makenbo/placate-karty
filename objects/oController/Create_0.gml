// Constants
#macro CENTER_X room_width/2
#macro CENTER_Y room_height/2

draw_set_halign(fa_center)
draw_set_valign(fa_middle)

titleText = font_add("external-fonts/arial.ttf", 100, false, false, 32, 128)
descriptionText = font_add("external-fonts/arial.ttf", 16, false, false, 32, 128)

getCSV = http_get_file(	"https://docs.google.com/spreadsheets/d/e/2PACX-1vQwi1CtQE_yw1czUlHT9h8kRwrnavTnd71oB48ziSsDKDkQGpHdOGv66ZTz0zGKOniJqDhpKu4gXCQi/pub?gid=316426278&single=true&output=csv",
						"test.csv")
statusText = "Downloading file"
loadedData = 0