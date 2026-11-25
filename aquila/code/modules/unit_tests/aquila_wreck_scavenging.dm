/// AQUILA - myśliwce przeszukują wraki (aquila/code/modules/overmap/modules/wreck_scavenging.dm): wrak z okrętu ma kilka
/// przeszukań, ocalałe moduły dokładają swoje fanty do puli, przeszukanie wkłada przedmioty do ładowni i zużywa jedno
/// przeszukanie, a wypatroszony wrak nic już nie daje. Wrak z bitwy znika z układu po odlocie okrętu gracza.
/datum/unit_test/aquila_wreck_scavenging

/datum/unit_test/aquila_wreck_scavenging/Run()
	var/obj/structure/overmap/ship = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	var/obj/structure/overmap/asteroid/shipbreak_wreck/wreck = allocate(/obj/structure/overmap/asteroid/shipbreak_wreck)
	wreck.copy_ship(ship)
	if(wreck.scavenge_left < 2)
		return Fail("Wrak okrętu ma tylko [wreck.scavenge_left] przeszukań")
	var/list/base_pool = list()
	for(var/datum/ship_module/module as anything in wreck.ship_modules.modules)
		module.integrity = 0
	base_pool = wreck.scavenge_pool()
	for(var/datum/ship_module/module as anything in wreck.ship_modules.modules)
		module.integrity = module.max_integrity
	if(length(wreck.scavenge_pool()) <= length(base_pool))
		return Fail("Ocalałe moduły wraku nie dokładają fantów do puli")
	var/obj/item/fighter_component/secondary/utility/hold/hold = allocate(/obj/item/fighter_component/secondary/utility/hold)
	wreck.scavenge_left = 1
	var/list/found = wreck.scavenge_into(hold, 2)
	// Dwa takie same stosy łączą się w jeden, więc przedmiotów może być mniej niż losowań
	if(!length(found) || length(found) > 2)
		return Fail("Przeszukanie dało [length(found)] przedmiotów zamiast 1–2")
	for(var/obj/item/I as anything in found)
		if(QDELETED(I) || I.loc != hold)
			return Fail("[I] nie trafił do ładowni")
	if(wreck.scavenge_left != 0)
		return Fail("Przeszukanie nie zużyło przeszukania wraku (zostało [wreck.scavenge_left])")
	if(length(wreck.scavenge_into(hold, 2)))
		return Fail("Wypatroszony wrak dalej daje fanty")
	// Wrak z bitwy znika z układu po odlocie okrętu gracza, losowy wrak układu zostaje
	if(!wreck.battle_wreck)
		return Fail("Wrak zestrzelonego okrętu nie jest oznaczony jako wrak z bitwy")
	var/obj/structure/overmap/asteroid/shipbreak_wreck/random_wreck = allocate(/obj/structure/overmap/asteroid/shipbreak_wreck)
	var/datum/star_system/S = new /datum/star_system(name = "Unit Test Wreck Cleanup", x = 1, y = 1, alignment = "unaligned", owner = "unaligned", sector = 2, adjacency_list = list())
	S.system_contents = list(wreck, random_wreck)
	S.clear_battle_wrecks()
	var/cleared = QDELETED(wreck) && !QDELETED(random_wreck) && !(wreck in S.system_contents)
	S.system_contents = list()
	qdel(S)
	if(!cleared)
		return Fail("Po odlocie wrak z bitwy został w układzie albo zniknął losowy wrak")

/// Dwa wylosowane takie same stosy łączą się w ładowni w jeden: przeszukanie zwraca tylko istniejące przedmioty
/datum/unit_test/aquila_wreck_scavenging_stacks

/obj/structure/overmap/asteroid/shipbreak_wreck/unit_test_rods

/obj/structure/overmap/asteroid/shipbreak_wreck/unit_test_rods/scavenge_pool()
	return list(list(/obj/item/stack/rods, 10))

/datum/unit_test/aquila_wreck_scavenging_stacks/Run()
	var/obj/structure/overmap/asteroid/shipbreak_wreck/unit_test_rods/wreck = allocate(/obj/structure/overmap/asteroid/shipbreak_wreck/unit_test_rods)
	var/obj/item/fighter_component/secondary/utility/hold/hold = allocate(/obj/item/fighter_component/secondary/utility/hold)
	wreck.scavenge_left = 1
	var/list/found = wreck.scavenge_into(hold, 2)
	if(length(found) != 1)
		return Fail("Dwa stosy prętów dały [length(found)] pozycji zamiast jednej")
	var/obj/item/stack/rods/rods = found[1]
	if(QDELETED(rods) || rods.loc != hold || rods.amount != 20)
		return Fail("Połączony stos prętów nie leży w ładowni albo ma [rods?.amount] zamiast 20")
