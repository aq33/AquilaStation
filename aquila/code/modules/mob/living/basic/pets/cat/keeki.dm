// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/pets/cat/keeki.dm (bee/master 0adf0fe9ae)
// We have no regenerator component or consumable_mob element: the regeneration and the bite stay as in our simple animal cak.
/mob/living/basic/pet/cat/cak //I told you I'd do it, Remie
	name = "Keeki"
	desc = "To kot zrobiony z ciasta."
	icon_state = "cak"
	icon_living = "cak"
	icon_dead = "cak_dead"
	health = 50
	maxHealth = 50
	gender = FEMALE
	butcher_results = list(/obj/item/organ/brain = 1, /obj/item/organ/heart = 1, /obj/item/food/cakeslice/birthday = 3, /obj/item/food/meat/slab = 2)
	response_harm_continuous = "odgryza kawałek"
	ai_controller = /datum/ai_controller/basic_controller/cat/cake
	attacked_sound = 'sound/items/eatfood.ogg'
	death_message = "traci swoje fałszywe życie i pada!"
	death_sound = "bodyfall"
	held_state = "cak"

/mob/living/basic/pet/cat/cak/CheckParts(list/parts)
	. = ..()
	var/obj/item/organ/brain/candidate = locate(/obj/item/organ/brain) in contents
	if(isnull(candidate?.brainmob?.mind))
		return
	candidate.brainmob.mind.transfer_to(src)
	to_chat(src, "<span class='big bold'>Jesteś kakiem!</span><b> Jesteś nieszkodliwą hybrydą kota i ciasta, którą wszyscy kochają. Głodni mogą odgryzać z ciebie kawałki, ale regenerujesz zdrowie tak szybko, że zwykle nie ma to znaczenia. Jesteś niezwykle odporny na wszelkie inne obrażenia i naprawdę trudno cię zabić. Chodź po stacji i rozdawaj szczęście oraz darmowe ciasto!</b>")
	var/new_name = stripped_input(src, "Podaj swoje imię lub naciśnij \"Cancel\", by zostać przy imieniu Keeki.", "Zmiana imienia")
	if(new_name)
		to_chat(src, "<span class='notice'>Twoje imię to teraz <b>\"new_name\"</b>!</span>")
		name = new_name

/mob/living/basic/pet/cat/cak/Life(seconds, times_fired)
	. = ..()
	if(stat)
		return
	if(health < maxHealth)
		adjustBruteLoss(-8) //Fast life regen

/mob/living/basic/pet/cat/cak/Move()
	. = ..()
	if(. && !stat)
		for(var/obj/item/food/donut/D in get_turf(src)) //Frosts nearby donuts!
			if(!D.is_decorated)
				D.decorate_donut()

/// Bee: the cake cat AI spins next to donuts to frost them
/mob/living/basic/pet/cat/cak/spin(spintime, speed)
	. = ..()
	for(var/obj/item/food/donut/target in oview(1, src))
		if(!target.is_decorated)
			target.decorate_donut()

/mob/living/basic/pet/cat/cak/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(user.combat_mode && user.reagents && !stat)
		user.reagents.add_reagent(/datum/reagent/consumable/nutriment, 0.4)
		user.reagents.add_reagent(/datum/reagent/consumable/nutriment/vitamin, 0.4)
