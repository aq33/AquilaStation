/// AQUILA - głowice specjalne (wzór: FTL13, code/modules/ftl/weaponry/ship_attacks.dm: bomba chemiczna i ogłuszająca).
/// Ogień, impuls jonowy i abordaż robią głowice NSV (HLLF, torpeda zakłócająca, torpeda z visceratorami) i dyfuzor tarcz.
/// Torpeda bije w kadłub słabiej niż zwykła, ale niesie ładunek do środka okrętu:
/// - okręt z wnętrzem (okręt gracza, wczytane wnętrze wroga): pocisk przekazany na pokład (relay_damage, Swiss Cheese)
///   rozrywa się za poszyciem; gdy pełny pancerz zatrzyma pocisk, ładunek i tak wchodzi przez przebicie na pierwsze pole
///   za poszyciem w miejscu trafienia,
/// - okręt AI bez wnętrza: skutek na module w miejscu trafienia (ship_modules.dm, ship_module_sim.dm).
/// Okręty AI Syndykatu czasem strzelają nimi w okręt z wnętrzem (ai_special_torpedo_type).
/// Torpedy, głowice do budowy, projekty i paczka w special_warhead_items.dm.

#define SPECIAL_WARHEAD_CHEMICAL "chemical"
#define SPECIAL_WARHEAD_FLASH "flash"
/// Jak długo załoga okrętu AI jest ogłuszona po głowicy ogłuszającej
#define SPECIAL_WARHEAD_STUN_TIME (20 SECONDS)

/// Szansa (%), że torpeda okrętu AI Syndykatu wystrzelona w okręt z wnętrzem będzie specjalna
GLOBAL_VAR_INIT(ai_special_torpedo_chance, 12)
GLOBAL_LIST_INIT(ai_special_torpedo_types, list(
	/obj/item/projectile/guided_munition/torpedo/special/chemical/ai,
	/obj/item/projectile/guided_munition/torpedo/special/flash/ai,
))
/// Trucizny głowicy chemicznej (odpowiedniki listy z FTL13)
GLOBAL_LIST_INIT(special_warhead_poisons, list(
	/datum/reagent/toxin/heparin,
	/datum/reagent/toxin/initropidril,
	/datum/reagent/toxin/amanitin,
	/datum/reagent/toxin/itching_powder,
	/datum/reagent/toxin/pancuronium,
))

// ---------------------------------------------------------------------------------------------------------------------
// Pociski na overmapie

/obj/item/projectile/guided_munition/torpedo/special
	name = "torpeda specjalna"
	damage = 120
	/// Rodzaj ładunku (SPECIAL_WARHEAD_*)
	var/warhead_kind

/obj/item/projectile/guided_munition/torpedo/special/spec_overmap_hit(obj/structure/overmap/target)
	. = ..()
	if(QDELETED(target) || length(target.occupying_levels))
		return // ładunek wejdzie na pokład z pociskiem przekazanym przez relay_damage()
	target.special_warhead_ai_hit(src, warhead_kind)

/obj/item/projectile/guided_munition/torpedo/special/chemical
	name = "torpeda chemiczna"
	color = "#7cff4a"
	damage = 100
	warhead_kind = SPECIAL_WARHEAD_CHEMICAL
	relay_projectile_type = /obj/item/projectile/bullet/delayed_prime/special_warhead/chemical

/obj/item/projectile/guided_munition/torpedo/special/chemical/ai
	obj_integrity = 40
	max_integrity = 40

/obj/item/projectile/guided_munition/torpedo/special/flash
	name = "torpeda ogłuszająca"
	color = "#ffe14a"
	damage = 100
	warhead_kind = SPECIAL_WARHEAD_FLASH
	relay_projectile_type = /obj/item/projectile/bullet/delayed_prime/special_warhead/flash

/obj/item/projectile/guided_munition/torpedo/special/flash/ai
	obj_integrity = 40
	max_integrity = 40

// ---------------------------------------------------------------------------------------------------------------------
// Pociski na pokładzie (relay_damage): przebijają poszycie i rozrywają się na pierwszym otwartym polu za nim

/obj/item/projectile/bullet/delayed_prime/special_warhead
	name = "głowica specjalna"
	icon_state = "torpedo"
	damage = 20
	penetration_fuze = 1
	var/warhead_kind

/obj/item/projectile/bullet/delayed_prime/special_warhead/fuze_trigger_value(atom/target)
	if(isclosedturf(target) || isliving(target))
		return 1
	return 0

/obj/item/projectile/bullet/delayed_prime/special_warhead/is_valid_to_release(atom/newloc)
	return penetration_fuze <= 0 && isopenturf(newloc) && !isspaceturf(newloc)

