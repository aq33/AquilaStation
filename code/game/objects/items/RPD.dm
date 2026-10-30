/*
CONTAINS:
RPD
*/

#define ATMOS_CATEGORY 0
#define DISPOSALS_CATEGORY 1
#define TRANSIT_CATEGORY 2
#define PLUMBING_CATEGORY 3

#define BUILD_MODE 1
#define WRENCH_MODE 2
#define DESTROY_MODE 4
#define PAINT_MODE 8


GLOBAL_LIST_INIT(atmos_pipe_recipes, list(
	"Pipes" = list(
		new /datum/pipe_info/pipe("Rura",				/obj/machinery/atmospherics/pipe/simple, TRUE),
		new /datum/pipe_info/pipe("Rozgałęźnik",			/obj/machinery/atmospherics/pipe/manifold, TRUE),
		new /datum/pipe_info/pipe("Zawór",		/obj/machinery/atmospherics/components/binary/valve, TRUE),
		new /datum/pipe_info/pipe("Zawór cyfrowy",		/obj/machinery/atmospherics/components/binary/valve/digital, TRUE),
		new /datum/pipe_info/pipe("Rozgałęźnik czterodrożny",		/obj/machinery/atmospherics/pipe/manifold4w, TRUE),
		new /datum/pipe_info/pipe("Adapter warstw",		/obj/machinery/atmospherics/pipe/layer_manifold, TRUE),
		new /datum/pipe_info/pipe("Adapter międzypokładowy", /obj/machinery/atmospherics/pipe/multiz, TRUE),
	),
	"Devices" = list(
		new /datum/pipe_info/pipe("Port przyłączeniowy",			/obj/machinery/atmospherics/components/unary/portables_connector, TRUE),
		new /datum/pipe_info/pipe("Nawiewnik",			/obj/machinery/atmospherics/components/unary/vent_pump, TRUE),
		new /datum/pipe_info/pipe("Pompa gazu",			/obj/machinery/atmospherics/components/binary/pump, TRUE),
		new /datum/pipe_info/pipe("Regulator ciśnienia",		/obj/machinery/atmospherics/components/binary/passive_gate, TRUE),
		new /datum/pipe_info/pipe("Pompa objętościowa",		/obj/machinery/atmospherics/components/binary/volume_pump, TRUE),
		new /datum/pipe_info/pipe("Oczyszczacz powietrza",			/obj/machinery/atmospherics/components/unary/vent_scrubber, TRUE),
		new /datum/pipe_info/pipe("Wtryskiwacz",			/obj/machinery/atmospherics/components/unary/outlet_injector, TRUE),
		new /datum/pipe_info/pipe("Pasywny nawiewnik",		/obj/machinery/atmospherics/components/unary/passive_vent, TRUE),
		new /datum/pipe_info/pipe("Filtr gazów",			/obj/machinery/atmospherics/components/trinary/filter, TRUE),
		new /datum/pipe_info/pipe("Mieszacz gazów",			/obj/machinery/atmospherics/components/trinary/mixer, TRUE),
		new /datum/pipe_info/pipe("Zawór ciśnieniowy",		/obj/machinery/atmospherics/components/binary/pressure_valve, TRUE),
		new /datum/pipe_info/pipe("Regulator temperatury",	/obj/machinery/atmospherics/components/binary/temperature_gate, TRUE),
		new /datum/pipe_info/pipe("Pompa temperaturowa",	/obj/machinery/atmospherics/components/binary/temperature_pump, TRUE),
		new /datum/pipe_info/meter("Miernik"),
	),
	"Heat Exchange" = list(
		new /datum/pipe_info/pipe("Rura",				/obj/machinery/atmospherics/pipe/heat_exchanging/simple, FALSE),
		new /datum/pipe_info/pipe("Rozgałęźnik",			/obj/machinery/atmospherics/pipe/heat_exchanging/manifold, FALSE),
		new /datum/pipe_info/pipe("Rozgałęźnik czterodrożny",		/obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w, FALSE),
		new /datum/pipe_info/pipe("Złączka",			/obj/machinery/atmospherics/pipe/heat_exchanging/junction, FALSE),
		new /datum/pipe_info/pipe("Wymiennik ciepła",		/obj/machinery/atmospherics/components/unary/heat_exchanger, FALSE),
	)
))

