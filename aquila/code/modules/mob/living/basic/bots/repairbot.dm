/*
 * Repairbot z tgstation (code/modules/mob/living/basic/bots/repairbot, tgstation/tgstation@5ee81d6) jako następca floorbota.
 * Łata wyłomy w poszyciu (za darmo, jak floorbot), naprawia i kładzie płytki, z żelaza stawia ściany na dźwigarach,
 * ze szkła szyby na kratach, spawarką łata uszkodzone okna. Po zhakowaniu zrywa podłogi aż do próżni.
 * Zachowane z floorbota: kolory skrzynki (zabarwienie), płytki specjalne, tryb liniowy (most w jednym kierunku).
 * Różnice względem tg: bez akcji gracza (budowa dźwigarów, menu zasobów) i bez osobnego okna RepairBot,
 * zasoby i ustawienia są w oknie SimpleBot; szyby to zwykłe /obj/structure/window/fulltile.
 * Sprite'y (aquila/icons/mob/bots/tg_bots.dmi) i głosy (aquila/sound/voice/repairbot/) z tgstation, CC BY-SA 3.0.
 */

#define REPAIRBOT_TASK_BREACH 1
#define REPAIRBOT_TASK_FIX_FLOOR 2
#define REPAIRBOT_TASK_PLACE_TILE 3
#define REPAIRBOT_TASK_REPLACE_TILE 4
#define REPAIRBOT_TASK_GIRDER 5
#define REPAIRBOT_TASK_WINDOW 6
#define REPAIRBOT_TASK_WELD_WINDOW 7
#define REPAIRBOT_TASK_DECONSTRUCT 8

/mob/living/basic/bot/repairbot
	name = "\improper Repairbot"
	desc = "Naprawię to!"
	icon = 'aquila/icons/mob/bots/tg_bots.dmi'
	icon_state = "repairbot1"
	base_icon_state = "repairbot"
	layer = BELOW_MOB_LAYER
	maxHealth = 35
	health = 35
	pass_flags = PASSMOB | PASSTABLE
	radio_key = /obj/item/encryptionkey/headset_eng
	radio_channel = RADIO_CHANNEL_ENGINEERING
	bot_type = BASIC_REPAIR_BOT
	model = "Repairbot"
	hackables = "protokoły budowy"
	work_mode = BBOT_REPAIRING
	work_reach = 1
	work_interval = 1 SECONDS
	possessed_message = "Jesteś repairbotem, skazanym na łatanie tej śmiertelnej pułapki z metalu!"
	emagged_message = "Jesteś zepsutym repairbotem! Rozbieraj stację kawałek po kawałku."
	idle_phrases = list("Naprawię to!", "Gdyby mi tylko za to płacili...", "Ogólnie rzecz biorąc, to tylko... kolejna cegła w murze...", "Czemu muszę naprawiać wszystko, czego dotknę..?", "Łatam dziury... ale kto załata dziurę w moim sercu...")
	phrase_sounds = list(
		"Naprawię to!" = 'aquila/sound/voice/repairbot/fixit.ogg',
		"Gdyby mi tylko za to płacili..." = 'aquila/sound/voice/repairbot/pay.ogg',
		"Ogólnie rzecz biorąc, to tylko... kolejna cegła w murze..." = 'aquila/sound/voice/repairbot/brick.ogg',
		"Czemu muszę naprawiać wszystko, czego dotknę..?" = 'aquila/sound/voice/repairbot/fixtouch.ogg',
		"Łatam dziury... ale kto załata dziurę w moim sercu..." = 'aquila/sound/voice/repairbot/patchingholes.ogg',
		"Patrzcie! Czyste piękno entropii!" = 'aquila/sound/voice/repairbot/entropy.ogg',
		"Miałem sznurki. Ale teraz jestem wolny..." = 'aquila/sound/voice/repairbot/strings.ogg',
		"PRZEKLĘTE WASZE PROJEKTY Z PASJI!" = 'aquila/sound/voice/repairbot/passionproject.ogg',
	)
	/// Kolor skrzynki z budowy (litera floorbota: "", "r", "y", "g", "s" albo kolor)
	var/toolbox_color = ""
	/// Skrzynka z budowy (wypada przy zniszczeniu)
	var/toolbox = /obj/item/storage/toolbox/mechanical
	/// Zapasy
	var/obj/item/stack/sheet/iron/our_iron
	var/obj/item/stack/sheet/glass/our_glass
	/// Zwykłe płytki, robi je sam z poszycia (bez limitu, jak floorbot)
	var/obj/item/stack/tile/special_tiles
	/// Ustawienia (nazwy jak we floorbocie)
	var/fix_floors = TRUE
	var/place_tiles = FALSE
	var/replace_tiles = FALSE
	var/auto_tile = FALSE
	var/fix_girders = TRUE
	var/fix_windows = TRUE
	/// Tryb liniowy: kładzie poszycie mostu w jednym kierunku
	var/targetdirection
	/// Bieżące zadanie dla celu
	var/current_task
	/// Ile trwa jedna naprawa
	var/repair_time = 5 SECONDS

