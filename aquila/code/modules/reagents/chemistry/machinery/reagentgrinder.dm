// Mielarka jak w Paradise: przy pracy zostaje nowy sprite (stary "juicer1_animated" nie pasuje do resprite'u),
// a mielenie trzęsie maszyną skokami w obu osiach.

/obj/machinery/reagentgrinder/update_icon()
	. = ..()
	if(operating)
		icon_state = beaker ? "juicer1" : "juicer0"

/obj/machinery/reagentgrinder/operate_for(time, silent = FALSE, juicing = FALSE)
	var/old_pixel_x = pixel_x
	var/old_pixel_y = pixel_y
	. = ..()
	if(juicing)
		return
	// Jeden skok i powrót trwają 2 decysekundy, stop_shaking() przerywa animację po czasie pracy
	animate(src, pixel_x = old_pixel_x + pick(-3, -2, 2, 3), pixel_y = old_pixel_y + pick(-3, -2, 2, 3), time = 1, loop = max(1, round(time / speed / 2)), easing = JUMP_EASING)
	animate(pixel_x = old_pixel_x, pixel_y = old_pixel_y, time = 1, easing = JUMP_EASING)
