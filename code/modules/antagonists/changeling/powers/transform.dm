/datum/action/changeling/transform
	name = "Przemiana"
	desc = "Przybieramy wygląd i głos kogoś, kogo wchłonęliśmy. Kosztuje 5 chemikaliów."
	button_icon_state = "transform"
	chemical_cost = 5
	dna_cost = 0
	req_dna = 1
	req_human = 1

/obj/item/clothing/glasses/changeling
	name = "tkanka"

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/glasses/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, "<span class='notice'>Wchłaniasz [src] z powrotem do ciała.</span>")
		qdel(src)
		return
	. = ..()

/obj/item/clothing/under/changeling
	name = "tkanka"

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/under/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, "<span class='notice'>Wchłaniasz [src] z powrotem do ciała.</span>")
		qdel(src)
		return
	. = ..()

/obj/item/clothing/suit/changeling
	name = "tkanka"
	allowed = list(/obj/item/changeling)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/suit/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, "<span class='notice'>Wchłaniasz [src] z powrotem do ciała.</span>")
		qdel(src)
		return
	. = ..()

/obj/item/clothing/head/changeling
	name = "tkanka"

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/head/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, "<span class='notice'>Wchłaniasz [src] z powrotem do ciała.</span>")
		qdel(src)
		return
	. = ..()

/obj/item/clothing/shoes/changeling
	name = "tkanka"

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/shoes/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, "<span class='notice'>Wchłaniasz [src] z powrotem do ciała.</span>")
		qdel(src)
		return
	. = ..()

/obj/item/clothing/gloves/changeling
	name = "tkanka"

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/gloves/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, "<span class='notice'>Wchłaniasz [src] z powrotem do ciała.</span>")
		qdel(src)
		return
	. = ..()

/obj/item/clothing/mask/changeling
	name = "tkanka"

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/mask/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, "<span class='notice'>Wchłaniasz [src] z powrotem do ciała.</span>")
		qdel(src)
		return
	. = ..()

/obj/item/changeling
	name = "tkanka"
	slot_flags = ALL
	allowed = list(/obj/item/changeling)
	item_flags = DROPDEL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user)
		if(user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
			to_chat(user, "<span class='notice'>Wchłaniasz [src] z powrotem do ciała.</span>")
		else
			to_chat(user, "<span class='notice'>[src] znika, to była tylko iluzja!</span>")
		qdel(src)
		return
	. = ..()

//=============
// ID CARD
// Copy pasted due to requiring inherited behaviour
//=============

/obj/item/card/id/changeling
	name = "tkanka"
	item_flags = DROPDEL

/obj/item/card/id/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user)
		if(user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
			to_chat(user, "<span class='notice'>Wchłaniasz [src] z powrotem do ciała.</span>")
		else
			to_chat(user, "<span class='notice'>[src] znika, to była tylko iluzja!</span>")
		qdel(src)
		return
	. = ..()

//Change our DNA to that of somebody we've absorbed.
/datum/action/changeling/transform/sting_action(mob/living/carbon/human/user)
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	var/datum/changelingprofile/chosen_prof = changeling.select_dna("Wybierz docelowe DNA: ", "Docelowe DNA")

	if(!chosen_prof)
		return
	..()
	changeling_transform(user, chosen_prof)
	return TRUE

/datum/antagonist/changeling/proc/select_dna(var/prompt, var/title)
	var/mob/living/carbon/user = owner.current
	if(!istype(user))
		return
	var/list/names = list("Porzuć cielesne przebranie")
	for(var/datum/changelingprofile/prof in stored_profiles)
		names += "[prof.name]"

	var/chosen_name = input(prompt, title, null) as null|anything in sortList(names)
	if(!chosen_name)
		return

	if(chosen_name == "Porzuć cielesne przebranie")
		for(var/slot in GLOB.slots)
			if(istype(user.vars[slot], GLOB.slot2type[slot]))
				qdel(user.vars[slot])

	var/datum/changelingprofile/prof = get_dna(chosen_name)
	return prof
