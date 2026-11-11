// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/vermin/butterfly.dm (BeeStation/BeeStation-Hornet#14771, tg port)
// Polish lines from our simple animal butterfly; the random colour also colours its chat name, as before.
/mob/living/basic/butterfly
	name = "motyl"
	desc = "Kolorowy motyl. Jak on się tu dostał?"
	icon_state = "butterfly"
	icon_living = "butterfly"
	icon_dead = "butterfly_dead"

	speak_emote = list("trzepocze")
	verb_say = "trzepocze"
	verb_ask = "trzepocze pytająco"
	verb_exclaim = "trzepocze zawzięcie"
	verb_yell = "trzepocze zawzięcie"

	response_help_continuous = "przegania"
	response_disarm_continuous = "odsuwa na bok"
	response_harm_continuous = "zgniata"
	friendly_verb_continuous = "trąca"

	maxHealth = 2
	health = 2

	density = FALSE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	ventcrawler = VENTCRAWLER_ALWAYS
	gold_core_spawnable = FRIENDLY_SPAWN

	ai_controller = /datum/ai_controller/basic_controller/butterfly

/mob/living/basic/butterfly/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	var/newcolor = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
	chat_color = newcolor
	add_atom_colour(newcolor, FIXED_COLOUR_PRIORITY)

/mob/living/basic/butterfly/bee_friendly()
	return TRUE //treaty signed at the Beeneeva convention

/datum/ai_controller/basic_controller/butterfly
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
