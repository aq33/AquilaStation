// AQUILA - nerki (AquilaMed 5, etap 6). Sprite'y z Goonstation (icons/obj/items/organs/kidney.dmi, CC BY-NC-SA 3.0).
// U nas wątroba metabolizuje toksyny (liver_toxins.dm), więc nerki robią co innego:
// - powoli oczyszczają krew z gotowych obrażeń toksycznych (naturalnej regeneracji tox wcześniej nie było),
// - wydalają nadmiar leków (to, co powyżej progu przedawkowania, schodzi szybciej),
// - uszkodzone dają krew w moczu (bladder/urination.dm).
// Bez nerek albo z niewydolnymi obrażenia toksyczne rosną; ratuje dializa (leżenie w działającym sleeperze) albo przeszczep.

/obj/item/organ/kidneys
	name = "nerki"
	desc = "Para nerek. Filtrują krew z toksyn i nadmiaru leków."
	icon = 'aquila/icons/obj/medical/organs_med5.dmi'
	icon_state = "kidneys"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_KIDNEYS
	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY
	low_threshold_passed = "<span class='info'>Coś ćmi cię w krzyżu, po obu stronach kręgosłupa.</span>"
	high_threshold_passed = "<span class='warning'>Ból w krzyżu nie ustępuje, a w ustach czujesz metaliczny posmak.</span>"
	now_failing = "<span class='danger'>Nerki przestają pracować. Czujesz, jak organizm się zatruwa.</span>"
	now_fixed = "<span class='info'>Ból w krzyżu mija.</span>"
	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/ammonia/urine = 2)

/obj/item/organ/kidneys/cybernetic
	name = "nerki cybernetyczne"
	desc = "Mechaniczne filtry krwi. Działają jak zdrowe nerki, ale impuls EMP potrafi je uszkodzić."
	icon_state = "kidneys-cyber"
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC
	maxHealth = STANDARD_ORGAN_THRESHOLD * 1.5

/obj/item/organ/kidneys/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	applyOrganDamage(25 / severity)

/// How well the kidneys work, 0-1
/obj/item/organ/kidneys/proc/aq_efficiency()
	if(organ_flags & ORGAN_FAILING)
		return 0
	return 1 - damage / maxHealth

/obj/item/organ/kidneys/on_life()
	. = ..()
	if(!owner || owner.stat == DEAD)
		return
	var/efficiency = owner.aq_on_dialysis() ? 1 : aq_efficiency()
	owner.aq_filter_blood(efficiency)
	// Dużo toksyn we krwi niszczy nerki
	if(owner.getToxLoss() > 50 && !(organ_flags & ORGAN_SYNTHETIC))
		applyOrganDamage(0.2)

/// Kidney work: clears toxin damage and the excess of drugs, or lets toxins build up when they fail
/mob/living/carbon/proc/aq_filter_blood(efficiency)
	if(efficiency < 0.5)
		if(getToxLoss() < 80)
			adjustToxLoss(0.3 * (1 - efficiency), forced = TRUE)
		return
	if(getToxLoss() > 0)
		adjustToxLoss(-0.2 * efficiency, forced = TRUE)
	for(var/datum/reagent/reagent as anything in reagents?.reagent_list)
		if(reagent.overdose_threshold && reagent.volume > reagent.overdose_threshold)
			reagents.remove_reagent(reagent.type, 0.3 * efficiency)

/// Lying in a working sleeper filters the blood like dialysis
/mob/living/carbon/proc/aq_on_dialysis()
	var/obj/machinery/sleeper/sleeper = loc
	return istype(sleeper) && !(sleeper.machine_stat & (NOPOWER|BROKEN))

/// No kidneys at all
/mob/living/carbon/human/Life()
	. = ..()
	if(QDELETED(src) || notransform || stat == DEAD || IsInStasis())
		return
	if(dna?.species?.mutantkidneys && dna.species.aq_has_med5_organs() && !getorganslot(ORGAN_SLOT_KIDNEYS))
		aq_filter_blood(aq_on_dialysis() ? 1 : 0)

/// Damaged kidneys put blood into the urine (bladder/urination.dm)
/mob/living/proc/aq_urine_extras(datum/reagents/urine, units)
	var/obj/item/organ/kidneys/kidneys = getorganslot(ORGAN_SLOT_KIDNEYS)
	if(!kidneys || kidneys.damage < kidneys.low_threshold || !iscarbon(src))
		return
	var/mob/living/carbon/C = src
	urine.add_reagent(/datum/reagent/blood, max(1, units * 0.2), C.get_blood_data(C.get_blood_id()))
	to_chat(src, "<span class='warning'>W moczu widać krew.</span>")

/datum/design/cybernetic_kidneys
	name = "Nerki cybernetyczne"
	desc = "Mechaniczne filtry krwi zamiast nerek."
	id = "aq_cybernetic_kidneys"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/organ/kidneys/cybernetic
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
