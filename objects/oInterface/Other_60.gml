ds_map_add(loadedSprites, async_load[? "filename"], async_load[? "id"])
//show_debug_message($"loaded {async_load[? "filename"]}")
alarm[0] = 1 // Rerender scene in the next frame, to avoid duplicate rerendering in a single frame