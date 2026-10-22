// AQUILA - port z tgstation (code/game/machinery/dna_infuser/organ_sets/carp_organs.dm)

/// bonus karpia: pływanie w kosmosie
/datum/status_effect/organ_set_bonus/carp
	id = "organ_set_bonus_carp"
	organs_needed = 5
	bonus_activate_text = "<span class='notice'>Karpie DNA przeniknęło cię do głębi! Nauczyłeś się napędzać w próżni!</span>"
	bonus_deactivate_text = "<span class='notice'>Twoje DNA znów jest w większości twoje, a wraz z tym znika umiejętność pływania w kosmosie...</span>"
	bonus_traits = list(TRAIT_SPACEWALK)

/// Płuca karpia: oddychasz w próżni, ale tlen cię dusi (potrzebujesz atmosfery ubogiej w tlen)
/obj/item/organ/lungs/carp
	name = "zmutowane karpie płuca"
	desc = "Karpie DNA wszczepione w coś, co kiedyś było parą zwykłych płuc."
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "carp_lungs"
	/// maksymalne ciśnienie parcjalne tlenu, powyżej którego zaczynasz się dusić
	var/safe_oxygen_max = 15

/obj/item/organ/lungs/carp/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "Ma na szyi dziwne skrzela.", BODY_ZONE_HEAD)
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/carp)

/obj/item/organ/lungs/carp/populate_gas_info()
	..()
	gas_min -= breathing_class
	gas_max[breathing_class] = safe_oxygen_max

/obj/item/organ/lungs/carp/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/H)
	if(!breath || breath.total_moles() == 0)
		// próżnia nie szkodzi karpiowi
		H.failed_last_breath = FALSE
		var/datum/breathing_class/oxy_class = GLOB.gas_data.breathing_classes[breathing_class]
		if(oxy_class?.low_alert_category)
			H.clear_alert(oxy_class.low_alert_category)
		return TRUE
	return ..()

/// zęby karpia: mocniejsze ciosy, czasem wypada ząb, ale nie założysz maski
/obj/item/organ/fangs
	name = "kły"
	desc = "Zestaw ostrych zębów."
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "fangs_lizard"
	zone = BODY_ZONE_PRECISE_MOUTH
	slot = "fangs"
	gender = PLURAL
	infuser_external = TRUE

/obj/item/organ/fangs/carp
	name = "zmutowane karpie szczęki"
	desc = "Karpie DNA wszczepione w coś, co kiedyś było zwykłymi zębami."
	/// o ile rośnie siła ciosu wręcz
	var/bite_bonus = 5
	/// czy to my zablokowaliśmy slot maski
	var/blocked_mask = FALSE

/obj/item/organ/fangs/carp/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "Ma wielkie i ostre zęby.", BODY_ZONE_PRECISE_MOUTH)
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/carp)

/obj/item/organ/fangs/carp/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(owner != M || !ishuman(M))
		return
	var/mob/living/carbon/human/human_owner = M
	if(!human_owner.can_mutate())
		return
	var/datum/species/owner_species = human_owner.dna.species
	owner_species.punchdamage += bite_bonus
	if(!(ITEM_SLOT_MASK in owner_species.no_equip))
		owner_species.no_equip += ITEM_SLOT_MASK
		blocked_mask = TRUE
		if(human_owner.wear_mask)
			human_owner.dropItemToGround(human_owner.wear_mask)

/obj/item/organ/fangs/carp/Remove(mob/living/carbon/M, special = 0)
	if(ishuman(M) && owner == M)
		var/mob/living/carbon/human/human_owner = M
		if(human_owner.dna?.species)
			var/datum/species/owner_species = human_owner.dna.species
			owner_species.punchdamage = max(owner_species.punchdamage - bite_bonus, initial(owner_species.punchdamage))
			if(blocked_mask)
				owner_species.no_equip -= ITEM_SLOT_MASK
	blocked_mask = FALSE
	return ..()

/obj/item/organ/fangs/carp/on_life()
	. = ..()
	if(!owner || owner.stat != CONSCIOUS || !prob(0.1))
		return
	owner.emote("cough")
	var/turf/tooth_fairy = get_turf(owner)
	if(tooth_fairy)
		new /obj/item/kitchen/knife/carp_tooth(tooth_fairy)

/obj/item/kitchen/knife/carp_tooth
	name = "ząb karpia"
	desc = "Wygląda na ostry. Wystarczająco ostry, żeby komuś wydłubać oko. O kurde, jaki wielki."
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "carptooth"
	materials = list()
	custom_price = 0

/obj/item/organ/tongue/carp
	name = "zmutowany karpi język"
	desc = "Karpie DNA wszczepione w coś, co kiedyś było zwykłym językiem."
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "carp_tongue"
	say_mod = "kłapie"

/obj/item/organ/tongue/carp/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/carp)

/// mózg karpia: co jakiś czas musisz zmienić poziom (z-level) - jak spacer z psem!
/obj/item/organ/brain/carp
	name = "zmutowany karpi mózg"
	desc = "Karpie DNA wszczepione w coś, co kiedyś było zwykłym mózgiem."
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "carp_brain"
	/// timer do złego nastroju
	var/cooldown_timer
	/// czas do złego nastroju
	var/cooldown_time = 10 MINUTES

/obj/item/organ/brain/carp/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/carp)
	AddElement(/datum/element/noticable_organ, "Chyba nie potrafi usiedzieć w miejscu.")

/obj/item/organ/brain/carp/Insert(mob/living/carbon/C, special = 0, no_id_transfer = FALSE)
	. = ..()
	name = initial(name)
	if(owner != C)
		return
	cooldown_timer = addtimer(CALLBACK(src, PROC_REF(unsatisfied_nomad)), cooldown_time, TIMER_STOPPABLE|TIMER_OVERRIDE|TIMER_UNIQUE)
	RegisterSignal(C, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(satisfied_nomad))

/obj/item/organ/brain/carp/Remove(mob/living/carbon/C, special = 0, no_id_transfer = FALSE)
	if(C)
		UnregisterSignal(C, COMSIG_MOVABLE_Z_CHANGED)
		C.clear_mood_event("nomad")
	deltimer(cooldown_timer)
	return ..()

/obj/item/organ/brain/carp/proc/unsatisfied_nomad()
	owner?.add_mood_event("nomad", /datum/mood_event/infuser_unsatisfied_nomad)

/obj/item/organ/brain/carp/proc/satisfied_nomad()
	SIGNAL_HANDLER
	owner?.clear_mood_event("nomad")
	cooldown_timer = addtimer(CALLBACK(src, PROC_REF(unsatisfied_nomad)), cooldown_time, TIMER_STOPPABLE|TIMER_OVERRIDE|TIMER_UNIQUE)

/// serce karpia: odporność na zimno i niskie ciśnienie
/obj/item/organ/heart/carp
	name = "zmutowane karpie serce"
	desc = "Karpie DNA wszczepione w coś, co kiedyś było zwykłym sercem."
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "carp_heart"
	organ_traits = list(TRAIT_RESISTCOLD, TRAIT_RESISTLOWPRESSURE)

/obj/item/organ/heart/carp/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "Na skórze wyrastają mu małe płaty łusek.", BODY_ZONE_CHEST)
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/carp)

/obj/item/organ/heart/carp/update_icon()
	icon_state = "carp_heart"
