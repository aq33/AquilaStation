/// AQUILA - wabiki i zagłuszanie (aquila/code/modules/overmap/modules/decoys.dm): flara odciąga torpedę, ale nie rakietę,
/// chaff odwrotnie, wabików ubywa i mają czas odnowienia, a zagłuszacz podnosi sygnaturę okrętu.
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
	if(missile.homing_target != ship)
		return Fail("Flara zwiodła rakietę radarową")
	if(ship.flares != flares_before - 1)
		return Fail("Flar nie ubyło ([ship.flares] z [flares_before])")
	if(ship.deploy_decoy("chaff", 100))
		return Fail("Chaff wystrzelił mimo czasu odnowienia wabików")
	ship.next_decoy = 0
	if(ship.deploy_decoy("chaff", 100) != 1 || !istype(missile.homing_target, /obj/effect/overmap_decoy/chaff))
		return Fail("Chaff nie zwiódł rakiety")
	var/profile = ship.sensor_profile
	ship.toggle_jammer()
	if(ship.sensor_profile <= profile || !ship.jammer_active)
		return Fail("Zagłuszacz nie podniósł sygnatury okrętu")
	ship.toggle_jammer()
	if(ship.sensor_profile != profile)
		return Fail("Wyłączony zagłuszacz zostawił sygnaturę [ship.sensor_profile] zamiast [profile]")
