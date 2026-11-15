/// AQUILA - kalibracja i zużycie dział (aquila/code/modules/munitions/weapon_wear.dm): ocena mini-gry, spadek kalibracji
/// po strzale, rozrzut z kalibracji w pocisku na overmapie, przepalony aktuator blokuje strzał do wymiany.
/datum/unit_test/aquila_weapon_wear

/datum/unit_test/aquila_weapon_wear/Run()
	// ocena mini-gry (Mastermind): 2 pkt za cyfrę na swoim miejscu, 1 pkt za cyfrę z kodu na złym miejscu
	var/list/result = weapon_calibration_check(list(1, 2, 3, 4), list(1, 2, 3, 4))
	if(result[1] != 4 || result[2] != 0 || weapon_calibration_percent(result[1], result[2]) != 100)
		return Fail("Trafiony kod nie daje 100% kalibracji: [result[1]]/[result[2]]")
	result = weapon_calibration_check(list(4, 3, 2, 1), list(1, 2, 3, 4))
	if(result[1] != 0 || result[2] != 4 || weapon_calibration_percent(result[1], result[2]) != 50)
		return Fail("Cyfry na złych miejscach źle ocenione: [result[1]]/[result[2]]")
	result = weapon_calibration_check(list(1, 1, 1, 1), list(1, 2, 3, 4))
	if(result[1] != 1 || result[2] != 0)
		return Fail("Powtórzona cyfra zbiera punkty więcej niż raz: [result[1]]/[result[2]]")
	result = weapon_calibration_check(list(2, 1, 5, 5), list(1, 2, 2, 9))
	if(result[1] != 0 || result[2] != 2)
		return Fail("Zła ocena cyfr na złych miejscach przy powtórzeniach w kodzie: [result[1]]/[result[2]]")
	if(weapon_calibration_percent(0, 0) != 0)
		return Fail("Próba bez trafień daje kalibrację")
	var/list/parsed = weapon_calibration_parse(" 09 12")
	if(length(parsed) != 4 || parsed[1] != 0 || parsed[2] != 9 || parsed[4] != 2)
		return Fail("Wpis „ 09 12” nie dał cyfr 0, 9, 1, 2")
	if(weapon_calibration_parse("12a4") || weapon_calibration_parse("123") || weapon_calibration_parse("12345"))
		return Fail("Wpis inny niż 4 cyfry został przyjęty")

	var/obj/machinery/ship_weapon/mac/gun = allocate(/obj/machinery/ship_weapon/mac)
	if(!gun.wear_enabled || gun.calibration != 100)
		return Fail("Nowe działo MAC nie ma kalibracji 100%")

	// spadek kalibracji po strzale
	gun.calibration_drop_chance = 100
	gun.actuator_burn_chance = 0
	gun.wear_after_shot()
	if(gun.calibration != 90)
		return Fail("Kalibracja po strzale wynosi [gun.calibration]%, oczekiwano 90%")
	gun.calibration_drop_chance = 0

	// niższa kalibracja = większy rozrzut
	gun.calibration = 100
	if(gun.calibration_spread() != 0)
		return Fail("Działo z pełną kalibracją ma rozrzut [gun.calibration_spread()]")
	gun.calibration = 50
	var/half_spread = gun.calibration_spread()
	gun.calibration = 10
	if(half_spread <= 0 || gun.calibration_spread() <= half_spread)
		return Fail("Rozrzut nie rośnie przy spadku kalibracji ([half_spread] przy 50%, [gun.calibration_spread()] przy 10%)")

	// rozrzut z kalibracji trafia do pocisku wystrzelonego na overmapie
	var/obj/structure/overmap/small_craft/ship = allocate(/obj/structure/overmap/small_craft/combat/light)
	ship.forceMove(locate(10, 10, run_loc_floor_bottom_left.z))
	ship.pending_weapon_spread = 8
	var/obj/item/projectile/bullet/mac_round/prototype = /obj/item/projectile/bullet/mac_round
	var/obj/item/projectile/proj = ship.fire_projectile(/obj/item/projectile/bullet/mac_round, locate(10, 30, run_loc_floor_bottom_left.z))
	if(!istype(proj))
		return Fail("Okręt nie wystrzelił pocisku")
	var/proj_spread = proj.spread
	qdel(proj)
	if(proj_spread != initial(prototype.spread) + 8)
		return Fail("Pocisk ma rozrzut [proj_spread], oczekiwano [initial(prototype.spread) + 8]")
	if(ship.pending_weapon_spread)
		return Fail("Rozrzut z kalibracji został w okręcie po strzale")

	// przepalony aktuator blokuje strzał do wymiany
	var/obj/item/ship_weapon/ammunition/railgun_ammo/round = new(gun)
	gun.ammo += round
	gun.chambered = round
	gun.state = STATE_CHAMBERED
	gun.safety = FALSE
	gun.malfunction = FALSE
	gun.calibration = 100
	if(!gun.can_fire(null, 1))
		return cleanup_round(gun, round, "Przygotowane działo nie może strzelić")
	if(!gun.burn_actuator())
		return cleanup_round(gun, round, "Aktuator się nie przepalił")
	if(gun.can_fire(null, 1))
		return cleanup_round(gun, round, "Działo z przepalonym aktuatorem może strzelić")
	if(!gun.remove_actuator() || gun.can_fire(null, 1))
		return cleanup_round(gun, round, "Działo bez aktuatora może strzelić")
	if(!gun.install_actuator() || !gun.can_fire(null, 1))
		return cleanup_round(gun, round, "Działo po wymianie aktuatora nie może strzelić")
	cleanup_round(gun, round)

/datum/unit_test/aquila_weapon_wear/proc/cleanup_round(obj/machinery/ship_weapon/gun, obj/item/round, failure)
	gun.ammo -= round
	gun.chambered = null
	gun.state = STATE_NOTLOADED
	qdel(round)
	if(failure)
		Fail(failure)

/// Działo MAC przy usuwaniu zostawia na polu swoje części (np. elektronikę spustową); bez sprzątania kolejne testy
/// (revenant_haunt_object szuka najbliższego przedmiotu) znajdują je w pokoju testowym
/datum/unit_test/aquila_weapon_wear/Destroy()
	var/turf/spot = run_loc_floor_bottom_left
	. = ..()
	if(!spot)
		return
	for(var/obj/item/leftover in range(3, spot))
		if(istype(leftover, /obj/item/ship_weapon/parts) || istype(leftover, /obj/item/burnt_actuator) || istype(leftover, /obj/item/stock_parts))
			qdel(leftover, TRUE) // force: elektronika spustowa bez niego zostaje (QDEL_HINT_LETMELIVE)
