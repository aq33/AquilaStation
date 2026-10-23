// AQUILA - Dół bingli, port z Monkestation (monkestation/code/modules/veth_misc_items/bingle/bingle_pit.dm)
// Różnice: wymiar Dołu to mapa z Monke załadowana w rezerwacji (u nas nie ma lazy templates), Dół przetwarza SSobj
// zamiast osobnego subsystemu, a rzucone przedmioty wpadają do Dołu na polu, na którym lądują (także na krawędzi).

/// Wymiar Dołu: rezerwacja z mapą, tworzona przy pierwszym połknięciu
GLOBAL_DATUM(bingle_pit_reservation, /datum/turf_reservation)
/// Wolne pola wymiaru, na które trafiają połknięte rzeczy
GLOBAL_LIST_EMPTY(bingle_pit_turfs)
/// Wszystkie Doły w rundzie
GLOBAL_LIST_EMPTY(bingle_holes)

/area/centcom/bingle_pit
	name = "Dół bingli"
	icon_state = "away"
	has_gravity = STANDARD_GRAVITY
	ambience_index = AMBIENCE_SPOOKY
	area_flags = HIDDEN_AREA | UNIQUE_AREA
	teleport_restriction = TELEPORT_ALLOW_NONE
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/turf/open/indestructible/bingle
	name = "dno dołu bingli"
	desc = "Dno dołu bingli. Niebieskie i nie do zniszczenia."
	icon = 'aquila/icons/mob/bingle/bingle_floor.dmi'
	icon_state = "carpet_orange-0"
	base_icon_state = "carpet_orange"
	smooth = SMOOTH_TRUE
	bitmask_smooth = TRUE
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open/indestructible/bingle/bitmask_connects_to(turf/T)
	return istype(T, /turf/open/indestructible/bingle)

/turf/closed/indestructible/bingle
	name = "ściana dołu bingli"
	desc = "Jest niebieska... I tyle da się o niej powiedzieć. Nie da się jej zniszczyć."
	icon = 'aquila/icons/mob/bingle/bingle_wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	smooth = SMOOTH_TRUE
	bitmask_smooth = TRUE

/turf/closed/indestructible/bingle/bitmask_connects_to(turf/T)
	return istype(T, /turf/closed/indestructible/bingle)

/datum/map_template/bingle_pit
	name = "Dół bingli"
	mappath = 'aquila/_maps/templates/bingle_pit.dmm'

/// Zwraca losowe wolne pole wymiaru, w razie potrzeby najpierw go ładując
/proc/get_random_bingle_pit_turf()
	if(!GLOB.bingle_pit_reservation)
		create_bingle_pit_dimension()
	var/list/eligible_turfs = list()
	for(var/turf/open/open_turf as anything in GLOB.bingle_pit_turfs)
		if(!is_blocked_turf(open_turf, exclude_mobs = TRUE))
			eligible_turfs += open_turf
	if(length(eligible_turfs))
		return pick(eligible_turfs)
	if(length(GLOB.bingle_pit_turfs))
		return pick(GLOB.bingle_pit_turfs)

/proc/create_bingle_pit_dimension()
	if(GLOB.bingle_pit_reservation)
		return
	var/datum/map_template/bingle_pit/template = new
	var/datum/turf_reservation/reservation = SSmapping.RequestBlockReservation(template.width, template.height)
	if(!reservation)
		log_world("Bingle pit: unable to reserve space")
		return
	GLOB.bingle_pit_reservation = reservation
	if(!template.load(locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])))
		log_world("Bingle pit: unable to load the template")
		QDEL_NULL(GLOB.bingle_pit_reservation)
		return
	// Jak w komorze testowej: loader potrafi zostawić 0 kPa, bo dookoła jest kosmos rezerwacji
	for(var/turf/open/indestructible/bingle/floor in reservation.reserved_turfs)
		floor.Initalize_Atmos(0)
		GLOB.bingle_pit_turfs += floor
	log_game("Bingle pit dimension loaded.")

