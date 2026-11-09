// AQUILA - ogień ciągły i strzał przy wciśnięciu przycisku.
// Zastępuje działanie komponentu /datum/component/full_auto z NSV13 (code/modules/projectiles/autofire.dm), który strzelał
// w takt SSfastprocess (co 0,2 s) i bez parametrów myszy (cała seria w środek kratki).
// Wzór: tg /datum/component/automatic_fire (strzały co tick w SSprojectiles, cel i piksel za kursorem przy przeciąganiu)
// i CM (strzał przy MouseDown, zwykły Click po puszczeniu przycisku jest pomijany: ignore_next_click).

/client
	/// Wciśnięcie przycisku zostało już obsłużone jako kliknięcie (strzał przy wciśnięciu), więc Click po puszczeniu pomijamy
	var/aq_ignore_next_click = FALSE

/client/MouseDown(object, location, control, params)
	aq_ignore_next_click = FALSE
	return ..()

/client/Click(atom/object, atom/location, control, params)
	if(aq_ignore_next_click)
		aq_ignore_next_click = FALSE
		return
	return ..()

/client/MouseDrop(src_object, over_object, src_location, over_location, src_control, over_control, params)
	aq_ignore_next_click = FALSE
	return ..()

/obj/item/gun/Initialize(mapload)
	. = ..()
	// Każda zwykła broń strzela przy wciśnięciu przycisku; bronie z własną obsługą myszy (karabin wiązkowy) zostają przy swojej
	if(!initial(canMouseDown))
		canMouseDown = TRUE

/obj/item/gun
	/// Odstęp między strzałami ognia ciągłego (ds); null = z fire_rate broni
	var/autofire_delay

/// Odstęp między strzałami ognia ciągłego: dwa razy szybciej niż klikanie (fire_rate), najwyżej 12 strzałów na sekundę
/obj/item/gun/proc/get_autofire_delay()
	if(autofire_delay)
		return autofire_delay
	return fire_rate ? max(5 / fire_rate, 0.8) : 1.5

/// Czy wciśnięcie przycisku na tym obiekcie ma od razu strzelić (zamiast czekać na zwykły Click)
/obj/item/gun/proc/should_fire_on_press(atom/target, mob/living/user, list/modifiers)
	if(initial(canMouseDown) || !istype(user) || !user.client || user.get_active_held_item() != src)
		return FALSE
	if(LAZYACCESS(modifiers, MIDDLE_CLICK) || LAZYACCESS(modifiers, SHIFT_CLICK) || LAZYACCESS(modifiers, CTRL_CLICK) || LAZYACCESS(modifiers, ALT_CLICK) || LAZYACCESS(modifiers, RIGHT_CLICK))
		return FALSE
	if(user.is_secondary_click(modifiers)) // stary tryb intencji: rozbrajanie to akcja dodatkowa (celowanie przez przyrządy)
		return FALSE
	if(!isatom(target) || (istype(target, /atom/movable/screen)))
		return FALSE
	if(user.click_intercept || user.client.click_intercept) // czar albo umiejętność z celowaniem
		return FALSE
	var/turf/target_turf = get_turf(target)
	if(!target_turf || (target in user.contents) || target == user)
		return FALSE
	// Z bliska zostaje zwykły klik (cios kolbą w combat mode albo strzał z przyłożenia)
	if(get_dist(user, target_turf) <= 1)
		return FALSE
	return TRUE

/obj/item/gun/onMouseDown(object, location, params, mob)
	var/mob/living/user = mob
	var/list/modifiers = params2list(params)
	var/atom/target = object
	if(istype(target, /atom/movable/screen/click_catcher) && istype(user) && user.client)
		target = parse_caught_click_modifiers(modifiers, get_turf(user.client.eye || user), user.client)
		if(!target)
			return
		modifiers["catcher"] = TRUE
		params = list2params(modifiers)
	if(!should_fire_on_press(target, user, modifiers))
		return
	user.client.aq_ignore_next_click = TRUE
	user.ClickOn(target, params)
	if(aq_firemode == AQ_FIREMODE_AUTO && autofire_component)
		autofire_component.start_firing(target, params, user)

/obj/item/gun/onMouseDrag(src_object, over_object, src_location, over_location, params, mob)
	autofire_component?.update_target(over_object, params)

/obj/item/gun/onMouseUp(object, location, params, mob)
	autofire_component?.stop_firing()

// --- Komponent ognia ciągłego (nadpisanie NSV13) ---

/datum/component/full_auto
	/// Kto strzela
	var/mob/living/shooter
	/// Parametry myszy ostatniego położenia kursora (strzał leci w piksel kursora)
	var/autofire_params
	/// Kafel celu na wypadek, gdyby cel zniknął w trakcie serii
	var/turf/autofire_turf
	/// Kiedy następny strzał
	var/next_shot = 0

/datum/component/full_auto/Destroy(force, silent)
	stop_firing()
	return ..()

/// Zaczyna serię; pierwszy strzał oddał już zwykły klik przy wciśnięciu przycisku
/datum/component/full_auto/proc/start_firing(atom/target, params, mob/living/user)
	var/obj/item/gun/gun = parent
	if(!istype(gun) || !istype(user))
		return FALSE
	shooter = user
	autofire_target = target
	autofire_turf = get_turf(target)
	autofire_params = params
	next_shot = world.time + gun.get_autofire_delay()
	START_PROCESSING(SSprojectiles, src)
	return TRUE

/// Przeciąganie myszy prowadzi ogień
/datum/component/full_auto/proc/update_target(atom/target, params)
	if(!autofire_target || !shooter)
		return
	if(istype(target, /atom/movable/screen/click_catcher) && shooter.client)
		var/list/modifiers = params2list(params)
		target = parse_caught_click_modifiers(modifiers, get_turf(shooter.client.eye || shooter), shooter.client)
		if(!target)
			return
		modifiers["catcher"] = TRUE
		params = list2params(modifiers)
	if(!isatom(target) || istype(target, /atom/movable/screen))
		return
	autofire_target = target
	autofire_turf = get_turf(target)
	autofire_params = params

/datum/component/full_auto/proc/stop_firing()
	autofire_target = null
	autofire_turf = null
	autofire_params = null
	shooter = null
	STOP_PROCESSING(SSprojectiles, src)

// Stare wejścia (sygnały NSV13: puszczenie przycisku, upuszczenie broni)
/datum/component/full_auto/unset_target()
	stop_firing()

/datum/component/full_auto/set_target(atom/target)
	return

/datum/component/full_auto/process()
	var/obj/item/gun/gun = parent
	if(!autofire_target || !shooter || !istype(gun))
		stop_firing()
		return PROCESS_KILL
	if(world.time < next_shot)
		return
	if(gun.loc != shooter || shooter.stat != CONSCIOUS || shooter.incapacitated() || shooter.get_active_held_item() != gun || gun.aq_firemode != AQ_FIREMODE_AUTO)
		stop_firing()
		return PROCESS_KILL
	next_shot = world.time + gun.get_autofire_delay()
	var/atom/target = QDELETED(autofire_target) ? autofire_turf : autofire_target
	if(!target || target.z != shooter.z)
		stop_firing()
		return PROCESS_KILL
	shooter.face_atom(target)
	// Seria ma własny rytm: cooldown pojedynczego strzału (ranged_cooldown, semicd) by ją dławił
	gun.ranged_cooldown = 0
	gun.semicd = FALSE
	gun.afterattack(target, shooter, FALSE, autofire_params)
	if(!gun.can_shoot())
		stop_firing()
		return PROCESS_KILL
