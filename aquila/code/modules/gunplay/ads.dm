// AQUILA - celowanie przez przyrządy (ADS) jak na filmie z przykładu: kursor zmienia się w pierścień celownika,
// w środku pierścienia widać powiększony wycinek świata (luneta), a reszta widoku się rozmywa. Widok się nie przesuwa.
// Broń mniej rozrzuca i mniej kopie, a postać idzie wolniej (Shiptest zoom()).
// Luneta to kopie płaszczyzn podłogi, gry i światła (render_source, jak poświata w soft_lighting.dm) powiększone
// wokół kursora i przycięte maską koła. Liczy je tylko karta graficzna klienta. Układ sprawdzony w Dream Seeker 516:
// - rozmyte tło: kopie podłogi i gry na własnym plane masterze pod światłem, z dziurą (odwrotna maska) pod kursorem;
// - soczewka: grupa KEEP_TOGETHER nad światłem z kopiami podłogi, gry i światła w vis_contents. Wolnej całkowitej
//   płaszczyzny między światłem a HUD-em nie ma (plane musi być liczbą całkowitą), więc to nie plane master.
//   Maska grupy liczy się od jej kafla "1,1", a nie od środka ekranu.
// Sterowanie: w combat mode prawy przycisk przytrzymany z bronią w aktywnej ręce; w starym trybie intencji (prawy przycisk
// to tam rozbrajanie) i dla chętnych w obu trybach przytrzymany klawisz „Celuj przez przyrządy”.

/// O ile rozrzut maleje przy celowaniu (ułamek)
#define AQ_ADS_SPREAD_MULT 0.5
/// O ile odrzut postaci mniej psuje celność przy celowaniu
#define AQ_ADS_RECOIL_SPREAD_MULT 0.6
/// Mnożnik przyrostu odrzutu przy celowaniu
#define AQ_ADS_RECOIL_GAIN_MULT 0.7
/// Płaszczyzna rozmytego tła: wolna, nad grą, pod światłem i HUD-em danych (paski zdrowia zostają ostre)
#define AQ_SCOPE_BLUR_PLANE 10
#define AQ_SCOPE_MASK "aq_scope_mask"

/obj/item/gun
	/// Czy broń da się przyłożyć do oka
	var/ads_allowed = TRUE
	/// Powiększenie w lunecie; null = według założonego celownika
	var/ads_zoom

// M-90gl strzela z granatnika prawym przyciskiem
/obj/item/gun/ballistic/automatic/m90
	ads_allowed = FALSE

/// Powiększenie w lunecie: przyrządy mechaniczne 1,5×, celownik optyczny 2×
/obj/item/gun/proc/get_ads_zoom()
	if(!isnull(ads_zoom))
		return ads_zoom
	for(var/obj/item/attachment/scope/sight in current_attachments)
		return 2
	return 1.5

/mob/living
	/// Broń, przez której przyrządy postać celuje
	var/obj/item/gun/aq_ads_gun
	/// Obiekty ekranu lunety (płaszczyzny i kopie)
	var/list/aq_scope_screens
	/// Kopie płaszczyzn w lunecie (te dostają powiększenie)
	var/list/aq_scope_lens_copies
	/// Powiększenie bieżącej lunety
	var/aq_scope_zoom = 1.5

/datum/movespeed_modifier/aq_ads
	multiplicative_slowdown = 1.2

/// Plane master rozmytego tła. Nie jest podtypem /atom/movable/screen/plane_master, żeby nie trafiał
/// do każdego HUD-u i konsoli kamer: istnieje tylko w czasie celowania.
/atom/movable/screen/aq_scope_blur_plane
	name = ""
	screen_loc = "CENTER"
	plane = AQ_SCOPE_BLUR_PLANE
	appearance_flags = PLANE_MASTER | NO_CLIENT_COLOR
	blend_mode = BLEND_OVERLAY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/// Kopia płaszczyzny do rozmytego tła. screen_loc "1,1" jak w soft_lighting.dm: z "CENTER" kopia na 516 jest
/// przesunięta o pół widoku.
/atom/movable/screen/aq_scope_blur_copy
	name = ""
	screen_loc = "1,1"
	plane = AQ_SCOPE_BLUR_PLANE
	appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/// Soczewka: grupa z kopiami płaszczyzn, nad światłem i pod promieniami lasera (ta sama płaszczyzna, niższa warstwa)
/atom/movable/screen/aq_scope_lens
	name = ""
	screen_loc = "1,1"
	plane = ABOVE_LIGHTING_PLANE
	layer = 1
	appearance_flags = KEEP_TOGETHER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/// Kopia płaszczyzny w soczewce, powiększana transformem wokół kursora (środek bufora to środek widoku)
/obj/effect/overlay/aq_scope_view
	name = ""
	plane = FLOAT_PLANE
	appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = NONE

/// Czarne tło soczewki: przestrzeń kosmiczna i niewidoczne kafle nie prześwitują przez nią niepowiększone
/obj/effect/overlay/aq_scope_view/backdrop
	icon = 'aquila/icons/effects/scope_mask.dmi'
	icon_state = "solid"
	color = "#000000"
	layer = 0