GLOBAL_LIST_INIT(disposal_pipe_recipes, list(
	"Disposal Pipes" = list(
		new /datum/pipe_info/disposal("Rura",			/obj/structure/disposalpipe/segment, PIPE_BENDABLE),
		new /datum/pipe_info/disposal("Złączka",		/obj/structure/disposalpipe/junction, PIPE_TRIN_M),
		new /datum/pipe_info/disposal("Złączka Y",		/obj/structure/disposalpipe/junction/yjunction),
		new /datum/pipe_info/disposal("Złączka sortująca",	/obj/structure/disposalpipe/sorting/mail, PIPE_TRIN_M),
		new /datum/pipe_info/disposal("Przyłącze",			/obj/structure/disposalpipe/trunk),
		new /datum/pipe_info/disposal("Kosz zsypowy",			/obj/machinery/disposal/bin, PIPE_ONEDIR),
		new /datum/pipe_info/disposal("Wylot",			/obj/structure/disposaloutlet),
		new /datum/pipe_info/disposal("Zsyp",			/obj/machinery/disposal/deliveryChute),
		new /datum/pipe_info/disposal("Przyłącze (w górę)",		/obj/structure/disposalpipe/trunk/multiz, PIPE_UNARY),
		new /datum/pipe_info/disposal("Przyłącze (w dół)",	/obj/structure/disposalpipe/trunk/multiz/down, PIPE_UNARY),
		new /datum/pipe_info/disposal("Loafer (prasa bochenkowa)", /obj/structure/disposalpipe/loafer, PIPE_STRAIGHT), // AQ EDIT - prasa bochenkowa z Monkestation
	)
))

