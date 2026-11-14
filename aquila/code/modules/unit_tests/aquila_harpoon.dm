/// AQUILA - harpun (aquila/code/modules/overmap/modules/harpoon.dm): strzał tylko z bliska, lina blokuje skok FTL obu okrętom,
/// napięta lina ciągnie cel ku harpunującemu, a odcięta czyści obie strony.
/datum/unit_test/aquila_harpoon
	var/obj/structure/overmap/small_craft/ship
	var/obj/structure/overmap/small_craft/target

/datum/unit_test/aquila_harpoon/Run()
	ship = allocate(/obj/structure/overmap/small_craft/combat/light)
	target = allocate(/obj/structure/overmap/small_craft/combat/light)
	target.faction = "syndicate"
	ship.faction = "nanotrasen"
	ship.forceMove(locate(10, 10, run_loc_floor_bottom_left.z))
	target.forceMove(locate(10, 30, run_loc_floor_bottom_left.z))
	ship.has_harpoon = TRUE
	if(!ship.harpoon_blocked(target))
		return Fail("Harpun strzelił do celu 20 pól dalej")
	target.forceMove(locate(10, 15, run_loc_floor_bottom_left.z))
	if(ship.harpoon_blocked(target))
		return Fail("Harpun nie strzela z 5 pól: [ship.harpoon_blocked(target)]")
	ship.attach_harpoon(target)
	var/datum/overmap_tether/tether = ship.harpoon_tether
	if(!tether || target.tethered_by != tether)
		return Fail("Harpun nie połączył okrętów liną")
	if(!(SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CHECK_INTERDICT, target) & STRONG_INTERDICT))
		return Fail("Okręt na linie może skoczyć FTL")
	if(!(SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CHECK_INTERDICT, ship) & STRONG_INTERDICT))
		return Fail("Harpunujący okręt może skoczyć FTL z liną")
	// napięta lina ciągnie cel ku harpunującemu (cel jest na północy, więc dostaje prędkość na południe)
	target.velocity.a = 0
	target.velocity.e = 0
	tether.length = 2
	tether.pull(5)
	if(target.velocity.e >= 0)
		return Fail("Napięta lina nie pociągnęła celu ku harpunującemu (prędkość [target.velocity.e])")
	tether.snap("Lina harpuna odcięta.")
	if(ship.harpoon_tether || target.tethered_by)
		return Fail("Odcięta lina została w zmiennych okrętów")
	if(SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CHECK_INTERDICT, target) & STRONG_INTERDICT)
		return Fail("Po odcięciu liny cel dalej nie może skoczyć")
