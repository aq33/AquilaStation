// AQUILA - celowanie przez przyrządy (ADS): kursor zmienia się w znak celownika broni, a widok wysuwa się w stronę
// kursora, tym dalej, im lepszy celownik (przyrządy mechaniczne 2 kratki, celownik optyczny 3–4). Bez rozmycia i lupy.
// Broń mniej rozrzuca i mniej kopie, a postać idzie wolniej (Shiptest zoom()).
// Sterowanie: w combat mode prawy przycisk przytrzymany z bronią w aktywnej ręce, lewy w tym czasie strzela;
// w starym trybie intencji (prawy przycisk to tam rozbrajanie) i dla chętnych w obu trybach przytrzymany klawisz
// „Celuj przez przyrządy”.

/// O ile rozrzut maleje przy celowaniu (ułamek)
#define AQ_ADS_SPREAD_MULT 0.5
/// O ile odrzut postaci mniej psuje celność przy celowaniu
#define AQ_ADS_RECOIL_SPREAD_MULT 0.6
/// Mnożnik przyrostu odrzutu przy celowaniu
#define AQ_ADS_RECOIL_GAIN_MULT 0.7

/obj/item/gun
	/// Czy broń da się przyłożyć do oka
	var/ads_allowed = TRUE
	/// O ile kratek widok może wysunąć się przy celowaniu; null = według założonego celownika
	var/ads_look_range

/obj/item/attachment/scope
	/// O ile kratek ten celownik pozwala patrzeć dalej przy celowaniu
	var/ads_look_range = 3

// M-90gl strzela z granatnika prawym przyciskiem
/obj/item/gun/ballistic/automatic/m90
	ads_allowed = FALSE

/// O ile kratek wysuwa się widok: przyrządy mechaniczne 2, z celownikiem według celownika
/obj/item/gun/proc/get_ads_look_range()
	if(!isnull(ads_look_range))
		return ads_look_range
	for(var/obj/item/attachment/scope/sight in current_attachments)
		return sight.ads_look_range
	return 2

/mob/living
	/// Broń, przez której przyrządy postać celuje
	var/obj/item/gun/aq_ads_gun
	/// O ile przesunięto widok (piksele), żeby cofnąć dokładnie tyle
	var/aq_ads_offset_x = 0
	var/aq_ads_offset_y = 0

/datum/movespeed_modifier/aq_ads
	multiplicative_slowdown = 1.2

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
	update_gun_cursor()
	update_inv_hands()

/// Widok wysuwa się w stronę kursora: kursor przy krawędzi ekranu = pełny zasięg celownika, przy postaci = nic.
/// Liczymy z położenia kursora na ekranie, a nie w świecie, żeby przesunięcie samo się nie napędzało.
/mob/living/proc/update_ads_view(time = 1)
	if(!aq_ads_gun || !client)
		return
	var/max_pixels = aq_ads_gun.get_ads_look_range() * world.icon_size
	var/want_x = 0
	var/want_y = 0
	if(aq_cursor_known)
		var/screen_x = aq_cursor_dx - client.pixel_x
		var/screen_y = aq_cursor_dy - client.pixel_y
		var/list/view_size = getviewsize(client.view)
		var/half_view = min(view_size[1], view_size[2]) * world.icon_size / 2
		var/distance = sqrt(screen_x ** 2 + screen_y ** 2)
		if(distance > 0)
			var/reach = min(distance / (half_view * 0.85), 1) * max_pixels
			want_x = round(screen_x / distance * reach)
			want_y = round(screen_y / distance * reach)
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