/// Wyrzuca wszystko z wymiaru Dołu na podane pole
/proc/eject_bingle_hole_contents(turf/target_turf)
	if(!target_turf)
		return
	for(var/turf/pit_turf as anything in GLOB.bingle_pit_turfs)
		for(var/atom/movable/thing as anything in pit_turf)
			if(thing.anchored || iseffect(thing) || isobserver(thing))
				continue
			thing.forceMove(target_turf)
			if(QDELETED(thing))
				continue
			var/turf/edge = get_edge_target_turf(target_turf, pick(GLOB.alldirs))
			thing.throw_at(edge, rand(1, 5), rand(1, 5))
		CHECK_TICK

/obj/structure/bingle_hole
	name = "bingle pit"
	desc = "Wszystkożerny dół niekończących się okropieństw... i bingli."
	icon = 'aquila/icons/mob/bingle/binglepit.dmi'
	icon_state = "binglepit"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 75, "bomb" = 99.5, "bio" = 100, "rad" = 100, "fire" = 50, "acid" = 80, "stamina" = 0, "bleed" = 0)
	max_integrity = 500
	light_color = COLOR_BLUE_LIGHT
	light_range = 5
	anchored = TRUE
	density = FALSE
	layer = TURF_LAYER + 0.1
	/// Ile punktów Dół już połknął
	var/item_value_consumed = 0
	/// Bok kwadratu Dołu
	var/current_pit_size = 1
	/// Nakładki większego Dołu
	var/list/pit_overlays = list()
	/// Przy ilu punktach była ostatnia ankieta na bingla
	var/last_bingle_spawn_value = 0
	/// Z jakiej odległości od środka bingle się leczą
	var/healing_range = 3
	/// Czy bingle są już pancerne
	var/armored = FALSE
	/// Czy było już ogłoszenie o zjadaniu stacji
	var/announcement_made = FALSE
	/// Rzeczy, które właśnie spadają, żeby nie liczyć ich dwa razy
	var/list/falling = list()
	/// Typy, których Dół nie połyka
	var/static/list/swallow_blacklist
	COOLDOWN_DECLARE(bomb_cooldown)

/obj/structure/bingle_hole/Initialize(mapload)
	. = ..()
	if(isnull(swallow_blacklist))
		swallow_blacklist = typecacheof(list(
			/mob/living/simple_animal/hostile/bingle,
			/obj/effect,
			/obj/item/projectile,
			/obj/structure/bingle_hole,
			/obj/structure/bingle_pit_overlay,
		))
	GLOB.bingle_holes += src
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	START_PROCESSING(SSobj, src)

/obj/structure/bingle_hole/Destroy()
	STOP_PROCESSING(SSobj, src)
	GLOB.bingle_holes -= src
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(eject_bingle_hole_contents), get_turf(src))
	QDEL_LIST(pit_overlays)
	// Co jeszcze spadało, zostaje na miejscu
	for(var/mob/living/falling_mob in falling)
		falling_mob.notransform = FALSE
	falling.Cut()
	return ..()

/obj/structure/bingle_hole/examine(mob/user)
	. = ..()
	if(IS_BINGLE(user) || !isliving(user))
		. += "<span class='alert'>Dół bingli połknął już [item_value_consumed] punktów!</span>"
		. += "<span class='notice'>Istoty są warte więcej, ale Dół przyjmie je dopiero od [BINGLE_PIT_LIVING_THRESHOLD] punktów.</span>"

/obj/structure/bingle_hole/CanAStarPass(obj/item/card/id/ID, to_dir, atom/movable/caller)
	if(!isliving(caller) || isbingle(caller))
		return TRUE
	var/mob/living/walker = caller
	return !walker.has_gravity() || (walker.movement_type & (FLYING | FLOATING))

/obj/structure/bingle_hole/ex_act(severity, target)
	if(!COOLDOWN_FINISHED(src, bomb_cooldown))
		return FALSE
	COOLDOWN_START(src, bomb_cooldown, 2 SECONDS)
	return ..()

/obj/structure/bingle_hole/attackby(obj/item/W, mob/user, params)
	if(isbingle(user))
		to_chat(user, "<span class='warning'>Twoje bingle-łapki przechodzą przez Dół bez szkody!</span>")
		return TRUE
	return ..()

/obj/structure/bingle_hole/attack_hand(mob/user, list/modifiers)
	if(isbingle(user))
		to_chat(user, "<span class='warning'>Twoje bingle-łapki przechodzą przez Dół bez szkody!</span>")
		return TRUE
	return ..()