GLOBAL_LIST_INIT(transit_tube_recipes, list(
	"Transit Tubes" = list(
		new /datum/pipe_info/transit("Rura prosta",				/obj/structure/c_transit_tube, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Rura prosta ze skrzyżowaniem",	/obj/structure/c_transit_tube/crossing, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Rura zakrzywiona",					/obj/structure/c_transit_tube/curved, PIPE_UNARY_FLIPPABLE),
		new /datum/pipe_info/transit("Rura ukośna",				/obj/structure/c_transit_tube/diagonal, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Rura ukośna ze skrzyżowaniem",	/obj/structure/c_transit_tube/diagonal/crossing, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Złączka",					/obj/structure/c_transit_tube/junction, PIPE_UNARY_FLIPPABLE),
	),
	"Station Equipment" = list(
		new /datum/pipe_info/transit("Stacja przelotowa",		/obj/structure/c_transit_tube/station, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Stacja końcowa",		/obj/structure/c_transit_tube/station/reverse, PIPE_UNARY),
		new /datum/pipe_info/transit("Kapsuła transportowa",			/obj/structure/c_transit_tube_pod, PIPE_ONEDIR),
	)
))

GLOBAL_LIST_INIT(fluid_duct_recipes, list(
	"Fluid Ducts" = list(
		new /datum/pipe_info/plumbing("Przewód",				/obj/machinery/duct, PIPE_ONEDIR),
	)
))

/datum/pipe_info
	var/name
	var/icon_state
	var/id = -1
	var/dirtype = PIPE_BENDABLE
	var/all_layers

/datum/pipe_info/proc/Render(dispenser)
	var/dat = "<li><a href='byond://?src=[REF(dispenser)]&[Params()]'>[name]</a></li>"

	// Stationary pipe dispensers don't allow you to pre-select pipe directions.
	// This makes it impossble to spawn bent versions of bendable pipes.
	// We add a "Bent" pipe type with a preset diagonal direction to work around it.
	if(istype(dispenser, /obj/machinery/pipedispenser) && (dirtype == PIPE_BENDABLE || dirtype == /obj/item/pipe/binary/bendable))
		dat += "<li><a href='byond://?src=[REF(dispenser)]&[Params()]&dir=[NORTHEAST]'>[name] (zagięta)</a></li>"

	return dat

/datum/pipe_info/proc/Params()
	return ""

/datum/pipe_info/proc/get_preview(selected_dir)
	var/list/dirs
	switch(dirtype)
		if(PIPE_STRAIGHT, PIPE_BENDABLE)
			dirs = list("[NORTH]" = "Pionowo", "[EAST]" = "Poziomo")
			if(dirtype == PIPE_BENDABLE)
				dirs += list("[NORTHWEST]" = "Zachód – północ", "[NORTHEAST]" = "Północ – wschód",
							 "[SOUTHWEST]" = "Południe – zachód", "[SOUTHEAST]" = "Wschód – południe")
		if(PIPE_TRINARY)
			dirs = list("[NORTH]" = "Zachód, południe, wschód", "[EAST]" = "Północ, zachód, południe",
						"[SOUTH]" = "Wschód, północ, zachód", "[WEST]" = "Południe, wschód, północ")
		if(PIPE_TRIN_M)
			dirs = list("[NORTH]" = "Północ, wschód, południe", "[EAST]" = "Wschód, południe, zachód",
						"[SOUTH]" = "Południe, zachód, północ", "[WEST]" = "Zachód, północ, wschód",
						"[SOUTHEAST]" = "Zachód, południe, wschód", "[NORTHEAST]" = "Południe, wschód, północ",
						"[NORTHWEST]" = "Wschód, północ, zachód", "[SOUTHWEST]" = "Północ, zachód, południe")
		if(PIPE_UNARY)
			dirs = list("[NORTH]" = "Północ", "[EAST]" = "Wschód", "[SOUTH]" = "Południe", "[WEST]" = "Zachód")
		if(PIPE_ONEDIR)
			dirs = list("[SOUTH]" = name)
		if(PIPE_UNARY_FLIPPABLE)
			dirs = list("[NORTH]" = "Północ", "[NORTHEAST]" = "Północ (odwrócone)", "[EAST]" = "Wschód", "[SOUTHEAST]" = "Wschód (odwrócone)",
						"[SOUTH]" = "Południe", "[SOUTHWEST]" = "Południe (odwrócone)", "[WEST]" = "Zachód", "[NORTHWEST]" = "Zachód (odwrócone)")


	var/list/rows = list()
	var/list/row = list("previews" = list())
	var/i = 0
	for(var/dir in dirs)
		var/numdir = text2num(dir)
		var/flipped = ((dirtype == PIPE_TRIN_M) || (dirtype == PIPE_UNARY_FLIPPABLE)) && (numdir in GLOB.diagonals)
		row["previews"] += list(list("selected" = (numdir == selected_dir), "dir" = dir2text(numdir), "dir_name" = dirs[dir], "icon_state" = icon_state, "flipped" = flipped))
		if(i++ || dirtype == PIPE_ONEDIR)
			rows += list(row)
			row = list("previews" = list())
			i = 0

	return rows

/datum/pipe_info/pipe/New(label, obj/machinery/atmospherics/path, use_five_layers)
	name = label
	id = path
	all_layers = use_five_layers
	icon_state = initial(path.pipe_state)
	var/obj/item/pipe/c = initial(path.construction_type)
	dirtype = initial(c.RPD_type)

/datum/pipe_info/pipe/Params()
	return "makepipe=[id]&type=[dirtype]"

/datum/pipe_info/meter
	icon_state = "meter"
	dirtype = PIPE_ONEDIR

/datum/pipe_info/meter/New(label)
	name = label

/datum/pipe_info/meter/Params()
	return "makemeter=[id]&type=[dirtype]"

/datum/pipe_info/disposal/New(label, obj/path, dt=PIPE_UNARY)
	name = label
	id = path

	icon_state = initial(path.icon_state)
	if(ispath(path, /obj/structure/disposalpipe))
		icon_state = "con[icon_state]"

	dirtype = dt

/datum/pipe_info/disposal/Params()
	return "dmake=[id]&type=[dirtype]"

/datum/pipe_info/transit/New(label, obj/path, dt=PIPE_UNARY)
	name = label
	id = path
	dirtype = dt
	icon_state = initial(path.icon_state)
	if(dt == PIPE_UNARY_FLIPPABLE)
		icon_state = "[icon_state]_preview"

/datum/pipe_info/plumbing/New(label, obj/path, dt=PIPE_UNARY)
	name = label
	id = path
	icon_state = initial(path.icon_state)
	dirtype = dt

/datum/pipe_info/plumbing/multilayer //exists as identifier so we can see the difference between multi_layer and just ducts properly later on


/obj/item/pipe_dispenser
	name = "szybki dozownik rur (RPD)"
	desc = "Urządzenie do szybkiego układania rur."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rpd"
	flags_1 = CONDUCT_1
	force = 10
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	materials = list(/datum/material/iron=75000, /datum/material/glass=37500)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50, "stamina" = 0, "bleed" = 0)
	resistance_flags = FIRE_PROOF
	var/datum/effect_system/spark_spread/spark_system
	var/working = 0
	var/p_dir = NORTH
	var/p_flipped = FALSE
	var/paint_color = "grey"
	var/atmos_build_speed = 5 //deciseconds (500ms)
	var/disposal_build_speed = 5
	var/transit_build_speed = 5
	var/plumbing_build_speed = 5
	var/destroy_speed = 5
	var/paint_speed = 5
	var/category = ATMOS_CATEGORY
	var/piping_layer = PIPING_LAYER_DEFAULT
	var/ducting_layer = DUCT_LAYER_DEFAULT
	var/datum/pipe_info/recipe
	var/static/datum/pipe_info/first_atmos
	var/static/datum/pipe_info/first_disposal
	var/static/datum/pipe_info/first_transit
	var/static/datum/pipe_info/first_plumbing
	var/mode = BUILD_MODE | PAINT_MODE | DESTROY_MODE | WRENCH_MODE
	var/locked = FALSE //wheter we can change categories. Useful for the plumber

