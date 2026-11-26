/// AQUILA - poprawki z przeglądu aq33/AquilaStation#643: wypalony wabik nie zostaje celem pocisku, zniszczony okręt znika
/// z wyborów modułu strzelca, przeszukanie bez miejsca w ładowni nie zużywa wraku, nowe wnętrze na poziomie rezerwacji
/// dostaje swój obrys pokładu, a lina harpuna ciągnie najkrótszą drogą przez krawędź overmapy.
/datum/unit_test/aquila_pr643_review_fixes

/datum/unit_test/aquila_pr643_review_fixes/Run()
	var/fail = check_decoy() || check_aim_modules() || check_scavenge() || check_deck_bounds() || check_tether_wrap() || check_civilian_fire()
	if(fail)
		return Fail(fail)

/datum/unit_test/aquila_pr643_review_fixes/proc/check_decoy()
	var/obj/structure/overmap/small_craft/ship = allocate(/obj/structure/overmap/small_craft/combat/light)
	ship.forceMove(locate(run_loc_floor_bottom_left.x + 6, run_loc_floor_bottom_left.y + 2, run_loc_floor_bottom_left.z))
	var/obj/item/projectile/guided_munition/torpedo/torpedo = allocate(/obj/item/projectile/guided_munition/torpedo, get_turf(ship))
	torpedo.set_homing_target(ship)
	ship.torpedoes_to_target = list(torpedo)
	if(ship.deploy_decoy("flare", 100) != 1)
		return "Flara nie zwiodła torpedy"
	var/obj/effect/overmap_decoy/flare = torpedo.homing_target
	ship.torpedoes_to_target = null
	if(!istype(flare))
		return "Torpeda nie poleciała za flarą"
	var/turf/stern = get_turf(flare)
	qdel(flare)
	for(var/obj/effect/overmap_decoy/extra in stern) // flary na obraz żyją kilka sekund: nie zostawiamy ich innym testom
		qdel(extra)
	if(torpedo.homing_target || torpedo.homing)
		return "Torpeda dalej celuje w wypaloną flarę ([torpedo.homing_target])"

/datum/unit_test/aquila_pr643_review_fixes/proc/check_aim_modules()
	var/obj/structure/overmap/shooter = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	var/obj/structure/overmap/target = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	shooter.set_aim_module(target, 1)
	if(LAZYACCESS(shooter.aim_modules, target) != 1)
		return "Strzelec nie zapamiętał wybranego modułu celu"
	qdel(target)
	if(LAZYLEN(shooter.aim_modules))
		return "Zniszczony cel został na liście wybranych modułów strzelca"

/datum/unit_test/aquila_pr643_review_fixes/proc/check_scavenge()
	var/obj/structure/overmap/asteroid/shipbreak_wreck/wreck = allocate(/obj/structure/overmap/asteroid/shipbreak_wreck)
	var/obj/item/fighter_component/secondary/utility/hold/hold = allocate(/obj/item/fighter_component/secondary/utility/hold)
	wreck.scavenge_left = 1
	if(length(wreck.scavenge_into(hold, 0)) || wreck.scavenge_left != 1)
		return "Przeszukanie bez miejsca w ładowni zużyło wrak (zostało [wreck.scavenge_left])"

/datum/unit_test/aquila_pr643_review_fixes/proc/check_deck_bounds()
	var/obj/structure/overmap/ship = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	var/z = run_loc_floor_bottom_left.z
	var/key = "[z]"
	var/list/old_bounds = GLOB.ship_deck_bounds[key]
	GLOB.ship_deck_bounds[key] = list(1, 1, 2, 2) // obrys poprzedniego wnętrza na tym poziomie
	ship.occupying_levels = list(SSmapping.z_list[z])
	ship.post_load_interior()
	ship.occupying_levels = list()
	var/stale = !isnull(GLOB.ship_deck_bounds[key])
	if(old_bounds)
		GLOB.ship_deck_bounds[key] = old_bounds
	else
		GLOB.ship_deck_bounds -= key
	if(stale)
		return "Nowe wnętrze na poziomie rezerwacji dostało obrys pokładu poprzedniego okrętu"

/datum/unit_test/aquila_pr643_review_fixes/proc/check_tether_wrap()
	var/obj/structure/overmap/source = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	var/obj/structure/overmap/target = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	var/y = run_loc_floor_bottom_left.y
	var/z = run_loc_floor_bottom_left.z
	// po dwóch stronach wschodniej krawędzi: najkrótsza droga z celu do źródła prowadzi na wschód, przez krawędź
	source.abstract_move(locate(TRANSITIONEDGE + 3, y, z))
	target.abstract_move(locate(world.maxx - TRANSITIONEDGE - 3, y, z))
	var/datum/overmap_tether/tether = new(source, target)
	tether.length = 1
	target.velocity.a = 0
	source.velocity.a = 0
	tether.pull(10)
	var/target_pull = target.velocity.a
	var/source_pull = source.velocity.a
	qdel(tether)
	if(target_pull <= 0 || source_pull >= 0)
		return "Lina ciągnie przez całą mapę zamiast przez krawędź (cel [target_pull], źródło [source_pull])"

/// Niezależny frachtowiec strzelał z działek do okrętu gracza (inna frakcja), co w testach rozsadzało rury na stacji
/datum/unit_test/aquila_pr643_review_fixes/proc/check_civilian_fire()
	var/obj/structure/overmap/civ = allocate(/obj/structure/overmap/nanotrasen/mining_cruiser/aquila_hex_freighter/civilian/independent)
	var/obj/structure/overmap/friendly = allocate(/obj/structure/overmap/nanotrasen/mining_cruiser/aquila_hex_freighter/civilian)
	var/datum/overmap_ship_weapon/gun
	for(var/datum/overmap_ship_weapon/weapon as anything in civ.autonomous_weapon_datums)
		gun = weapon
		break
	if(!gun)
		return "Niezależny frachtowiec nie ma broni autonomicznej"
	gun.next_firetime = 0
	if(gun.can_fire(friendly))
		return "Niezależny frachtowiec może strzelać do okrętu Nanotrasen"
