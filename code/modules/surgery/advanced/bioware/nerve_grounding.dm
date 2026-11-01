/datum/surgery/advanced/bioware/nerve_grounding
	name = "Uziemienie nerwów"
	desc = "Zabieg chirurgiczny, po którym nerwy pacjenta działają jak uziemienie, chroniąc go przed porażeniem prądem."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/incise,
				/datum/surgery_step/ground_nerves,
				/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_CHEST)
	bioware_target = BIOWARE_NERVES

/datum/surgery_step/ground_nerves
	name = "uziem nerwy"
	accept_hand = TRUE
	time = 155

/datum/surgery_step/ground_nerves/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Zaczynasz przekierowywać nerwy [target].</span>",
		"[user] zaczyna przekierowywać nerwy [target].",
		"[user] zaczyna manipulować układem nerwowym [target].")

/datum/surgery_step/ground_nerves/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Pomyślnie przekierowujesz układ nerwowy [target]!</span>",
		"[user] pomyślnie przekierowuje układ nerwowy [target]!",
		"[user] kończy manipulować układem nerwowym [target].")
	new /datum/bioware/grounded_nerves(target)
	return TRUE

/datum/bioware/grounded_nerves
	name = "Uziemione nerwy"
	desc = "Nerwy tworzą bezpieczną ścieżkę dla prądu, chroniąc ciało przed porażeniem."
	mod_type = BIOWARE_NERVES

/datum/bioware/grounded_nerves/on_gain()
	..()
	ADD_TRAIT(owner, TRAIT_SHOCKIMMUNE, "grounded_nerves")

/datum/bioware/grounded_nerves/on_lose()
	..()
	REMOVE_TRAIT(owner, TRAIT_SHOCKIMMUNE, "grounded_nerves")
