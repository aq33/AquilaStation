// Duma gangu jak w Goonstation: pełny mundur (kombinezon i nakrycie głowy gangu) na własnym lub spornym terenie
// daje +30 maks. zdrowia, większą pulę i regenerację staminy, powolne leczenie (szybsze przy szafce) i krótsze ogłuszenia.
// Gangster bez munduru na terenie wroga traci część staminy. Szef nigdy nie dostaje kary.

#define GANG_PRIDE_NONE 0
#define GANG_PRIDE_BUFF 1
#define GANG_PRIDE_DEBUFF 2

/datum/status_effect/gang_pride
	id = "gang_pride"
	duration = -1
	tick_interval = 2 SECONDS
	alert_type = null
	status_type = STATUS_EFFECT_UNIQUE
	/// Który stan działa teraz
	var/state = GANG_PRIDE_NONE

/datum/status_effect/gang_pride/on_remove()
	set_state(GANG_PRIDE_NONE)

/datum/status_effect/gang_pride/tick()
	var/datum/antagonist/gang/gangster = owner.mind?.has_antag_datum(/datum/antagonist/gang)
	var/datum/team/gang/G = gangster?.gang
	if(!G || owner.stat == DEAD || !ishuman(owner))
		set_state(GANG_PRIDE_NONE)
		return
	var/mob/living/carbon/human/H = owner
	var/uniformed = G.wears_full_uniform(H)
	var/list/turf_gangs = aq_gang_turf_gangs(get_turf(H))
	var/new_state = GANG_PRIDE_NONE
	if(uniformed && (G in turf_gangs))
		new_state = GANG_PRIDE_BUFF
	else if(!uniformed && length(turf_gangs) && !(G in turf_gangs) && !istype(gangster, /datum/antagonist/gang/boss))
		new_state = GANG_PRIDE_DEBUFF
	set_state(new_state)
	if(state != GANG_PRIDE_BUFF)
		return
	var/heal = 0.4
	if(G.locker && !G.locker.hidden && get_dist(H, G.locker) < GANG_LOCKER_RADIUS)
		heal = 1
	H.heal_overall_damage(heal, heal)
	H.AdjustStun(-2 SECONDS)
	H.AdjustKnockdown(-2 SECONDS)
	H.AdjustUnconscious(-2 SECONDS)

/datum/status_effect/gang_pride/proc/set_state(new_state)
	if(state == new_state)
		return
	switch(state)
		if(GANG_PRIDE_BUFF)
			owner.maxHealth -= 30
			owner.stamina?.remove_max_modifier("gang_pride")
			owner.stamina?.remove_regen_modifier("gang_pride")
			owner.clear_alert("gang_pride")
			owner.updatehealth()
		if(GANG_PRIDE_DEBUFF)
			owner.stamina?.remove_max_modifier("gang_pride")
			owner.stamina?.remove_regen_modifier("gang_pride")
			owner.clear_alert("gang_pride")
	state = new_state
	switch(state)
		if(GANG_PRIDE_BUFF)
			owner.maxHealth += 30
			owner.stamina?.add_max_modifier("gang_pride", 50)
			owner.stamina?.add_regen_modifier("gang_pride", 3)
			owner.throw_alert("gang_pride", /atom/movable/screen/alert/gang_pride)
			owner.updatehealth()
		if(GANG_PRIDE_DEBUFF)
			owner.stamina?.add_max_modifier("gang_pride", -25)
			owner.stamina?.add_regen_modifier("gang_pride", -2)
			owner.throw_alert("gang_pride", /atom/movable/screen/alert/gang_pride/shame)

/datum/team/gang/proc/wears_full_uniform(mob/living/carbon/human/H)
	return H.w_uniform?.type == outfit && H.head?.type == hat

/atom/movable/screen/alert/gang_pride
	name = "Duma gangu"
	desc = "Nosisz mundur gangu na swoim terenie: więcej zdrowia i staminy, szybciej dochodzisz do siebie. Przy szafce gangu leczysz się szybciej."
	icon = 'aquila/icons/hud/gang_button.dmi'
	icon_state = "gang"

/atom/movable/screen/alert/gang_pride/shame
	name = "Bez barw na obcym terenie"
	desc = "Chowasz barwy gangu na terenie wroga. Wstyd: masz mniej staminy, dopóki nie założysz munduru albo stąd nie wyjdziesz."
	color = "#888888"

/datum/antagonist/gang/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/M = mob_override || owner.current
	M?.apply_status_effect(/datum/status_effect/gang_pride)

/datum/antagonist/gang/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/M = mob_override || owner.current
	M?.remove_status_effect(/datum/status_effect/gang_pride)

#undef GANG_PRIDE_NONE
#undef GANG_PRIDE_BUFF
#undef GANG_PRIDE_DEBUFF
