// AQUILA - tablica detektywa z tgstation/tgstation#85609 (stan tg z listopada 2026, z poprawkami #86221, #86454,
// #86516, #90591, #92054 i #98413). Detektyw zakłada na niej sprawy, przypina zdjęcia i kartki jako dowody
// i łączy je nitkami. Różnice względem tg: ikona naszej tablicy ogłoszeń (nboard00-05), attackby zamiast
// item_interaction, deconstruct zamiast atom_deconstruct, nasz /obj/item/wallframe, tablica w szafce detektywa.

#define DETECTIVE_BOARD_MAX_ICON_NOTICES 5
#define DETECTIVE_BOARD_MAX_CASES 8
#define DETECTIVE_BOARD_MAX_EVIDENCE_Y 3500
#define DETECTIVE_BOARD_MAX_EVIDENCE_X 1180

#define EVIDENCE_TYPE_PHOTO "photo"
#define EVIDENCE_TYPE_PAPER "paper"

/obj/structure/detectiveboard
	name = "tablica detektywa"
	desc = "Tablica do łączenia dowodów ze sprawami."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nboard00"
	layer = ABOVE_WINDOW_LAYER
	density = FALSE
	anchored = TRUE
	max_integrity = 150
	/// TRUE, gdy ktoś właśnie przypina dowód (czeka na nazwę i opis)
	var/attaching_evidence = FALSE
	/// Kolory zakładek spraw (klasy BoardTab__<kolor> w DetectiveBoard.scss)
	var/static/list/case_colors = list("czerwony" = "red", "pomarańczowy" = "orange", "żółty" = "yellow", "zielony" = "green", "niebieski" = "blue", "fioletowy" = "violet")
	/// Sprawy na tablicy
	var/list/datum/case/cases = list()
	/// Indeks oglądanej sprawy w cases
	var/current_case = 1
	/// Zdjęcia już wysłane klientom („ref klienta-plik”), żeby ui_data nie słało ich przy każdym odświeżeniu
	var/list/sent_photos = list()

/obj/structure/detectiveboard/Initialize(mapload, ndir, building)
	. = ..()
	if(!mapload || building)
		return
	for(var/obj/item/item in loc)
		if(!istype(item, /obj/item/paper) && !istype(item, /obj/item/photo))
			continue
		if(!length(cases))
			cases += new /datum/case("Sprawa bez nazwy", "red")
		item.forceMove(src)
		var/datum/case/case = cases[current_case]
		case.evidences += new /datum/evidence(item.name, item.desc, item)
		case.notices++
	update_appearance(UPDATE_ICON)

/obj/structure/detectiveboard/Destroy()
	for(var/datum/case/case as anything in cases)
		QDEL_LIST(case.evidences)
	QDEL_LIST(cases)
	return ..()

/obj/structure/detectiveboard/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Przypnij zdjęcie albo kartkę, żeby dodać dowód do bieżącej sprawy.</span>"
	. += "<span class='notice'>Kluczem [user.secondary_click_text()] zdejmiesz tablicę ze ściany.</span>"

/obj/structure/detectiveboard/attackby(obj/item/tool, mob/user, params)
	if(!istype(tool, /obj/item/paper) && !istype(tool, /obj/item/photo))
		return ..()
	if(!length(cases))
		to_chat(user, "<span class='warning'>Na tablicy nie ma żadnej sprawy!</span>")
		return TRUE
	if(attaching_evidence)
		to_chat(user, "<span class='warning'>Już przypinasz dowód!</span>")
		return TRUE

	attaching_evidence = TRUE
	var/evidence_name = tgui_input_text(user, "Podaj nazwę dowodu", "Tablica detektywa", max_length = MAX_NAME_LEN)
	if(!evidence_name)
		evidence_name = tool.name
	var/evidence_desc = tgui_input_text(user, "Podaj opis dowodu", "Tablica detektywa", max_length = MAX_MESSAGE_LEN)
	if(!evidence_desc)
		evidence_desc = tool.desc

	if(QDELETED(src) || !length(cases) || !user.canUseTopic(src, BE_CLOSE) || !user.transferItemToLoc(tool, src))
		attaching_evidence = FALSE
		return TRUE

	current_case = clamp(current_case, 1, length(cases))
	var/datum/case/case = cases[current_case]
	case.notices++
	case.evidences += new /datum/evidence(evidence_name, evidence_desc, tool)
	to_chat(user, "<span class='notice'>Przypinasz [tool] do tablicy detektywa.</span>")
	attaching_evidence = FALSE
	update_appearance(UPDATE_ICON)
	return TRUE

/obj/structure/detectiveboard/wrench_act_secondary(mob/living/user, obj/item/tool)
	. = TRUE
	balloon_alert(user, "odkręcanie...")
	tool.play_tool_sound(src)
	if(!tool.use_tool(src, user, 6 SECONDS))
		return
	playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
	balloon_alert(user, "odkręcona")
	deconstruct(TRUE)

/obj/structure/detectiveboard/ui_state(mob/user)
	return GLOB.physical_state

