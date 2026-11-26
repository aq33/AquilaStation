/// AQUILA - abordaż kapsułą desantową (plan walki na overmapie, etap E4). Wyrzutnia kapsuł z planet (planets/drop_pod.dm)
/// dostaje drugi rodzaj celu: wrogi okręt w układzie, który ma wnętrze abordażu i zbite tarcze. Kapsuła leci po overmapie
/// jak torpeda, więc obrona punktowa celu może ją zestrzelić; pasażer zestrzelonej kapsuły ląduje ranny w kosmosie przy
/// własnym okręcie. Trafiona kapsuła wczytuje wnętrze celu (ai_load_interior, jak harpun), spada na losową podłogę,
/// wybija sąsiednią ścianę i zostawia wyrwę. Lot jest w jedną stronę: wraca się promem, harpunem albo teleportem.

/// Obrażenia pasażera zestrzelonej kapsuły (min, max)
#define BOARDING_POD_CRASH_MIN 50
#define BOARDING_POD_CRASH_MAX 80
/// Jak DROP_POD_RECHARGE i DROP_POD_FALL_TIME w planets/drop_pod.dm (tam są #undef na końcu pliku)
#define BOARDING_POD_RECHARGE (2 MINUTES)
#define BOARDING_POD_FALL_TIME (0.6 SECONDS)

/obj/machinery/drop_pod_bay
	/// AQUILA - wrogi okręt jako cel zrzutu (abordaż); null = cel na planecie
	var/obj/structure/overmap/target_ship

/obj/machinery/drop_pod_bay/Destroy()
	target_ship = null
	return ..()

/// Okręty, na które można zrzucić kapsułę: wrogie, w tym samym układzie, z wnętrzem abordażu i bez tarcz
/obj/machinery/drop_pod_bay/proc/available_ships()
	. = list()
	var/obj/structure/overmap/ship = get_overmap()
	if(!ship?.z)
		return
	for(var/obj/structure/overmap/OM as anything in ship.current_system?.system_contents)
		if(boarding_pod_target_blocked(ship, OM))
			continue
		. += OM

/// Powód, dla którego kapsuła nie poleci na okręt target, albo null
/proc/boarding_pod_target_blocked(obj/structure/overmap/ship, obj/structure/overmap/target)
	if(!istype(target) || QDELETED(target) || target == ship || target.z != ship?.z)
		return "Cel zniknął z układu."
	if(target.faction == ship.faction || isasteroid(target) || istype(target, /obj/structure/overmap/small_craft))
		return "To nie jest wrogi okręt."
	if(target.interior_mode == NO_INTERIOR || target.interior_mode == INTERIOR_DYNAMIC || !length(target.possible_interior_maps))
		return "Okręt nie ma pokładu, na który da się wejść."
	if(target.harpoon_shields_up())
		return "Tarcze celu są aktywne."
	return null

/obj/machinery/drop_pod_bay/choose_target(mob/living/user)
	if(user.buckled != src || !ready)
		return
	var/list/ships = available_ships()
	if(!length(ships))
		return ..()
	var/obj/structure/overmap/ship = get_overmap()
	var/list/options = list("Planeta" = "planet")
	var/range = ship.dradis ? ship.dradis.sensor_range : SENSOR_RANGE_DEFAULT
	for(var/obj/structure/overmap/OM as anything in ships)
		options["Abordaż: [ship.get_contact_label(OM, ship.is_contact_identified(OM, range))]"] = OM
	var/choice = tgui_input_list(user, "Dokąd leci kapsuła?", "Cel zrzutu", options)
	if(!choice || user.buckled != src)
		return
	if(options[choice] == "planet")
		return ..()
	set_ship_target(user, options[choice], choice)

/obj/machinery/drop_pod_bay/set_target(mob/living/user, obj/structure/overmap/planet/planet, turf/T, new_name)
	target_ship = null
	return ..()

/obj/machinery/drop_pod_bay/proc/set_ship_target(mob/living/user, obj/structure/overmap/OM, new_name)
	target_ship = OM
	target_planet = null
	target_turf = get_turf(OM) // tylko dla świateł gotowości na luku (update_overlays)
	target_name = new_name
	update_icon()
	playsound(src, 'sound/machines/twobeep.ogg', 30, TRUE)
	to_chat(user, span_notice("Cel zrzutu: [target_name]. Kapsuła poleci po overmapie i może zostać zestrzelona. Odpal ją akcją „Zrzut”."))