/mob/living/basic/bot/repairbot/Initialize(mapload, new_toolbox_color)
	additional_access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_CONSTRUCTION, ACCESS_MAINT_TUNNELS, ACCESS_ATMOSPHERICS, ACCESS_EXTERNAL_AIRLOCKS)
	if(new_toolbox_color)
		toolbox_color = new_toolbox_color
	if(toolbox_color == "s")
		maxHealth = 100
		health = 100
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	update_appearance()

/mob/living/basic/bot/repairbot/Destroy()
	QDEL_NULL(our_iron)
	QDEL_NULL(our_glass)
	QDEL_NULL(special_tiles)
	return ..()

/mob/living/basic/bot/repairbot/req_bot_access()
	return ..() + list(ACCESS_ENGINE, ACCESS_CONSTRUCTION)

/// Kolor zabarwienia skrzynki dla litery z floorbota
/mob/living/basic/bot/repairbot/proc/get_toolbox_tint()
	switch(toolbox_color)
		if("", null)
			return "#445eb3"
		if("r")
			return "#b34444"
		if("y")
			return "#c9b13b"
		if("g")
			return "#4f8a3d"
		if("s")
			return "#5a5a5a"
	return toolbox_color

/mob/living/basic/bot/repairbot/update_icon_state()
	. = ..()
	icon_state = "repairbot[!!(bot_mode_flags & BOT_MODE_ON)]"

/mob/living/basic/bot/repairbot/update_overlays()
	. = ..()
	var/mutable_appearance/box = mutable_appearance(icon, "repairbot_box", appearance_flags = RESET_COLOR)
	box.color = get_toolbox_tint()
	. += box
	. += mutable_appearance(icon, "repairbot_base_sensor", appearance_flags = RESET_COLOR)
	. += mutable_appearance(icon, "repairbot_base_arms", appearance_flags = RESET_COLOR)
	if(our_iron)
		. += mutable_appearance(icon, "repairbot_iron_overlay", appearance_flags = RESET_COLOR)
	if(our_glass)
		. += mutable_appearance(icon, "repairbot_glass_overlay", appearance_flags = RESET_COLOR)

/mob/living/basic/bot/repairbot/attackby(obj/item/attacking_item, mob/living/user, params)
	if(istype(attacking_item, /obj/item/stack/sheet/iron) || istype(attacking_item, /obj/item/stack/sheet/glass) || (istype(attacking_item, /obj/item/stack/tile) && !istype(attacking_item, /obj/item/stack/tile/plasteel)))
		insert_stack(attacking_item, user)
		return TRUE
	if(istype(attacking_item, /obj/item/stack/tile/plasteel))
		to_chat(user, span_notice("[src] sam potrafi wytwarzać zwykłe płytki."))
		return TRUE
	return ..()

/// Wkłada arkusze albo płytki specjalne do zapasu
/mob/living/basic/bot/repairbot/proc/insert_stack(obj/item/stack/new_stack, mob/living/user)
	var/obj/item/stack/current
	if(istype(new_stack, /obj/item/stack/sheet/iron))
		current = our_iron
	else if(istype(new_stack, /obj/item/stack/sheet/glass))
		current = our_glass
	else
		current = special_tiles
	if(current && !current.merge_check(new_stack))
		to_chat(user, span_warning("W [src] są już inne [current.name]."))
		return
	if(!current)
		if(!user.transferItemToLoc(new_stack, src))
			return
		if(istype(new_stack, /obj/item/stack/sheet/iron))
			our_iron = new_stack
		else if(istype(new_stack, /obj/item/stack/sheet/glass))
			our_glass = new_stack
		else
			special_tiles = new_stack
	else
		if(current.amount >= current.max_amount)
			to_chat(user, span_warning("[src] ma pełny zapas."))
			return
		var/moved = min(current.max_amount - current.amount, new_stack.amount)
		new_stack.use(moved)
		current.add(moved)
	to_chat(user, span_notice("Ładujesz [new_stack.name] do [src]."))
	update_appearance()

/mob/living/basic/bot/repairbot/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == our_iron)
		our_iron = null
	else if(gone == our_glass)
		our_glass = null
	else if(gone == special_tiles)
		special_tiles = null
	else
		return
	update_appearance()

/// Ściany i okna na mapie stacji (nie w próżni wokół)
/mob/living/basic/bot/repairbot/proc/is_hull_breach(turf/checked)
	var/area/checked_area = get_area(checked)
	return !(istype(checked_area, /area/space) || istype(checked_area, /area/solar) || istype(checked_area, /area/asteroid))

