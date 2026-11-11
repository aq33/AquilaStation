// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/pets/dog/dog_subtypes.dm (bee/master 0adf0fe9ae)
// Polish lines from our simple animal dogs; Walter is ours. McGriff and the capybara are not ported.

//Less exciting dog breeds

/mob/living/basic/pet/dog/pug
	name = "\improper mops"
	real_name = "mops"
	desc = "To mops."
	icon = 'icons/mob/pets.dmi'
	icon_state = "pug"
	icon_living = "pug"
	icon_dead = "pug_dead"
	butcher_results = list(/obj/item/food/meat/slab/pug = 3)
	gold_core_spawnable = FRIENDLY_SPAWN
	worn_slot_flags = ITEM_SLOT_HEAD
	collar_icon_state = "pug"
	held_state = "pug"

/mob/living/basic/pet/dog/bullterrier
	name = "\improper bulterier"
	real_name = "bulterier"
	desc = "To bulterier."
	icon = 'icons/mob/pets.dmi'
	icon_state = "bullterrier"
	icon_living = "bullterrier"
	icon_dead = "bullterrier_dead"
	butcher_results = list(/obj/item/food/meat/slab/corgi = 3) // Would feel redundant to add more new dog meats.
	gold_core_spawnable = FRIENDLY_SPAWN
	worn_slot_flags = ITEM_SLOT_HEAD //by popular demand
	collar_icon_state = "bullterrier"
	held_state = "bullterrier"
	head_icon = 'icons/mob/pets_held_large.dmi'

/mob/living/basic/pet/dog/bullterrier/walter
	name = "Walter"
	real_name = "Walter"
	gender = MALE
	desc = "Nar'Sie i Ratvar to nic w porównaniu z potęgą tego psa, który kocha monster trucki."
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/basic/pet/dog/bullterrier/walter/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	. = ..()
	speech.speak = string_list(list("szczeka!", "hauka!", "Walter", "firetrucks", "monstertrucks"))
