// AQUILA - wyrzutnia kapsuł desantowych, na wzór /obj/structure/droppod z TGMC (tgstation/TerraGov-Marine-Corps,
// AGPLv3): siadasz w kapsule, wybierasz cel na planecie w układzie i lecisz w dół. Zamiast tranzytu i minimapy TGMC
// lot robi nasza kapsuła zaopatrzeniowa (animacja spadania i znacznik lądowiska), a cel wybiera się z listy lądowisk
// i znaczników albo kamerą nad powierzchnią. Powrót tylko promem. Po zrzucie wyrzutnia ładuje kolejną kapsułę.

/// Czas przygotowania kolejnej kapsuły
#define DROP_POD_RECHARGE (2 MINUTES)
/// Rozrzut lądowania wokół celu
#define DROP_POD_SCATTER 2

/obj/machinery/drop_pod_bay
	name = "wyrzutnia kapsuł desantowych"
	desc = "Kapsuła na jedną osobę osadzona w luku zrzutowym. Usiądź w niej, wybierz cel na powierzchni planety w układzie i odpal. Wraca się promem."
	icon = 'icons/obj/supplypods.dmi'
	icon_state = "darkpod"
	pixel_x = -16
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

/obj/machinery/drop_pod_bay/update_overlays()
	. = ..()
	if(!ready)
		. += "pod_door"
		. += "pod_glow_red"
	else
		. += "pod_glow_green"

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
	to_chat(M, span_notice("Siedzisz w kapsule desantowej. „Cel zrzutu” wybiera miejsce na planecie, „Zrzut” odpala kapsułę."))

/obj/machinery/drop_pod_bay/post_unbuckle_mob(mob/living/M)
	. = ..()
	for(var/datum/action/innate/drop_pod/action as anything in pod_actions)
		action.Remove(M)
	if(target_eye?.eye_user == M)
		QDEL_NULL(target_eye)

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
	to_chat(user, span_notice("Cel zrzutu: [target_name]. Odpal kapsułę akcją „Zrzut”."))

/// Czy kapsuła może tu wylądować: grunt pod niebem planety, bez lawy i przeszkód
/obj/machinery/drop_pod_bay/proc/can_land_at(turf/T)
	if(!get_planet_of(T) || !isopenturf(T) || islava(T) || ischasm(T))
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
	if(!target_turf || QDELETED(target_planet) || !target_planet.z || target_planet.surface?.state != PLANET_SURFACE_READY || !target_planet.surface.contains(target_turf))
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
	update_icon()
	unbuckle_mob(user, TRUE)
	var/obj/structure/closet/supplypod/drop_pod/pod = new
	pod.forceMove(GLOB.areas_by_type[/area/centcom/supplypod/supplypod_temp_holding])
	user.forceMove(pod)
	new /obj/effect/pod_landingzone(landing, pod)
	playsound(src, 'sound/effects/bang.ogg', 70, TRUE)
	visible_message(span_notice("Luk zrzutowy [src] otwiera się z hukiem i kapsuła znika w dole."))
	log_game("[key_name(user)] launched a drop pod from [AREACOORD(src)] to [target_planet] at [AREACOORD(landing)]")
	target_planet = null
	target_turf = null
	target_name = null
	addtimer(CALLBACK(src, PROC_REF(recharge)), DROP_POD_RECHARGE)

/obj/machinery/drop_pod_bay/proc/recharge()
	ready = TRUE
	update_icon()
	visible_message(span_notice("[src] ma gotową nową kapsułę."))

/// Kapsuła w locie: spada jak kapsuła zaopatrzeniowa i zostaje na planecie jako wrak
/obj/structure/closet/supplypod/drop_pod
	name = "kapsuła desantowa"
	desc = "Jednoosobowa kapsuła desantowa. Po wylądowaniu nadaje się już tylko na złom."
	style = STYLE_STANDARD
	specialised = TRUE
	explosionSize = list(0, 0, 0, 2)
	delays = list(POD_TRANSIT = 30, POD_FALLING = 20, POD_OPENING = 20, POD_LEAVING = 30)
	stay_after_drop = TRUE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/structure/closet/supplypod/drop_pod/Initialize(mapload)
	. = ..()
	name = initial(name)
	desc = initial(desc)

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
#undef DROP_POD_SCATTER
