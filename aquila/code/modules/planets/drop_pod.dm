// AQUILA - wyrzutnia kapsuł desantowych, na wzór /obj/structure/droppod z TGMC (tgstation/TerraGov-Marine-Corps,
// AGPLv3): siadasz w kapsule, wybierasz cel na planecie w układzie i lecisz w dół. Zamiast minimapy TGMC cel wybiera
// się z listy lądowisk i znaczników albo kamerą nad powierzchnią. Lot jak w TGMC: kapsuła zamyka się, znika w górze,
// po kilku sekundach spada na cel i otwiera się, a jej skorupa zostaje na planecie. Powrót tylko promem. Po zrzucie
// wyrzutnia ładuje kolejną kapsułę.
// Sprite'y kapsuły i luku (aquila/icons/planets/droppod.dmi) i dźwięki (aquila/sound/planets/) z TGMC, licencja
// CC BY-NC-SA 3.0, tak jak barykady TGMC u nas.

/// Czas lotu kapsuły (od startu do pojawienia się nad celem)
#define DROP_POD_TRANSIT_TIME (8 SECONDS)
/// Czas spadania na cel
#define DROP_POD_FALL_TIME (0.6 SECONDS)

/// Czas przygotowania kolejnej kapsuły
#define DROP_POD_RECHARGE (2 MINUTES)
/// Rozrzut lądowania wokół celu
#define DROP_POD_SCATTER 2

/obj/machinery/drop_pod_bay
	name = "wyrzutnia kapsuł desantowych"
	desc = "Kapsuła na jedną osobę osadzona w luku zrzutowym. Usiądź w niej, wybierz cel na powierzchni planety w układzie i odpal. Wraca się promem."
	icon = 'aquila/icons/planets/droppod.dmi'
	icon_state = "launch_bay"
	density = TRUE
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = 0
	layer = ABOVE_MOB_LAYER
	circuit = /obj/item/circuitboard/machine/drop_pod_bay
	idle_power_usage = 50
	active_power_usage = 2000
	/// Kapsuła gotowa do startu
	var/ready = TRUE
	/// Cel zrzutu
	var/obj/structure/overmap/planet/target_planet
	var/turf/target_turf
	var/target_name
	/// Kamera wyboru celu (tylko w trakcie wyboru)
	var/mob/camera/ai_eye/remote/drop_pod_target/target_eye
	var/list/datum/action/innate/drop_pod/pod_actions = list()

/obj/machinery/drop_pod_bay/Initialize(mapload)
	. = ..()
	for(var/action_type in list(/datum/action/innate/drop_pod/target, /datum/action/innate/drop_pod/launch))
		var/datum/action/innate/drop_pod/action = new action_type
		action.bay = src
		pod_actions += action
	update_icon()

/obj/machinery/drop_pod_bay/Destroy()
	QDEL_NULL(target_eye)
	QDEL_LIST(pod_actions)
	target_planet = null
	target_turf = null
	return ..()

/// Na luku stoi kapsuła: otwarta, a z celem i siedzącym w środku z zielonymi światłami gotowości
/obj/machinery/drop_pod_bay/update_overlays()
	. = ..()
	if(!ready)
		return
	var/armed = length(buckled_mobs) && target_turf
	. += mutable_appearance(icon, armed ? "singlepod_green_active" : "singlepod_green_inactive", ABOVE_MOB_LAYER)
	if(armed)
		. += emissive_appearance(icon, "singlepod_green_active_emissive", ABOVE_MOB_LAYER)

/obj/machinery/drop_pod_bay/examine(mob/user)
	. = ..()
	if(!ready)
		. += span_notice("Wyrzutnia ładuje nową kapsułę.")
	else if(target_name)
		. += span_notice("Cel zrzutu: [target_name].")
	else
		. += span_notice("Usiądź w kapsule i wybierz cel zrzutu przyciskiem akcji.")

/obj/machinery/drop_pod_bay/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	if(!ready)
		to_chat(user, span_warning("Kapsuła jeszcze nie jest gotowa."))
		return FALSE
	if(M != user || !ishuman(M))
		to_chat(user, span_warning("Do kapsuły trzeba wsiąść samemu."))
		return FALSE
	return ..()

/obj/machinery/drop_pod_bay/post_buckle_mob(mob/living/M)
	. = ..()
	for(var/datum/action/innate/drop_pod/action as anything in pod_actions)
		action.Grant(M)
	update_icon()
	to_chat(M, span_notice("Siedzisz w kapsule desantowej. „Cel zrzutu” wybiera miejsce na planecie, „Zrzut” odpala kapsułę."))

