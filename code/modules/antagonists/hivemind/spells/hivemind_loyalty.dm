/obj/effect/proc_holder/spell/self/hive_loyal
	name = "Skupiona infiltracja"
	desc = "Przygotowujemy się do skupionego ataku na umysł, który przebija technologię osłony umysłu. Osłona umysłu pozostaje po ataku (przełącznik)."
	panel = "Hivemind Abilities"
	charge_max = 1
	invocation_type = "none"
	clothes_req = 0
	human_req = 1
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "loyal"
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/self/hive_loyal/cast(mob/living/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>To błąd. Kod: HIVE1</span>")
		return
	var/obj/effect/proc_holder/spell/targeted/hive_add/the_spell = locate(/obj/effect/proc_holder/spell/targeted/hive_add) in user.mind.spell_list
	if(!the_spell)
		to_chat(user, "<span class='notice'>To błąd. Kod: HIVE5</span>")
		return
	the_spell.ignore_mindshield = !active
	to_chat(user, "<span class='notice'>[active?"Pozwalamy umysłom odpocząć i rozluźniamy koncentrację.":"Przygotowujemy się, by przebić technologię osłony umysłu!"]</span>")
	active = !active
	if(active)
		revert_cast()
