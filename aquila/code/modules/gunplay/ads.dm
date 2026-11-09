// AQUILA - celowanie przez przyrządy (ADS) jak na filmie z przykładu: widok najeżdża w stronę kursora, brzegi ekranu
// ciemnieją i rozmywają się promieniście, broń mniej rozrzuca i mniej kopie, a postać idzie wolniej.
// Wzór: Shiptest zoom() (każda broń, przesunięcie widoku zależne od klasy broni, spowolnienie przy celowaniu).
// Sterowanie: w combat mode prawy przycisk przytrzymany z bronią w aktywnej ręce; w starym trybie intencji (prawy przycisk
// to tam rozbrajanie) i dla chętnych w obu trybach przytrzymany klawisz „Celuj przez przyrządy”.

/// O ile rozrzut maleje przy celowaniu (ułamek)
#define AQ_ADS_SPREAD_MULT 0.5
/// O ile odrzut postaci mniej psuje celność przy celowaniu
#define AQ_ADS_RECOIL_SPREAD_MULT 0.6
/// Mnożnik przyrostu odrzutu przy celowaniu
#define AQ_ADS_RECOIL_GAIN_MULT 0.7
#define AQ_ADS_FILTER "aq_ads_blur"

/obj/item/gun
	/// Czy broń da się przyłożyć do oka
	var/ads_allowed = TRUE
	/// O ile kafli przesuwa się widok przy celowaniu; null = według wagi broni
	var/ads_zoom

// M-90gl strzela z granatnika prawym przyciskiem
/obj/item/gun/ballistic/automatic/m90
	ads_allowed = FALSE

/obj/item/gun/proc/get_ads_zoom()
	if(!isnull(ads_zoom))
		return ads_zoom
	switch(weapon_weight)
		if(WEAPON_LIGHT)
			return 2
		if(WEAPON_MEDIUM)
			return 3
	return 4

/mob/living
	/// Broń, przez której przyrządy postać celuje
	var/obj/item/gun/aq_ads_gun
	/// O ile przesunięto widok (piksele), żeby cofnąć dokładnie tyle
	var/aq_ads_offset_x = 0
	var/aq_ads_offset_y = 0

/datum/movespeed_modifier/aq_ads
	multiplicative_slowdown = 1.2

/atom/movable/screen/fullscreen/aq_ads
	icon_state = "impairedoverlay"
	alpha = 170

/// Zaczyna celowanie przez przyrządy
/mob/living/proc/start_ads(obj/item/gun/gun)
	if(aq_ads_gun || !client || !istype(gun) || !gun.ads_allowed || get_active_held_item() != gun || incapacitated())
		return FALSE
	if(gun.zoomed)
		return FALSE
	if(gun.requires_wielding && gun.weapon_weight >= WEAPON_HEAVY && !gun.is_wielded)
		balloon_alert(src, "weź broń w obie ręce")
		return FALSE
	aq_ads_gun = gun
	RegisterSignal(gun, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED, COMSIG_TWOHANDED_UNWIELD, COMSIG_PARENT_QDELETING), PROC_REF(on_ads_gun_lost))
	RegisterSignal(src, list(COMSIG_LIVING_STATUS_KNOCKDOWN, COMSIG_LIVING_STATUS_PARALYZE, COMSIG_LIVING_STATUS_STUN), PROC_REF(on_ads_interrupted))
	add_movespeed_modifier(/datum/movespeed_modifier/aq_ads)
	update_ads_view(2.5)
	overlay_fullscreen("aq_ads", /atom/movable/screen/fullscreen/aq_ads, 1)
	set_ads_blur(TRUE)
	update_inv_hands() // broń w ręku prostuje się (feel.dm)
	playsound_local(get_turf(src), 'sound/weapons/gun_magazine_insert_empty_2.ogg', 20, TRUE)
	update_gun_cursor()
	return TRUE