/obj/structure/detectiveboard/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DetectiveBoard", name)
		ui.open()

/obj/structure/detectiveboard/ui_data(mob/user)
	var/list/data = list()
	var/list/data_cases = list()
	for(var/datum/case/case as anything in cases)
		var/list/data_case = list("ref" = REF(case), "name" = case.name, "color" = case.color)
		var/list/data_evidences = list()
		for(var/datum/evidence/evidence as anything in case.evidences)
			var/list/data_evidence = list("ref" = REF(evidence), "name" = evidence.name, "type" = evidence.evidence_type, "description" = evidence.description, "x" = evidence.x, "y" = evidence.y)
			var/list/data_connections = list()
			for(var/datum/evidence/connection as anything in evidence.connections)
				data_connections += REF(connection)
			data_evidence["connections"] = data_connections
			switch(evidence.evidence_type)
				if(EVIDENCE_TYPE_PHOTO)
					var/obj/item/photo/photo = evidence.item
					var/tmp_picture_name = "evidence_photo[REF(photo)].png"
					var/sent_key = "[REF(user.client)]-[tmp_picture_name]"
					if(photo.picture?.picture_image && !sent_photos[sent_key])
						user << browse_rsc(photo.picture.picture_image, tmp_picture_name)
						sent_photos[sent_key] = TRUE
					data_evidence["photo_url"] = tmp_picture_name
				if(EVIDENCE_TYPE_PAPER)
					var/obj/item/paper/paper = evidence.item
					data_evidence["text"] = ""
					if(LAZYLEN(paper.raw_text_inputs))
						var/datum/paper_input/first_input = paper.raw_text_inputs[1]
						data_evidence["text"] = first_input.raw_text // okno pokazuje to jako zwykły tekst
			data_evidences += list(data_evidence)
		data_case["evidences"] = data_evidences
		var/list/connections = list()
		for(var/datum/evidence/evidence as anything in case.evidences)
			for(var/datum/evidence/connection as anything in evidence.connections)
				var/list/from_pos = get_pin_position(evidence)
				var/list/to_pos = get_pin_position(connection)
				var/found_in_connections = FALSE
				for(var/list/con in connections)
					if(con["from"]["x"] == to_pos["x"] && con["from"]["y"] == to_pos["y"] && con["to"]["x"] == from_pos["x"] && con["to"]["y"] == from_pos["y"])
						found_in_connections = TRUE
				if(!found_in_connections)
					connections += list(list("color" = "red", "from" = from_pos, "to" = to_pos))
		data_case["connections"] = connections
		data_cases += list(data_case)

	data["cases"] = data_cases
	data["current_case"] = current_case
	return data

/obj/structure/detectiveboard/proc/get_pin_position(datum/evidence/evidence)
	return list("x" = evidence.x + 15, "y" = evidence.y + 15)

/obj/structure/detectiveboard/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	switch(action)
		if("add_case")
			if(length(cases) >= DETECTIVE_BOARD_MAX_CASES)
				return FALSE
			var/new_case = tgui_input_text(user, "Podaj nazwę sprawy", "Tablica detektywa", max_length = MAX_NAME_LEN)
			if(!new_case)
				return FALSE
			var/case_color = tgui_input_list(user, "Wybierz kolor sprawy", "Tablica detektywa", case_colors)
			if(!case_color || length(cases) >= DETECTIVE_BOARD_MAX_CASES)
				return FALSE
			cases += new /datum/case(new_case, case_colors[case_color])
			current_case = length(cases)
			update_appearance(UPDATE_ICON)
			return TRUE
		if("set_case")
			var/index = text2num("[params["case"]]")
			if(index && index >= 1 && index <= length(cases))
				current_case = index
				update_appearance(UPDATE_ICON)
				return TRUE
		if("remove_case")
			var/datum/case/case = locate(params["case_ref"]) in cases
			if(!case)
				return FALSE
			for(var/datum/evidence/evidence as anything in case.evidences)
				if(evidence.item?.loc == src)
					evidence.item.forceMove(drop_location())
			QDEL_LIST(case.evidences)
			cases -= case
			qdel(case)
			current_case = clamp(current_case, 1, max(length(cases), 1))
			update_appearance(UPDATE_ICON)
			return TRUE
		if("rename_case")
			var/datum/case/case = locate(params["case_ref"]) in cases
			if(!case)
				return FALSE
			var/new_name = tgui_input_text(user, "Podaj nową nazwę sprawy", "Tablica detektywa", case.name, max_length = MAX_NAME_LEN)
			if(new_name && !QDELETED(case))
				case.name = new_name
				return TRUE
		if("look_evidence")
			var/datum/case/case = locate(params["case_ref"]) in cases
			var/datum/evidence/evidence = case && (locate(params["evidence_ref"]) in case.evidences)
			if(!evidence)
				return FALSE
			if(evidence.evidence_type == EVIDENCE_TYPE_PHOTO)
				var/obj/item/photo/photo = evidence.item
				photo.show(user)
				return TRUE
			var/obj/item/paper/paper = evidence.item
			var/paper_text = ""
			for(var/datum/paper_input/text_input as anything in paper.raw_text_inputs)
				paper_text += html_encode(text_input.raw_text)
			user << browse("<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>[html_encode(paper.name)]</title></head>" \
				+ "<body style='overflow:hidden;padding:5px'>[paper_text]</body></html>", "window=photo_showing;size=480x608")
			onclose(user, "photo_showing")
		if("remove_evidence")
			if(!length(cases))
				return FALSE
			var/datum/case/case = cases[current_case]
			var/datum/evidence/evidence = locate(params["evidence_ref"]) in case.evidences
			if(!evidence)
				return FALSE
			var/obj/item/item = evidence.item
			if(!istype(item) || item.loc != src)
				return FALSE
			remove_item(item, user)
			case.notices = max(case.notices - 1, 0)
			case.evidences -= evidence
			qdel(evidence)
			update_appearance(UPDATE_ICON)
			return TRUE
		if("set_evidence_cords")
			var/datum/case/case = locate(params["case_ref"]) in cases
			var/datum/evidence/evidence = case && (locate(params["evidence_ref"]) in case.evidences)
			if(evidence)
				evidence.x = clamp(text2num("[params["rel_x"]]"), 0, DETECTIVE_BOARD_MAX_EVIDENCE_X)
				evidence.y = clamp(text2num("[params["rel_y"]]"), 0, DETECTIVE_BOARD_MAX_EVIDENCE_Y)
			return TRUE
		if("add_connection")
			if(!length(cases))
				return FALSE
			var/datum/case/case = cases[current_case]
			var/datum/evidence/from_evidence = locate(params["from_ref"]) in case.evidences
			var/datum/evidence/to_evidence = locate(params["to_ref"]) in case.evidences
			if(from_evidence && to_evidence && from_evidence != to_evidence)
				from_evidence.connections |= to_evidence
				to_evidence.connections |= from_evidence
			return TRUE
	return FALSE

