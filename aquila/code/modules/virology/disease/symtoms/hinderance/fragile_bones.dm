/datum/symptom/acute/bones
	name = "Fragile Person Syndrome"
	desc = "Attacks the infected's body structure, making it more fragile."
	stage = 4
	badness = EFFECT_DANGER_HINDRANCE
	severity = 3

/datum/symptom/acute/bones/activate(mob/living/carbon/human/victim)
	if(!ishuman(victim))
		return
	// AQ: nasze konczyny nie maja wound_resistance, wiec objaw tylko zwieksza szanse na rany przez max_damage
	for(var/obj/item/bodypart/part in victim.bodyparts)
		part.max_damage = max(1, part.max_damage - 10)

/datum/symptom/acute/bones/deactivate(mob/living/carbon/human/victim, safe = FALSE)
	if(!ishuman(victim))
		return
	for(var/obj/item/bodypart/part in victim.bodyparts)
		part.max_damage = part.max_damage + 10
