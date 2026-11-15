// AQUILA - widoczna tarcza i maskowanie (rework systemów okrętu, etap B).
// Bańka: poświata wokół statku na overmapie, jasna przy pełnej tarczy i gasnąca razem z nią
// (trafienie już ma rozbłysk: /obj/effect/temp_visual/overmap_shield_hit).
// Maskowanie: tryb generatora tarcz włączany z jego konsoli. Tarcza nie pochłania wtedy trafień, generator bierze
// SHIELD_CLOAK_POWER przez podział mocy (system Tarcza), a sygnatura statku (rozmiar i ciepło) oraz zasięg wrogiego
// radaru wobec niego spadają do SHIELD_CLOAK_SIGNATURE. Jak tarcza, maska nie ma limitu czasu ani stygnięcia: trwa,
// dopóki jest prąd. Zdejmuje ją strzał, skok, uszkodzenie generatora albo brak prądu.

#define SHIELD_CLOAK_POWER 6e6
#define SHIELD_CLOAK_SIGNATURE 0.2
/// Przezroczystość statku na overmapie w masce (radar.dm: 51-100 = "ledwo widoczny")
#define SHIELD_CLOAK_ALPHA 90
#define SHIELD_BUBBLE_FILTER "aq_shield_bubble"

/obj/machinery/shield_generator
	/// Czy generator utrzymuje maskowanie zamiast tarczy
	var/cloaked = FALSE
	/// Poziom, na którym włączono maskę (skok na inny poziom ją zdejmuje)
	var/cloak_z = 0
	/// Ostatnia jasność bańki, żeby nie odświeżać filtra bez potrzeby
	var/bubble_level = -1
	/// Czy tarcza była podniesiona przed maską (koniec maski ją przywraca)
	var/cloak_restore_active = FALSE
	/// aq_weapon_shots okrętu w chwili włączenia maski: każdy późniejszy strzał ją zdejmuje, także w tym samym ticku
	var/cloak_fire_mark = 0

/obj/structure/overmap
	/// Ile razy okręt strzelił (sensor_signature.dm); maska zdejmuje się po każdym strzale po jej włączeniu
	var/aq_weapon_shots = 0

/obj/structure/overmap/proc/is_cloaked()
	var/obj/machinery/shield_generator/gen = shields
	return istype(gen) && !QDELETED(gen) && gen.cloaked

/obj/structure/overmap/get_signature_size()
	. = ..()
	if(is_cloaked())
		. *= SHIELD_CLOAK_SIGNATURE

/obj/structure/overmap/get_signature_heat()
	. = ..()
	if(is_cloaked())
		. *= SHIELD_CLOAK_SIGNATURE

/// Ile zasięgu radaru zostaje wobec tego okrętu (maska)
/obj/structure/overmap/proc/get_cloak_lidar_mult()
	return is_cloaked() ? SHIELD_CLOAK_SIGNATURE : 1

/obj/structure/overmap/get_suite_range(suite, obj/structure/overmap/target)
	. = ..()
	// Radar gracza liczy maskę w get_player_lidar_range (player_sensors.dm)
	if(suite == SENSOR_LIDAR && ai_controlled && target)
		. *= target.get_cloak_lidar_mult()

/obj/machinery/shield_generator/proc/can_cloak()
	if(cloaked)
		return FALSE
	if(!powered() || (machine_stat & BROKEN))
		return FALSE
	var/obj/structure/overmap/ship = get_overmap()
	return istype(ship) && ship.shields == src

/obj/machinery/shield_generator/proc/start_cloak(mob/user)
	if(!can_cloak())
		return FALSE
	var/obj/structure/overmap/ship = get_overmap()
	cloaked = TRUE
	cloak_z = ship.z
	cloak_restore_active = active
	cloak_fire_mark = ship.aq_weapon_shots
	active = FALSE
	animate(ship, 1.5 SECONDS, alpha = SHIELD_CLOAK_ALPHA)
	ship.relay(null, "<span class='notice'>Generator tarczy przechodzi w tryb maskowania. Sygnatura okrętu gaśnie.</span>", FALSE)
	if(user)
		log_game("[key_name(user)] włączył maskowanie statku [ship] w [AREACOORD(src)]")
	update_bubble(TRUE)
	return TRUE

