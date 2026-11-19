/// AQUILA - strefy zagrożeń na overmapie (aquila/code/modules/overmap/hazards/): szybki okręt w polu szczątków obrywa,
/// wolny nie; pole szczątków skraca zasięg wykrycia i zakłóca radio; AI zwalnia w polu; złomowisko dostaje 1-3 pola,
/// a układ startowy żadnej strefy; teren kafla mapy hex wygrywa z typem układu, a kafle z własnymi eventami (pole asteroid,
/// mgławica, burze, promieniowanie, rozbłyski) nie dostają stref; pole przyciągania ciągnie do środka; warstwa środkowa
/// tła nakłada się dla każdego terenu.

/// Bez uzbrojenia, żeby nic w teście nie strzelało
/obj/structure/overmap/syndicate/ai/gunboat/hazard_test
	missiles = 0
	shots_left = 0
	torpedoes = 0

/obj/structure/overmap/syndicate/ai/gunboat/hazard_test/apply_weapons()
	return

/datum/unit_test/aquila_overmap_hazards
	var/obj/structure/overmap/syndicate/ai/gunboat/hazard_test/ship
	var/obj/structure/overmap/small_craft/observer
	var/list/made_systems = list()

/datum/unit_test/aquila_overmap_hazards/Run()
	var/was_enabled = GLOB.overmap_hazards_enabled
	GLOB.overmap_hazards_enabled = TRUE
	ship = allocate(/obj/structure/overmap/syndicate/ai/gunboat/hazard_test)
	observer = allocate(/obj/structure/overmap/small_craft/combat/light)
	observer.faction = "nanotrasen"
	ship.ai_controlled = FALSE
	var/fail = check_speed_field() || check_concealment() || check_ai_speed_cap() || check_interference() || check_spawn() || check_gravity() || check_terrain_background()
	GLOB.overmap_hazards_enabled = was_enabled
	if(fail)
		return Fail(fail)

/datum/unit_test/aquila_overmap_hazards/Destroy()
	for(var/datum/star_system/S as anything in made_systems)
		for(var/obj/effect/overmap_anomaly/anomaly in S.system_contents.Copy())
			// Bazowe anomalie (gwiazda z apply_system_effects()) nie sprzątają po sobie w Destroy()
			GLOB.overmap_anomalies -= anomaly
			S.system_contents -= anomaly
			anomaly.current_system = null
			qdel(anomaly)
		qdel(S)
	made_systems = null
	return ..()

/// Strefa na kafelku okrętu, z okrętem w środku
/datum/unit_test/aquila_overmap_hazards/proc/place_zone(zone_type)
	var/obj/effect/overmap_anomaly/hazard/zone = allocate(zone_type)
	zone.forceMove(get_turf(ship))
	zone.refresh_affected(list(ship, observer))
	return zone

/datum/unit_test/aquila_overmap_hazards/proc/check_speed_field()
	var/obj/effect/overmap_anomaly/hazard/speed/debris_field/field = place_zone(/obj/effect/overmap_anomaly/hazard/speed/debris_field)
	if(!(field in ship.overmap_hazards) || !(ship in field.affecting))
		return "Okręt na środku pola szczątków nie trafił do strefy"
	field.chance_to_affect = 100 // szybki okręt: 100% + nadwyżka, wolny: 0%
	ship.obj_integrity = ship.max_integrity
	ship.velocity.a = field.safe_speed * 0.5
	ship.velocity.e = 0
	if(field.get_affect_chance(ship) > 0)
		return "Wolny okręt ([ship.velocity.ln()] pola/s, bezpiecznie [field.safe_speed]) ma szansę na odłamek"
	for(var/i in 1 to 5)
		field.hazard_tick(ship)
	if(ship.obj_integrity < ship.max_integrity)
		return "Wolny okręt w polu szczątków stracił [ship.max_integrity - ship.obj_integrity] wytrzymałości"
	ship.velocity.a = field.safe_speed + 1
	field.hazard_tick(ship)
	if(ship.obj_integrity >= ship.max_integrity)
		return "Szybki okręt ([ship.velocity.ln()] pola/s) w polu szczątków nie dostał odłamkiem"
	ship.velocity.a = 0
	ship.obj_integrity = ship.max_integrity
	// Wyjście ze strefy czyści obie strony
	field.forceMove(locate(clamp(ship.x + field.radius + 10, 1, world.maxx), ship.y, ship.z))
	field.refresh_affected(list(ship, observer))
	if(ship.overmap_hazards || length(field.affecting))
		return "Okręt poza polem szczątków został w strefie"
	qdel(field)

/datum/unit_test/aquila_overmap_hazards/proc/check_concealment()
	ship.faction = "syndicate"
	var/before = ship.get_detection_range(observer, FALSE)
	var/obj/effect/overmap_anomaly/hazard/speed/debris_field/debris = place_zone(/obj/effect/overmap_anomaly/hazard/speed/debris_field)
	// obserwator też w polu: liczy się i ukrycie celu, i słabsze czujniki
	var/inside = ship.get_detection_range(observer, FALSE)
	if(inside >= before)
		return "Pole szczątków nie zmniejszyło zasięgu wykrycia okrętu ([before] -> [inside])"
	debris.clear_affecting(TRUE)
	debris.refresh_affected(list(ship)) // sam cel w polu
	var/hidden_only = ship.get_detection_range(observer, FALSE)
	if(hidden_only >= before || hidden_only <= inside)
		return "Ukrycie w polu szczątków działa źle (bez strefy [before], cel w środku [hidden_only], obaj w środku [inside])"
	qdel(debris)
	if(ship.overmap_hazards)
		return "Usunięte pole szczątków zostało na liście stref okrętu"
	if(ship.get_detection_range(observer, FALSE) != before)
		return "Po usunięciu pola szczątków zasięg wykrycia nie wrócił ([before] -> [ship.get_detection_range(observer, FALSE)])"