/// Który przycisk myszy faktycznie wciśnięto albo puszczono. BYOND w left/right/middle podaje wszystkie trzymane
/// przyciski, więc lewy kliknięty przy przytrzymanym prawym (celowanie) przychodzi z left=1 i right=1 naraz;
/// rozstrzyga parametr "button", a bez niego zakładamy, że przy celowaniu klika lewy.
/proc/aq_mouse_button(list/modifiers, aiming = FALSE)
	var/button = LAZYACCESS(modifiers, "button")
	if(button)
		return button
	var/left = LAZYACCESS(modifiers, LEFT_CLICK)
	var/right = LAZYACCESS(modifiers, RIGHT_CLICK)
	if(left && right)
		return aiming ? LEFT_CLICK : RIGHT_CLICK
	if(right)
		return RIGHT_CLICK
	if(left)
		return LEFT_CLICK
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		return MIDDLE_CLICK
	return null

/// Parametry kliknięcia lewym przy celowaniu bez trzymanego prawego, żeby strzał nie był brany za akcję prawego przycisku
/proc/aq_params_without_held_right(params)
	var/list/modifiers = params2list(params)
	if(!LAZYACCESS(modifiers, RIGHT_CLICK) || aq_mouse_button(modifiers, TRUE) != LEFT_CLICK)
		return params
	modifiers -= RIGHT_CLICK
	return list2params(modifiers)

// Prawy przycisk w combat mode: przytrzymanie = celowanie, lewy w tym czasie strzela
/obj/item/gun/onMouseDown(object, location, params, mob)
	var/mob/living/user = mob
	var/list/modifiers = params2list(params)
	if(istype(user) && user.aq_ads_gun == src)
		return ..(object, location, aq_params_without_held_right(params), mob)
	var/aiming_click = istype(user) && aq_mouse_button(modifiers) == RIGHT_CLICK && !LAZYACCESS(modifiers, SHIFT_CLICK) && !LAZYACCESS(modifiers, CTRL_CLICK) && !LAZYACCESS(modifiers, ALT_CLICK)
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
	if(istype(user) && user.aq_ads_gun == src)
		var/list/modifiers = params2list(params)
		if(aq_mouse_button(modifiers, TRUE) == RIGHT_CLICK)
			user.stop_ads()
			return
		return ..(object, location, aq_params_without_held_right(params), mob)
	return ..()

// Zwykły Click po puszczeniu lewego przy celowaniu też nie może nieść trzymanego prawego
/client/Click(atom/object, atom/location, control, params)
	var/mob/living/living_mob = mob
	if(istype(living_mob) && living_mob.aq_ads_gun)
		params = aq_params_without_held_right(params)
	return ..(object, location, control, params)

/datum/keybinding/mob/aq_aim_down_sights
	key = "Unbound"
	name = "aq_aim"
	full_name = "Celuj przez przyrządy"
	description = "Przytrzymaj, żeby przyłożyć broń do oka: kursor staje się celownikiem, widok wysuwa się w stronę kursora, rozrzut i odrzut są mniejsze, ruch wolniejszy."
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

// --- Kursor celownika przy celowaniu (kursor zmienia się w znak celownika broni) ---

/// Stan kursora z aquila/icons/effects/scope_reticle.dmi: krzyż przyrządów mechanicznych albo znak założonego celownika
/obj/item/gun/proc/get_ads_cursor_state()
	for(var/obj/item/attachment/scope/sight in current_attachments)
		if(istype(sight, /obj/item/attachment/scope/holo))
			return "holo"
		if(istype(sight, /obj/item/attachment/scope/infrared))
			return "thermal"
		return "dot"
	return "cross"

GLOBAL_LIST_EMPTY(aq_ads_cursor_icons)

/proc/aq_get_ads_cursor_icon(state)
	var/icon/cached = GLOB.aq_ads_cursor_icons[state]
	if(cached)
		return cached
	var/icon/result = new
	result.Insert(icon('aquila/icons/effects/scope_reticle.dmi', state), "")
	GLOB.aq_ads_cursor_icons[state] = result
	return result

/mob/living/get_gun_cursor_icon()
	if(aq_ads_gun && aq_ads_gun == get_active_held_item())
		return aq_get_ads_cursor_icon(aq_ads_gun.get_ads_cursor_state())
	return ..()

/datum/aq_mouse_tracker/onMouseMove(object, location, control, params)
	. = ..()
	owner?.update_ads_view()
