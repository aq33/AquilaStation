// AQUILA - widoczna tarcza i maskowanie (rework systemów okrętu, etap B).
// Bańka: poświata wokół statku na overmapie, jasna przy pełnej tarczy i gasnąca razem z nią
// (trafienie już ma rozbłysk: /obj/effect/temp_visual/overmap_shield_hit).
// Maskowanie: tryb generatora tarcz włączany z jego konsoli. Tarcza nie pochłania wtedy trafień, generator bierze
// SHIELD_CLOAK_POWER przez podział mocy (system Tarcza), a sygnatura statku (rozmiar i ciepło) oraz zasięg wrogiego
// radaru wobec niego spadają do SHIELD_CLOAK_SIGNATURE. Maska trwa najwyżej SHIELD_CLOAK_DURATION, potem generator
// stygnie SHIELD_CLOAK_COOLDOWN. Zdejmuje ją strzał, skok, uszkodzenie generatora albo brak prądu.

#define SHIELD_CLOAK_POWER 6e6
#define SHIELD_CLOAK_DURATION (60 SECONDS)
#define SHIELD_CLOAK_COOLDOWN (120 SECONDS)
#define SHIELD_CLOAK_SIGNATURE 0.2
/// Przezroczystość statku na overmapie w masce (radar.dm: 51-100 = "ledwo widoczny")
#define SHIELD_CLOAK_ALPHA 90
#define SHIELD_BUBBLE_FILTER "aq_shield_bubble"

/obj/machinery/shield_generator
	/// Czy generator utrzymuje maskowanie zamiast tarczy
	var/cloaked = FALSE
	/// Kiedy maska sama się skończy
	var/cloak_until = 0
	/// Od kiedy można znów włączyć maskę
	var/cloak_ready_at = 0
	/// Poziom, na którym włączono maskę (skok na inny poziom ją zdejmuje)
	var/cloak_z = 0
	/// Ostatnia jasność bańki, żeby nie odświeżać filtra bez potrzeby
	var/bubble_level = -1

/obj/structure/overmap/proc/is_cloaked()
	var/obj/machinery/shield_generator/gen = shields
	return istype(gen) && gen.cloaked

/obj/structure/overmap/get_signature_size()
	. = ..()
	if(is_cloaked())
		. *= SHIELD_CLOAK_SIGNATURE

/obj/structure/overmap/get_signature_heat()
	. = ..()
	if(is_cloaked())
		. *= SHIELD_CLOAK_SIGNATURE

/obj/structure/overmap/get_suite_range(suite, obj/structure/overmap/target)
	. = ..()
	if(suite == SENSOR_LIDAR && target?.is_cloaked())
		. *= SHIELD_CLOAK_SIGNATURE

/obj/machinery/shield_generator/proc/can_cloak()
	if(cloaked || world.time < cloak_ready_at)
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
	cloak_until = world.time + SHIELD_CLOAK_DURATION
	cloak_z = ship.z
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
	cloak_ready_at = world.time + SHIELD_CLOAK_COOLDOWN
	var/obj/structure/overmap/ship = get_overmap()
	if(istype(ship))
		animate(ship, 1.5 SECONDS, alpha = 255)
		ship.relay(null, "<span class='warning'>Maskowanie zdjęte[reason ? ": [reason]" : ""]. Generator tarczy stygnie.</span>", FALSE)
	update_bubble(TRUE)

/obj/machinery/shield_generator/process()
	if(!cloaked)
		. = ..()
		update_bubble()
		return
	var/obj/structure/overmap/ship = get_overmap()
	if(!istype(ship) || ship.z != cloak_z)
		end_cloak("skok")
		return
	if(world.time >= cloak_until)
		end_cloak("koniec czasu")
		return
	if(world.time < ship.last_weapon_fire + 2 SECONDS)
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
	.["cloak_left"] = cloaked ? max(0, round((cloak_until - world.time) / 10)) : 0
	.["cloak_cooldown"] = max(0, round((cloak_ready_at - world.time) / 10))
	.["cloak_power"] = SHIELD_CLOAK_POWER / 1e6
	.["can_cloak"] = can_cloak()

/obj/machinery/shield_generator/ui_act(action, params)
	if(action == "cloakToggle")
		if(cloaked)
			end_cloak("na rozkaz")
		else
			start_cloak(usr)
		return TRUE
	return ..()

#undef SHIELD_CLOAK_POWER
#undef SHIELD_CLOAK_DURATION
#undef SHIELD_CLOAK_COOLDOWN
#undef SHIELD_CLOAK_SIGNATURE
#undef SHIELD_CLOAK_ALPHA
#undef SHIELD_BUBBLE_FILTER
