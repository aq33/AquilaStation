/datum/symptom/acute/horsethroat
	name = "Horse Throat"
	desc = "Inhibits communication from the infected through spontaneous generation of a horse mask."
	stage = 3
	badness = EFFECT_DANGER_HINDRANCE
	severity = 2

/datum/symptom/acute/horsethroat/activate(mob/living/carbon/mob)
	if(ismouse(mob))
		var/mob/living/simple_animal/mouse/mouse = mob
		mouse.icon_state = "mouse_horse"
		mouse.icon_living = "mouse_horse"
		mouse.icon_dead = "mouse_horse_dead"
		mouse.held_state = "mouse_horse"

	mob.say(pick("NEIGH!", "Neigh!", "Neigh.", "Neigh?", "Neigh!!", "Neigh?!", "Neigh..."))
	if(!ishuman(mob))
		return

	var/mob/living/carbon/human/human = mob
	var/obj/item/clothing/mask/horsehead/magichead = new /obj/item/clothing/mask/horsehead
	if(human.wear_mask && !istype(human.wear_mask,/obj/item/clothing/mask/horsehead))
		human.dropItemToGround(human.wear_mask, TRUE)
		human.equip_to_slot(magichead, ITEM_SLOT_MASK)
	if(!human.wear_mask)
		human.equip_to_slot(magichead, ITEM_SLOT_MASK)
	to_chat(human, span_warning("You feel a little horse!"))
