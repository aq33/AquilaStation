// AQUILA - Mechanik: flatpacker, port tgstation/tgstation#83836 (code/game/machinery/flatpacker.dm) na nasze materiały i części.
// Różnice względem tg: paczkę robi z włożonej płytki albo ze schematu z bazy techwebu (wtedy sam drukuje płytkę),
// tier części ogranicza manipulator (u nas zamiast serwomechanizmu), maszyny z czarnej listy tylko po emagu.

/// Arkusze żelaza na ramę maszyny albo komputera
#define FLATPACK_FRAME_IRON (MINERAL_MATERIAL_AMOUNT * 5)
/// Odcinki kabla na okablowanie ramy
#define FLATPACK_FRAME_CABLE 5
/// Szyby panelu komputera
#define FLATPACK_COMPUTER_GLASS 2

/obj/machinery/flatpacker
	name = "flatpacker"
	desc = "Pakuje maszyny w płaskie paczki z płytki albo ze schematu z bazy sieci badań. Zużywa żelazo, szkło i materiały części."
	icon = 'aquila/icons/obj/mechanic/flatpacker.dmi'
	icon_state = "flatpacker"
	base_icon_state = "flatpacker"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 1000
	layer = BELOW_OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/flatpacker

	/// Trwa pakowanie
	var/busy = FALSE
	/// Mnożnik zużycia materiałów, lasery go obniżają
	var/creation_efficiency = 2
	/// Najwyższy tier części, jaki ten flatpacker zapakuje (z manipulatora)
	var/max_part_tier = 1
	/// Czas pakowania
	var/flatpack_time = 4.5 SECONDS
	/// Sieć badań z bazą schematów
	var/datum/techweb/stored_research
	/// Włożona płytka (ma pierwszeństwo przed schematem)
	var/obj/item/circuitboard/inserted_board
	/// Klucz wybranego schematu z bazy
	var/selected_key
	/// Części włożone ręcznie do bieżącej paczki
	var/list/obj/item/flatpacked_components = list()

	// Wyliczone dla bieżącego źródła (płytki albo schematu), patrz recalculate()
	/// Nazwa maszyny
	var/source_name
	/// Typ płytki, który trafi do paczki
	var/source_board_type
	/// Maszyna, którą płytka zbuduje
	var/source_build_path
	/// Maszyna z czarnej listy
	var/source_illegal = FALSE
	/// Części robione z materiałów: typ = ilość
	var/list/auto_parts = list()
	/// Części do włożenia ręcznie: typ = ilość
	var/list/manual_parts = list()
	/// Materiały na całą paczkę przed mnożnikiem
	var/list/needed_mats = list()
	/// Najwyższy tier części w paczce
	var/print_tier = 1

/obj/machinery/flatpacker/Initialize(mapload)
	AddComponent(/datum/component/material_container, SSmaterials.get_material_types(MAT_CATEGORY_RIGID) + /datum/material/bluespace, 0, TRUE, /obj/item/stack)
	. = ..()
	stored_research = SSresearch.science_tech

/obj/machinery/flatpacker/Destroy()
	QDEL_NULL(inserted_board)
	QDEL_LIST(flatpacked_components)
	stored_research = null
	return ..()

/obj/machinery/flatpacker/on_deconstruction()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials?.retrieve_all()
	inserted_board?.forceMove(drop_location())
	drop_manual_parts()
	return ..()

/obj/machinery/flatpacker/RefreshParts()
	var/mat_capacity = 0
	for(var/obj/item/stock_parts/matter_bin/bin in component_parts)
		mat_capacity += bin.rating * 25 * MINERAL_MATERIAL_AMOUNT
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	if(materials)
		materials.max_amount = mat_capacity

	max_part_tier = 1
	for(var/obj/item/stock_parts/manipulator/manipulator in component_parts)
		max_part_tier = max(max_part_tier, manipulator.rating)
	flatpack_time = initial(flatpack_time) - max_part_tier * 0.5 SECONDS

	var/efficiency = initial(creation_efficiency)
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		efficiency -= laser.rating * 0.2
	creation_efficiency = max(1.2, round(efficiency, 0.1))