/obj/machinery/drop_pod_bay/launch(mob/living/user)
	if(!target_ship)
		return ..()
	if(user.buckled != src || !ready)
		return
	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, span_warning("Wyrzutnia nie ma zasilania."))
		return
	var/obj/structure/overmap/ship = get_overmap()
	var/blocked = boarding_pod_target_blocked(ship, target_ship)
	if(blocked)
		to_chat(user, span_warning("[blocked] Wybierz inny cel."))
		target_ship = null
		target_turf = null
		update_icon()
		return
	var/obj/structure/overmap/target = target_ship
	ready = FALSE
	use_power(active_power_usage)
	unbuckle_mob(user, TRUE)
	var/obj/structure/drop_pod/pod = new(get_turf(src))
	user.forceMove(pod)
	update_icon()
	pod.launch_at_ship(ship, target)
	visible_message(span_notice("Kapsuła w [src] zamyka się i z hukiem wylatuje w stronę [target_name]."))
	log_game("[key_name(user)] launched a boarding pod from [AREACOORD(src)] at [target]")
	target_ship = null
	target_turf = null
	target_name = null
	addtimer(CALLBACK(src, PROC_REF(recharge)), BOARDING_POD_RECHARGE)

// ---- Lot kapsuły na okręt ----

/obj/structure/drop_pod
	/// AQUILA - okręt, z którego wystartowała kapsuła abordażowa (tam ląduje pasażer zestrzelonej kapsuły)
	var/obj/structure/overmap/boarding_source

/obj/structure/drop_pod/Destroy()
	boarding_source = null
	return ..()

/// Start na okręt: zamyka się, wylatuje z luku, a na overmapie odpala pocisk-kapsułę w cel
/obj/structure/drop_pod/proc/launch_at_ship(obj/structure/overmap/source, obj/structure/overmap/target)
	origin = get_turf(src)
	boarding_source = source
	flick("singlepod_green_closing", src)
	playsound(src, 'aquila/sound/planets/escape_pod_launch.ogg', 70)
	addtimer(CALLBACK(src, PROC_REF(leave_to_ship), target), 2 SECONDS)

/obj/structure/drop_pod/proc/leave_to_ship(obj/structure/overmap/target)
	animate(src, pixel_z = 500, alpha = 0, time = 0.8 SECONDS, easing = QUAD_EASING | EASE_IN)
	addtimer(CALLBACK(src, PROC_REF(fly_to_ship), target), 0.8 SECONDS)

/obj/structure/drop_pod/proc/fly_to_ship(obj/structure/overmap/target)
	moveToNullspace()
	if(QDELETED(boarding_source) || QDELETED(target))
		abort_drop()
		return
	var/obj/item/projectile/guided_munition/boarding_pod/flight = boarding_source.fire_projectile(/obj/item/projectile/guided_munition/boarding_pod, target)
	if(!istype(flight))
		abort_drop()
		return
	flight.pod = src
	flight.pod_target = target

/// Kapsuła dotarła do celu: wczytanie wnętrza i lądowanie na losowej podłodze z wybiciem ściany
/obj/structure/drop_pod/proc/arrive_at_ship(obj/structure/overmap/target)
	set waitfor = FALSE
	if(QDELETED(target) || !boarding_source || !target.ai_load_interior(boarding_source))
		for(var/mob/living/passenger in contents)
			to_chat(passenger, span_warning("Kapsuła nie znalazła miejsca do przebicia się na pokład celu."))
		abort_drop()
		return
	var/turf/landing = target.random_boarding_floor()
	if(!landing)
		abort_drop()
		return
	forceMove(landing)
	pixel_z = 500
	alpha = 255
	animate(src, pixel_z = 0, time = BOARDING_POD_FALL_TIME, easing = LINEAR_EASING)
	addtimer(CALLBACK(src, PROC_REF(impact_on_ship)), BOARDING_POD_FALL_TIME)

