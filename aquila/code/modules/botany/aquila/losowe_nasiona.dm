/*
	AQUILA - pula losowych nasion. Losowe źródła (dziwne nasiona z biogeneratora, poczty, czarnego rynku i dronów,
	nasiona ze szlamu) oraz cel Skarbca DNA biorą tylko presety, które da się zdobyć na stacji.
	Poza pulą: nasiona obce (artefakt „Seeding”, ruiny planet, skrzynia kapsuły ksenoflory) i dzikie presety struktur planet.
*/
/obj/item/plant_seeds/preset
	/// Czy preset trafia do losowych źródeł nasion i do celu Skarbca DNA
	var/random_pool = TRUE

/obj/item/plant_seeds/preset/alien
	random_pool = FALSE

GLOBAL_LIST_INIT(random_plant_seeds, build_random_plant_seeds())

/proc/build_random_plant_seeds()
	. = list()
	for(var/obj/item/plant_seeds/preset/seed_type as anything in valid_subtypesof(/obj/item/plant_seeds/preset))
		if(initial(seed_type.random_pool))
			. += seed_type

// Skarbiec DNA liczył wszystkie podtypy presetów, także abstrakcyjne, obce i dzikie, których nie da się zdobyć na stacji
/datum/station_goal/dna_vault/non_standard_plants_count()
	return length(GLOB.random_plant_seeds)