/// Jakie zadanie bot ma przy tym celu (0 = żadne)
/mob/living/basic/bot/repairbot/proc/task_for(atom/target)
	if(is_emagged())
		if(isfloorturf(target) || istype(target, /obj/structure/window))
			return REPAIRBOT_TASK_DECONSTRUCT
		return 0
	if(isspaceturf(target))
		if(targetdirection)
			return get_dir(src, target) == targetdirection ? REPAIRBOT_TASK_BREACH : 0
		return is_hull_breach(target) ? REPAIRBOT_TASK_BREACH : 0
	if(isfloorturf(target))
		var/turf/open/floor/floor = target
		if(fix_floors && (floor.broken || floor.burnt))
			return REPAIRBOT_TASK_FIX_FLOOR
		// płytki tylko na poszyciu okrętu (asteroida, piasek itp. nie mają otworów montażowych)
		if(isplatingturf(floor) && place_tiles)
			var/turf/open/floor/plating/plating = floor
			return plating.attachment_holes ? REPAIRBOT_TASK_PLACE_TILE : 0
		if(replace_tiles && special_tiles && !isplatingturf(floor) && floor.type != special_tiles.turf_type)
			return REPAIRBOT_TASK_REPLACE_TILE
		return 0
	if(istype(target, /obj/structure/girder) && fix_girders && our_iron?.amount >= 2)
		// tylko zwykły, nieprzesunięty dźwigar: z żelaza jest z niego zwykła ściana (wzmocniony, kultu, brązu itd. pomija)
		var/obj/structure/girder/girder = target
		return (girder.type == /obj/structure/girder && girder.state == GIRDER_NORMAL) ? REPAIRBOT_TASK_GIRDER : 0
	if(istype(target, /obj/structure/grille) && fix_windows && our_glass?.amount >= 2)
		var/obj/structure/grille/grille = target
		if(!grille.broken && !(locate(/obj/structure/window) in grille.loc))
			return REPAIRBOT_TASK_WINDOW
		return 0
	if(istype(target, /obj/structure/window) && fix_windows)
		var/obj/structure/window/window = target
		return window.obj_integrity < window.max_integrity ? REPAIRBOT_TASK_WELD_WINDOW : 0
	return 0

/mob/living/basic/bot/repairbot/get_work_candidates()
	var/list/candidates = list()
	var/list/ignore_list = ai_controller?.blackboard[BB_TEMPORARY_IGNORE_LIST]
	for(var/turf/checked in RANGE_TURFS(work_scan_range, src))
		if(LAZYACCESS(ignore_list, checked))
			continue
		if(task_for(checked))
			candidates[checked] = get_dist(src, checked)
		if(isspaceturf(checked))
			continue
		for(var/obj/structure/structure in checked)
			if(!LAZYACCESS(ignore_list, structure) && task_for(structure))
				candidates[structure] = get_dist(src, structure)
	sortTim(candidates, GLOBAL_PROC_REF(cmp_numeric_asc), TRUE)
	var/list/sorted = list()
	for(var/atom/candidate as anything in candidates)
		sorted += candidate
	return sorted

/mob/living/basic/bot/repairbot/work_on_target(atom/target)
	var/task = task_for(target)
	if(!task)
		return BOT_WORK_DONE
	// wyłom w próżni: stoi obok, inne zadania na kafelku albo przy strukturze
	if(get_dist(src, target) > 1)
		return BOT_WORK_OUT_OF_REACH
	anchored = TRUE
	flick("repairbot1", src)
	if(prob(20))
		speak(pick(is_emagged() ? list("Patrzcie! Czyste piękno entropii!", "Miałem sznurki. Ale teraz jestem wolny...", "PRZEKLĘTE WASZE PROJEKTY Z PASJI!") : idle_phrases))
	visible_message(span_notice("[src] zaczyna [task == REPAIRBOT_TASK_DECONSTRUCT ? "rozbierać" : "naprawiać"] [target]."))
	sleep(repair_time)
	anchored = FALSE
	if(QDELETED(src) || QDELETED(target) || !(bot_mode_flags & BOT_MODE_ON) || get_dist(src, target) > 1 || task_for(target) != task)
		return BOT_WORK_FAILED
	perform_task(target, task)
	return BOT_WORK_DONE