/obj/machinery/flatpacker/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !isobserver(user))
		return
	. += "<span class='notice'>Wyświetlacz stanu pokazuje: pakuje części do <b>tieru [max_part_tier]</b>, zużycie materiałów <b>[creation_efficiency * 100]%</b>.</span>"
	if(inserted_board)
		. += "<span class='notice'>Płytkę wyjmuje się Ctrl+kliknięciem.</span>"
	if(length(manual_parts))
		. += "<span class='warning'>Przed pakowaniem trzeba włożyć ręcznie:</span>"
		for(var/part_path in manual_parts)
			var/obj/item/part = part_path
			. += "<span class='warning'>[initial(part.name)]: [component_count(part_path)]/[manual_parts[part_path]]</span>"

/obj/machinery/flatpacker/update_icon_state()
	icon_state = panel_open ? "[base_icon_state]_o" : base_icon_state
	return ..()

/obj/machinery/flatpacker/update_overlays()
	. = ..()
	if(inserted_board)
		. += mutable_appearance(icon, "[base_icon_state]_c")

/obj/machinery/flatpacker/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	playsound(src, "sparks", 75, TRUE)
	to_chat(user, "<span class='warning'>Wyłączasz blokady [src].</span>")
	return TRUE

/// Liczba ręcznie włożonych części danego typu
/obj/machinery/flatpacker/proc/component_count(part_path)
	. = 0
	for(var/obj/item/component as anything in flatpacked_components)
		if(component.type == part_path)
			.++

/// Wybrany schemat, jeśli nadal jest w bazie
/obj/machinery/flatpacker/proc/selected_schematic()
	if(!selected_key || !stored_research)
		return null
	return stored_research.machine_schematics[selected_key]

/// Przelicza części, koszt i tier dla bieżącego źródła paczki
/obj/machinery/flatpacker/proc/recalculate()
	source_name = null
	source_board_type = null
	source_build_path = null
	source_illegal = FALSE
	auto_parts = list()
	manual_parts = list()
	needed_mats = list()
	print_tier = 1

	var/list/parts = list()
	var/from_schematic = FALSE
	if(inserted_board)
		source_board_type = inserted_board.type
		source_build_path = inserted_board.build_path
		var/obj/item/circuitboard/machine/machine_board = inserted_board
		if(istype(machine_board))
			for(var/part_path in machine_board.req_components)
				var/real_path = LAZYACCESS(machine_board.def_components, part_path) || part_path
				parts[real_path] += machine_board.req_components[part_path]
	else
		var/datum/machine_schematic/schematic = selected_schematic()
		if(!schematic)
			selected_key = null
			return
		from_schematic = TRUE
		source_board_type = schematic.board_type
		source_build_path = schematic.build_path
		parts = schematic.part_types.Copy()

	if(!source_build_path)
		return
	var/obj/machinery/target = source_build_path
	source_name = initial(target.name)
	source_illegal = mechanic_is_blacklisted(source_build_path)
	print_tier = mechanic_parts_tier(parts)

	for(var/part_path in parts)
		var/list/unit_cost = mechanic_unit_cost(part_path)
		if(!length(unit_cost))
			manual_parts[part_path] = parts[part_path]
			continue
		auto_parts[part_path] = parts[part_path]
		add_cost(unit_cost, parts[part_path])

	// Rama, kable i (dla komputera) szyby; płytkę ze schematu flatpacker drukuje sam
	add_cost(list(getmaterialref(/datum/material/iron) = FLATPACK_FRAME_IRON))
	add_cost(mechanic_unit_cost(/obj/item/stack/cable_coil), FLATPACK_FRAME_CABLE)
	if(ispath(source_board_type, /obj/item/circuitboard/computer))
		add_cost(mechanic_unit_cost(/obj/item/stack/sheet/glass), FLATPACK_COMPUTER_GLASS)
	if(from_schematic)
		add_cost(mechanic_unit_cost(source_board_type))

/obj/machinery/flatpacker/proc/add_cost(list/unit_cost, count = 1)
	for(var/datum/material/material as anything in unit_cost)
		needed_mats[material] += unit_cost[material] * count

