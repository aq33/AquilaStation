// AQUILA - port z tgstation (code/datums/mutations/aoe_moodlet.dm)

/datum/mutation/aoe_moodlet
	name = "Extremely Unsightly"
	desc = "The subject's body - and especially their face - is unnaturally unsightly, causing a negative reaction from those around them. \
		Wearing a mask will dampen the effect."
	quality = NEGATIVE
	text_gain_indication = "<span class='warning'>Czujesz się piękny na swój własny sposób.</span>"
	text_lose_indication = "<span class='notice'>Czujesz się mniej skrępowany swoim wyglądem.</span>"
	difficulty = 12
	/// Nastrój u patrzących
	var/datum/mood_event/seen_moodlet = /datum/mood_event/seen_ugly_mutation
	/// Nastrój u patrzących, gdy twarz zasłonięta
	var/datum/mood_event/seen_weak_moodlet = /datum/mood_event/seen_ugly_mutation/weak
	/// Nastrój właściciela przy lustrze
	var/datum/mood_event/self_moodlet = /datum/mood_event/seen_ugly_mutation/self

/datum/mutation/aoe_moodlet/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	RegisterSignal(owner, COMSIG_PARENT_EXAMINE, PROC_REF(on_examined))

/datum/mutation/aoe_moodlet/on_losing(mob/living/carbon/owner)
	if(..())
		return TRUE
	UnregisterSignal(owner, COMSIG_PARENT_EXAMINE)

/datum/mutation/aoe_moodlet/proc/on_examined(datum/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER
	if(examiner == owner || !isliving(examiner))
		return
	apply_other_moodlet(examiner)

/// Przy lustrze właściciel widzi siebie
/datum/mutation/aoe_moodlet/on_move(new_loc)
	if(!owner || !isturf(owner.loc))
		return
	if(!(locate(/obj/structure/mirror) in range(1, owner)))
		return
	owner.add_mood_event("[type]_self", self_moodlet, owner)

/datum/mutation/aoe_moodlet/on_life()
	for(var/mob/living/nearby in viewers(3, owner))
		if(nearby == owner || nearby.stat != CONSCIOUS || nearby.is_blind())
			continue
		apply_other_moodlet(nearby)

/datum/mutation/aoe_moodlet/proc/apply_other_moodlet(mob/living/other)
	other.add_mood_event("[type]", face_hidden() ? seen_weak_moodlet : seen_moodlet, owner)

/// Czy maska albo hełm zasłania twarz
/datum/mutation/aoe_moodlet/proc/face_hidden()
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/human_owner = owner
	if(human_owner.wear_mask && (human_owner.wear_mask.flags_inv & HIDEFACE))
		return TRUE
	if(human_owner.head && (human_owner.head.flags_inv & HIDEFACE))
		return TRUE
	return FALSE

/datum/mutation/aoe_moodlet/positive
	name = "Extremely Comely"
	desc = "The subject's body - and especially their face - is unnaturally comely, causing a positive reaction from those around them. \
		Wearing a mask will dampen the effect."
	quality = POSITIVE
	instability = 10
	text_gain_indication = "<span class='notice'>Czujesz się piękny na swój własny sposób.</span>"
	seen_moodlet = /datum/mood_event/seen_pretty_mutation
	seen_weak_moodlet = /datum/mood_event/seen_pretty_mutation/weak
	self_moodlet = /datum/mood_event/seen_pretty_mutation/self

// Wersja negatywna
/datum/mood_event/seen_ugly_mutation
	description = "<span class='warning'>Z tym gościem jest coś mocno nie tak!</span>\n"
	mood_change = -3
	timeout = 2 MINUTES

/datum/mood_event/seen_ugly_mutation/add_effects(mob/mutant)
	description = "<span class='warning'>Z [mutant || "tym gościem"] jest coś mocno nie tak!</span>\n"

/datum/mood_event/seen_ugly_mutation/weak
	description = "<span class='warning'>Coś jest nie tak z wyglądem tego gościa.</span>\n"
	mood_change = -1

/datum/mood_event/seen_ugly_mutation/weak/add_effects(mob/mutant)
	description = "<span class='warning'>Coś jest nie tak z wyglądem [mutant || "tego gościa"].</span>\n"

/datum/mood_event/seen_ugly_mutation/self
	description = "<span class='boldwarning'>...Ja TAK wyglądam?!</span>\n"
	mood_change = -2
	timeout = 5 MINUTES

/datum/mood_event/seen_ugly_mutation/self/add_effects(mob/mutant)
	return

// Wersja pozytywna
/datum/mood_event/seen_pretty_mutation
	description = "<span class='nicegreen'>Ta osoba świetnie wygląda - pewnie nowa fryzura czy coś.</span>\n"
	mood_change = 3
	timeout = 2 MINUTES

/datum/mood_event/seen_pretty_mutation/add_effects(mob/mutant)
	description = "<span class='nicegreen'>[mutant || "Ta osoba"] świetnie wygląda - pewnie nowa fryzura czy coś.</span>\n"

/datum/mood_event/seen_pretty_mutation/weak
	description = "<span class='nicegreen'>Ta osoba wygląda całkiem nieźle - to pewnie przez oświetlenie.</span>\n"
	mood_change = 1

/datum/mood_event/seen_pretty_mutation/weak/add_effects(mob/mutant)
	description = "<span class='nicegreen'>[mutant || "Ta osoba"] wygląda całkiem nieźle - to pewnie przez oświetlenie.</span>\n"

/datum/mood_event/seen_pretty_mutation/self
	description = "<span class='nicegreen'>Świetnie wyglądam!</span>\n"
	mood_change = 2
	timeout = 5 MINUTES

/datum/mood_event/seen_pretty_mutation/self/add_effects(mob/mutant)
	return
