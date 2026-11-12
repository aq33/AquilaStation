// AQUILA - ręczne lądowanie promu z wnętrzem na asteroidzie, na wzór kamery dokowania promów (shuttle_docking.dm):
// po wleceniu w asteroidę w trybie dokowania pilot dostaje kamerę nad jej wnętrzem z obrysem kadłuba (zielony = wolne,
// czerwony = zajęte, niebieski = pola przed włazem), obraca go i zatwierdza miejsce. Anulowanie albo brak wyboru przez
// minutę = miejsce wybrane przez komputer dokowania. Przy okrętach lądowanie zostaje automatyczne (port albo kadłub).

/// Jak długo pilot może wybierać miejsce lądowania, zanim komputer dokowania wyląduje sam
#define SHUTTLE_CRAFT_MANUAL_LANDING_TIME (60 SECONDS)

/obj/structure/overmap/small_craft/transport
	/// Kamera, którą pilot wybiera miejsce lądowania (tylko w trakcie wyboru)
	var/mob/camera/ai_eye/remote/shuttle_craft_landing/shuttle_landing_eye
	var/shuttle_landing_timer

/// Lądowanie przy celu: przy asteroidzie pilot najpierw wybiera miejsce kamerą, przy okręcie od razu automat
/obj/structure/overmap/small_craft/transport/proc/shuttle_begin_landing(obj/structure/overmap/OM)
	if(isasteroid(OM) && shuttle_manual_landing(OM))
		return
	shuttle_try_land(OM)

/// Kształt kadłuba obrócony z obecnego kierunku wnętrza na new_dir (jak obrót obrazu w kamerze dokowania)
/obj/structure/overmap/small_craft/transport/proc/shuttle_rotate_offsets(list/offsets, new_dir)
	. = list()
	var/turns = ((dir2angle(new_dir) - dir2angle(shuttle_port.dir) + 360) % 360) / 90
	for(var/list/offset as anything in offsets)
		var/offset_x = offset[1]
		var/offset_y = offset[2]
		for(var/i = 0, i < turns, i++)
			var/old_x = offset_x
			offset_x = offset_y
			offset_y = -old_x
		. += list(list(offset_x, offset_y))

/// Daje pilotowi kamerę nad wnętrzem celu; FALSE, gdy się nie da (wtedy ląduje automat)
/obj/structure/overmap/small_craft/transport/proc/shuttle_manual_landing(obj/structure/overmap/OM)
	var/mob/living/user = pilot
	if(!user?.client || !OM.roomReservation || shuttle_landing_eye || shuttle_docked_at || !shuttle_port)
		return FALSE
	var/turf/center = shuttle_landing_center(OM)
	if(!center)
		return FALSE
	shuttle_cache_offsets()
	// Prom zawisa nad asteroidą, a pilot puszcza ster i patrzy przez kamerę
	velocity._set(0, 0)
	angular_velocity = 0
	user_thrust_dir = 0
	brakes = TRUE
	stop_piloting(user)
	var/mob/camera/ai_eye/remote/shuttle_craft_landing/eye = new(center)
	shuttle_landing_eye = eye
	eye.start(src, OM, user)
	shuttle_landing_timer = addtimer(CALLBACK(src, PROC_REF(shuttle_manual_landing_timeout), eye), SHUTTLE_CRAFT_MANUAL_LANDING_TIME, TIMER_STOPPABLE)
	to_chat(user, span_notice("Komputer dokowania pokazuje [OM] z góry. Kamerą ruszasz klawiszami ruchu, „Obróć prom” obraca miejsce lądowania, a „Wyląduj tutaj” zatwierdza zielony obrys (niebieskie pola to wyjście z włazu). Jeśli nic nie wybierzesz w ciągu [DisplayTimeText(SHUTTLE_CRAFT_MANUAL_LANDING_TIME)], komputer wyląduje sam."))
	return TRUE

/// Zamyka kamerę lądowania
/obj/structure/overmap/small_craft/transport/proc/shuttle_manual_landing_end(mob/camera/ai_eye/remote/shuttle_craft_landing/eye)
	if(shuttle_landing_eye == eye)
		shuttle_landing_eye = null
	if(shuttle_landing_timer)
		deltimer(shuttle_landing_timer)
		shuttle_landing_timer = null
	if(!QDELETED(eye))
		qdel(eye)

/// Wybór przerwany: cel zniknął, więc komputer dokowania znów jest wolny, albo ląduje automat
/obj/structure/overmap/small_craft/transport/proc/shuttle_manual_landing_fallback(obj/structure/overmap/OM)
	if(QDELETED(src) || shuttle_docked_at)
		return
	if(QDELETED(OM))
		var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
		if(DC)
			DC.docking_cooldown = FALSE
		return
	INVOKE_ASYNC(src, PROC_REF(shuttle_try_land), OM)

