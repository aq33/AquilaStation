#define ATMOS_PIPEDISPENSER 0
#define DISPOSAL_PIPEDISPENSER 1
#define TRANSIT_PIPEDISPENSER 2

/obj/machinery/pipedispenser
	name = "pipe dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	desc = "Dispenses countless types of pipes. Very useful if you need pipes."
	density = TRUE
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_OFFLINE
	var/wait = 0
	var/piping_layer = PIPING_LAYER_DEFAULT
	/// AQUILA: kolor wydawanych rur (jak w RPD)
	var/paint_color = "grey"
	/// AQUILA: rodzaj dozownika (okno TGUI PipeDispenser z tg)
	var/category = ATMOS_PIPEDISPENSER

/obj/machinery/pipedispenser/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/pipedispenser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PipeDispenser", name)
		ui.open()

/obj/machinery/pipedispenser/ui_status(mob/user, datum/ui_state/state)
	if(!anchored)
		return UI_CLOSE
	return ..()

/obj/machinery/pipedispenser/proc/get_recipes()
	switch(category)
		if(ATMOS_PIPEDISPENSER)
			return GLOB.atmos_pipe_recipes
		if(DISPOSAL_PIPEDISPENSER)
			return GLOB.disposal_pipe_recipes
		if(TRANSIT_PIPEDISPENSER)
			return GLOB.transit_tube_recipes

/obj/machinery/pipedispenser/ui_static_data(mob/user)
	var/list/data = list()
	data["paint_colors"] = GLOB.pipe_paint_colors
	data["category"] = category
	data["categories"] = list()
	var/list/recipes = get_recipes()
	for(var/c in recipes)
		var/list/cat = recipes[c]
		var/list/r = list()
		for(var/i in 1 to length(cat))
			var/datum/pipe_info/info = cat[i]
			r += list(list("pipe_name" = info.name, "pipe_index" = i, "all_layers" = info.all_layers, "dir" = NORTH))
			// Stationary pipe dispensers don't allow you to pre-select pipe directions, so add a bent version
			if(info.dirtype == PIPE_BENDABLE)
				r += list(list("pipe_name" = "[info.name] (zagięta)", "pipe_index" = i, "all_layers" = info.all_layers, "dir" = NORTHEAST))
		data["categories"] += list(list("cat_name" = c, "recipes" = r))
	return data

/obj/machinery/pipedispenser/ui_data(mob/user)
	var/list/data = list()
	data["piping_layer"] = piping_layer
	data["selected_color"] = paint_color
	return data

/obj/machinery/pipedispenser/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/mob/living/L = usr
	if(!anchored || (istype(L) && !(L.mobility_flags & MOBILITY_UI)) || usr.stat || usr.restrained())
		return
	add_fingerprint(usr)
	switch(action)
		if("color")
			if(!(params["paint_color"] in GLOB.pipe_paint_colors))
				return
			paint_color = params["paint_color"]
			return TRUE
		if("piping_layer")
			piping_layer = clamp(round(text2num(params["piping_layer"])), PIPING_LAYER_MIN, PIPING_LAYER_MAX)
			return TRUE
		if("pipe_type")
			if(wait >= world.time)
				return
			var/list/recipes = get_recipes()
			var/list/cat = recipes?[params["category"]]
			var/index = text2num(params["pipe_type"])
			if(!islist(cat) || !index || index < 1 || index > length(cat))
				return
			var/datum/pipe_info/info = cat[index]
			var/p_dir = text2num(params["pipe_dir"]) || NORTH
			if(!(p_dir in GLOB.alldirs))
				p_dir = NORTH
			make_pipe(info, p_dir, usr)
			return TRUE

/// AQUILA: tworzy rurę/urządzenie z przepisu (logika z dawnego Topic())
/obj/machinery/pipedispenser/proc/make_pipe(datum/pipe_info/info, p_dir, mob/user)
	switch(category)
		if(ATMOS_PIPEDISPENSER)
			if(istype(info, /datum/pipe_info/meter))
				new /obj/item/pipe_meter(loc)
				wait = world.time + 15
				return
			var/obj/machinery/atmospherics/path = info.id
			if(!ispath(path, /obj/machinery/atmospherics))
				return
			var/pipe_item_type = initial(path.construction_type) || /obj/item/pipe
			var/obj/item/pipe/P = new pipe_item_type(loc, path, p_dir)
			P.set_piping_layer(piping_layer)
			if(findtext("[path]", "/obj/machinery/atmospherics/pipe") && !findtext("[path]", "layer_manifold"))
				P.add_atom_colour(GLOB.pipe_paint_colors[paint_color], FIXED_COLOUR_PRIORITY)
			P.add_fingerprint(user)
			wait = world.time + 10
		if(DISPOSAL_PIPEDISPENSER)
			var/obj/structure/disposalconstruct/C = new (loc, info.id)
			if(!C.can_place())
				to_chat(user, "<span class='warning'>Za mało miejsca, by to tu zbudować!</span>")
				qdel(C)
				return
			C.setDir(p_dir)
			C.add_fingerprint(user)
			C.update_icon()
			wait = world.time + 15
		if(TRANSIT_PIPEDISPENSER)
			var/tube_type = info.id
			if(!ispath(tube_type, /obj/structure))
				return
			var/obj/structure/C = new tube_type(loc)
			C.setDir(p_dir)
			C.add_fingerprint(user)
			wait = world.time + 15

/obj/machinery/pipedispenser/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if (istype(W, /obj/item/pipe) || istype(W, /obj/item/pipe_meter))
		to_chat(usr, "<span class='notice'>Odkładasz [W] z powrotem do [src].</span>")
		qdel(W)
		return
	else
		return ..()

/obj/machinery/pipedispenser/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I, 40)
	return TRUE


/obj/machinery/pipedispenser/disposal
	name = "disposal pipe dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	desc = "Dispenses pipes that will ultimately be used to move trash around."
	density = TRUE
	category = DISPOSAL_PIPEDISPENSER


//Allow you to drag-drop disposal pipes and transit tubes into it
/obj/machinery/pipedispenser/disposal/MouseDrop_T(obj/structure/pipe, mob/usr)
	if(usr.incapacitated())
		return

	if (!istype(pipe, /obj/structure/disposalconstruct) && !istype(pipe, /obj/structure/c_transit_tube) && !istype(pipe, /obj/structure/c_transit_tube_pod))
		return

	if (get_dist(usr, src) > 1 || get_dist(src,pipe) > 1 )
		return

	if (pipe.anchored)
		return

	qdel(pipe)

//transit tube dispenser
//inherit disposal for the dragging proc
/obj/machinery/pipedispenser/disposal/transit_tube
	name = "transit tube dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	density = TRUE
	desc = "Dispenses pipes that will move beings around."
	category = TRANSIT_PIPEDISPENSER

#undef ATMOS_PIPEDISPENSER
#undef DISPOSAL_PIPEDISPENSER
#undef TRANSIT_PIPEDISPENSER
