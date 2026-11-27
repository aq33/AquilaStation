/// AQUILA - obracane działa na sprite'cie okrętu (aquila/code/modules/overmap/ship_turrets.dm): okręt z mocowaniami ma
/// warstwę na każde działo, lufa z lewej burty patrzy na cel strzelca po lewej, lufa z prawej burty zostaje w swoim łuku,
/// a strzał broni grupy obraca jej lufy na cel strzału (kąty z tolerancją, bo cel liczy się od środka okrętu).

/obj/structure/overmap/syndicate/ai/gunboat/morale_test/turret_test
	icon = 'aquila/icons/overmap/aquilas.dmi'
	icon_state = "aquilas-no-weapons"

/obj/structure/overmap/syndicate/ai/gunboat/morale_test/turret_test/Initialize(mapload)
	turret_mounts = GLOB.aquilas_turret_mounts
	return ..()

/datum/unit_test/aquila_ship_turrets

/datum/unit_test/aquila_ship_turrets/Run()
	var/obj/structure/overmap/ship = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test/turret_test, locate(run_loc_floor_bottom_left.x + 10, run_loc_floor_bottom_left.y + 5, run_loc_floor_bottom_left.z))
	if(length(ship.turret_layers) != length(GLOB.aquilas_turret_mounts))
		return Fail("Okręt ma [length(ship.turret_layers)] warstw dział zamiast [length(GLOB.aquilas_turret_mounts)]")
	for(var/obj/effect/overmap_turret/layer as anything in ship.turret_layers)
		if(!(layer in ship.vis_contents))
			return Fail("Warstwa [layer.icon_state] nie jest narysowana na okręcie")
		if(!(layer.icon_state in icon_states(ship.icon)) || !("[layer.icon_state]-firing" in icon_states(ship.icon)))
			return Fail("Ikona okrętu nie ma stanu [layer.icon_state] albo jego strzału")
	ship.angle = 0
	var/obj/effect/overmap_turret/west = ship.turret_layers[1]
	var/obj/effect/overmap_turret/east = ship.turret_layers[3]
	var/obj/effect/overmap_turret/artillery = ship.turret_layers[5]
	// cel po lewej (zachód): lewa wieżyczka patrzy na niego, prawa zostaje na granicy swojego łuku
	ship.turret_aim_at(locate(ship.x - 8, ship.y, ship.z))
	if(turret_angle_off(west.relative_angle, 270) > 15)
		return Fail("Lewa wieżyczka patrzy pod kątem [west.relative_angle] zamiast 270 na cel po lewej")
	if(turret_angle_off(east.relative_angle, 90) > 90)
		return Fail("Prawa wieżyczka wyszła poza swój łuk ([east.relative_angle])")
	// cel przed dziobem: artyleria patrzy prosto
	ship.turret_aim_at(locate(ship.x, ship.y + 8, ship.z))
	if(turret_angle_off(artillery.relative_angle, 0) > 15)
		return Fail("Artyleria patrzy pod kątem [artillery.relative_angle] zamiast 0 na cel przed dziobem")
	// strzał grupy artylerii w prawo obraca ją na cel strzału, mimo celu strzelca przed dziobem
	var/datum/overmap_ship_weapon/mac/weapon = new(ship, FALSE)
	ship.turret_fired(weapon, locate(ship.x + 8, ship.y, ship.z))
	if(turret_angle_off(artillery.relative_angle, 90) > 15)
		return Fail("Po strzale w prawo artyleria patrzy pod kątem [artillery.relative_angle] zamiast 90")
	if(turret_angle_off(west.relative_angle, 0) > 15)
		return Fail("Strzał artylerii obrócił też wieżyczki ([west.relative_angle])")
	qdel(weapon)

/// Różnica kątów w stopniach (0–180)
/datum/unit_test/aquila_ship_turrets/proc/turret_angle_off(a, b)
	return abs(((a - b) % 360 + 540) % 360 - 180)
