/*
	AQUILA - nasiona obcych roślin w ruinach planet (port roślin, C9)
	Drugie źródło obcych nasion obok cechy artefaktu Seeding: po wczytaniu ruiny na planecie z szansą
	PLANET_RUIN_SEED_CHANCE wypada 1-2 paczek nasion z puli /obj/item/plant_seeds/preset/alien (rośliny obcych,
	rośliny-artefakty, ksenoflora) na wolnej podłodze w obszarach ruiny. Map nie zmieniamy.
*/

/// Szansa (%), że ruina planety dostanie paczki obcych nasion
#define PLANET_RUIN_SEED_CHANCE 40

/datum/planet_surface/load_ruin(datum/map_template/ruin/ruin, turf/where, centered)
	. = ..()
	if(!.)
		return
	var/list/inside = list()
	for(var/turf/T as anything in ruin.get_affected_turfs(where, centered))
		if(T.loc != surface_area && T.loc != cave_area)
			inside += T
	scatter_alien_seeds(inside, PLANET_RUIN_SEED_CHANCE)

/// Z szansą chance kładzie 1-2 paczki obcych nasion na wolnych, otwartych polach z listy. Zwraca położone paczki.
/proc/scatter_alien_seeds(list/turfs, chance)
	. = list()
	if(!length(turfs) || !prob(chance))
		return
	if(!length(GLOB.alien_plant_seeds))
		return
	var/list/free = list()
	for(var/turf/open/T in turfs)
		if(!is_blocked_turf(T, TRUE))
			free += T
	for(var/i in 1 to rand(1, 2))
		if(!length(free))
			break
		var/seed_type = pickweight(GLOB.alien_plant_seeds)
		. += new seed_type(pick_n_take(free))

#undef PLANET_RUIN_SEED_CHANCE