/obj/item/projectile/bullet/delayed_prime/special_warhead/release_payload(atom/detonation_location)
	special_warhead_detonate(detonation_location, warhead_kind)

/obj/item/projectile/bullet/delayed_prime/special_warhead/chemical
	name = "torpeda chemiczna"
	color = "#7cff4a"
	warhead_kind = SPECIAL_WARHEAD_CHEMICAL

/obj/item/projectile/bullet/delayed_prime/special_warhead/flash
	name = "torpeda ogłuszająca"
	color = "#ffe14a"
	warhead_kind = SPECIAL_WARHEAD_FLASH

/// Ładunek głowicy na polu wnętrza okrętu
/proc/special_warhead_detonate(turf/target, kind)
	var/turf/open/T = target
	if(!istype(T) || isspaceturf(T))
		T = null
		for(var/turf/open/near in range(1, target))
			if(!isspaceturf(near))
				T = near
				break
	if(!T)
		return
	switch(kind)
		if(SPECIAL_WARHEAD_CHEMICAL)
			T.visible_message("<span class='userdanger'>Z rozbitej głowicy bucha trujący obłok!</span>")
			var/datum/reagents/poison = new /datum/reagents(50)
			poison.my_atom = T
			if(prob(20))
				poison.add_reagent(pick(GLOB.special_warhead_poisons), 50)
				var/datum/effect_system/foam_spread/foam = new
				foam.set_up(80, T, poison)
				playsound(T, 'sound/effects/bubbles2.ogg', 80, TRUE)
				foam.start()
				qdel(foam)
			else
				poison.add_reagent(pick(GLOB.special_warhead_poisons), 20)
				var/datum/effect_system/smoke_spread/chem/smoke = new
				smoke.set_up(poison, 5, T, TRUE)
				playsound(T, 'sound/effects/smoke.ogg', 100, TRUE)
				smoke.start()
				qdel(smoke)
			qdel(poison)
		if(SPECIAL_WARHEAD_FLASH)
			var/obj/item/grenade/flashbang/bang = new(T)
			bang.prime()

// ---------------------------------------------------------------------------------------------------------------------
// Okręt z wnętrzem: pancerz i miejsce trafienia

// Pełny pancerz zatrzymuje pocisk na poszyciu (swiss_cheese.dm), ale ładunek głowicy specjalnej i tak wchodzi do środka.
// Ten plik musi być dołączony po swiss_cheese.dm, żeby to nadpisanie szło przed nim i widziało last_hull_hit.
/obj/structure/overmap/relay_damage(proj_type, original_proj_angle)
	if(!ispath(proj_type, /obj/item/projectile/bullet/delayed_prime/special_warhead))
		return ..()
	var/turf/armoured = special_warhead_armour_turf()
	. = ..()
	if(!armoured)
		return
	var/obj/item/projectile/bullet/delayed_prime/special_warhead/payload = proj_type
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(special_warhead_detonate), armoured, initial(payload.warhead_kind)), 1 SECONDS)

/// Pole wnętrza tuż za poszyciem w miejscu ostatniego trafienia, gdy pełny pancerz nie wpuści pocisku (Swiss Cheese
/// zrobi tylko wgniecenie); null, gdy pocisk wejdzie sam albo nie ma gdzie trafić
/obj/structure/overmap/proc/special_warhead_armour_turf()
	var/list/hit = last_hull_hit
	if(!hit || !length(occupying_levels))
		return null
	var/datum/space_level/SL = pick(occupying_levels)
	var/list/bounds = ship_deck_bounds(SL.z_value)
	if(!bounds)
		return null
	var/list/deck = swiss_cheese_deck_point(bounds, hit[1], hit[2], hit[3], hit[4])
	if(!deck)
		return null
	var/turf/target = locate(deck[1], deck[2], SL.z_value)
	var/turf/start = swiss_cheese_start(target, deck[3], deck[4], bounds)
	if(!target || !start)
		return null
	if(deck_hole_depth(target, hull_hit_armour(hit)) > 0)
		return null // pancerz zbity: Swiss Cheese wpuści pocisk z ładunkiem
	var/turf/hull = swiss_cheese_first_hull(start, deck[3], deck[4])
	if(!hull)
		return null
	var/x = hull.x
	var/y = hull.y
	for(var/i in 1 to 10)
		var/turf/T = locate(round(x), round(y), hull.z)
		if(!T)
			return null
		if(isopenturf(T) && !isspaceturf(T) && !istype(T.loc, /area/space))
			return T
		x += deck[3]
		y += deck[4]
	return null

// ---------------------------------------------------------------------------------------------------------------------
// Okręt AI bez wnętrza: skutek na module w miejscu trafienia