/obj/structure/drop_pod/proc/impact_on_ship()
	var/turf/T = get_turf(src)
	playsound(T, 'aquila/sound/planets/droppod_impact.ogg', 100, FALSE, 10)
	// Wybuch w wybijanej ścianie, nie pod kapsułą: podsystem wybuchów liczy go z opóźnieniem, więc pasażer pod
	// wybuchem dostawał go już po otwarciu kapsuły (~90 obrażeń). Kapsuła otwiera się dopiero po jego przeliczeniu.
	var/turf/breach = breach_adjacent_wall(T)
	explosion(breach || T, 0, 0, breach ? 1 : 0, 3, adminlog = FALSE)
	addtimer(CALLBACK(src, PROC_REF(open)), 2 SECONDS)

/// Wybija jedną sąsiednią ścianę (wyrwa, którą załoga celu musi łatać)
/proc/breach_adjacent_wall(turf/T)
	for(var/dir in shuffle(GLOB.cardinals.Copy()))
		var/turf/closed/wall/W = get_step(T, dir)
		if(istype(W)) // niezniszczalne ściany to /turf/closed/indestructible, nie /wall
			W.dismantle_wall(TRUE)
			return W
	return null

/// Zestrzelona kapsuła: pasażer ląduje ranny w kosmosie przy własnym okręcie
/obj/structure/drop_pod/proc/shot_down()
	var/turf/start = origin
	var/turf/drop = start
	if(start && boarding_source)
		drop = boarding_source.get_hazard_edge_turf(start, pick(GLOB.cardinals)) || start
	for(var/mob/living/passenger in contents)
		passenger.forceMove(drop)
		passenger.adjustBruteLoss(rand(BOARDING_POD_CRASH_MIN, BOARDING_POD_CRASH_MAX))
		to_chat(passenger, span_userdanger("Kapsuła rozpada się trafiona w locie! Wyrzuca cię w próżnię przy kadłubie twojego okrętu."))
	for(var/atom/movable/AM as anything in contents)
		AM.forceMove(drop)
	qdel(src)

/// Losowa wolna podłoga we wnętrzu okrętu (miejsce lądowania kapsuły)
/obj/structure/overmap/proc/random_boarding_floor()
	var/list/floors = list()
	for(var/area/A as anything in linked_areas)
		for(var/turf/open/floor/F in A)
			if(!is_blocked_turf(F, TRUE))
				floors += F
	return length(floors) ? pick(floors) : null

/// Kapsuła na overmapie: kierowana jak torpeda, mało wytrzymała, nie przenosi trafienia na pokład
/obj/item/projectile/guided_munition/boarding_pod
	name = "kapsuła abordażowa"
	icon = 'nsv13/icons/obj/projectiles_nsv.dmi'
	icon_state = "torpedo"
	damage = 5
	flag = "overmap_light"
	speed = 3
	obj_integrity = 40
	max_integrity = 40
	projectile_relaying_allowed = FALSE
	/// Kapsuła z pasażerem (w nullspace na czas lotu)
	var/obj/structure/drop_pod/pod
	var/obj/structure/overmap/pod_target
	var/arrived = FALSE

/obj/item/projectile/guided_munition/boarding_pod/detonate(atom/target)
	return

/obj/item/projectile/guided_munition/boarding_pod/spec_overmap_hit(obj/structure/overmap/target)
	. = ..()
	if(!pod || target != pod_target || arrived)
		return
	arrived = TRUE
	pod.arrive_at_ship(target)
	pod = null

/obj/item/projectile/guided_munition/boarding_pod/Destroy()
	// Zestrzał obsługuje kapsuła tuż po zniknięciu pocisku: pasażer wypadający na pole z pociskiem nie może go trafić
	// w trakcie jego własnego Destroy (pętla qdel)
	if(pod && !arrived && !QDELETED(pod))
		addtimer(CALLBACK(pod, TYPE_PROC_REF(/obj/structure/drop_pod, shot_down)), 0)
	pod = null
	pod_target = null
	return ..()

#undef BOARDING_POD_CRASH_MIN
#undef BOARDING_POD_CRASH_MAX
#undef BOARDING_POD_RECHARGE
#undef BOARDING_POD_FALL_TIME
