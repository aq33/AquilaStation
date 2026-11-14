/// AQUILA - promy antagonistów na overmapie (aquila/code/modules/overmap/modules/antag_shuttles.dm): każdy prom z tabeli
/// ma swój okręt ze sprite'em i obrysem, a okręt bez promu na mapie znika przy pierwszym tiku.
/datum/unit_test/aquila_antag_shuttles

/datum/unit_test/aquila_antag_shuttles/Run()
	for(var/shuttle_id in GLOB.antag_shuttle_overmaps)
		var/obj/structure/overmap/antag_shuttle/marker_type = GLOB.antag_shuttle_overmaps[shuttle_id]
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
