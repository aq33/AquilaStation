/// AQUILA - wabiki i zagłuszanie (aquila/code/modules/overmap/modules/decoys.dm): flara odciąga torpedę i pocisk na podczerwień, ale nie rakietę radarową,
/// chaff odwrotnie (według głowicy z projektu pocisku), flara wypuszcza dwie flary na obraz i sypie iskrami, wabików ubywa i mają czas odnowienia, a zagłuszacz podnosi sygnaturę okrętu.
/datum/unit_test/aquila_decoys
	var/obj/structure/overmap/small_craft/ship

/datum/unit_test/aquila_decoys/Run()
	ship = allocate(/obj/structure/overmap/small_craft/combat/light)
	ship.forceMove(locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y + 2, run_loc_floor_bottom_left.z))
	var/obj/item/projectile/guided_munition/torpedo/torpedo = allocate(/obj/item/projectile/guided_munition/torpedo, get_turf(ship))
	var/obj/item/projectile/guided_munition/missile/missile = allocate(/obj/item/projectile/guided_munition/missile, get_turf(ship))
	torpedo.set_homing_target(ship)
	missile.set_homing_target(ship)
	LAZYADD(ship.torpedoes_to_target, torpedo)
	LAZYADD(ship.torpedoes_to_target, missile)
	var/flares_before = ship.flares
	if(ship.deploy_decoy("flare", 100) != 1)
		return Fail("Flara nie zwiodła dokładnie jednego pocisku (torpedy)")
	if(!istype(torpedo.homing_target, /obj/effect/overmap_decoy/flare))
		return Fail("Torpeda nie poleciała za flarą")
	var/obj/effect/overmap_decoy/flare/main_flare = torpedo.homing_target
	if(!main_flare.particles)
		return Fail("Flara nie sypie iskrami (brak cząsteczek)")
	var/visual_flares = 0
	for(var/obj/effect/overmap_decoy/flare/visual/extra in get_turf(main_flare))
		visual_flares++
	if(visual_flares != 2)
		return Fail("Za rufą jest [visual_flares] dodatkowych flar zamiast 2")
	if(missile.homing_target != ship)
		return Fail("Flara zwiodła rakietę radarową")
	if(ship.flares != flares_before - 1)
		return Fail("Flar nie ubyło ([ship.flares] z [flares_before])")
	if(ship.deploy_decoy("chaff", 100))
		return Fail("Chaff wystrzelił mimo czasu odnowienia wabików")
	ship.next_decoy = 0
	if(ship.deploy_decoy("chaff", 100) != 1 || !istype(missile.homing_target, /obj/effect/overmap_decoy/chaff))
		return Fail("Chaff nie zwiódł rakiety")
	// Pocisk z projektu: flara myli głowicę na podczerwień (także w rakiecie), chaff radarową (także w torpedzie)
	var/obj/item/projectile/guided_munition/missile/ir_missile = allocate(/obj/item/projectile/guided_munition/missile, get_turf(ship))
	var/obj/item/projectile/guided_munition/torpedo/radar_torpedo = allocate(/obj/item/projectile/guided_munition/torpedo, get_turf(ship))
	var/datum/missile_design/ir_design = new
	ir_design.seeker = "podczerwień"
	ir_missile.AddComponent(/datum/component/missile_design, ir_design)
	var/datum/missile_design/radar_design = new
	radar_design.seeker = "radar"
	radar_torpedo.AddComponent(/datum/component/missile_design, radar_design)
	ir_missile.set_homing_target(ship)
	radar_torpedo.set_homing_target(ship)
	ship.torpedoes_to_target = list(ir_missile, radar_torpedo)
	ship.next_decoy = 0
	ship.flares = ship.max_flares
	ship.chaff = ship.max_chaff
	if(ship.deploy_decoy("flare", 100) != 1 || !istype(ir_missile.homing_target, /obj/effect/overmap_decoy/flare) || radar_torpedo.homing_target != ship)
		return Fail("Flara nie zwiodła rakiety na podczerwień albo zwiodła torpedę radarową")
	ship.next_decoy = 0
	if(ship.deploy_decoy("chaff", 100) != 1 || !istype(radar_torpedo.homing_target, /obj/effect/overmap_decoy/chaff))
		return Fail("Chaff nie zwiódł torpedy z głowicą radarową")
	ship.torpedoes_to_target = null
	var/profile = ship.sensor_profile
	ship.toggle_jammer()
	if(ship.sensor_profile <= profile || !ship.jammer_active)
		return Fail("Zagłuszacz nie podniósł sygnatury okrętu")
	ship.toggle_jammer()
	if(ship.sensor_profile != profile)
		return Fail("Wyłączony zagłuszacz zostawił sygnaturę [ship.sensor_profile] zamiast [profile]")

/// Wabiki wylatują z rufy kadłuba (także po obrocie okrętu), a zagłuszacz działa tylko w stożku wokół namiaru
/datum/unit_test/aquila_decoys_direction

/datum/unit_test/aquila_decoys_direction/Run()
	var/obj/structure/overmap/ship = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	var/obj/structure/overmap/enemy = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	enemy.abstract_move(locate(ship.x + 6, ship.y, ship.z)) // forceMove okrętu działa tylko na overmapie
	for(var/heading in list(0, 90))
		ship.angle = heading
		var/list/stern = ship.overmap_stern_point()
		var/list/hull = ship.overmap_hull_local(0, 0)
		if(!stern || !hull)
			return Fail("Brak rufy albo obrysu kadłuba kanonierki")
		var/turf/T = stern[1]
		var/stern_x = (T.x - ship.x) * world.icon_size + stern[2] + world.icon_size / 2
		var/stern_y = (T.y - ship.y) * world.icon_size + stern[3] + world.icon_size / 2
		var/along = heading ? hull[5] - stern_x : hull[6] - stern_y
		var/across = heading ? abs(stern_y - hull[6]) : abs(stern_x - hull[5])
		if(abs(along - hull[4]) > 1 || across > 1)
			return Fail("Przy kursie [heading]° wabik startuje [along] px za środkiem i [across] px w bok zamiast na rufie ([hull[4]] px za środkiem)")
	ship.toggle_jammer()
	ship.jammer_bearing = 90
	var/covered_east = ship.jammer_covers(enemy)
	ship.jammer_bearing = 270
	var/covered_west = ship.jammer_covers(enemy)
	ship.jammer_bearing = 130
	var/covered_off = ship.jammer_covers(enemy)
	ship.toggle_jammer()
	if(!covered_east || covered_west || covered_off)
		return Fail("Zagłuszacz na wschód: [covered_east], na zachód: [covered_west], 40° obok: [covered_off] (okręt w namiarze [ship.bearing_to(enemy)]°)")