/obj/structure/bingle_hole/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(isbingle(user))
		to_chat(user, "<span class='warning'>Nie potrafisz skrzywdzić świętego Dołu!</span>")
		return FALSE
	return ..()

/obj/structure/bingle_hole/proc/on_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	swallow(arrived)

/obj/structure/bingle_hole/process(delta_time)
	// Ankieta na bingla co 50 punktów, osobno za każdy przekroczony próg
	while(item_value_consumed >= last_bingle_spawn_value + BINGLE_PIT_SPAWN_STEP)
		last_bingle_spawn_value += BINGLE_PIT_SPAWN_STEP
		INVOKE_ASYNC(src, PROC_REF(spawn_bingle_from_ghost))

	var/desired_pit_size = min(1 + round(item_value_consumed / BINGLE_PIT_GROW_STEP), BINGLE_PIT_MAX_SIZE)
	if(desired_pit_size > current_pit_size)
		grow_pit(desired_pit_size)

	if(!armored && item_value_consumed >= BINGLE_PIT_ARMOR_THRESHOLD)
		armored = TRUE
		for(var/mob/living/simple_animal/hostile/bingle/bingle in GLOB.mob_living_list)
			if(bingle.linked_pit == src && bingle.stat != DEAD)
				bingle.evolve()

/obj/structure/bingle_hole/proc/get_item_value(atom/movable/thing)
	if(isliving(thing))
		return 10
	if(isstack(thing))
		var/obj/item/stack/stack = thing
		return stack.amount
	return 1

/obj/structure/bingle_hole/proc/swallow(atom/movable/item)
	if(QDELETED(src) || QDELETED(item) || item == src)
		return
	if(is_type_in_typecache(item, swallow_blacklist) || (item.flags_1 & HOLOGRAM_1))
		return
	if(falling[item])
		return
	if(item.throwing && item.throwing.target_turf != get_turf(item)) // przez Dół można przerzucać rzeczy
		return
	if(swallow_mob(item) || swallow_obj(item))
		item.pulledby?.stop_pulling()
		item.stop_pulling()
		item.unbuckle_all_mobs()

/obj/structure/bingle_hole/proc/swallow_mob(mob/living/victim)
	if(!isliving(victim))
		return FALSE
	if(victim.buckled || victim.incorporeal_move || victim.notransform)
		return FALSE
	if(victim.mobility_flags & MOBILITY_STAND)
		if(!victim.has_gravity())
			return FALSE
		if(victim.movement_type & (FLYING | FLOATING))
			return FALSE
	if(item_value_consumed < BINGLE_PIT_LIVING_THRESHOLD)
		var/turf/target = get_edge_target_turf(src, pick(GLOB.alldirs))
		victim.throw_at(target, rand(1, 5), rand(1, 5))
		to_chat(victim, "<span class='warning'>Dół nie połknął jeszcze dość przedmiotów, żeby przyjmować istoty!</span>")
		return FALSE
	falling[victim] = TRUE
	victim.notransform = TRUE
	item_value_consumed += get_item_value(victim)
	log_combat(victim, src, "fell into", addition = "(pit value: [item_value_consumed])")
	animate_falling_into_pit(victim)
	addtimer(CALLBACK(src, PROC_REF(finish_swallow), victim), 1 SECONDS)
	return TRUE

/obj/structure/bingle_hole/proc/swallow_obj(obj/thing)
	if(!isobj(thing))
		return FALSE
	falling[thing] = TRUE
	item_value_consumed += get_item_value(thing)
	for(var/atom/movable/content as anything in thing.GetAllContents(ignore_flag_1 = HOLOGRAM_1) - thing)
		if(QDELETED(content) || falling[content] || isbrain(content))
			continue
		if(isliving(content) || is_type_in_typecache(content, swallow_blacklist))
			if(istype(content, /obj/item/projectile))
				continue
			content.forceMove(content.drop_location())
		else if(isobj(content))
			item_value_consumed += get_item_value(content)
	animate_falling_into_pit(thing)
	addtimer(CALLBACK(src, PROC_REF(finish_swallow), thing), 1 SECONDS)
	return TRUE

