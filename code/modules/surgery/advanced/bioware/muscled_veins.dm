/datum/surgery/advanced/bioware/muscled_veins
	name = "Mięśniowa błona żył"
	desc = "Zabieg chirurgiczny, który dodaje do naczyń krwionośnych umięśnioną błonę, dzięki czemu mogą pompować krew bez serca."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/incise,
				/datum/surgery_step/muscled_veins,
				/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_CHEST)
	bioware_target = BIOWARE_CIRCULATION

/datum/surgery_step/muscled_veins
	name = "uformuj mięśnie żył"
	accept_hand = TRUE
	time = 125

/datum/surgery_step/muscled_veins/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Zaczynasz owijać mięśnie wokół układu krwionośnego [target].</span>",
		"[user] zaczyna owijać mięśnie wokół układu krwionośnego [target].",
		"[user] zaczyna manipulować układem krwionośnym [target].")

/datum/surgery_step/muscled_veins/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Przekształcasz układ krwionośny [target], dodając umięśnioną błonę!</span>",
		"[user] przekształca układ krwionośny [target], dodając umięśnioną błonę!",
		"[user] kończy manipulować układem krwionośnym [target].")
	new /datum/bioware/muscled_veins(target)
	return TRUE

/datum/bioware/muscled_veins
	name = "Umięśnione żyły"
	desc = "Naczynia krwionośne mają umięśnioną błonę, dzięki której pompują krew bez serca."
	mod_type = BIOWARE_CIRCULATION

/datum/bioware/muscled_veins/on_gain()
	..()
	ADD_TRAIT(owner, TRAIT_STABLEHEART, "muscled_veins")

/datum/bioware/muscled_veins/on_lose()
	..()
	REMOVE_TRAIT(owner, TRAIT_STABLEHEART, "muscled_veins")
