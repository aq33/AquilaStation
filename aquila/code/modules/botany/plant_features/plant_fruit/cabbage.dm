/*
	Cabbage
	Medium Fruit that grows averagely
*/
/datum/plant_feature/fruit/cabbage
	species_name = "brassica infantem"
	name = "cabbage"
	icon_state = "cabbage"
	icon_uneven = TRUE
	seed_icon_state = "seed-cabbage"
	fruit_product = /obj/item/food/grown/cabbage
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	total_volume = PLANT_FRUIT_VOLUME_MEDIUM
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	fruit_size = PLANT_FRUIT_SIZE_MEDIUM

/*
	Dionae Pod
	AQUILA - u nas replica pod: zamiast nimfy daje nasiona albo, z próbką krwi, człowieka-strąka (aquila/replica_pod.dm)
*/
/datum/plant_feature/fruit/cabbage/diona
	species_name = "brassica homo"
	name = "replica pod"
	icon_state = "invincible"
	seed_icon_state = "seed-dionapod"
	fruit_product = /obj/item/plant_seeds/preset/diona_pod
	trait_power = 2
	can_copy = FALSE
	can_remove = FALSE
	whitelist_features = list(/datum/plant_feature/body/diona_pod, /datum/plant_feature/roots)
	///Dane z wstrzykniętej krwi (kopia blood.data), z których powstanie klon
	var/list/clone_data