/obj/structure/bingle_hole/proc/finish_swallow(atom/movable/swallowed)
	falling -= swallowed
	if(QDELETED(swallowed))
		return
	var/mob/living/swallowed_mob = isliving(swallowed) ? swallowed : null
	if(swallowed_mob)
		swallowed_mob.notransform = FALSE
	if(QDELETED(src))
		return
	var/turf/bingle_pit_turf = get_random_bingle_pit_turf()
	// Bez wymiaru połknięta rzecz zostaje tam, gdzie była, zamiast znikać
	if(bingle_pit_turf)
		swallowed.forceMove(bingle_pit_turf)

/obj/structure/bingle_hole/proc/animate_falling_into_pit(atom/movable/item)
	var/turf/item_turf = get_turf(item)
	var/turf/pit_turf = get_turf(src)
	if(isnull(item_turf) || isnull(pit_turf))
		return
	playsound(item_turf, 'sound/effects/gravhit.ogg', 50, TRUE)
	var/original_px = item.pixel_x
	var/original_py = item.pixel_y
	var/original_alpha = item.alpha
	var/matrix/original_transform = matrix(item.transform)
	var/dx = pit_turf.x - item_turf.x
	var/dy = pit_turf.y - item_turf.y
	// Kręci się i kurczy, lecąc do środka Dołu, a potem wraca do normalnego wyglądu
	animate(item, pixel_x = original_px + dx * world.icon_size, pixel_y = original_py + dy * world.icon_size, transform = turn(original_transform, 360) * 0.3, alpha = 100, time = 0.8 SECONDS, easing = EASE_IN)
	animate(transform = turn(original_transform, 720) * 0.1, alpha = 0, time = 0.2 SECONDS, easing = EASE_IN)
	animate(pixel_x = original_px, pixel_y = original_py, alpha = original_alpha, transform = original_transform, time = 0.5 SECONDS, easing = EASE_IN)
	new /obj/effect/temp_visual/bingle_pit_swirl(pit_turf)

/obj/effect/temp_visual/bingle_pit_swirl
	name = "wirująca pustka"
	desc = "Rzeczywistość wygina się wokół Dołu..."
	icon = 'icons/effects/effects.dmi'
	icon_state = "quantum_sparks"
	layer = ABOVE_MOB_LAYER
	duration = 1.5 SECONDS
	alpha = 150

/obj/effect/temp_visual/bingle_pit_swirl/Initialize(mapload)
	. = ..()
	animate(src, transform = turn(transform, 360), time = 1 SECONDS)
	animate(alpha = 0, time = 0.5 SECONDS)

/obj/structure/bingle_hole/proc/grow_pit(new_size)
	new_size = min(new_size, BINGLE_PIT_MAX_SIZE)
	if(current_pit_size >= new_size)
		return
	var/turf/origin = get_turf(src)
	if(!origin)
		return
	QDEL_LIST(pit_overlays)
	icon_state = "" // nakładki rysują cały Dół

	// Parzyste rozmiary rosną w prawo i w górę
	var/start_coord
	var/end_coord
	if(new_size % 2)
		end_coord = (new_size - 1) / 2
		start_coord = -end_coord
	else
		end_coord = new_size / 2
		start_coord = -(end_coord - 1)

	for(var/dx in start_coord to end_coord)
		for(var/dy in start_coord to end_coord)
			var/turf/T = locate(origin.x + dx, origin.y + dy, origin.z)
			if(!T)
				continue
			var/icon_state_to_use
			if(dx == start_coord && dy == end_coord)
				icon_state_to_use = "corner_north"
			else if(dx == end_coord && dy == end_coord)
				icon_state_to_use = "corner_west"
			else if(dx == end_coord && dy == start_coord)
				icon_state_to_use = "corner_south"
			else if(dx == start_coord && dy == start_coord)
				icon_state_to_use = "corner_east"
			else if(dy == end_coord)
				icon_state_to_use = "edge_north"
			else if(dy == start_coord)
				icon_state_to_use = "edge_south"
			else if(dx == start_coord)
				icon_state_to_use = "edge_west"
			else if(dx == end_coord)
				icon_state_to_use = "edge_east"
			else
				icon_state_to_use = "filler"

			var/obj/structure/bingle_pit_overlay/overlay = new(T, src)
			overlay.icon_state = icon_state_to_use
			pit_overlays += overlay

			// Większy niż 3x3 Dół pożera ściany i gęste struktury
			if(new_size > 3)
				for(var/obj/structure/thing in T)
					if(thing.density && !istype(thing, /obj/structure/bingle_pit_overlay))
						swallow(thing)
				if(iswallturf(T))
					T.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
					item_value_consumed++
				if(!announcement_made)
					announcement_made = TRUE
					priority_announce("Na pokładzie [station_name()] wykryto niebieską falę. Cała załoga ma natychmiast powstrzymać pożeranie statku.", "Alarm biologiczny", ANNOUNCER_OUTBREAK5)
	current_pit_size = new_size
	healing_range = max(round(new_size / 2, 1) + 2, 3)

