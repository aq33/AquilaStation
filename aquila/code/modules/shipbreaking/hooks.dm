// W strefie złomowania ściany, dźwigary, maszyny i silniki dają złom zamiast zwykłych materiałów.
// Poza strefą wszystko działa po staremu (..()).

/// Jaki złom zostaje po ścianie rozebranej w strefie złomowania
/turf/closed/wall/var/scrap_type = /obj/item/stack/scrap/plating

/turf/closed/wall/break_wall()
	if(!is_shipbreak_area(src))
		return ..()
	new scrap_type(src, sheet_amount)
	if(girder_type)
		return new girder_type(src)

/turf/closed/wall/devastate_wall()
	if(!is_shipbreak_area(src))
		return ..()
	new scrap_type(src, sheet_amount)
	if(girder_type)
		new /obj/item/stack/scrap/framing(src)

// r_wall ma własne devastate_wall bez ..(), więc potrzebuje osobnego nadpisania
/turf/closed/wall/r_wall/devastate_wall()
	if(!is_shipbreak_area(src))
		return ..()
	new scrap_type(src, sheet_amount)
	new /obj/item/stack/scrap/framing(src)

/obj/structure/girder/deconstruct(disassembled = TRUE)
	if(!is_shipbreak_area(src) || (flags_1 & NODECONSTRUCT_1))
		return ..()
	new /obj/item/stack/scrap/framing(loc)
	qdel(src)

// Rozkręcenie przesuniętego dźwigara śrubokrętem (w core żelazo powstaje w środku screwdriver_act)
/obj/structure/girder/screwdriver_act(mob/user, obj/item/tool)
	if(state != GIRDER_DISPLACED || !is_shipbreak_area(src))
		return ..()
	user.visible_message("<span class='warning'>[user] rozbiera [src].</span>",
						"<span class='notice'>Zaczynasz rozbierać [src]...</span>",
						"Słyszysz brzęk i łomot.")
	if(tool.use_tool(src, user, 40, volume=100))
		if(state != GIRDER_DISPLACED)
			return TRUE
		state = GIRDER_DISASSEMBLED
		balloon_alert(user, "Rozbierasz [src].")
		var/obj/item/stack/scrap/framing/framing = new(loc)
		framing.add_fingerprint(user)
		qdel(src)
	return TRUE

/// Dodatkowy złom, który maszyna zostawia po rozbiórce w strefie złomowania
/obj/machinery/var/list/shipbreaking_extra_reward

/obj/machinery/power/port_gen/pacman
	shipbreaking_extra_reward = list(/obj/item/stack/scrap/plasma)

/obj/machinery/power/smes
	shipbreaking_extra_reward = list(/obj/item/stack/scrap/electronics, /obj/item/stack/scrap/core)

/obj/machinery/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1) && is_shipbreak_area(src))
		convert_parts_to_scrap()
	return ..()

/obj/machinery/computer/deconstruct(disassembled = TRUE, mob/user)
	if(!(flags_1 & NODECONSTRUCT_1) && is_shipbreak_area(src))
		convert_parts_to_scrap()
		if(circuit)
			new /obj/item/stack/scrap/electronics(loc)
			QDEL_NULL(circuit)
	return ..()

/// Zamienia części maszyny na złom (część zostaje, jeśli nie ma odpowiednika)
/obj/machinery/proc/convert_parts_to_scrap()
	for(var/extra in shipbreaking_extra_reward)
		new extra(loc)
	for(var/obj/item/part in component_parts)
		var/reward = part.get_shipbreaking_reward()
		if(!reward)
			continue
		component_parts -= part
		new reward(loc)
		qdel(part)

/obj/structure/shuttle/engine/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1) && is_shipbreak_area(src))
		new /obj/item/stack/scrap/core(loc)
	return ..()

/// Martwa konsola z wraku (zamiast konsol lotu, które mogłyby się podpiąć pod nasz statek)
/obj/machinery/computer/shipbreak_wreck
	name = "martwa konsola"
	desc = "Konsola z wraku. Ekran jest ciemny, a w środku została już tylko elektronika na złom."
	icon_screen = "generic"
	icon_keyboard = "generic_key"
	circuit = /obj/item/circuitboard/computer/shipbreak_wreck

/obj/machinery/computer/shipbreak_wreck/ui_interact(mob/user, datum/tgui/ui)
	to_chat(user, "<span class='warning'>[src] nie reaguje. Nadaje się tylko na złom.</span>")

/obj/item/circuitboard/computer/shipbreak_wreck
	name = "spalona płytka konsoli"
	desc = "Płytka z konsoli wraku. Nic już z niej nie będzie poza złomem."
	build_path = /obj/machinery/computer/shipbreak_wreck
