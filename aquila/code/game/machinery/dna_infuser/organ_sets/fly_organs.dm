// AQUILA - port z tgstation (code/game/machinery/dna_infuser/organ_sets/fly_organs.dm)
// Rasa /datum/species/fly i organy tongue/liver/stomach muchy już u nas są - dopinamy im element zestawu.

#define FLY_INFUSED_ORGAN_DESC "Nie masz pojęcia, co to do diabła jest ani jak to w ogóle utrzymuje cokolwiek przy życiu."
#define FLY_INFUSED_ORGAN_ICON pick("brain-x-d", "liver-x", "kidneys-x", "spinner-x", "lungs-x", "random_fly_1", "random_fly_2", "random_fly_3", "random_fly_4", "random_fly_5")

/// bonus muchy: jesteś teraz muchoczłowiekiem. Przykro nam.
/datum/status_effect/organ_set_bonus/fly
	id = "organ_set_bonus_fly"
	organs_needed = 4 // organów muchy jest więcej, ale wystarczą 4, żeby zostać muchą. Uważaj!
	bonus_activate_text = null
	bonus_deactivate_text = null

/datum/status_effect/organ_set_bonus/fly/enable_bonus(obj/item/organ/inserted_organ)
	. = ..()
	if(!. || !ishuman(owner) || isflyperson(owner))
		return
	// zmiana gatunku podmienia organy, więc czekamy, aż wstawianie organu się skończy
	addtimer(CALLBACK(src, PROC_REF(flyify)), 1)

/datum/status_effect/organ_set_bonus/fly/proc/flyify()
	var/mob/living/carbon/human/new_fly = owner
	if(QDELETED(new_fly) || !bonus_active || isflyperson(new_fly))
		return
	to_chat(new_fly, "<span class='danger'>Za dużo muszego DNA! Twoja skóra zaczyna czernieć, gdy stajesz się bardziej muchą niż człowiekiem!</span>")
	new_fly.set_species(/datum/species/fly)

/obj/item/organ/tongue/fly/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fly)

/obj/item/organ/liver/fly/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fly)

/obj/item/organ/stomach/fly/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fly)

/obj/item/organ/eyes/fly
	name = "musze oczy"
	desc = "Te oczy zdają się patrzeć na ciebie, niezależnie od kierunku, z którego na nie spojrzysz."
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "eyes_fly"
	flash_protect = -1

/obj/item/organ/eyes/fly/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fly)

/obj/item/organ/heart/fly
	desc = FLY_INFUSED_ORGAN_DESC
	icon = 'aquila/icons/dna_infuser/organs.dmi'

/obj/item/organ/heart/fly/Initialize(mapload)
	. = ..()
	name = odd_organ_name()
	icon_state = FLY_INFUSED_ORGAN_ICON
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fly)

/obj/item/organ/heart/fly/update_icon()
	return

/obj/item/organ/lungs/fly
	desc = FLY_INFUSED_ORGAN_DESC
	icon = 'aquila/icons/dna_infuser/organs.dmi'

/obj/item/organ/lungs/fly/Initialize(mapload)
	. = ..()
	name = odd_organ_name()
	icon_state = FLY_INFUSED_ORGAN_ICON
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fly)

/obj/item/organ/appendix/fly
	desc = FLY_INFUSED_ORGAN_DESC
	icon = 'aquila/icons/dna_infuser/organs.dmi'

/obj/item/organ/appendix/fly/Initialize(mapload)
	. = ..()
	name = odd_organ_name()
	icon_state = FLY_INFUSED_ORGAN_ICON
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fly)

/obj/item/organ/appendix/fly/update_icon()
	return // nie zmieniamy nazwy ani ikony

#undef FLY_INFUSED_ORGAN_DESC
#undef FLY_INFUSED_ORGAN_ICON