/obj/machinery/drop_pod_bay/post_unbuckle_mob(mob/living/M)
	. = ..()
	for(var/datum/action/innate/drop_pod/action as anything in pod_actions)
		action.Remove(M)
	if(target_eye?.eye_user == M)
		QDEL_NULL(target_eye)
	update_icon()

/// Planety z powierzchnią, na które można zrzucić kapsułę (układ, w którym jest okręt z wyrzutnią)
/obj/machinery/drop_pod_bay/proc/available_planets()
	. = list()
	var/obj/structure/overmap/ship = get_overmap()
	if(!ship?.current_system)
		return
	for(var/obj/structure/overmap/planet/planet as anything in ship.current_system.get_planets())
		if(planet.z && planet.planet_type.can_land)
			. += planet

/// Wybór celu: planeta, potem lądowisko, znacznik albo punkt z kamery
/obj/machinery/drop_pod_bay/proc/choose_target(mob/living/user)
	if(user.buckled != src || !ready)
		return
	var/list/planets = available_planets()
	if(!length(planets))
		to_chat(user, span_warning("W tym układzie nie ma planety, na którą można zrzucić kapsułę."))
		return
	var/obj/structure/overmap/planet/planet = length(planets) == 1 ? planets[1] : tgui_input_list(user, "Na którą planetę?", "Cel zrzutu", planets)
	if(!planet || user.buckled != src)
		return
	if(!planet.ensure_surface())
		to_chat(user, span_notice("Komputer kapsuły mapuje powierzchnię [planet]. Spróbuj za kilka sekund."))
		return
	var/list/options = list()
	for(var/turf/zone as anything in planet.surface.landing_zones)
		options[planet.surface.landing_zones[zone]] = zone
	for(var/obj/effect/planet_laser_target/laser as anything in GLOB.planet_laser_targets)
		if(planet.surface.contains(get_turf(laser)))
			options["Znacznik celu ([laser.placer_name])"] = get_turf(laser)
	options["Wskaż miejsce kamerą"] = "camera"
	var/choice = tgui_input_list(user, "Gdzie lądujesz?", "Cel zrzutu na [planet]", options)
	if(!choice || user.buckled != src || QDELETED(planet))
		return
	if(options[choice] == "camera")
		start_target_camera(user, planet)
		return
	set_target(user, planet, options[choice], "[choice] na [planet]")

/obj/machinery/drop_pod_bay/proc/set_target(mob/living/user, obj/structure/overmap/planet/planet, turf/T, new_name)
	target_planet = planet
	target_turf = T
	target_name = new_name
	update_icon()
	playsound(src, 'sound/machines/twobeep.ogg', 30, TRUE)
	to_chat(user, span_notice("Cel zrzutu: [target_name]. Odpal kapsułę akcją „Zrzut”."))

/// Czy kapsuła może tu wylądować: grunt pod niebem planety, bez lawy i przeszkód
/obj/machinery/drop_pod_bay/proc/can_land_at(turf/T)
	return drop_pod_can_land_at(T)

/// Czy kapsuła może spaść na pole (powierzchnia planety pod niebem, bez lawy i gęstych obiektów, np. innej kapsuły)
/proc/drop_pod_can_land_at(turf/T)
	if(!get_planet_of(T) || is_planet_hazard_turf(T))
		return FALSE
	for(var/atom/movable/AM as anything in T)
		if(AM.density && !ismob(AM))
			return FALSE
	return TRUE

/obj/machinery/drop_pod_bay/proc/start_target_camera(mob/living/user, obj/structure/overmap/planet/planet)
	if(target_eye || !user.client)
		return
	target_eye = new(planet.surface.center())
	target_eye.start(src, planet, user)
	to_chat(user, span_notice("Kamera pokazuje powierzchnię [planet]. Ustaw ją nad miejscem lądowania i użyj „Zrzut tutaj”."))