/obj/item/pipe_dispenser/Initialize(mapload)
	. = ..()
	spark_system = new
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	if(!first_atmos)
		first_atmos = GLOB.atmos_pipe_recipes[GLOB.atmos_pipe_recipes[1]][1]
	if(!first_disposal)
		first_disposal = GLOB.disposal_pipe_recipes[GLOB.disposal_pipe_recipes[1]][1]
	if(!first_transit)
		first_transit = GLOB.transit_tube_recipes[GLOB.transit_tube_recipes[1]][1]

	recipe = first_atmos

/obj/item/pipe_dispenser/Destroy()
	qdel(spark_system)
	spark_system = null
	return ..()

/obj/item/pipe_dispenser/attack_self(mob/user)
	ui_interact(user)

/obj/item/pipe_dispenser/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] kieruje końcówkę RPD do gardła i naciska przycisk! Wygląda na to, że próbuje popełnić samobójstwo...</span>")
	playsound(get_turf(user), 'sound/machines/click.ogg', 50, 1)
	playsound(get_turf(user), 'sound/items/deconstruct.ogg', 50, 1)
	return(BRUTELOSS)

/obj/item/pipe_dispenser/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/pipes),
	)


/obj/item/pipe_dispenser/ui_state(mob/user)
	return GLOB.default_state

/obj/item/pipe_dispenser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RapidPipeDispenser")
		ui.open()

