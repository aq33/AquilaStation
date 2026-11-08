/datum/hallucination/message
	random_hallucination_weight = 60
	hallucination_tier = HALLUCINATION_TIER_COMMON

/datum/hallucination/message/start()
	var/list/nearby_humans = list()
	var/adjacent_to_us = FALSE
	var/mob/living/carbon/human/suspicious_personnel
	for(var/mob/living/carbon/human/nearby_human in oview(hallucinator, 7))
		if(get_dist(nearby_human, hallucinator) <= 1)
			suspicious_personnel = nearby_human
			adjacent_to_us = TRUE
			break
		nearby_humans += nearby_human

	if(!suspicious_personnel && length(nearby_humans))
		suspicious_personnel = pick(nearby_humans)

	var/list/message_pool = list()
	if(suspicious_personnel)
		if(adjacent_to_us)
			message_pool[span_warning("Czujesz małe ukłucie!")] = 5

		var/obj/item/storage/equipped_backpack = suspicious_personnel.get_item_by_slot(ITEM_SLOT_BACK)
		if(istype(equipped_backpack))
			// in the future, this could / should be de-harcoded and
			// just draw from a pool uplink, theft, and antag item typepaths
			var/static/list/stash_items = list(
				"rewolwer .357",
				"miecz energetyczny",
				"sekwencer kryptograficzny",
				"pochłaniacz energii",
				"ładunek C-4",
				"łuk energetyczny",
				"pałka ogłuszająca",
				"flash",
				"pistolet na strzałki",
				"piła tarczowa",
				"rytualny sztylet",
				"księga zaklęć",
				"Codex Cicatrix",
				"zapasowy identyfikator kapitana",
				"ręczny teleporter",
				"hypospray",
				"antyczny pistolet laserowy",
				"wielofazowa broń energetyczna X-01",
				"plany stacji",
			)
			message_pool[span_notice("[suspicious_personnel] wkłada do [equipped_backpack]: [pick(stash_items)].")] = 5

		message_pool["[span_bold("[suspicious_personnel]")] [pick("kicha", "kaszle")]."] = 1

	message_pool[span_notice("Słyszysz, jak coś przeciska się przez kanały...")] = 1

	message_pool[span_warning("Swędzi cię [pick("ręka", "noga", "plecy", "głowa")].")] = 1
	message_pool[span_warning("Czujesz się [pick("rozpalony", "zmarznięty", "wysuszony", "przemoczony", "oszołomiony", "słabo")].")] = 1
	message_pool[span_warning("Burczy ci w brzuchu.")] = 1
	message_pool[span_warning("Boli cię głowa.")] = 1
	message_pool[span_warning("Słyszysz w głowie ciche brzęczenie.")] = 1

	if(prob(10))
		message_pool[span_warning("Za tobą.")] = 1
		message_pool[span_warning("Słyszysz cichy śmiech.")] = 1
		message_pool[span_warning("Słyszysz drapanie na suficie.")] = 1
		message_pool[span_warning("Widzisz w oddali nieludzko wysoką sylwetkę.")] = 2

	if(prob(30))
		var/some_help = pick_list_replacements(HALLUCINATION_FILE, "advice")
		message_pool[some_help] = 4

	var/chosen = pick_weight(message_pool)
	feedback_details += "Message: [chosen]"
	to_chat(hallucinator, chosen)
	qdel(src)
	return TRUE
