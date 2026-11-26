/// AQUILA - wybuch magazynu amunicji dobija okręt w trakcie trafienia: Destroy okrętu usuwa jego moduły, a hit() kończył
/// przeliczeniem zdolności na usuniętym okręcie (runtime „Cannot modify null.forward_maxthrust” w ship_modules.dm)
/datum/unit_test/aquila_ship_module_ammo_kill

/// Okręt, który ginie od pierwszych obrażeń (prawdziwe zniszczenie okrętu AI idzie przez krytyk struktury i timery)
/obj/structure/overmap/syndicate/ai/gunboat/morale_test/dies_on_hit

/obj/structure/overmap/syndicate/ai/gunboat/morale_test/dies_on_hit/take_damage(damage_amount, damage_type, damage_flag, sound_effect, nsv_damagesound)
	qdel(src)
	return FALSE

/datum/unit_test/aquila_ship_module_ammo_kill/Run()
	var/obj/structure/overmap/ship = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test/dies_on_hit)
	var/datum/ship_modules/modules = ship.get_ship_modules()
	if(!modules)
		return Fail("Fregata AI nie dostała modułów")
	// magazyn poza resztą siatki, żeby trafienie weszło tylko w niego
	modules.add_module("ammo", 1000, 1000, 1001, 1001, 1)
	var/datum/ship_module/ammo = modules.modules[length(modules.modules)]
	ammo.integrity = 1
	modules.hit(1000.5, 1000.5, 1, 0, 500, TRUE)
	if(!QDELETED(ship) || !QDELETED(modules))
		return Fail("Wybuch magazynu nie zniszczył okrętu testowego, więc test nie sprawdza trafienia w trakcie zniszczenia")
