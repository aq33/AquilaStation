
/datum/bloodcult_ritual/bloodspill
	name = "Rozlej krew"
	desc = "więcej krwi... potrzeba więcej...<br>na podłogach... na ścianach..."

	only_once = TRUE
	ritual_type = "bloodspill"
	difficulty = "hard"
	reward_achiever = 0
	reward_faction = 500

	keys = list("bloodspill")

	var/percent_bloodspill = 4//percent of all the station's simulated floors, you should keep it under 5.
	var/target_bloodspill = 1000//actual amount of bloodied floors to reach
	var/max_bloodspill = 0//max amount of bloodied floors simultanously reached

/datum/bloodcult_ritual/bloodspill/init_ritual()
	var/floor_count = 0
	//AQUILA - liczymy podłogi na wszystkich poziomach stacji (statku), bez kosmosu, asteroid i więzienia
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		for(var/turf/open/floor/tile in block(locate(1, 1, z), locate(world.maxx, world.maxy, z)))
			var/area/tile_area = tile.loc
			if(istype(tile_area, /area/space) || istype(tile_area, /area/mine) || istype(tile_area, /area/security/prison))
				continue
			floor_count++
	target_bloodspill = round(floor_count * percent_bloodspill / 100)
	target_bloodspill += rand(-20, 20)

	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	cult?.bloodspill_ritual = src

/datum/bloodcult_ritual/bloodspill/update_desc()
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	desc = "więcej krwi... potrzeba więcej...<br>na podłogach... na ścianach...<br>jeszcze co najmniej [target_bloodspill - length(cult?.bloody_floors)]..."

/datum/bloodcult_ritual/bloodspill/key_found(extra)
	if(extra > max_bloodspill)
		max_bloodspill = extra
	if(max_bloodspill >= target_bloodspill)
		return TRUE
	return FALSE

/datum/bloodcult_ritual/bloodspill/complete()
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	cult?.bloodspill_ritual = null
	..()
