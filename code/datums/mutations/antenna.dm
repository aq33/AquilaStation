/datum/mutation/antenna
	name = "Antena"
	desc = "Osobie wyrasta antena. Wiadomo, że pozwala ona biernie odbierać ogólne kanały radiowe."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Czujesz, jak z twojego czoła wyrasta antena.</span>"
	text_lose_indication = "<span class='notice'>Twoja antena kurczy się z powrotem.</span>"
	instability = 5
	difficulty = 8
	var/datum/weakref/radio_weakref

/obj/item/implant/radio/antenna
	name = "wewnętrzny organ anteny"
	desc = "Wewnętrzna, organiczna część anteny. Nauka nie wymyśliła jeszcze dla niej dobrej nazwy."
	icon = 'icons/obj/radio.dmi'//maybe make a unique sprite later. not important
	icon_state = "walkietalkie"

/obj/item/implant/radio/antenna/Initialize(mapload)
	. = ..()
	radio.name = "wewnętrzna antena"

/datum/mutation/antenna/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	var/obj/item/implant/radio/antenna/linked_radio = new(owner)
	linked_radio.implant(owner, null, TRUE, TRUE)
	radio_weakref = WEAKREF(linked_radio)

/datum/mutation/antenna/on_losing(mob/living/carbon/owner)
	if(..())
		return
	var/obj/item/implant/radio/antenna/linked_radio = radio_weakref.resolve()
	if(linked_radio)
		QDEL_NULL(linked_radio)

/datum/mutation/antenna/New(class_ = MUT_OTHER, timer, datum/mutation/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "antenna", -FRONT_MUTATIONS_LAYER+1))//-MUTATIONS_LAYER+1

/datum/mutation/antenna/get_visual_indicator()
	return visual_indicators[type][1]
