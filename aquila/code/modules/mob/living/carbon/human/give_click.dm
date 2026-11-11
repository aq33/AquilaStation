// AQUILA - Ctrl+Shift+klik oferuje trzymany przedmiot tylko osobie, którą klikasz, i tylko gdy stoi obok.
// W core (give.dm) każdy Ctrl+Shift+klik woła Give(): bez nikogo obok oferta od razu znika, a w czacie zostaje
// „Oferujesz ...”, więc klikanie po podłodze z bronią w ręku spamowało ofertami karabinu. Give() oferuje też
// każdemu w zasięgu ręki, więc po ofercie zostawiamy tylko klikniętą osobę.
// Na wszystkim innym zostaje zwykła akcja Ctrl+Shift+kliku obiektu (CtrlShiftClick, np. przewracanie stołu).

/mob/living/carbon/human/CtrlShiftClickOn(atom/A)
	var/mob/living/carbon/receiver = A
	if(receiver == src || !istype(receiver) || !Adjacent(receiver) || IS_DEAD_OR_INCAP(receiver))
		A.CtrlShiftClick(src)
		return
	. = ..()
	var/datum/status_effect/offering/offer = has_status_effect(STATUS_EFFECT_OFFERING)
	if(!offer || !(receiver in offer.possible_takers))
		return
	for(var/mob/living/carbon/other_taker as anything in offer.possible_takers.Copy())
		if(other_taker != receiver)
			offer.remove_candidate(other_taker)
