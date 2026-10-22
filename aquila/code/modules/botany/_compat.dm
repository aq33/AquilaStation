// Warstwa zgodności dla botaniki z BeeStation/BeeStation-Hornet#14133.
// Bee ma abstract_type na /datum i /atom, u nas tylko na kilku typach, więc dokładamy je tylko bazowym typom botaniki.

/datum/plant_feature/var/abstract_type
/datum/plant_trait/var/abstract_type
/datum/dictionary_entry/var/abstract_type
/obj/item/plant_seeds/var/abstract_type

// valid_subtypesof jest w aquila/code/modules/antagonists/vampire/_compat.dm (wspólny z wampirem)

/// Bee nazywa reaction() expose(), argumenty i metody (TOUCH, INJECT...) są te same
/datum/reagents/proc/expose(atom/A, method = TOUCH, volume_modifier = 1, show_message = 1, obj/item/bodypart/affecting)
	return reaction(A, method, volume_modifier, show_message, affecting)

/// Wszystkie turfy obszaru (u Bee obszary trzymają je per poziom z)
/area/proc/get_turfs_from_all_zlevels()
	. = list()
	for(var/turf/T in src)
		. += T