/mob/living/proc/stop_ads()
	if(!aq_ads_gun)
		return
	UnregisterSignal(aq_ads_gun, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED, COMSIG_TWOHANDED_UNWIELD, COMSIG_PARENT_QDELETING))
	UnregisterSignal(src, list(COMSIG_LIVING_STATUS_KNOCKDOWN, COMSIG_LIVING_STATUS_PARALYZE, COMSIG_LIVING_STATUS_STUN))
	aq_ads_gun = null
	remove_movespeed_modifier(/datum/movespeed_modifier/aq_ads)
	if(client && (aq_ads_offset_x || aq_ads_offset_y))
		animate(client, pixel_x = -aq_ads_offset_x, pixel_y = -aq_ads_offset_y, time = 2, easing = SINE_EASING, flags = ANIMATION_RELATIVE | ANIMATION_PARALLEL)
	aq_ads_offset_x = 0
	aq_ads_offset_y = 0
	clear_fullscreen("aq_ads", 2)
	set_ads_blur(FALSE)
	update_gun_cursor()
	update_inv_hands()

/// Widok przy celowaniu idzie za kursorem: przesunięcie w jego stronę, tym większe, im dalej mierzysz (do zasięgu broni)
/mob/living/proc/update_ads_view(time = 1)
	if(!aq_ads_gun || !client)
		return
	var/max_pixels = aq_ads_gun.get_ads_zoom() * world.icon_size
	var/want_x
	var/want_y
	if(aq_cursor_known)
		// aq_cursor_dx/dy liczymy względem postaci (z odjętym przesunięciem widoku), więc to punkt w świecie
		var/distance = sqrt(aq_cursor_dx ** 2 + aq_cursor_dy ** 2)
		var/scale = distance ? min(distance * 0.6, max_pixels) / distance : 0
		want_x = round(aq_cursor_dx * scale)
		want_y = round(aq_cursor_dy * scale)
	else
		var/angle = dir2angle(dir)
		want_x = round(sin(angle) * max_pixels)
		want_y = round(cos(angle) * max_pixels)
	var/delta_x = want_x - aq_ads_offset_x
	var/delta_y = want_y - aq_ads_offset_y
	if(abs(delta_x) < 2 && abs(delta_y) < 2)
		return
	aq_ads_offset_x = want_x
	aq_ads_offset_y = want_y
	animate(client, pixel_x = delta_x, pixel_y = delta_y, time = time, easing = SINE_EASING | EASE_OUT, flags = ANIMATION_RELATIVE | ANIMATION_PARALLEL)

/mob/living/proc/on_ads_gun_lost(datum/source)
	SIGNAL_HANDLER
	stop_ads()

/mob/living/proc/on_ads_interrupted(datum/source, amount)
	SIGNAL_HANDLER
	if(amount > 0)
		stop_ads()

/mob/living/Logout()
	stop_ads()
	return ..()

/// Promieniste rozmycie świata przy celowaniu (BYOND radial_blur: środek ostry, brzegi rozmyte)
/mob/living/proc/set_ads_blur(enable)
	if(!client)
		return
	for(var/atom/movable/screen/plane_master/plane in client.screen)
		if(!istype(plane, /atom/movable/screen/plane_master/game_world) && !istype(plane, /atom/movable/screen/plane_master/floor))
			continue
		if(enable)
			plane.add_filter(AQ_ADS_FILTER, 10, radial_blur_filter(0))
			var/blur = plane.get_filter(AQ_ADS_FILTER)
			if(blur)
				animate(blur, size = 0.015, time = 2.5, easing = SINE_EASING | EASE_OUT)
		else
			plane.remove_filter(AQ_ADS_FILTER)

/obj/item/gun/get_dynamic_spread(mob/living/user)
	. = ..()
	if(istype(user) && user.aq_ads_gun == src)
		. -= spread * AQ_ADS_SPREAD_MULT + user.aq_recoil * (1 - AQ_ADS_RECOIL_SPREAD_MULT)

/obj/item/gun/get_shot_recoil(obj/item/ammo_casing/casing, mob/living/user)
	. = ..()
	if(istype(user) && user.aq_ads_gun == src)
		. *= AQ_ADS_RECOIL_GAIN_MULT

