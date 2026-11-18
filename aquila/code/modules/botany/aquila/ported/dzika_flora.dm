/*
	AQUILA - dzika roślina (/obj/structure/flora/ash, code/modules/mining/lavaland/ash_flora.dm) dostaje przy Initialize
	losową cechę w każdej części. Cecha kosztuje 1-3 punkty budżetu; gdy przekroczy budżet części, roślina dostaje
	losową potrzebę (np. wodę), a na planecie nie ma zbiornika, więc nigdy by nie zaowocowała. Taką cechę zdejmujemy
	(zwrot budżetu i usunięcie potrzeby robi Destroy cechy). Cechy własne gatunku zostają bez zmian.
*/
/obj/structure/flora/ash/Initialize(mapload)
	. = ..()
	var/datum/component/plant/plant_component = GetComponent(/datum/component/plant)
	if(!plant_component)
		return
	var/changed = FALSE
	for(var/datum/plant_feature/feature as anything in plant_component.plant_features)
		if(feature.remaining_genetic_budget >= 0 || !length(feature.plant_traits))
			continue
		// Losowa cecha jest dopisywana jako ostatnia
		var/datum/plant_trait/random_trait = feature.plant_traits[length(feature.plant_traits)]
		feature.plant_traits -= random_trait
		qdel(random_trait)
		changed = TRUE
	if(changed)
		plant_component.compile_species_id()