/obj/machinery/shield_generator/proc/end_cloak(reason)
	if(!cloaked)
		return
	cloaked = FALSE
	// Tarcza wraca do stanu sprzed maski (zniszczony generator już jej nie podniesie)
	if(!QDELETED(src) && !(machine_stat & BROKEN))
		active = cloak_restore_active
	cloak_restore_active = FALSE
	var/obj/structure/overmap/ship = get_overmap()
	if(istype(ship))
		animate(ship, 1.5 SECONDS, alpha = 255)
		ship.relay(null, "<span class='warning'>Maskowanie zdjęte[reason ? ": [reason]" : ""][active ? ". Tarcza wraca" : ""].</span>", FALSE)
	update_bubble(TRUE)

/// Zniszczony albo rozebrany generator zdejmuje maskę i przestaje być tarczą okrętu
/obj/machinery/shield_generator/Destroy()
	if(cloaked)
		end_cloak("generator zniszczony")
	// Szukamy po okrętach, a nie przez get_overmap(): generator mógł już być poza statkiem (wyniesiony, przeniesiony)
	for(var/obj/structure/overmap/ship as anything in GLOB.overmap_objects)
		if(ship.shields == src)
			ship.remove_filter(SHIELD_BUBBLE_FILTER)
			ship.shields = null
	return ..()

/// Maskę włącza i zdejmuje inżynieria albo dowództwo
/obj/machinery/shield_generator/proc/can_toggle_cloak(mob/user)
	if(issilicon(user) || IsAdminGhost(user))
		return TRUE
	var/obj/item/card/id/card = user?.get_idcard(TRUE)
	var/list/access = card?.GetAccess()
	return (ACCESS_ENGINE in access) || (ACCESS_HEADS in access)

/obj/machinery/shield_generator/process()
	if(!cloaked)
		. = ..()
		update_bubble()
		return
	var/obj/structure/overmap/ship = get_overmap()
	if(!istype(ship) || ship.z != cloak_z)
		end_cloak("skok")
		return
	// Porównanie z chwilą włączenia, a nie okno czasu: strzał między dwoma tickami też zdejmuje maskę
	if(ship.aq_weapon_shots > cloak_fire_mark)
		end_cloak("strzał")
		return
	if(!powered() || !try_use_power(SHIELD_CLOAK_POWER))
		end_cloak("brak mocy")
		return
	// Tarcza nie chroni w masce i powoli się rozładowuje
	shield["integrity"] = max(0, shield["integrity"] - 2)

/obj/machinery/shield_generator/absorb_hit(obj/item/projectile/proj)
	if(cloaked)
		return SHIELD_NOEFFECT
	. = ..()
	if(. == SHIELD_ABSORB)
		update_bubble(TRUE)

/obj/machinery/shield_generator/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()
	if(. && cloaked)
		end_cloak("uszkodzony generator")

/// Poświata tarczy wokół statku na overmapie: jasność od stanu tarczy, brak w masce i przy zgaszonej tarczy
/obj/machinery/shield_generator/proc/update_bubble(force = FALSE)
	var/obj/structure/overmap/ship = get_overmap()
	if(!istype(ship))
		return
	var/level = 0
	if(active && !cloaked && shield["max_integrity"] > 0)
		level = round(clamp(shield["integrity"] / shield["max_integrity"], 0, 1) * 10)
	if(level == bubble_level && !force)
		return
	bubble_level = level
	if(level <= 0)
		ship.remove_filter(SHIELD_BUBBLE_FILTER)
		return
	var/color = rgb(90, 190, 255, 40 + level * 14)
	if(ship.get_filter(SHIELD_BUBBLE_FILTER))
		ship.remove_filter(SHIELD_BUBBLE_FILTER)
	ship.add_filter(SHIELD_BUBBLE_FILTER, 3, outline_filter(2, color))

// --- Konsola generatora: maskowanie ---

/obj/machinery/shield_generator/ui_data(mob/user)
	. = ..()
	.["cloaked"] = cloaked
	.["cloak_power"] = SHIELD_CLOAK_POWER / 1e6
	.["can_cloak"] = can_cloak()

/obj/machinery/shield_generator/ui_act(action, params)
	if(action != "cloakToggle")
		return ..()
	if(machine_stat & (BROKEN|NOPOWER))
		return TRUE
	if(!can_toggle_cloak(usr))
		to_chat(usr, "<span class='warning'>Brak dostępu. Maskowanie włącza inżynieria albo dowództwo.</span>")
		return TRUE
	if(cloaked)
		end_cloak("na rozkaz")
	else
		start_cloak(usr)
	return TRUE

#undef SHIELD_CLOAK_POWER
#undef SHIELD_CLOAK_SIGNATURE
#undef SHIELD_CLOAK_ALPHA
#undef SHIELD_BUBBLE_FILTER