/obj/item/pipe_dispenser/ui_data(mob/user)
	var/list/data = list(
		"category" = category,
		"piping_layer" = piping_layer,
		"ducting_layer" = ducting_layer,
		"preview_rows" = recipe.get_preview(p_dir),
		"categories" = list(),
		"selected_color" = paint_color,
		"paint_colors" = GLOB.pipe_paint_colors,
		"mode" = mode,
		"locked" = locked
	)

	var/list/recipes
	switch(category)
		if(ATMOS_CATEGORY)
			recipes = GLOB.atmos_pipe_recipes
		if(DISPOSALS_CATEGORY)
			recipes = GLOB.disposal_pipe_recipes
		if(TRANSIT_CATEGORY)
			recipes = GLOB.transit_tube_recipes
		if(PLUMBING_CATEGORY)
			recipes = GLOB.fluid_duct_recipes
	for(var/c in recipes)
		var/list/cat = recipes[c]
		var/list/r = list()
		for(var/i in 1 to cat.len)
			var/datum/pipe_info/info = cat[i]
			// AQUILA: okno z tg pokazuje podgląd kierunków dla każdej receptury
			var/list/previews = list()
			for(var/list/preview_row in info.get_preview(info == recipe ? p_dir : null))
				previews += preview_row["previews"]
			if(info == recipe)
				data["selected_category"] = c
			r += list(list("pipe_name" = info.name, "pipe_index" = i, "selected" = (info == recipe), "all_layers" = info.all_layers, "previews" = previews))
		data["categories"] += list(list("cat_name" = c, "recipes" = r))

	return data

/obj/item/pipe_dispenser/ui_act(action, params)
	if(..())
		return
	var/playeffect = TRUE
	switch(action)
		if("color")
			paint_color = params["paint_color"]
			. = TRUE
		if("category")
			category = text2num(params["category"])
			switch(category)
				if(DISPOSALS_CATEGORY)
					recipe = first_disposal
				if(ATMOS_CATEGORY)
					recipe = first_atmos
				if(TRANSIT_CATEGORY)
					recipe = first_transit
				if(PLUMBING_CATEGORY)
					recipe = first_plumbing
			p_dir = NORTH
			playeffect = FALSE
			. = TRUE
		if("piping_layer")
			piping_layer = text2num(params["piping_layer"])
			playeffect = FALSE
			. = TRUE
		if("ducting_layer")
			ducting_layer = text2num(params["ducting_layer"])
			playeffect = FALSE
			. = TRUE
		if("pipe_type")
			var/static/list/recipes
			if(!recipes)
				recipes = GLOB.disposal_pipe_recipes + GLOB.atmos_pipe_recipes + GLOB.transit_tube_recipes + GLOB.fluid_duct_recipes
			recipe = recipes[params["category"]][text2num(params["pipe_type"])]
			p_dir = NORTH
			. = TRUE
		if("setdir")
			p_dir = text2dir(params["dir"])
			p_flipped = text2num(params["flipped"])
			playeffect = FALSE
			. = TRUE
		if("mode")
			var/n = text2num(params["mode"])
			. = TRUE
			if(mode & n)
				mode &= ~n
			else
				mode |= n
	if(playeffect && .)
		spark_system.start()
		playsound(get_turf(src), 'sound/effects/pop.ogg', 50, FALSE)