/// Spawnuje bingla dla ducha z ankiety
/obj/structure/bingle_hole/proc/spawn_bingle_from_ghost()
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Chcesz zagrać jako bingiel? Po śmierci wrócisz do poprzedniego ciała.", ROLE_BINGLE, /datum/role_preference/midround_ghost/bingle, 20 SECONDS, POLL_IGNORE_BINGLE, alert_pic = src)
	if(!length(candidates) || QDELETED(src))
		return
	var/turf/spawn_loc = get_turf(src)
	if(isnull(spawn_loc))
		return
	var/mob/dead/observer/selected = pick(candidates)
	var/datum/mind/ghost_mind = selected.mind
	var/mob/living/simple_animal/hostile/bingle/bingle = new(spawn_loc, src)
	if(armored)
		bingle.evolve(fresh = TRUE)
	bingle.key = selected.key
	if(ghost_mind)
		bingle.AddComponent(/datum/component/temporary_body, ghost_mind, ghost_mind.current, TRUE)
	if(bingle.mind && !IS_BINGLE(bingle))
		bingle.mind.add_antag_datum(/datum/antagonist/bingle)
	message_admins("[ADMIN_LOOKUPFLW(bingle)] has been made into a bingle (pit spawn).")
	log_game("[key_name(bingle)] was spawned as a bingle by the pit.")

/obj/structure/bingle_pit_overlay
	name = "bingle pit"
	desc = "Wszystkożerny dół niekończących się okropieństw... i bingli."
	icon = 'aquila/icons/mob/bingle/binglepit.dmi'
	layer = TURF_LAYER + 0.5
	plane = GAME_PLANE
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	resistance_flags = INDESTRUCTIBLE
	/// Dół, do którego należy nakładka
	var/obj/structure/bingle_hole/parent_pit

/obj/structure/bingle_pit_overlay/Initialize(mapload, obj/structure/bingle_hole/parent_pit)
	. = ..()
	src.parent_pit = parent_pit
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/bingle_pit_overlay/Destroy()
	parent_pit?.pit_overlays -= src
	parent_pit = null
	return ..()

/obj/structure/bingle_pit_overlay/proc/on_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(!QDELETED(src) && !QDELETED(parent_pit))
		parent_pit.swallow(arrived)

/obj/structure/bingle_pit_overlay/examine(mob/user)
	. = ..()
	if(parent_pit)
		. += "<span class='alert'>Dół bingli połknął już [parent_pit.item_value_consumed] punktów! Istoty są warte więcej, ale Dół przyjmie je dopiero od [BINGLE_PIT_LIVING_THRESHOLD] punktów.</span>"

/obj/structure/bingle_pit_overlay/CanAStarPass(obj/item/card/id/ID, to_dir, atom/movable/caller)
	return parent_pit ? parent_pit.CanAStarPass(ID, to_dir, caller) : TRUE

/obj/structure/bingle_pit_overlay/ex_act(severity, target)
	return parent_pit?.ex_act(severity, target)

/obj/structure/bingle_pit_overlay/attackby(obj/item/W, mob/user, params)
	if(parent_pit)
		return parent_pit.attackby(W, user, params)
	return ..()

/obj/structure/bingle_pit_overlay/attack_hand(mob/user, list/modifiers)
	if(parent_pit)
		return parent_pit.attack_hand(user, modifiers)
	return ..()

/obj/structure/bingle_pit_overlay/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(parent_pit)
		return parent_pit.attack_animal(user, modifiers)
	return ..()

/obj/structure/bingle_pit_overlay/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	if(isbingle(P.firer))
		return BULLET_ACT_FORCE_PIERCE
	if(parent_pit)
		return parent_pit.bullet_act(P, def_zone, piercing_hit)
	return ..()
