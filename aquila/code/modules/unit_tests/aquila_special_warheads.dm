/// AQUILA - głowice specjalne (aquila/code/modules/overmap/warheads/): każda głowica ma skutek na module okrętu AI bez
/// wnętrza (straty załogi, ogłuszenie), trafienie pociskiem odpala skutek w module, AI Syndykatu wybiera specjalną torpedę
/// tylko na okręt z wnętrzem, ładunek na pokładzie puszcza trujący obłok, a głowica z visceratorami buduje torpedę
/// opancerzoną NSV, która wypuszcza na pokładzie visceratory.
/datum/unit_test/aquila_special_warheads
	var/obj/structure/overmap/ship
	var/obj/structure/overmap/small_craft/target

/datum/unit_test/aquila_special_warheads/Run()
	ship = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	target = allocate(/obj/structure/overmap/small_craft/combat/light)
	ship.forceMove(locate(10, 10, run_loc_floor_bottom_left.z))
	target.forceMove(locate(30, 10, run_loc_floor_bottom_left.z))
	var/fail = check_items() || check_modules() || check_projectile_hit() || check_ai_choice() || check_deck_payloads()
	if(fail)
		return Fail(fail)

/// Głowica do budowy daje torpedę, której pocisk przenosi ładunek na pokład
/datum/unit_test/aquila_special_warheads/proc/check_items()
	for(var/warhead_type in subtypesof(/obj/item/ship_weapon/parts/missile/warhead))
		if(!findtext("[warhead_type]", "/special_"))
			continue
		var/obj/item/ship_weapon/parts/missile/warhead/warhead = warhead_type
		var/obj/item/ship_weapon/ammunition/torpedo/torpedo = initial(warhead.build_path)
		var/obj/item/projectile/guided_munition/torpedo/special/projectile = initial(torpedo.projectile_type)
		if(!ispath(projectile, /obj/item/projectile/guided_munition/torpedo/special))
			return "[warhead_type] buduje torpedę bez pocisku specjalnego ([projectile])"
		if(!ispath(initial(projectile.relay_projectile_type), /obj/item/projectile/bullet/delayed_prime/special_warhead))
			return "Pocisk [projectile] nie przenosi ładunku na pokład"
	var/obj/item/ship_weapon/parts/missile/warhead/viscerator = /obj/item/ship_weapon/parts/missile/warhead/viscerator
	var/obj/item/ship_weapon/ammunition/torpedo/viscerator_torpedo = initial(viscerator.build_path)
	if(initial(viscerator_torpedo.projectile_type) != /obj/item/projectile/guided_munition/torpedo/viscerator)
		return "Głowica z visceratorami nie buduje torpedy opancerzonej NSV"

/datum/unit_test/aquila_special_warheads/proc/check_modules()
	var/datum/ship_modules/modules = ship.get_ship_modules()
	if(!modules)
		return "Fregata AI nie ma modułów"
	var/datum/ship_module/bridge = modules.modules_of("bridge")[1]
	var/crew_before = bridge.crew_lost
	modules.special_warhead_effect(bridge, "chemical")
	if(bridge.crew_lost <= crew_before)
		return "Głowica chemiczna nie zabiła załogi modułu"
	var/efficiency_before = modules.crew_efficiency()
	modules.special_warhead_effect(bridge, "flash")
	if(modules.crew_efficiency() >= efficiency_before)
		return "Głowica ogłuszająca nie obniżyła sprawności załogi"
	modules.crew_stunned_until = 0

/// Trafienie pociskiem w okręt bez wnętrza odpala skutek w module
/datum/unit_test/aquila_special_warheads/proc/check_projectile_hit()
	var/datum/ship_modules/modules = ship.get_ship_modules()
	modules.crew_stunned_until = 0
	var/obj/item/projectile/guided_munition/torpedo/special/flash/torpedo = allocate(/obj/item/projectile/guided_munition/torpedo/special/flash, get_turf(ship))
	torpedo.spec_overmap_hit(ship)
	qdel(torpedo) // pocisk na polu trafiałby w to, co na nie wejdzie
	if(world.time >= modules.crew_stunned_until)
		return "Trafienie torpedą ogłuszającą nie ogłuszyło załogi"
	modules.crew_stunned_until = 0

/// AI Syndykatu strzela specjalną torpedą tylko w okręt z wnętrzem
/datum/unit_test/aquila_special_warheads/proc/check_ai_choice()
	var/old_chance = GLOB.ai_special_torpedo_chance
	var/old_ai = ship.ai_controlled
	GLOB.ai_special_torpedo_chance = 100
	ship.ai_controlled = TRUE
	. = null
	if(ship.ai_special_torpedo_type(target))
		. = "AI wybrało specjalną torpedę na myśliwiec bez wnętrza"
	target.role = MAIN_OVERMAP
	var/chosen = ship.ai_special_torpedo_type(target)
	target.role = initial(target.role)
	if(!. && !(chosen in GLOB.ai_special_torpedo_types))
		. = "AI nie wybrało specjalnej torpedy na okręt gracza ([chosen])"
	GLOB.ai_special_torpedo_chance = old_chance
	ship.ai_controlled = old_ai

/// Ładunek na pokładzie okrętu z wnętrzem
/datum/unit_test/aquila_special_warheads/proc/check_deck_payloads()
	var/turf/open/T = locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y + 2, run_loc_floor_bottom_left.z)
	if(!istype(T))
		return "Brak podłogi do testu ładunku"
	// chemiczna: trujący dym albo piana
	special_warhead_detonate(T, "chemical")
	var/found_cloud = FALSE
	for(var/obj/effect/particle_effect/cloud in range(7, T))
		if(istype(cloud, /obj/effect/particle_effect/smoke/chem) || istype(cloud, /obj/effect/particle_effect/foam))
			found_cloud = TRUE
		qdel(cloud)
	if(!found_cloud)
		return "Głowica chemiczna nie wypuściła dymu ani piany"
	// visceratory: torpeda opancerzona NSV wypuszcza je na pokładzie
	var/obj/item/projectile/bullet/delayed_prime/relayed_viscerator_torpedo/payload = allocate(/obj/item/projectile/bullet/delayed_prime/relayed_viscerator_torpedo, T)
	payload.release_payload(T)
	qdel(payload)
	var/count = 0
	for(var/mob/living/basic/viscerator/manhack in range(1, T))
		count++
		qdel(manhack)
	if(!count)
		return "Torpeda z visceratorami nie wypuściła ich na pokładzie"