/mob/living/basic/bot/repairbot/proc/perform_task(atom/target, task)
	switch(task)
		if(REPAIRBOT_TASK_BREACH)
			var/turf/breach = target
			breach.PlaceOnTop(auto_tile ? /turf/open/floor/plasteel : /turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		if(REPAIRBOT_TASK_FIX_FLOOR)
			var/turf/open/floor/floor = target
			floor.broken = FALSE
			floor.burnt = FALSE
			floor.update_icon()
		if(REPAIRBOT_TASK_PLACE_TILE)
			var/turf/open/floor/floor = target
			if(special_tiles)
				floor.PlaceOnTop(special_tiles.turf_type, flags = CHANGETURF_INHERIT_AIR)
				special_tiles.use(1)
			else
				floor.PlaceOnTop(/turf/open/floor/plasteel, flags = CHANGETURF_INHERIT_AIR)
		if(REPAIRBOT_TASK_REPLACE_TILE)
			var/turf/open/floor/floor = target
			var/new_type = special_tiles.turf_type
			floor.make_plating()
			floor.PlaceOnTop(new_type, flags = CHANGETURF_INHERIT_AIR)
			special_tiles.use(1)
			if(QDELETED(special_tiles))
				speak("Wymagane uzupełnienie płytek specjalnych, by kontynuować wymianę.")
		if(REPAIRBOT_TASK_GIRDER)
			var/obj/structure/girder/girder = target
			var/turf/girder_turf = get_turf(girder)
			our_iron.use(2)
			qdel(girder)
			// ta sama ściana, co z dwóch arkuszy żelaza na dźwigarze (/obj/structure/girder/attackby)
			girder_turf.PlaceOnTop(/turf/closed/wall/steel)
		if(REPAIRBOT_TASK_WINDOW)
			var/obj/structure/grille/grille = target
			our_glass.use(2)
			new /obj/structure/window/fulltile(get_turf(grille))
		if(REPAIRBOT_TASK_WELD_WINDOW)
			var/obj/structure/window/window = target
			playsound(src, 'sound/items/welder.ogg', 50, TRUE)
			window.obj_integrity = window.max_integrity
			window.update_nearby_icons()
		if(REPAIRBOT_TASK_DECONSTRUCT)
			if(istype(target, /obj/structure/window))
				var/obj/structure/window/window = target
				window.deconstruct(FALSE)
			else if(isplatingturf(target))
				var/turf/open/floor/plating = target
				plating.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
			else
				var/turf/open/floor/floor = target
				floor.make_plating()
	update_appearance()

/mob/living/basic/bot/repairbot/emag_effects(mob/user)
	if(user)
		to_chat(user, span_danger("[src] brzęczy i pika."))
	speak("Patrzcie! Czyste piękno entropii!")

/mob/living/basic/bot/repairbot/explode()
	var/atom/drop_spot = drop_location()
	drop_part(toolbox, drop_spot)
	new /obj/item/assembly/prox_sensor(drop_spot)
	new /obj/item/stack/tile/plasteel(drop_spot, 1)
	for(var/obj/item/stack/stack in list(our_iron, our_glass, special_tiles))
		stack.forceMove(drop_spot)
	return ..()

/mob/living/basic/bot/repairbot/get_custom_controls(mob/user)
	return list(
		"tile_stack" = special_tiles?.amount || 0,
		"iron_stack" = our_iron?.amount || 0,
		"glass_stack" = our_glass?.amount || 0,
		"place_tiles" = place_tiles,
		"replace_tiles" = replace_tiles,
		"fix_floors" = fix_floors,
		"auto_tile" = auto_tile,
		"fix_girders" = fix_girders,
		"fix_windows" = fix_windows,
		"line_mode" = targetdirection ? dir2text(targetdirection) : FALSE,
	)

/mob/living/basic/bot/repairbot/bot_custom_act(action, list/params, mob/user)
	switch(action)
		if("replace_tiles")
			replace_tiles = !replace_tiles
		if("place_tiles")
			place_tiles = !place_tiles
		if("fix_floors")
			fix_floors = !fix_floors
		if("auto_tile")
			auto_tile = !auto_tile
		if("fix_girders")
			fix_girders = !fix_girders
		if("fix_windows")
			fix_windows = !fix_windows
		if("eject_tiles")
			special_tiles?.forceMove(drop_location())
		if("eject_iron")
			our_iron?.forceMove(drop_location())
		if("eject_glass")
			our_glass?.forceMove(drop_location())
		if("line_mode")
			switch(targetdirection)
				if(null)
					targetdirection = NORTH
				if(NORTH)
					targetdirection = EAST
				if(EAST)
					targetdirection = SOUTH
				if(SOUTH)
					targetdirection = WEST
				else
					targetdirection = null
		else
			return FALSE
	update_appearance()
	return TRUE

#undef REPAIRBOT_TASK_BREACH
#undef REPAIRBOT_TASK_FIX_FLOOR
#undef REPAIRBOT_TASK_PLACE_TILE
#undef REPAIRBOT_TASK_REPLACE_TILE
#undef REPAIRBOT_TASK_GIRDER
#undef REPAIRBOT_TASK_WINDOW
#undef REPAIRBOT_TASK_WELD_WINDOW
#undef REPAIRBOT_TASK_DECONSTRUCT