/obj/structure/overmap/small_craft/transport/proc/shuttle_manual_landing_timeout(mob/camera/ai_eye/remote/shuttle_craft_landing/eye)
	shuttle_landing_timer = null
	if(QDELETED(eye) || shuttle_landing_eye != eye)
		return
	var/obj/structure/overmap/OM = eye.landing_target
	if(eye.eye_user)
		to_chat(eye.eye_user, span_warning("Nie wybrano miejsca lądowania: komputer dokowania ląduje sam."))
	shuttle_manual_landing_end(eye)
	shuttle_manual_landing_fallback(OM)

/obj/structure/overmap/small_craft/transport/proc/shuttle_manual_landing_cancel(mob/camera/ai_eye/remote/shuttle_craft_landing/eye)
	if(QDELETED(eye) || shuttle_landing_eye != eye)
		return
	var/obj/structure/overmap/OM = eye.landing_target
	if(eye.eye_user)
		to_chat(eye.eye_user, span_notice("Komputer dokowania sam wybierze miejsce lądowania."))
	shuttle_manual_landing_end(eye)
	shuttle_manual_landing_fallback(OM)

/// „Wyląduj tutaj”: miejsce pod kamerą, jeśli cały obrys jest zielony
/obj/structure/overmap/small_craft/transport/proc/shuttle_manual_landing_confirm(mob/camera/ai_eye/remote/shuttle_craft_landing/eye)
	if(QDELETED(eye) || shuttle_landing_eye != eye)
		return FALSE
	var/obj/structure/overmap/OM = eye.landing_target
	var/mob/user = eye.eye_user
	if(QDELETED(OM))
		shuttle_manual_landing_end(eye)
		shuttle_manual_landing_fallback(OM)
		return FALSE
	var/turf/spot_turf = get_turf(eye)
	var/spot_dir = eye.landing_dir
	if(!spot_turf || !shuttle_spot_free(OM, spot_turf.x, spot_turf.y, spot_turf.z, shuttle_rotate_offsets(hull_offsets, spot_dir)))
		if(user)
			to_chat(user, span_warning("Tu prom się nie zmieści: czerwone pola są zajęte. Przesuń kamerę albo obróć prom."))
		return FALSE
	shuttle_manual_landing_end(eye)
	return shuttle_land_at_spot(OM, spot_turf, spot_dir)

/// Ląduje na wybranym polu (mobilny port na spot_turf, wnętrze skierowane na spot_dir); bez powodzenia ląduje automat
/obj/structure/overmap/small_craft/transport/proc/shuttle_land_at_spot(obj/structure/overmap/OM, turf/spot_turf, spot_dir)
	var/obj/docking_port/stationary/port = shuttle_new_spot(spot_turf, "miejsce lądowania przy [OM]", spot_dir)
	if(shuttle_land(OM, port))
		return TRUE
	shuttle_manual_landing_fallback(OM)
	return FALSE

// Kamera lądowania: po wnętrzu celu, z obrysem kadłuba w miejscu, gdzie stanie mobilny port

/mob/camera/ai_eye/remote/shuttle_craft_landing
	name = "kamera lądowania"
	visible_icon = FALSE
	use_static = FALSE
	/// Prom, który ląduje
	var/obj/structure/overmap/small_craft/transport/craft
	/// Asteroida (albo inny cel), nad którą lata kamera
	var/obj/structure/overmap/landing_target
	/// Kierunek wnętrza po lądowaniu
	var/landing_dir
	/// Czy cały obrys jest teraz wolny
	var/landing_clear = FALSE
	/// Obraz pola kadłuba -> przesunięcie względem mobilnego portu
	var/list/hull_images = list()
	/// Obraz pola przed włazem -> przesunięcie
	var/list/exit_images = list()
	var/list/datum/action/innate/shuttle_craft_landing/landing_actions = list()

/mob/camera/ai_eye/remote/shuttle_craft_landing/proc/start(obj/structure/overmap/small_craft/transport/new_craft, obj/structure/overmap/target, mob/living/user)
	craft = new_craft
	landing_target = target
	landing_dir = craft.shuttle_port.dir
	for(var/list/offset as anything in craft.hull_offsets)
		var/image/I = image('icons/effects/alphacolors.dmi', loc, "green")
		I.layer = ABOVE_NORMAL_TURF_LAYER
		I.plane = 0
		I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		hull_images[I] = null
	for(var/list/offset as anything in craft.exit_offsets)
		var/image/I = image('icons/effects/alphacolors.dmi', loc, "blue")
		I.layer = ABOVE_NORMAL_TURF_LAYER
		I.plane = 0
		I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		exit_images[I] = null
	update_offsets()
	for(var/action_type in list(/datum/action/innate/shuttle_craft_landing/place, /datum/action/innate/shuttle_craft_landing/rotate, /datum/action/innate/shuttle_craft_landing/cancel))
		var/datum/action/innate/shuttle_craft_landing/action = new action_type
		action.eye = src
		action.target = user
		action.Grant(user)
		landing_actions += action
	eye_user = user
	name = "kamera lądowania ([user.name])"
	user.remote_control = src
	user.reset_perspective(src)
	if(user.client)
		user.client.images += hull_images
		user.client.images += exit_images
	setLoc(loc)
	user.update_sight()

