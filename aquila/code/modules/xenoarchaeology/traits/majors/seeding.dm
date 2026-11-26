/*
	Seeding
	AQUILA - artefakt wyrzuca nasiono losowej obcej rośliny
*/
/datum/xenoartifact_trait/major/seeding
	label_name = "Seeding"
	label_desc = "Seeding: artefakt wydaje się zawierać zasuszone nasiona. Ich aktywacja wyrzuci nasiono obcej rośliny."
	cooldown = XENOA_TRAIT_COOLDOWN_SAFE
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = FALSE
	weight = 9
	conductivity = 9
	///Najkrótsza przerwa między kolejnymi nasionami, żeby artefakt nie zasypał stacji
	var/seed_cooldown_time = 90 SECONDS
	COOLDOWN_DECLARE(seed_cooldown)

/datum/xenoartifact_trait/major/seeding/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	spawn_seed()

///Wyrzuca jedno nasiono obcej rośliny obok artefaktu, zwraca je albo null w czasie przerwy
/datum/xenoartifact_trait/major/seeding/proc/spawn_seed()
	if(!COOLDOWN_FINISHED(src, seed_cooldown))
		return
	var/turf/artifact_turf = get_turf(component_parent?.parent)
	if(!artifact_turf || !length(GLOB.alien_plant_seeds))
		return
	COOLDOWN_START(src, seed_cooldown, seed_cooldown_time)
	var/seed_type = pickweight(GLOB.alien_plant_seeds)
	var/obj/item/plant_seeds/seeds = new seed_type(artifact_turf)
	seeds.visible_message(span_notice("Z [component_parent.parent] wysypuje się nasiono: [seeds]."))
	playsound(artifact_turf, 'sound/effects/rustle.ogg', 40, TRUE)
	return seeds

/datum/xenoartifact_trait/major/seeding/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_RANDOMISED)
