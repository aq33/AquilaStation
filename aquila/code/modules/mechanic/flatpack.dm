// AQUILA - Mechanik: paczka z maszyną i wózek na paczki, port tgstation/tgstation#83836 (code/game/objects/items/flatpacks.dm).
// Różnica względem tg: paczka trzyma płytkę i prawdziwe części (z pakownicy, z ulepszeniami) albo typy części z flatpackera.

/obj/item/flatpack
	name = "paczka"
	desc = "Pudło z ciasno złożoną maszyną. Połóż na podłodze i użyj multitoola, żeby ją rozłożyć. Maszyna stanie przodem tam, gdzie patrzysz."
	icon = 'aquila/icons/obj/mechanic/flatpack.dmi'
	icon_state = "flatpack"
	density = TRUE
	w_class = WEIGHT_CLASS_HUGE
	throw_range = 2
	item_flags = SLOWS_WHILE_IN_HAND
	slowdown = 2.5
	drag_slowdown = 3.5
	/// Płytka maszyny (albo typ płytki dla paczek z mapy)
	var/obj/item/circuitboard/board
	/// Części do zrobienia przy rozkładaniu: typ = ilość. Prawdziwe części leżą w contents.
	var/list/part_types = list()

/obj/item/flatpack/Initialize(mapload, obj/item/circuitboard/new_board, list/new_part_types, list/obj/item/real_parts)
	. = ..()
	if(isnull(board) && isnull(new_board))
		return INITIALIZE_HINT_QDEL
	if(!new_board)
		// Paczka z mapy: płytka z typu i domyślne części płytki, jak w maszynie postawionej na mapie
		new_board = new board(src)
		var/obj/item/circuitboard/machine/machine_board = new_board
		if(istype(machine_board) && !new_part_types)
			new_part_types = list()
			for(var/part_path in machine_board.req_components)
				new_part_types[LAZYACCESS(machine_board.def_components, part_path) || part_path] += machine_board.req_components[part_path]
	board = new_board
	if(board.loc != src)
		board.forceMove(src)
	if(new_part_types)
		part_types = new_part_types.Copy()
	for(var/obj/item/part as anything in real_parts)
		part.forceMove(src)
	var/obj/machinery/target = board.build_path
	name = "paczka ([initial(target.name)])"

/obj/item/flatpack/Destroy()
	QDEL_NULL(board)
	return ..()

/obj/item/flatpack/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == board)
		board = null

/obj/item/flatpack/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !isobserver(user))
		return
	var/list/part_names = list()
	for(var/obj/item/part in contents)
		if(part != board)
			part_names += part.name
	for(var/part_path in part_types)
		var/obj/item/part = part_path
		part_names += "[part_types[part_path]] [initial(part.name)]"
	if(length(part_names))
		. += "<span class='notice'>W środku: [english_list(part_names)].</span>"
	if(loc == user)
		. += "<span class='warning'>Nie rozłożysz jej, trzymając w rękach.</span>"
	else if(isturf(loc) && deploy_problem())
		. += "<span class='warning'>[deploy_problem()]</span>"

/// Powód, dla którego paczki nie da się teraz rozłożyć, albo null
/obj/item/flatpack/proc/deploy_problem()
	if(!board)
		return "Paczka jest pusta."
	if(!isturf(loc))
		return "Paczkę trzeba położyć na podłodze."
	var/turf/location = loc
	if(location.density || isspaceturf(location))
		return "Tu nie da się jej rozłożyć."
	for(var/atom/movable/thing in location)
		if(thing != src && thing.density)
			return "Brakuje miejsca na rozłożenie."
	return null

/obj/item/flatpack/multitool_act(mob/living/user, obj/item/tool)
	var/problem = deploy_problem()
	if(problem)
		balloon_alert(user, problem)
		return TRUE
	balloon_alert_to_viewers("rozkładanie!")
	if(!tool.use_tool(src, user, 1 SECONDS))
		return TRUE
	if(deploy_problem())
		return TRUE
	deploy(user.dir)
	return TRUE

/**
 * Rozkłada paczkę w gotową maszynę z płytką i częściami z paczki, tak jak przy dokręceniu kompletnej ramy.
 * Zwraca maszynę.
 */
