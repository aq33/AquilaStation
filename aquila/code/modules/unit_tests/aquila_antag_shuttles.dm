/// AQUILA - promy antagonistów na overmapie (aquila/code/modules/overmap/modules/antag_shuttles.dm): każdy prom z tabeli
/// ma swój okręt ze sprite'em i obrysem (także spodek porywaczy i prom ERT), a okręt bez promu na mapie, spodek bez żywej
/// drużyny i prom ERT po czasie pobytu znikają przy pierwszym tiku.
/datum/unit_test/aquila_antag_shuttles

/datum/unit_test/aquila_antag_shuttles/Run()
	var/list/marker_types = GLOB.antag_shuttle_overmaps.Copy()
	marker_types["abductor"] = /obj/structure/overmap/antag_shuttle/abductor
	marker_types["ert"] = /obj/structure/overmap/antag_shuttle/ert
	for(var/shuttle_id in marker_types)
		var/obj/structure/overmap/antag_shuttle/marker_type = marker_types[shuttle_id]
		if(!ispath(marker_type, /obj/structure/overmap/antag_shuttle))
			return Fail("Prom [shuttle_id] wskazuje [marker_type], a nie okręt promu")
		if(!(initial(marker_type.icon_state) in icon_states(initial(marker_type.icon))))
			return Fail("[marker_type] nie ma stanu [initial(marker_type.icon_state)] w swojej ikonie")
		if(!overmap_sprite_bounds_of(initial(marker_type.icon), initial(marker_type.icon_state)))
			return Fail("[marker_type] nie ma obrysu w overmap_sprite_bounds (uruchom tools/overmap_scale/sprite_bounds.py)")
	var/obj/structure/overmap/antag_shuttle/orphan = new /obj/structure/overmap/antag_shuttle/pirate(run_loc_floor_bottom_left)
	orphan.follow_main_ship()
	if(!QDELETED(orphan))
		qdel(orphan)
		return Fail("Okręt promu bez promu na mapie nie zniknął")
	var/obj/structure/overmap/antag_shuttle/abductor/saucer = new(run_loc_floor_bottom_left)
	saucer.follow_main_ship()
	if(!QDELETED(saucer))
		qdel(saucer)
		return Fail("Spodek porywaczy bez drużyny nie zniknął")
	var/obj/structure/overmap/antag_shuttle/ert/ert = new(run_loc_floor_bottom_left)
	ert.follow_main_ship()
	if(QDELETED(ert))
		return Fail("Prom ERT zniknął przed końcem pobytu")
	ert.leave_time = world.time - 1
	ert.follow_main_ship()
	if(!QDELETED(ert))
		qdel(ert)
		return Fail("Prom ERT nie odleciał po czasie pobytu")