/obj/item/pipe_dispenser/pre_attack(atom/A, mob/user)
	if(!user.IsAdvancedToolUser() || istype(A, /turf/open/space/transit))
		return ..()

	//So that changing the menu settings doesn't affect the pipes already being built.
	var/queued_p_type = recipe.id
	var/queued_p_dir = p_dir
	var/queued_p_flipped = p_flipped

	//make sure what we're clicking is valid for the current category
	var/static/list/make_pipe_whitelist
	if(!make_pipe_whitelist)
		make_pipe_whitelist = typecacheof(list(/obj/structure/lattice, /obj/structure/girder, /obj/item/pipe, /obj/structure/window, /obj/structure/grille))
	var/can_make_pipe = (isturf(A) || is_type_in_typecache(A, make_pipe_whitelist))

	. = FALSE

	if((mode&DESTROY_MODE) && istype(A, /obj/item/pipe) || istype(A, /obj/structure/disposalconstruct) || istype(A, /obj/structure/c_transit_tube) || istype(A, /obj/structure/c_transit_tube_pod) || istype(A, /obj/item/pipe_meter))
		to_chat(user, "<span class='notice'>Zaczynasz niszczyć rurę...</span>")
		playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
		if(do_after(user, destroy_speed, target = A))
			activate()
			qdel(A)
		return

	if(mode & PAINT_MODE)
		var/obj/machinery/atmospherics/pipe/M = A
		if(istype(M) && M.paintable)
			to_chat(user, "<span class='notice'>Zaczynasz malować [M] na kolor: [paint_color]...</span>")
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
			if(do_after(user, paint_speed, target = M))
				M.paint(GLOB.pipe_paint_colors[paint_color]) //paint the pipe
				user.visible_message("<span class='notice'>[user] maluje [M] na kolor: [paint_color].</span>","<span class='notice'>Malujesz [M] na kolor: [paint_color].</span>")
			return
		var/obj/item/pipe/P = A
		if(istype(P) && P.paintable)
			to_chat(user, "<span class='notice'>Zaczynasz malować [P] na kolor: [paint_color]...</span>")
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
			if(do_after(user, paint_speed, target = P))
				P.add_atom_colour(GLOB.pipe_paint_colors[paint_color], FIXED_COLOUR_PRIORITY) //paint the pipe
				user.visible_message("<span class='notice'>[user] maluje [P] na kolor: [paint_color].</span>","<span class='notice'>Malujesz [P] na kolor: [paint_color].</span>")
			return

	if(mode&BUILD_MODE)
		switch(category) //if we've gotten this var, the target is valid
			if(ATMOS_CATEGORY) //Making pipes
				if(!can_make_pipe)
					return ..()
				playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
				if (recipe.type == /datum/pipe_info/meter)
					to_chat(user, "<span class='notice'>Zaczynasz budować miernik...</span>")
					if(do_after(user, atmos_build_speed, target = A))
						activate()
						var/obj/item/pipe_meter/PM = new /obj/item/pipe_meter(get_turf(A))
						PM.setAttachLayer(piping_layer)
						if(mode&WRENCH_MODE)
							PM.wrench_act(user, src)
				else
					if(recipe.all_layers == FALSE && (piping_layer == 1 || piping_layer == 5))
						to_chat(user, "<span class='notice'>Nie możesz zbudować tego obiektu na tej warstwie...</span>")
						return ..()
					to_chat(user, "<span class='notice'>Zaczynasz budować rurę...</span>")
					if(do_after(user, atmos_build_speed, target = A))
						if(recipe.all_layers == FALSE && (piping_layer == 1 || piping_layer == 5)) // double check to stop cheaters (and to not waste time waiting for something that can't be placed)
							to_chat(user, "<span class='notice'>Nie możesz zbudować tego obiektu na tej warstwie...</span>")
							return ..()
						activate()
						var/obj/machinery/atmospherics/path = queued_p_type
						var/pipe_item_type = initial(path.construction_type) || /obj/item/pipe
						var/obj/item/pipe/P = new pipe_item_type(get_turf(A), queued_p_type, queued_p_dir)

						if(queued_p_flipped && istype(P, /obj/item/pipe/trinary/flippable))
							var/obj/item/pipe/trinary/flippable/F = P
							F.flipped = queued_p_flipped

						P.update()
						P.add_fingerprint(usr)
						P.set_piping_layer(piping_layer)
						if(findtext("[queued_p_type]", "/obj/machinery/atmospherics/pipe") && !findtext("[queued_p_type]", "layer_manifold"))
							P.add_atom_colour(GLOB.pipe_paint_colors[paint_color], FIXED_COLOUR_PRIORITY)
						if(mode&WRENCH_MODE)
							P.wrench_act(user, src)

			if(DISPOSALS_CATEGORY) //Making disposals pipes
				if(!can_make_pipe)
					return ..()
				A = get_turf(A)
				if(isclosedturf(A))
					to_chat(user, "<span class='warning'>Lampka błędu [src] migocze; coś jest na drodze!</span>")
					return
				to_chat(user, "<span class='notice'>Zaczynasz budować rurę zsypową...</span>")
				playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
				if(do_after(user, disposal_build_speed, target = A))
					var/obj/structure/disposalconstruct/C = new (A, queued_p_type, queued_p_dir, queued_p_flipped)

					if(!C.can_place())
						to_chat(user, "<span class='warning'>Za mało miejsca, by to tu zbudować!</span>")
						qdel(C)
						return

					activate()

					C.add_fingerprint(usr)
					C.update_icon()
					if(mode&WRENCH_MODE)
						C.wrench_act(user, src)
					return

			if(TRANSIT_CATEGORY) //Making transit tubes
				if(!can_make_pipe)
					return ..()
				A = get_turf(A)
				if(isclosedturf(A))
					to_chat(user, "<span class='warning'>Lampka błędu [src] migocze; coś jest na drodze!</span>")
					return
				to_chat(user, "<span class='notice'>Zaczynasz budować rurę transportową...</span>")
				playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
				if(do_after(user, transit_build_speed, target = A))
					activate()
					if(queued_p_type == /obj/structure/c_transit_tube_pod)
						var/obj/structure/c_transit_tube_pod/pod = new /obj/structure/c_transit_tube_pod(A)
						pod.add_fingerprint(usr)
						if(mode&WRENCH_MODE)
							pod.wrench_act(user, src)

					else
						var/obj/structure/c_transit_tube/tube = new queued_p_type(A)
						tube.setDir(queued_p_dir)

						if(queued_p_flipped)
							tube.setDir(turn(queued_p_dir, 45 + ROTATION_FLIP))
							tube.AfterRotation(user, ROTATION_FLIP)

						tube.add_fingerprint(usr)
						if(mode&WRENCH_MODE)
							tube.wrench_act(user, src)
					return
			if(PLUMBING_CATEGORY) //Making pancakes
				if(!can_make_pipe)
					return ..()
				A = get_turf(A)
				if(isclosedturf(A))
					to_chat(user, "<span class='warning'>Lampka błędu [src] migocze; coś jest na drodze!</span>")
					return
				to_chat(user, "<span class='notice'>Zaczynasz budować przewód płynów...</span>")
				playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
				if(do_after(user, plumbing_build_speed, target = A))
					// AQ EDIT START - plumbing port from tg, ducts connect on their own
					if(!isnull(ducting_layer_check(A, ducting_layer)))
						to_chat(user, "<span class='warning'>Na tym polu jest już rura lub maszyna na tej warstwie!</span>")
						return
					var/obj/machinery/duct/D = new queued_p_type (A, paint_color, ducting_layer)
					D.add_fingerprint(usr)
					// AQ EDIT END

			else
				return ..()

/obj/item/pipe_dispenser/proc/activate()
	playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)

/obj/item/pipe_dispenser/plumbing
	name = "Hydraulikator"
	desc = "Prymitywne urządzenie do szybkiego układania instalacji wodnych."
	icon_state = "plumberer"
	category = PLUMBING_CATEGORY
	locked = TRUE

/obj/item/pipe_dispenser/plumbing/Initialize(mapload)
	. = ..()
	spark_system = new
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	if(!first_plumbing)
		first_plumbing = GLOB.fluid_duct_recipes[GLOB.fluid_duct_recipes[1]][1]

	recipe = first_plumbing

#undef ATMOS_CATEGORY
#undef DISPOSALS_CATEGORY
#undef TRANSIT_CATEGORY
#undef PLUMBING_CATEGORY

#undef BUILD_MODE
#undef DESTROY_MODE
#undef PAINT_MODE
#undef WRENCH_MODE
