/obj/item/projectile/beam/mindflayer
	name = "promień Mind Flayera"

/obj/item/projectile/beam/mindflayer/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20)
		M.adjust_hallucinations(60 SECONDS) // AQ EDIT - halucynacje jako efekt statusu (Bee#13095)