/obj/item/flatpack/proc/deploy(direction = SOUTH)
	var/turf/location = loc
	var/obj/item/circuitboard/leaving_board = board
	board = null

	var/list/obj/item/parts = list()
	for(var/obj/item/part in contents)
		if(part != leaving_board)
			parts += part
	for(var/part_path in part_types)
		if(ispath(part_path, /obj/item/stack))
			parts += new part_path(null, part_types[part_path])
		else
			for(var/i in 1 to part_types[part_path])
				parts += new part_path(null)

	var/obj/machinery/machine
	if(istype(leaving_board, /obj/item/circuitboard/computer))
		machine = new leaving_board.build_path(location, leaving_board)
		machine.setDir(direction)
		QDEL_LIST(parts)
	else
		// Rury liczą kierunki połączeń przy tworzeniu, więc kierunek trzeba podać od razu (New(loc, process, setdir))
		if(ispath(leaving_board.build_path, /obj/machinery/atmospherics))
			machine = new leaving_board.build_path(location, TRUE, direction)
		else
			machine = new leaving_board.build_path(location)
		if(machine.circuit && machine.circuit != leaving_board)
			QDEL_NULL(machine.circuit)
		machine.circuit = leaving_board
		machine.setAnchored(TRUE)
		machine.setDir(direction)
		machine.on_construction(direction)
		for(var/obj/old_part in machine.component_parts)
			qdel(old_part)
		machine.component_parts = list(leaving_board)
		leaving_board.moveToNullspace()
		for(var/obj/item/part as anything in parts)
			part.moveToNullspace()
			machine.component_parts += part
		machine.RefreshParts()

	new /obj/effect/temp_visual/mook_dust(location)
	playsound(location, 'sound/machines/terminal_eject.ogg', 70, TRUE)
	location.visible_message("<span class='notice'>[src] rozkłada się w [machine].</span>")
	qdel(src)
	return machine

/**
 * Składa działającą maszynę w paczkę z jej płytką i częściami (ulepszenia zostają).
 * Zawartość maszyny wypada jak przy rozbiórce. Zwraca paczkę.
 */
/proc/mechanic_pack_machine(obj/machinery/machine)
	var/turf/location = get_turf(machine)
	var/obj/item/circuitboard/board = machine.circuit
	machine.on_deconstruction()
	var/list/obj/item/parts = list()
	for(var/obj/item/part in machine.component_parts)
		if(part != board)
			parts += part
	machine.component_parts?.Cut()
	machine.circuit = null
	var/obj/item/flatpack/pack = new(location, board, null, parts)
	qdel(machine)
	return pack

/// Gotowe paczki z domyślnymi częściami płytki (komora testowa, admini)
/obj/item/flatpack/flatpacker
	name = "paczka (flatpacker)"
	board = /obj/item/circuitboard/machine/flatpacker

/obj/item/flatpack/schematic_reader
	name = "paczka (czytnik schematów)"
	board = /obj/item/circuitboard/machine/schematic_reader

#define MAX_FLAT_PACKS 3

/obj/structure/flatpack_cart
	name = "wózek na paczki"
	desc = "Wózek na paczki z flatpackera, który rozkłada ich ciężar. Wygodne!"
	icon = 'aquila/icons/obj/mechanic/flatpack.dmi'
	icon_state = "flatcart"
	density = TRUE
	anchored = FALSE
	custom_materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 8)

/obj/structure/flatpack_cart/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation)

/obj/structure/flatpack_cart/setDir(newdir)
	. = ..()
	update_appearance()

// Ciągnięty wózek obraca się rączką do ciągnącego, pchnięty zostaje tak, jak stał
/obj/structure/flatpack_cart/Move(atom/newloc, direct, glide_size_override)
	var/old_dir = dir
	. = ..()
	if(!pulledby && dir != old_dir)
		setDir(old_dir)

// Turkocze, gdy ktoś go ciągnie, tak jak wózek woźnego
/obj/structure/flatpack_cart/Moved(atom/OldLoc, Dir, Forced)
	. = ..()
	if(!Forced && isturf(loc) && has_gravity())
		playsound(src, 'aquila/sound/effects/janicart_roll.ogg', 40, TRUE, -3)

/obj/structure/flatpack_cart/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !isobserver(user))
		return
	if(!length(contents))
		. += "<span class='notice'>Wózek jest pusty.</span>"
		return
	. += "<span class='notice'>Od dołu do góry:</span>"
	for(var/obj/item/flatpack/pack in contents)
		. += "<span class='notice'>- [pack.name]</span>"

/obj/structure/flatpack_cart/update_overlays()
	. = ..()
	var/offset = 0
	for(var/obj/item/flatpack/pack in contents)
		var/mutable_appearance/pack_overlay = mutable_appearance(icon, "flatcart_flat", layer + offset * 0.01)
		pack_overlay.dir = dir
		pack_overlay.pixel_y = offset
		offset += 4
		. += pack_overlay

/obj/structure/flatpack_cart/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(. || !length(contents))
		return
	var/obj/item/flatpack/top = contents[length(contents)]
	top.forceMove(drop_location())
	user.put_in_hands(top)
	update_appearance()
	return TRUE

/obj/structure/flatpack_cart/attackby(obj/item/I, mob/living/user, params)
	if(!istype(I, /obj/item/flatpack) || user.combat_mode)
		return ..()
	if(length(contents) >= MAX_FLAT_PACKS)
		balloon_alert(user, "pełny!")
		return TRUE
	if(!user.transferItemToLoc(I, src))
		return TRUE
	update_appearance()
	return TRUE

/obj/structure/flatpack_cart/Exited(atom/movable/gone, direction)
	. = ..()
	update_appearance()

/obj/structure/flatpack_cart/deconstruct(disassembled = TRUE)
	var/turf/drop = drop_location()
	for(var/atom/movable/thing as anything in contents)
		thing.forceMove(drop)
	return ..()

#undef MAX_FLAT_PACKS