/datum/unit_test/aquila_overmap_hazards/proc/check_ai_speed_cap()
	var/free_mult = ship.get_overmap_speed_mult()
	var/obj/effect/overmap_anomaly/hazard/speed/debris_field/dense/field = place_zone(/obj/effect/overmap_anomaly/hazard/speed/debris_field/dense)
	if(ship.get_overmap_speed_mult() != free_mult)
		return "Okręt gracza w polu szczątków został spowolniony"
	ship.ai_controlled = TRUE
	var/capped = ship.speed_limit * ship.get_overmap_speed_mult()
	ship.ai_controlled = FALSE
	if(capped >= ship.speed_limit * free_mult || capped > field.safe_speed)
		return "AI w gęstym polu szczątków może lecieć [capped] pola/s na oś (bezpiecznie [field.safe_speed])"
	qdel(field)

/datum/unit_test/aquila_overmap_hazards/proc/check_interference()
	if(ship.get_hazard_interference())
		return "Okręt poza strefami ma zakłócone radio"
	var/obj/effect/overmap_anomaly/hazard/speed/debris_field/debris = place_zone(/obj/effect/overmap_anomaly/hazard/speed/debris_field)
	if(ship.get_hazard_interference() != debris.interference)
		return "Pole szczątków nie zakłóca radia okrętu ([ship.get_hazard_interference()]%)"
	qdel(debris)

/datum/unit_test/aquila_overmap_hazards/proc/check_spawn()
	var/datum/star_system/rocks = new /datum/star_system(name = "Unit Test Hazard Rocks", x = 1, y = 1, alignment = "unaligned", owner = "unaligned", sector = 2, adjacency_list = list(), system_type = list(tag = "graveyard"))
	made_systems += rocks
	if(rocks.hazard_terrain() != "junk")
		return "Układ typu graveyard ma teren [rocks.hazard_terrain()] zamiast złomowiska (junk)"
	var/list/zones = rocks.spawn_hazard_zones(rocks.hazard_terrain())
	if(length(zones) < 1 || length(zones) > 3)
		return "Złomowisko dostało [length(zones)] stref (powinno być 1-3)"
	for(var/obj/effect/overmap_anomaly/hazard/zone as anything in zones)
		if(!istype(zone, /obj/effect/overmap_anomaly/hazard/speed/debris_field))
			return "Na złomowisku powstała strefa [zone.type]"
		if(!(zone in rocks.system_contents) || zone.current_system != rocks || zone.z)
			return "Strefa nie leży w niezajętym układzie jak anomalia (z=[zone.z])"
	var/datum/star_system/start = new /datum/star_system(name = SSstar_system.player_start_system_name(), x = 1, y = 1, alignment = "nanotrasen", owner = "nanotrasen", sector = 2, adjacency_list = list(), system_type = list(tag = "debris"))
	made_systems += start
	start.apply_system_effects()
	for(var/obj/effect/overmap_anomaly/hazard/zone in start.system_contents)
		return "W układzie startowym powstała strefa zagrożenia ([zone.name])"
	// kafel mapy hex: teren kafla wygrywa z typem układu, a pusty kafel nie dostaje stref
	rocks.hex_terrain_id = "empty"
	if(length(rocks.spawn_hazard_zones(rocks.hazard_terrain())))
		return "Pusty kafel dostał strefy zagrożeń"
	// kafle z własnymi eventami nie dublują ich strefami
	for(var/terrain in list("meteor", "nebula", "estorm", "storm", "rad", "flare"))
		rocks.hex_terrain_id = terrain
		if(length(rocks.spawn_hazard_zones(rocks.hazard_terrain())))
			rocks.hex_terrain_id = null
			return "Kafel [terrain] dostał strefę, choć ma własne eventy"
	rocks.hex_terrain_id = null

/datum/unit_test/aquila_overmap_hazards/proc/check_gravity()
	var/obj/effect/overmap_anomaly/hazard/gravity_well/well = allocate(/obj/effect/overmap_anomaly/hazard/gravity_well)
	well.forceMove(locate(ship.x + 5, ship.y, ship.z))
	ship.velocity.a = 0
	ship.velocity.e = 0
	well.pull_ship(ship, 1)
	var/pulled_x = ship.velocity.a
	var/pulled_y = ship.velocity.e
	ship.velocity.a = 0
	ship.velocity.e = 0
	qdel(well)
	if(pulled_x <= 0 || abs(pulled_y) > 0.001)
		return "Pole przyciągania nie ciągnie okrętu do środka (prędkość [pulled_x], [pulled_y])"

/datum/unit_test/aquila_overmap_hazards/proc/check_terrain_background()
	var/atom/movable/screen/parallax_layer/terrain_mid/mid = new(null, world.view)
	for(var/terrain in list("meteor", "junk", "nebula", "estorm", "storm", "rad", "flare", "anom", "grav", "carp", "wh", "comet", "mines", "empty"))
		mid.apply_terrain(terrain)
		if(mid.terrain != terrain)
			qdel(mid)
			return "Warstwa tła nie przyjęła terenu [terrain]"
	mid.apply_terrain("meteor")
	var/has_dust = !!mid.particles
	mid.apply_terrain(null)
	var/leftovers = mid.particles || length(mid.overlays)
	qdel(mid)
	if(!has_dust)
		return "Pole asteroid nie ma pyłu w warstwie tła"
	if(leftovers)
		return "Warstwa tła bez terenu dalej coś pokazuje"