/// Powód, dla którego nie da się teraz zrobić paczki, albo pusty tekst
/obj/machinery/flatpacker/proc/disable_reason()
	if(!source_build_path)
		return "Włóż płytkę albo wybierz schemat."
	if(source_illegal && !(obj_flags & EMAGGED))
		return "Zabezpieczenia blokują pakowanie tej maszyny."
	if(print_tier > max_part_tier)
		return "Części tej maszyny są za zaawansowane dla tego flatpackera."
	for(var/part_path in manual_parts)
		var/missing = manual_parts[part_path] - component_count(part_path)
		if(missing > 0)
			var/obj/item/part = part_path
			return "Włóż ręcznie: [initial(part.name)] ([missing])."
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	if(!materials.has_materials(needed_mats, creation_efficiency))
		return "Za mało materiałów."
	return ""

/obj/machinery/flatpacker/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/circuitboard/machine) || istype(I, /obj/item/circuitboard/computer))
		if(busy)
			balloon_alert(user, "zajęty!")
			return TRUE
		if(!user.transferItemToLoc(I, src))
			return TRUE
		// Nowa płytka to nowa maszyna: części włożone pod poprzednią wypadają
		inserted_board?.forceMove(drop_location())
		drop_manual_parts()
		inserted_board = I
		recalculate()
		update_appearance()
		to_chat(user, "<span class='notice'>Wkładasz [I] do [src].</span>")
		return TRUE
	if(manual_parts[I.type])
		if(component_count(I.type) >= manual_parts[I.type])
			balloon_alert(user, "już jest komplet!")
			return TRUE
		if(!user.transferItemToLoc(I, src))
			return TRUE
		flatpacked_components += I
		to_chat(user, "<span class='notice'>Wkładasz [I] do [src].</span>")
		return TRUE
	if(!busy && default_deconstruction_screwdriver(user, "[base_icon_state]_o", base_icon_state, I))
		update_appearance()
		return TRUE
	if(!busy && default_deconstruction_crowbar(I))
		return TRUE
	return ..()

/obj/machinery/flatpacker/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == inserted_board)
		inserted_board = null
		recalculate()
		update_appearance()
	if(gone in flatpacked_components)
		flatpacked_components -= gone

/obj/machinery/flatpacker/CtrlClick(mob/user)
	if(!inserted_board || busy || !user.canUseTopic(src, BE_CLOSE))
		return ..()
	eject_board(user)

/obj/machinery/flatpacker/proc/eject_board(mob/user)
	var/obj/item/circuitboard/board = inserted_board
	board.forceMove(drop_location())
	user?.put_in_hands(board)
	drop_manual_parts()

/obj/machinery/flatpacker/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Flatpacker")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/flatpacker/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/spritesheet/sheetmaterials))

/obj/machinery/flatpacker/ui_data(mob/user)
	var/list/data = list()
	data["materials"] = fabricator_ui_materials(GetComponent(/datum/component/material_container))
	data["busy"] = busy
	data["maxTier"] = max_part_tier
	data["efficiency"] = creation_efficiency
	data["emagged"] = !!(obj_flags & EMAGGED)
	data["boardInserted"] = !!inserted_board
	data["selected"] = selected_key

	var/list/schematics = list()
	for(var/key in stored_research?.machine_schematics)
		var/datum/machine_schematic/schematic = stored_research.machine_schematics[key]
		schematics += list(list(
			"key" = key,
			"name" = schematic.name,
			"tier" = schematic.tier,
			"illegal" = schematic.illegal,
		))
	data["schematics"] = schematics

	var/list/design
	if(source_build_path)
		var/list/cost = list()
		for(var/datum/material/material as anything in needed_mats)
			cost += list(list(
				"name" = material.name,
				"amount" = round(needed_mats[material] * creation_efficiency),
			))
		var/list/manual = list()
		for(var/part_path in manual_parts)
			var/obj/item/part = part_path
			manual += list(list(
				"name" = initial(part.name),
				"have" = component_count(part_path),
				"need" = manual_parts[part_path],
			))
		var/obj/machinery/target = source_build_path
		design = list(
			"name" = source_name,
			"tier" = print_tier,
			"illegal" = source_illegal,
			"icon" = "[initial(target.icon)]",
			"icon_state" = initial(target.icon_state),
			"requiredMaterials" = cost,
			"manual" = manual,
			"disableReason" = disable_reason(),
		)
	data["design"] = design
	return data