/obj/item/gun/get_spread_cone(mob/living/user)
	return max(..(), 0)

// Prawy przycisk w combat mode: przytrzymanie = celowanie
/obj/item/gun/onMouseDown(object, location, params, mob)
	var/mob/living/user = mob
	var/list/modifiers = params2list(params)
	var/aiming_click = istype(user) && LAZYACCESS(modifiers, RIGHT_CLICK) && !LAZYACCESS(modifiers, SHIFT_CLICK) && !LAZYACCESS(modifiers, CTRL_CLICK) && !LAZYACCESS(modifiers, ALT_CLICK)
	if(aiming_click && user.combat_mode && ads_allowed && !initial(canMouseDown) && user.get_active_held_item() == src && (!istype(object, /atom/movable/screen) || istype(object, /atom/movable/screen/click_catcher)))
		// Prawy przycisk z bronią w combat mode zawsze celuje i nigdy nie strzela (wyjątek: przepchnięcie stojącego obok)
		var/atom/clicked = object
		if(isliving(clicked) && get_dist(user, clicked) <= 1)
			return ..()
		user.client.aq_ignore_next_click = TRUE
		user.start_ads(src)
		return
	return ..()

/obj/item/gun/onMouseUp(object, location, params, mob)
	var/mob/living/user = mob
	if(istype(user) && user.aq_ads_gun == src && LAZYACCESS(params2list(params), RIGHT_CLICK))
		user.stop_ads()
		return
	return ..()

/datum/keybinding/mob/aq_aim_down_sights
	key = "Unbound"
	name = "aq_aim"
	full_name = "Celuj przez przyrządy"
	description = "Przytrzymaj, żeby przyłożyć broń do oka: widok najeżdża w stronę kursora, mniejszy rozrzut i odrzut, wolniejszy ruch."
	keybind_signal = COMSIG_KB_AQ_AIM_DOWN

/datum/keybinding/mob/aq_aim_down_sights/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/living_mob = user.mob
	if(!istype(living_mob))
		return
	var/obj/item/gun/held_gun = living_mob.get_active_held_item()
	if(istype(held_gun))
		living_mob.start_ads(held_gun)
	return TRUE

/datum/keybinding/mob/aq_aim_down_sights/up(client/user)
	. = ..()
	var/mob/living/living_mob = user.mob
	if(istype(living_mob))
		living_mob.stop_ads()

/datum/preferences/load_from_database()
	. = ..()
	offer_default_keybind("aq_aim", "C")

#undef AQ_ADS_SPREAD_MULT
#undef AQ_ADS_RECOIL_SPREAD_MULT
#undef AQ_ADS_RECOIL_GAIN_MULT
#undef AQ_ADS_FILTER

// --- Kursor celownika przy celowaniu (jak na filmie: kursor zmienia się w przyrządy broni) ---

/// Stan kursora z aquila/icons/effects/ads_cursor.dmi: przyrządy mechaniczne albo założony celownik
/obj/item/gun/proc/get_ads_cursor_state()
	for(var/obj/item/attachment/scope/sight in current_attachments)
		if(istype(sight, /obj/item/attachment/scope/holo))
			return "holo"
		if(istype(sight, /obj/item/attachment/scope/infrared))
			return "thermal"
		return "dot"
	return "iron"

GLOBAL_LIST_EMPTY(aq_ads_cursor_icons)

/proc/aq_get_ads_cursor_icon(state)
	var/icon/cached = GLOB.aq_ads_cursor_icons[state]
	if(cached)
		return cached
	var/icon/result = new
	result.Insert(icon('aquila/icons/effects/ads_cursor.dmi', state), "")
	GLOB.aq_ads_cursor_icons[state] = result
	return result

/mob/living/get_gun_cursor_icon()
	if(aq_ads_gun && aq_ads_gun == get_active_held_item())
		return aq_get_ads_cursor_icon(aq_ads_gun.get_ads_cursor_state())
	return ..()

/datum/aq_mouse_tracker/onMouseMove(object, location, control, params)
	. = ..()
	owner?.update_ads_view()
