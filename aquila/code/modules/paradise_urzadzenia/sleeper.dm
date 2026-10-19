// Sleepery z Paradise (ParadiseSS13/Paradise, grafiki CC BY-SA 3.0): pacjent widoczny pod półprzezroczystym wiekiem.
// Zamknięty stan to pusta kapsuła; na nią idzie pomniejszony wygląd pacjenta, obręcz i wieko, jak w Paradise.

/obj/machinery/sleeper
	/// AQUILA: nakładki pacjenta, obręczy i wieka, żeby zdjąć tylko je
	var/list/occupant_overlays

/obj/machinery/sleeper/update_icon()
	. = ..()
	if(occupant_overlays)
		cut_overlay(occupant_overlays)
		occupant_overlays = null
	var/base = initial(icon_state)
	if(state_open || !occupant || !("[base]_first_overlay" in icon_states(icon)))
		return
	var/mutable_appearance/body = new(occupant)
	body.plane = FLOAT_PLANE
	body.layer = FLOAT_LAYER
	body.pixel_x = 0
	body.pixel_y = 0
	body.dir = dir
	var/matrix/M = matrix()
	switch(dir)
		if(NORTH)
			M.Turn(180)
			body.dir = SOUTH
		if(EAST)
			M.Turn(270)
			body.pixel_y = -8
		if(WEST)
			M.Turn(90)
			body.pixel_y = -8
	M.Scale(0.66, 0.66)
	body.transform = M
	var/mutable_appearance/rim = mutable_appearance(icon, "[base]_first_overlay")
	var/mutable_appearance/lid = mutable_appearance(icon, "[base]-lid-nodetail", alpha = 140)
	occupant_overlays = list(body, rim, lid)
	add_overlay(occupant_overlays)