/obj/machinery/flatpacker/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("select")
			if(busy)
				return
			var/key = params["key"]
			if(!stored_research?.machine_schematics[key])
				return
			selected_key = key
			if(!inserted_board)
				drop_manual_parts()
				recalculate()
			return TRUE
		if("deselect")
			if(busy)
				return
			selected_key = null
			if(!inserted_board)
				drop_manual_parts()
				recalculate()
			return TRUE
		if("ejectBoard")
			if(busy || !inserted_board)
				return
			eject_board(usr)
			return TRUE
		if("build")
			return start_build(usr)
		if("remove_mat")
			if(busy)
				return
			var/amount = round(text2num(params["amount"]))
			if(!amount || amount <= 0 || amount > 50)
				return
			var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
			for(var/datum/material/material as anything in materials.materials)
				if(REF(material) == params["ref"])
					materials.retrieve_sheets(amount, material, drop_location())
					return TRUE

/// Zmiana schematu: ręcznie włożone części poprzedniej maszyny wypadają
/obj/machinery/flatpacker/proc/drop_manual_parts()
	var/turf/drop = drop_location()
	for(var/obj/item/component as anything in flatpacked_components)
		component.forceMove(drop)

/obj/machinery/flatpacker/proc/start_build(mob/user)
	if(busy || !is_operational)
		return FALSE
	if(panel_open)
		say("Zamknij właz serwisowy.")
		return FALSE
	recalculate()
	var/reason = disable_reason()
	if(reason)
		say(reason)
		return FALSE
	busy = TRUE
	use_power = ACTIVE_POWER_USE
	playsound(src, 'sound/items/rped.ogg', 50, TRUE)
	flick_overlay_view(image(icon, src, "[base_icon_state]_bar", ABOVE_OBJ_LAYER), src, flatpack_time)
	addtimer(CALLBACK(src, PROC_REF(finish_build)), flatpack_time)
	return TRUE

/// Zużywa materiały i wypluwa paczkę. Zwraca paczkę albo null.
/obj/machinery/flatpacker/proc/finish_build()
	busy = FALSE
	use_power = IDLE_POWER_USE
	if(QDELETED(src))
		return null
	if(!is_operational)
		return null
	// disable_reason() sprawdza też materiały; wynik use_materials() nie mówi, czy się udało (zawsze 0)
	if(disable_reason())
		return null
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.use_materials(needed_mats, creation_efficiency)

	var/obj/item/circuitboard/board = inserted_board
	if(!board)
		board = new source_board_type(null)
	// Płytka automatu z wyborem marki przestawia też nazwę i kanister, którego wymaga rama
	var/obj/item/circuitboard/machine/vendor/vendor_board = board
	if(istype(vendor_board) && ispath(source_build_path, /obj/machinery/vending))
		vendor_board.set_type(source_build_path)
	else
		board.build_path = source_build_path
	var/list/parts = auto_parts.Copy()
	// Do paczki idą tylko części, których ta maszyna wymaga; reszta zostaje we flatpackerze
	var/list/manual = list()
	var/list/still_needed = manual_parts.Copy()
	for(var/obj/item/component as anything in flatpacked_components)
		if(still_needed[component.type] > 0)
			still_needed[component.type]--
			manual += component
	var/obj/item/flatpack/pack = new(drop_location(), board, parts, manual)
	playsound(src, 'sound/machines/terminal_eject.ogg', 50, TRUE)
	recalculate()
	SStgui.update_uis(src)
	return pack

/obj/item/circuitboard/machine/flatpacker
	name = "flatpacker (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/flatpacker
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stack/sheet/glass = 1)

#undef FLATPACK_FRAME_IRON
#undef FLATPACK_FRAME_CABLE
#undef FLATPACK_COMPUTER_GLASS
