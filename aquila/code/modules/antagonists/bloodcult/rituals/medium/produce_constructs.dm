
/datum/bloodcult_ritual/produce_constructs
	name = "Po jednym z każdego"
	desc = "rzemieślnik...<br>widmo...<br>juggernaut..."

	ritual_type = "constructs"
	difficulty = "medium"
	reward_faction = 300

	keys = list("build_construct")

	var/list/types_to_build = list("Artificer", "Wraith", "Juggernaut")

/datum/bloodcult_ritual/produce_constructs/init_ritual()
	types_to_build = list("Artificer", "Wraith", "Juggernaut")

/datum/bloodcult_ritual/produce_constructs/key_found(extra)
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	for (var/datum/mind/mind in cult?.members)
		var/mob/M = mind.current
		if (istype(M, /mob/living/simple_animal/hostile/construct))
			var/mob/living/simple_animal/hostile/construct/C = M
			types_to_build -= C.construct_type
	if (types_to_build.len <= 0)
		return TRUE
	return FALSE