/// Odpala kapsułę z siedzącym w niej
/obj/machinery/drop_pod_bay/proc/launch(mob/living/user)
	if(user.buckled != src || !ready)
		return
	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, span_warning("Wyrzutnia nie ma zasilania."))
		return
	var/obj/structure/overmap/ship = get_overmap()
	if(!target_turf || QDELETED(target_planet) || target_planet.current_system != ship?.current_system || !target_planet.z || target_planet.surface?.state != PLANET_SURFACE_READY || !target_planet.surface.contains(target_turf))
		to_chat(user, span_warning("Najpierw wybierz cel zrzutu na planecie w tym układzie."))
		return
	var/list/landing_spots = list()
	for(var/turf/T as anything in RANGE_TURFS(DROP_POD_SCATTER, target_turf))
		if(can_land_at(T))
			landing_spots += T
	if(!length(landing_spots))
		to_chat(user, span_warning("W miejscu zrzutu nie ma gdzie wylądować. Wybierz inny cel."))
		return
	var/turf/landing = pick(landing_spots)
	ready = FALSE
	use_power(active_power_usage)
	unbuckle_mob(user, TRUE)
	var/obj/structure/drop_pod/pod = new(get_turf(src))
	user.forceMove(pod)
	update_icon()
	pod.launch(landing)
	visible_message(span_notice("Kapsuła w [src] zamyka się i z hukiem wylatuje przez luk zrzutowy."))
	log_game("[key_name(user)] launched a drop pod from [AREACOORD(src)] to [target_planet] at [AREACOORD(landing)]")
	target_planet = null
	target_turf = null
	target_name = null
	addtimer(CALLBACK(src, PROC_REF(recharge)), DROP_POD_RECHARGE)

/obj/machinery/drop_pod_bay/proc/recharge()
	ready = TRUE
	update_icon()
	visible_message(span_notice("[src] ma gotową nową kapsułę."))

/// Kapsuła w locie i jej skorupa po wylądowaniu. Pasażer siedzi w jej zawartości aż do otwarcia.
/obj/structure/drop_pod
	name = "kapsuła desantowa"
	desc = "Jednoosobowa kapsuła desantowa. Po wylądowaniu nadaje się już tylko na złom."
	icon = 'aquila/icons/planets/droppod.dmi'
	icon_state = "singlepod_green"
	density = TRUE
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	max_integrity = 300
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF | INDESTRUCTIBLE
	/// Już wylądowała i stoi otwarta
	var/landed = FALSE
	/// Pole startu: tam wraca kapsuła, jeśli cel zniknie w trakcie lotu
	var/turf/origin
	/// Powietrze w kabinie: w locie kapsuła jest poza mapą, a pasażer dalej oddycha
	var/datum/gas_mixture/cabin_air

/obj/structure/drop_pod/Initialize(mapload)
	. = ..()
	cabin_air = new
	cabin_air.set_temperature(T20C)
	cabin_air.set_volume(200)
	cabin_air.set_moles(GAS_O2, O2STANDARD * ONE_ATMOSPHERE * cabin_air.return_volume() / (R_IDEAL_GAS_EQUATION * cabin_air.return_temperature()))
	cabin_air.set_moles(GAS_N2, N2STANDARD * ONE_ATMOSPHERE * cabin_air.return_volume() / (R_IDEAL_GAS_EQUATION * cabin_air.return_temperature()))

/obj/structure/drop_pod/return_air()
	return cabin_air

/obj/structure/drop_pod/remove_air_ratio(ratio)
	return cabin_air.remove_ratio(ratio)

/obj/structure/drop_pod/remove_air(amount)
	return cabin_air.remove(amount)

/obj/structure/drop_pod/Destroy()
	origin = null
	cabin_air = null
	// Kapsuła zniknęła w locie (np. razem z planetą): pasażer nie może przepaść razem z nią
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM as anything in contents)
		if(T)
			AM.forceMove(T)
		else if(ismob(AM))
			var/mob/M = AM
			M.ghostize()
	return ..()

/obj/structure/drop_pod/contents_explosion(severity, target)
	return // Pasażer jest osłonięty pancerzem kapsuły

/// Start: zamyka się na luku, wylatuje w górę i po czasie lotu spada na cel
/obj/structure/drop_pod/proc/launch(turf/landing)
	origin = get_turf(src)
	flick("singlepod_green_closing", src)
	playsound(src, 'aquila/sound/planets/escape_pod_launch.ogg', 70)
	playsound(src, 'aquila/sound/planets/droppod_launch.ogg', 70)
	addtimer(CALLBACK(src, PROC_REF(leave), landing), 2 SECONDS)

/obj/structure/drop_pod/proc/leave(turf/landing)
	animate(src, pixel_z = 500, alpha = 0, time = 0.8 SECONDS, easing = QUAD_EASING | EASE_IN)
	addtimer(CALLBACK(src, PROC_REF(in_transit), landing), 0.8 SECONDS)

