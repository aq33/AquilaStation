/// AQUILA - wrak przejmuje wnętrze i moduły zestrzelonego okrętu (aquila/code/modules/overmap/modules/wreck_interiors.dm):
/// konsola odzysku widzi go jak okręt z wnętrzem, moduły zostają takie, jak po walce, a załoga jest martwa. Wrak ma
/// wytrzymałość z kadłuba okrętu, PDC go nie rusza, działa tak, a liczba promów do wyciągnięcia zależy od klasy i ładowni.
/datum/unit_test/aquila_wreck_interiors

/datum/unit_test/aquila_wreck_interiors/Run()
	var/obj/structure/overmap/ship = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	var/datum/ship_modules/modules = ship.get_ship_modules()
	if(!modules)
		return Fail("Fregata przeciwlotnicza AI nie ma modułów")
	var/datum/ship_module/bridge = modules.modules_of("bridge")[1]
	modules.damage_module(bridge, bridge.max_integrity / 2)
	var/obj/structure/overmap/asteroid/shipbreak_wreck/wreck = allocate(/obj/structure/overmap/asteroid/shipbreak_wreck)
	wreck.copy_ship(ship)
	if(wreck.interior_mode != INTERIOR_EXCLUSIVE || !length(wreck.possible_interior_maps))
		return Fail("Wrak nie przejął wnętrza okrętu (tryb [wreck.interior_mode])")
	if(wreck.ship_modules != modules || ship.ship_modules)
		return Fail("Moduły nie przeszły z okrętu na wrak")
	if(modules.ship != wreck || !modules.derelict)
		return Fail("Moduły wraku nie wskazują na wrak albo nie są oznaczone jako martwy okręt")
	if(bridge.integrity != bridge.max_integrity / 2)
		return Fail("Wrak nie zachował stanu mostka po walce ([bridge.integrity]/[bridge.max_integrity])")
	for(var/datum/ship_module/module as anything in modules.modules)
		if(module.crew_lost < 1 || module.fire)
			return Fail("Moduł [module.kind] wraku ma żywą załogę albo pożar")
	if(!wreck.overmap_display_bounds())
		return Fail("Wrak nie ma obrysu sprite'a okrętu do skali wizualnej")
	if(wreck.max_integrity < 300 || wreck.obj_integrity != wreck.max_integrity)
		return Fail("Wrak ma [wreck.obj_integrity]/[wreck.max_integrity] wytrzymałości zamiast co najmniej 300")
	var/obj/item/projectile/bullet/pdc_round/pdc = allocate(/obj/item/projectile/bullet/pdc_round)
	var/obj/item/projectile/bullet/heavy_cannon_round/cannon = allocate(/obj/item/projectile/bullet/heavy_cannon_round)
	if(wreck.run_obj_armor(pdc.damage, pdc.damage_type, pdc.flag) >= pdc.damage * 0.5)
		return Fail("PDC rozbija wrak prawie bez osłabienia")
	if(wreck.run_obj_armor(cannon.damage, cannon.damage_type, cannon.flag) < cannon.damage)
		return Fail("Działo średnie nie zadaje wrakowi pełnych obrażeń")
	// Promy do wyciągnięcia: klasa okrętu, mniej przy rozbitej ładowni; ostatni prom zostawia wypatroszony wrak
	var/expected = wreck_salvage_count(ship, null)
	if(expected < 1)
		return Fail("Okręt daje [expected] promów do wyciągnięcia")
	wreck.salvage_left = 1
	wreck.take_salvage()
	if(wreck.salvage_left != 0 || QDELETED(wreck) || !findtext(wreck.name, "Wypatroszony"))
		return Fail("Po ostatnim promie wrak zniknął albo nie jest wypatroszony ([wreck.name], zostało [wreck.salvage_left])")