/obj/structure/detectiveboard/update_icon_state()
	var/notices = 0
	if(length(cases))
		var/datum/case/case = cases[clamp(current_case, 1, length(cases))]
		notices = clamp(case.notices, 0, DETECTIVE_BOARD_MAX_ICON_NOTICES)
	icon_state = "nboard0[notices]"
	return ..()

/// Zdejmuje przedmiot z tablicy i podaje go do ręki, jeśli ktoś go zdejmuje
/obj/structure/detectiveboard/proc/remove_item(obj/item/item, mob/user)
	item.forceMove(drop_location())
	if(user)
		user.put_in_hands(item)
		balloon_alert(user, "zdjęto z tablicy")

/obj/structure/detectiveboard/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			new /obj/item/wallframe/detectiveboard(loc)
		else
			new /obj/item/stack/sheet/mineral/wood(loc)
	for(var/obj/item/content in contents)
		content.forceMove(loc)
	qdel(src)

/obj/item/wallframe/detectiveboard
	name = "tablica detektywa"
	desc = "Tablica do łączenia dowodów ze sprawami. Zamontuj ją na ścianie."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nboard00"
	materials = list() // u nas nie ma materiału drewna
	resistance_flags = FLAMMABLE
	result_path = /obj/structure/detectiveboard
	pixel_shift = -32

/// Dowód przypięty do tablicy: zdjęcie albo kartka
/datum/evidence
	var/name = "Brak"
	var/description = "Brak opisu"
	var/evidence_type = "none"
	var/x = 0
	var/y = 0
	/// Dowody połączone nitką z tym
	var/list/datum/evidence/connections = list()
	var/obj/item/item = null

/datum/evidence/New(param_name, param_desc, obj/item/param_item)
	name = param_name
	description = param_desc
	item = param_item
	evidence_type = istype(param_item, /obj/item/photo) ? EVIDENCE_TYPE_PHOTO : EVIDENCE_TYPE_PAPER

/datum/evidence/Destroy(force)
	for(var/datum/evidence/connection as anything in connections)
		connection.connections -= src
	connections.Cut()
	item = null
	return ..()

/// Sprawa na tablicy: nazwa, kolor zakładki i dowody
/datum/case
	var/notices = 0
	var/name = ""
	var/color = "red"
	var/list/datum/evidence/evidences = list()

/datum/case/New(param_name, param_color)
	name = param_name
	color = param_color

// Tablica jest w skrzyni kryminalistycznej i w szafce detektywa (w tg stoi na mapach)
/datum/supply_pack/security/forensics/New()
	. = ..()
	contains += /obj/item/wallframe/detectiveboard

/obj/structure/closet/secure_closet/detective/PopulateContents()
	..()
	new /obj/item/wallframe/detectiveboard(src)

#undef EVIDENCE_TYPE_PHOTO
#undef EVIDENCE_TYPE_PAPER

#undef DETECTIVE_BOARD_MAX_EVIDENCE_Y
#undef DETECTIVE_BOARD_MAX_EVIDENCE_X
#undef DETECTIVE_BOARD_MAX_ICON_NOTICES
#undef DETECTIVE_BOARD_MAX_CASES