/obj/structure/drop_pod/proc/in_transit(turf/landing)
	moveToNullspace()
	new /obj/effect/temp_visual/drop_pod_target(landing)
	addtimer(CALLBACK(src, PROC_REF(fall), landing), DROP_POD_TRANSIT_TIME)

/obj/structure/drop_pod/proc/fall(turf/landing)
	// Cel sprawdzany drugi raz przy spadaniu: w czasie lotu na polu mogła wylądować inna kapsuła albo prom
	if(!drop_pod_can_land_at(landing))
		var/turf/new_landing
		if(landing && get_planet_of(landing))
			var/list/spots = list()
			for(var/turf/T as anything in RANGE_TURFS(DROP_POD_SCATTER, landing))
				if(drop_pod_can_land_at(T))
					spots += T
			if(length(spots))
				new_landing = pick(spots)
		if(!new_landing)
			abort_drop()
			return
		landing = new_landing
	forceMove(landing)
	pixel_z = 500
	alpha = 255
	animate(src, pixel_z = 0, time = DROP_POD_FALL_TIME, easing = LINEAR_EASING)
	addtimer(CALLBACK(src, PROC_REF(impact)), DROP_POD_FALL_TIME)

/// Powierzchnia zniknęła w trakcie lotu (okręt opuścił układ) albo nie ma gdzie spaść: kapsuła przerywa zrzut i wraca na
/// pole startu bez uderzenia (dawniej spadała z wybuchem na wyrzutnię i zostawiała tam skorupę)
/obj/structure/drop_pod/proc/abort_drop()
	var/turf/T = origin
	if(!T)
		qdel(src)
		return
	forceMove(T)
	alpha = 255
	pixel_z = 0
	playsound(T, 'sound/machines/airlockopen.ogg', 50, TRUE)
	for(var/mob/living/passenger in contents)
		to_chat(passenger, span_warning("Komputer kapsuły przerywa zrzut: cel zniknął. Kapsuła wraca na okręt."))
	qdel(src) // Destroy wypuszcza pasażera na pole startu

/obj/structure/drop_pod/proc/impact()
	var/turf/T = get_turf(src)
	playsound(T, 'aquila/sound/planets/droppod_impact.ogg', 100, FALSE, 10)
	explosion(T, 0, 0, 1, 3)
	for(var/mob/living/crushed in T)
		if(crushed.loc == T)
			crushed.adjustBruteLoss(60)
	addtimer(CALLBACK(src, PROC_REF(open)), 0.7 SECONDS)

/obj/structure/drop_pod/proc/open()
	landed = TRUE
	icon_state = "singlepod_green_inactive"
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM as anything in contents)
		AM.forceMove(T)

/// Znacznik lądowiska kapsuły na celu (jak w naszych kapsułach zaopatrzeniowych)
/obj/effect/temp_visual/drop_pod_target
	name = "znacznik lądowania kapsuły"
	icon = 'icons/obj/supplypods_32x32.dmi'
	icon_state = "LZ"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	duration = DROP_POD_TRANSIT_TIME + DROP_POD_FALL_TIME
	randomdir = FALSE

/obj/item/circuitboard/machine/drop_pod_bay
	name = "wyrzutnia kapsuł desantowych (płytka maszyny)"
	icon_state = "security"
	build_path = /obj/machinery/drop_pod_bay
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stack/sheet/plasteel = 10,
		/obj/item/stack/cable_coil = 5,
	)

/datum/design/board/drop_pod_bay
	name = "Projekt maszyny (wyrzutnia kapsuł desantowych)"
	desc = "Płytka do budowy wyrzutni kapsuł desantowych, która zrzuca żołnierzy na powierzchnię planet."
	id = "drop_pod_bay"
	build_path = /obj/item/circuitboard/machine/drop_pod_bay
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS | DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SECURITY

/datum/techweb_node/ship_circuits/New()
	. = ..()
	design_ids += "drop_pod_bay"

// Przyciski w kapsule

/datum/action/innate/drop_pod
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	check_flags = AB_CHECK_CONSCIOUS
	var/obj/machinery/drop_pod_bay/bay

/datum/action/innate/drop_pod/Destroy()
	bay = null
	return ..()

/datum/action/innate/drop_pod/target
	name = "Cel zrzutu"
	desc = "Wybierz planetę i miejsce lądowania."
	button_icon_state = "mech_zoom_on"

/datum/action/innate/drop_pod/target/Activate()
	if(!QDELETED(bay))
		INVOKE_ASYNC(bay, TYPE_PROC_REF(/obj/machinery/drop_pod_bay, choose_target), owner)