// Kopia światła dla lunety. Nazwę dostaje tylko plane master HUD-u (backdrop), jak podłoga i gra w soft_lighting.dm.
/atom/movable/screen/plane_master/lighting/backdrop(mob/mymob)
	. = ..()
	render_target = LIGHTING_RENDER_TARGET

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
	show_scope_lens()
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
	hide_scope_lens()
	update_gun_cursor()
	update_inv_hands()

/// Tworzy lunetę: rozmyte tło z dziurą na soczewkę i powiększoną soczewkę pod kursorem
/mob/living/proc/show_scope_lens()
	hide_scope_lens()
	if(!client || !aq_ads_gun)
		return
	aq_scope_zoom = aq_ads_gun.get_ads_zoom()
	var/icon/mask_icon = icon('aquila/icons/effects/scope_mask.dmi', "mask")
	var/atom/movable/screen/aq_scope_blur_plane/blur_plane = new
	blur_plane.add_filter("aq_scope_blur", 1, gauss_blur_filter(1.5))
	blur_plane.add_filter(AQ_SCOPE_MASK, 2, alpha_mask_filter(icon = mask_icon, flags = MASK_INVERSE))
	var/atom/movable/screen/aq_scope_lens/lens = new
	lens.add_filter(AQ_SCOPE_MASK, 1, alpha_mask_filter(icon = mask_icon))
	aq_scope_screens = list(blur_plane, lens)
	aq_scope_lens_copies = list()
	var/obj/effect/overlay/aq_scope_view/backdrop/backdrop = new
	lens.vis_contents += backdrop
	aq_scope_lens_copies += backdrop
	var/list/sources = list(FLOOR_PLANE_RENDER_TARGET, GAME_PLANE_RENDER_TARGET, LIGHTING_RENDER_TARGET)
	for(var/i in 1 to length(sources))
		var/obj/effect/overlay/aq_scope_view/lens_copy = new
		lens_copy.render_source = sources[i]
		lens_copy.layer = i
		lens.vis_contents += lens_copy
		aq_scope_lens_copies += lens_copy
		if(sources[i] == LIGHTING_RENDER_TARGET)
			lens_copy.blend_mode = BLEND_MULTIPLY
			continue // tło leży pod prawdziwym światłem, więc kopii światła nie potrzebuje
		var/atom/movable/screen/aq_scope_blur_copy/blur_copy = new
		blur_copy.render_source = sources[i]
		blur_copy.layer = i
		aq_scope_screens += blur_copy
	client.screen += aq_scope_screens
	update_ads_view()

/mob/living/proc/hide_scope_lens()
	if(!length(aq_scope_screens))
		return
	client?.screen -= aq_scope_screens
	QDEL_LIST(aq_scope_lens_copies)
	QDEL_LIST(aq_scope_screens)
	aq_scope_screens = null
	aq_scope_lens_copies = null

/// Soczewka idzie za kursorem: maska koła w miejscu kursora i powiększenie wokół tego punktu
/mob/living/proc/update_ads_view()
	if(!aq_ads_gun || !client || !length(aq_scope_screens))
		return
	var/screen_x = 0
	var/screen_y = 0
	if(aq_cursor_known)
		// aq_cursor_dx/dy są względem postaci (z doliczonym przesunięciem kamery), a soczewka leży na ekranie
		screen_x = round(aq_cursor_dx - client.pixel_x)
		screen_y = round(aq_cursor_dy - client.pixel_y)
	var/list/view_size = getviewsize(client.view)
	var/center_x = view_size[1] * world.icon_size / 2
	var/center_y = view_size[2] * world.icon_size / 2
	for(var/atom/movable/screen/scope_screen as anything in aq_scope_screens)
		var/mask = scope_screen.get_filter(AQ_SCOPE_MASK)
		if(!mask)
			continue
		if(istype(scope_screen, /atom/movable/screen/aq_scope_blur_plane))
			mask:x = screen_x // plane master: maska od środka ekranu
			mask:y = screen_y
		else
			mask:x = center_x - world.icon_size / 2 + screen_x // grupa: maska od środka jej kafla "1,1"
			mask:y = center_y - world.icon_size / 2 + screen_y
	var/matrix/zoom = matrix()
	zoom.Translate(-screen_x, -screen_y)
	zoom.Scale(aq_scope_zoom)
	zoom.Translate(screen_x, screen_y)
	for(var/obj/effect/overlay/aq_scope_view/lens_copy as anything in aq_scope_lens_copies)
		if(istype(lens_copy, /obj/effect/overlay/aq_scope_view/backdrop))
			// 96x96 leży lewym dolnym rogiem na kaflu "1,1": przesuwamy go pod kursor (z zapasem na brzeg soczewki)
			var/matrix/backdrop_matrix = matrix()
			backdrop_matrix.Translate(center_x - 48 + screen_x, center_y - 48 + screen_y)
			lens_copy.transform = backdrop_matrix
			continue
		lens_copy.transform = zoom

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
	description = "Przytrzymaj, żeby przyłożyć broń do oka: pod kursorem pojawia się powiększenie, rozrzut i odrzut są mniejsze, ruch wolniejszy."
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
#undef AQ_SCOPE_BLUR_PLANE
#undef AQ_SCOPE_MASK

// --- Kursor celownika przy celowaniu (jak na filmie: kursor zmienia się w pierścień lunety) ---

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
