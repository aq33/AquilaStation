//Penguins

/mob/living/simple_animal/pet/penguin
	response_help  = "głaszcze"
	response_disarm = "pstryka"
	response_harm   = "kopie"
	speak = list("Gah Gah!", "NOOT NOOT!", "NOOT!", "Noot", "noot", "Prah!", "Grah!")
	speak_emote = list("skrzeczy", "gęga")
	emote_hear = list("skrzeczy!", "gęga!", "nootuje.","NOOTUJE!")
	emote_see = list("potrząsa dziobem.", "trzepocze skrzydłami.","czyści pióra.")
	faction = list("penguin")
	minbodytemp = 0
	see_in_dark = 5
	speak_chance = 1
	turns_per_move = 10
	icon = 'icons/mob/penguins.dmi'
	butcher_results = list(/obj/item/organ/ears/penguin = 1, /obj/item/food/meat/slab/penguin = 3)
	chat_color = "#81D9FF"

	do_footstep = TRUE

/mob/living/simple_animal/pet/penguin/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/waddling)

/mob/living/simple_animal/pet/penguin/emperor
	name = "pingwin cesarski"
	real_name = "pingwin"
	desc = "Cesarz wszystkiego, na co spojrzy."
	icon_state = "penguin"
	icon_living = "penguin"
	icon_dead = "penguin_dead"
	butcher_results = list()
	gold_core_spawnable = FRIENDLY_SPAWN
	butcher_results = list(/obj/item/organ/ears/penguin = 1, /obj/item/food/meat/slab/penguin = 3)

/mob/living/simple_animal/pet/penguin/emperor/shamebrero
	name = "pingwin w hańbrero"
	desc = "Hańba wszystkiego, na co spojrzy."
	icon_state = "penguin_shamebrero"
	icon_living = "penguin_shamebrero"
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/simple_animal/pet/penguin/baby
	speak = list("gah", "noot noot", "noot!", "noot", "squeee!", "noo!")
	name = "pisklę pingwina"
	real_name = "pingwin"
	desc = "Nie lata i ledwo się kołysze, a jednak jest księciem wszystkich piskląt."
	icon_state = "penguin_baby"
	icon_living = "penguin_baby"
	icon_dead = "penguin_baby_dead"
	density = FALSE
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL
	butcher_results = list(/obj/item/organ/ears/penguin = 1, /obj/item/food/meat/slab/penguin = 1)