/// Skutek głowicy na okręcie bez wnętrza; zwraca trafiony moduł
/obj/structure/overmap/proc/special_warhead_ai_hit(obj/item/projectile/P, kind)
	var/datum/ship_modules/modules = get_ship_modules()
	if(!modules)
		return null
	var/datum/ship_module/module = special_warhead_module(P)
	if(module)
		modules.special_warhead_effect(module, kind)
	return module

/// Moduł w miejscu trafienia pocisku (pierwszy na jego drodze w głąb kadłuba), awaryjnie losowy
/obj/structure/overmap/proc/special_warhead_module(obj/item/projectile/P)
	var/datum/ship_modules/modules = get_ship_modules()
	if(!modules || !length(modules.modules))
		return null
	var/list/local = P ? overmap_hull_local((P.x - x) * 32 + P.pixel_x + 16, (P.y - y) * 32 + P.pixel_y + 16) : null
	if(local)
		// jak w ship_module_projectile_hit(): punkt w układzie okrętu i kierunek lotu pocisku
		var/layout_x = (clamp(local[2] / local[4], -1, 1) + 1) / 2 * modules.length
		var/layout_y = (clamp(local[1] / local[3], -1, 1) + 1) / 2 * modules.width
		var/wx = sin(P.Angle)
		var/wy = cos(P.Angle)
		var/c = cos(angle)
		var/s = sin(angle)
		var/dir_x = (wx * s + wy * c) * modules.length / (2 * local[4])
		var/dir_y = (wx * c - wy * s) * modules.width / (2 * local[3])
		var/norm = sqrt(dir_x * dir_x + dir_y * dir_y)
		if(norm)
			dir_x /= norm
			dir_y /= norm
		for(var/step in 0 to 16)
			var/datum/ship_module/module = modules.module_at(layout_x + dir_x * step / 2, layout_y + dir_y * step / 2)
			if(module)
				return module
	return pick(modules.modules)

/datum/ship_modules
	/// AQUILA - załoga ogłuszona głowicą ogłuszającą do tego czasu (special_warheads.dm)
	var/crew_stunned_until = 0

/datum/ship_modules/proc/special_warhead_effect(datum/ship_module/module, kind)
	switch(kind)
		if(SPECIAL_WARHEAD_CHEMICAL) // trucizna zabija załogę modułu, część obłoku przechodzi dalej
			module.crew_lost = min(1, module.crew_lost + 0.4)
			for(var/datum/ship_module/near as anything in neighbours(module))
				near.crew_lost = min(1, near.crew_lost + 0.15)
		if(SPECIAL_WARHEAD_FLASH) // ogłuszona załoga: słabiej gasi i naprawia, AI i broń się zacinają
			crew_stunned_until = max(crew_stunned_until, world.time + SPECIAL_WARHEAD_STUN_TIME)
	apply_effects()

/datum/ship_modules/crew_efficiency()
	. = ..()
	if(world.time < crew_stunned_until)
		. *= 0.4

// Ogłuszona załoga: AI czasem nie podejmuje decyzji
/obj/structure/overmap/ai_process()
	if(ship_modules && world.time < ship_modules.crew_stunned_until && prob(40))
		return
	return ..()

// Ogłuszona obsługa broni: co drugi strzał się nie udaje
/datum/overmap_ship_weapon/can_fire(atom/target, list/inplace_report)
	. = ..()
	if(!.)
		return
	var/datum/ship_modules/modules = linked_overmap?.ship_modules
	if(!modules || world.time >= modules.crew_stunned_until || !prob(50))
		return
	if(inplace_report)
		inplace_report[1] = "Błąd - ogłuszona obsługa broni. ([src])"
	return FALSE

// ---------------------------------------------------------------------------------------------------------------------
// AI Syndykatu: czasem specjalna torpeda w okręt z wnętrzem

/datum/overmap_ship_weapon/torpedo_launcher/get_nonphysical_projectile_type()
	. = ..()
	var/special = linked_overmap?.ai_special_torpedo_type(linked_overmap.last_target)
	if(special)
		return special

/// Typ specjalnej torpedy, którą okręt AI wystrzeli w cel, albo null (zwykła torpeda)
/obj/structure/overmap/proc/ai_special_torpedo_type(obj/structure/overmap/target)
	if(!ai_controlled || faction != "syndicate" || !istype(target) || QDELETED(target))
		return null
	if(target.role != MAIN_OVERMAP && !length(target.occupying_levels))
		return null
	if(!prob(GLOB.ai_special_torpedo_chance))
		return null
	return pick(GLOB.ai_special_torpedo_types)

#undef SPECIAL_WARHEAD_CHEMICAL
#undef SPECIAL_WARHEAD_FLASH
#undef SPECIAL_WARHEAD_STUN_TIME