/// Przypisuje obrazom przesunięcia kadłuba i włazu w obecnym kierunku
/mob/camera/ai_eye/remote/shuttle_craft_landing/proc/update_offsets()
	var/list/hull = craft.shuttle_rotate_offsets(craft.hull_offsets, landing_dir)
	var/list/exits = craft.shuttle_rotate_offsets(craft.exit_offsets, landing_dir)
	var/i = 0
	for(var/image/I as anything in hull_images)
		hull_images[I] = hull[++i]
	i = 0
	for(var/image/I as anything in exit_images)
		exit_images[I] = exits[++i]

/mob/camera/ai_eye/remote/shuttle_craft_landing/proc/rotate()
	landing_dir = turn(landing_dir, -90)
	update_offsets()
	update_preview()

/// Przesuwa obrys pod kamerę i koloruje pola: zielone wolne, czerwone zajęte
/mob/camera/ai_eye/remote/shuttle_craft_landing/proc/update_preview()
	var/turf/here = get_turf(src)
	if(!here || QDELETED(craft) || QDELETED(landing_target))
		landing_clear = FALSE
		return
	landing_clear = TRUE
	for(var/image/I as anything in hull_images)
		var/list/offset = hull_images[I]
		var/turf/T = locate(here.x + offset[1], here.y + offset[2], here.z)
		I.loc = T
		if(craft.shuttle_landing_turf_free(landing_target, T))
			I.icon_state = "green"
		else
			I.icon_state = "red"
			landing_clear = FALSE
	for(var/image/I as anything in exit_images)
		var/list/offset = exit_images[I]
		I.loc = locate(here.x + offset[1], here.y + offset[2], here.z)

/// Kamera nie wychodzi poza wnętrze celu
/mob/camera/ai_eye/remote/shuttle_craft_landing/setLoc(destination)
	var/turf/T = get_turf(destination)
	var/datum/turf_reservation/reservation = landing_target?.roomReservation
	if(T && reservation)
		var/list/bl = reservation.bottom_left_coords
		var/list/tr = reservation.top_right_coords
		T = locate(clamp(T.x, bl[1], tr[1]), clamp(T.y, bl[2], tr[2]), bl[3])
	. = ..(T)
	update_preview()

/mob/camera/ai_eye/remote/shuttle_craft_landing/canZMove(direction, turf/target)
	return FALSE

/mob/camera/ai_eye/remote/shuttle_craft_landing/update_remote_sight(mob/living/user)
	user.sight = BLIND|SEE_TURFS|SEE_OBJS
	user.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	user.sync_lighting_plane_alpha()
	return TRUE

/mob/camera/ai_eye/remote/shuttle_craft_landing/Destroy()
	var/mob/living/user = eye_user
	if(user)
		for(var/datum/action/action as anything in landing_actions)
			action.Remove(user)
		if(user.client)
			user.client.images -= hull_images
			user.client.images -= exit_images
		if(user.remote_control == src)
			user.remote_control = null
			user.reset_perspective(null)
			user.update_sight()
	QDEL_LIST(landing_actions)
	hull_images = null
	exit_images = null
	if(craft?.shuttle_landing_eye == src)
		craft.shuttle_landing_eye = null
	craft = null
	landing_target = null
	return ..()

/datum/action/innate/shuttle_craft_landing
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	check_flags = AB_CHECK_CONSCIOUS
	var/mob/camera/ai_eye/remote/shuttle_craft_landing/eye

/datum/action/innate/shuttle_craft_landing/Destroy()
	eye = null
	return ..()

/datum/action/innate/shuttle_craft_landing/Activate()
	if(QDELETED(eye) || QDELETED(eye.craft) || owner != eye.eye_user)
		return
	use(eye.craft)

/datum/action/innate/shuttle_craft_landing/proc/use(obj/structure/overmap/small_craft/transport/craft)
	return

/datum/action/innate/shuttle_craft_landing/place
	name = "Wyląduj tutaj"
	desc = "Prom ląduje w zielonym obrysie. Niebieskie pola to wyjście z włazu."
	button_icon_state = "mech_zoom_off"

/datum/action/innate/shuttle_craft_landing/place/use(obj/structure/overmap/small_craft/transport/craft)
	craft.shuttle_manual_landing_confirm(eye)

/datum/action/innate/shuttle_craft_landing/rotate
	name = "Obróć prom"
	desc = "Obraca miejsce lądowania o 90 stopni."
	button_icon_state = "mech_cycle_equip_off"

/datum/action/innate/shuttle_craft_landing/rotate/use(obj/structure/overmap/small_craft/transport/craft)
	eye.rotate()

/datum/action/innate/shuttle_craft_landing/cancel
	name = "Lądowanie automatyczne"
	desc = "Zamyka kamerę, a komputer dokowania sam wybiera miejsce lądowania."
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "camera_off"

/datum/action/innate/shuttle_craft_landing/cancel/use(obj/structure/overmap/small_craft/transport/craft)
	craft.shuttle_manual_landing_cancel(eye)

#undef SHUTTLE_CRAFT_MANUAL_LANDING_TIME
