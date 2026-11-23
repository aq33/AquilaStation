// AQUILA: find_and_set variants of tgstation/tgstation code/datums/ai/generic/find_and_set.dm (tg 926bf40c5a) that Bee lacks
/// Like find_and_set/in_list, but looks for turfs of the given types we can see
/datum/ai_behavior/find_and_set/in_list/turf_types

/datum/ai_behavior/find_and_set/in_list/turf_types/search_tactic(datum/ai_controller/controller, locate_paths, search_range = SEARCH_TACTIC_DEFAULT_RANGE)
	var/list/found = RANGE_TURFS(search_range, controller.pawn)
	shuffle_inplace(found)
	for(var/turf/possible_turf as anything in found)
		if(!is_type_in_typecache(possible_turf, locate_paths))
			continue
		if(can_see(controller.pawn, possible_turf, search_range))
			return possible_turf
	return null
