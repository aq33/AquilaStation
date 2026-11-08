/datum/hallucination/death
	random_hallucination_weight = 1

	hallucination_tier = HALLUCINATION_TIER_UNCOMMON
/datum/hallucination/death/Destroy()
	if(!QDELETED(hallucinator))
		// Really make sure these go away, would be bad if they stuck around
		if(iscarbon(hallucinator))
			var/mob/living/carbon/carbon_hallucinator = hallucinator
			carbon_hallucinator.set_screwyhud(SCREWYHUD_NONE)
		REMOVE_TRAIT(hallucinator, TRAIT_MUTE, REF(src))
		REMOVE_TRAIT(hallucinator, TRAIT_EMOTEMUTE, REF(src))

	return ..()

/datum/hallucination/death/start()
	hallucinator.Paralyze(30 SECONDS)
	if(iscarbon(hallucinator))
		var/mob/living/carbon/carbon_hallucinator = hallucinator
		carbon_hallucinator.set_screwyhud(SCREWYHUD_DEAD)
	ADD_TRAIT(hallucinator, TRAIT_MUTE, REF(src))
	ADD_TRAIT(hallucinator, TRAIT_EMOTEMUTE, REF(src))

	to_chat(hallucinator, span_deadsay("<b>[hallucinator.real_name]</b> umiera w <b>[get_area_name(hallucinator)]</b>."))

	var/delay = 0

	if(prob(50))
		var/mob/who_is_salting
		if(length(GLOB.dead_mob_list))
			who_is_salting = pick(GLOB.dead_mob_list)

		if(who_is_salting)
			delay = rand(2 SECONDS, 5 SECONDS)

			var/static/list/things_to_hate = list(
				"adminów",
				"pałek",
				"kultu krwi",
				"koderów",
				"heretyków",
				"siebie",
				"revenantów",
				"rewolucjonistów",
				"ochrony",
				"ss13",
				"tej gry",
				"tej rundy",
				"tej zmiany",
				"tego gówna",
				"tego",
				"czarodziejów",
				"ciebie",
			)

			var/list/dead_chat_salt = list(
				"...",
				"KURWA",
				"git gud",
				"no do cholery",
				"hej [hallucinator.first_name()]",
				"[prob(50) ? "kurwa, " : ""]nienawidzę [pick(things_to_hate)]",
				"czy SI jest zbuntowana?",
				"rip",
				"shitsec",
				"czemu właśnie padłem martwy?",
				"czemu mnie zgibowało",
				"czarodziej?",
				"ty też?",
			)

			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), hallucinator, span_deadsay("<b>MARTWI: [who_is_salting.name]</b> mówi: \"[pick(dead_chat_salt)]\"")), delay)

	addtimer(CALLBACK(src, PROC_REF(wake_up)), delay + rand(7 SECONDS, 9 SECONDS))
	return TRUE

/datum/hallucination/death/proc/wake_up()
	if(!QDELETED(hallucinator))
		if(iscarbon(hallucinator))
			var/mob/living/carbon/carbon_hallucinator = hallucinator
			carbon_hallucinator.set_screwyhud(SCREWYHUD_NONE)
		hallucinator.SetParalyzed(0 SECONDS)
		REMOVE_TRAIT(hallucinator, TRAIT_MUTE, REF(src))
		REMOVE_TRAIT(hallucinator, TRAIT_EMOTEMUTE, REF(src))

	if(!QDELETED(src))
		qdel(src)