/datum/action/innate/drop_pod/launch
	name = "Zrzut"
	desc = "Odpal kapsułę do wybranego celu."
	button_icon_state = "mech_eject"

/datum/action/innate/drop_pod/launch/Activate()
	if(!QDELETED(bay))
		bay.launch(owner)

// Kamera wyboru celu: po powierzchni jednej planety

/mob/camera/ai_eye/remote/drop_pod_target
	name = "kamera celu zrzutu"
	visible_icon = FALSE
	use_static = FALSE
	var/obj/machinery/drop_pod_bay/bay
	var/obj/structure/overmap/planet/planet
	var/list/datum/action/innate/drop_pod_camera/camera_actions = list()

/mob/camera/ai_eye/remote/drop_pod_target/proc/start(obj/machinery/drop_pod_bay/new_bay, obj/structure/overmap/planet/new_planet, mob/living/user)
	bay = new_bay
	planet = new_planet
	for(var/action_type in list(/datum/action/innate/drop_pod_camera/place, /datum/action/innate/drop_pod_camera/cancel))
		var/datum/action/innate/drop_pod_camera/action = new action_type
		action.eye = src
		action.Grant(user)
		camera_actions += action
	eye_user = user
	name = "kamera celu zrzutu ([user.name])"
	user.remote_control = src
	user.reset_perspective(src)
	setLoc(loc)
	user.update_sight()

/mob/camera/ai_eye/remote/drop_pod_target/setLoc(destination)
	var/turf/T = get_turf(destination)
	var/datum/turf_reservation/reservation = planet?.surface?.reservation
	if(T && reservation)
		var/list/bl = reservation.bottom_left_coords
		var/list/tr = reservation.top_right_coords
		T = locate(clamp(T.x, bl[1], tr[1]), clamp(T.y, bl[2], tr[2]), bl[3])
	return ..(T)

/mob/camera/ai_eye/remote/drop_pod_target/canZMove(direction, turf/target)
	return FALSE

/mob/camera/ai_eye/remote/drop_pod_target/update_remote_sight(mob/living/user)
	user.sight = BLIND|SEE_TURFS|SEE_OBJS|SEE_MOBS
	user.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	user.sync_lighting_plane_alpha()
	return TRUE

/mob/camera/ai_eye/remote/drop_pod_target/Destroy()
	var/mob/living/user = eye_user
	if(user)
		for(var/datum/action/action as anything in camera_actions)
			action.Remove(user)
		if(user.remote_control == src)
			user.remote_control = null
			user.reset_perspective(null)
			user.update_sight()
	QDEL_LIST(camera_actions)
	if(bay?.target_eye == src)
		bay.target_eye = null
	bay = null
	planet = null
	return ..()

/datum/action/innate/drop_pod_camera
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	check_flags = AB_CHECK_CONSCIOUS
	var/mob/camera/ai_eye/remote/drop_pod_target/eye

/datum/action/innate/drop_pod_camera/Destroy()
	eye = null
	return ..()

/datum/action/innate/drop_pod_camera/place
	name = "Zrzut tutaj"
	desc = "Ustawia cel zrzutu pod kamerą."
	button_icon_state = "mech_zoom_off"

/datum/action/innate/drop_pod_camera/place/Activate()
	if(QDELETED(eye) || QDELETED(eye.bay) || QDELETED(eye.planet))
		return
	var/turf/T = get_turf(eye)
	if(!eye.bay.can_land_at(T))
		to_chat(owner, span_warning("Tu kapsuła nie wyląduje: potrzebny jest otwarty grunt pod niebem, bez lawy i przeszkód."))
		return
	var/obj/machinery/drop_pod_bay/bay = eye.bay
	bay.set_target(owner, eye.planet, T, "punkt [T.x - eye.planet.surface.reservation.bottom_left_coords[1]]:[T.y - eye.planet.surface.reservation.bottom_left_coords[2]] na [eye.planet]")
	qdel(eye)

/datum/action/innate/drop_pod_camera/cancel
	name = "Zamknij kamerę"
	desc = "Wraca do kapsuły bez zmiany celu."
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "camera_off"

/datum/action/innate/drop_pod_camera/cancel/Activate()
	if(!QDELETED(eye))
		qdel(eye)

#undef DROP_POD_RECHARGE
#undef DROP_POD_TRANSIT_TIME
#undef DROP_POD_FALL_TIME
#undef DROP_POD_SCATTER
