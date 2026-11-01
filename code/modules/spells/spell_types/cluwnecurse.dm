/obj/effect/proc_holder/spell/targeted/cluwnecurse
	name = "Klątwa cluwne'a"
	desc = "To zaklęcie skazuje każdą nieszczęsną duszę na życie żałosnego cluwne'a, straszliwej istoty, na którą poluje się dla zabawy."
	school = "transmutation"
	charge_type = "recharge"
	charge_max	= 600
	clothes_req = 1
	stat_allowed = 0
	invocation = "CLU WO'NIS CA'TE'BEST'IS MAXIMUS!"
	invocation_type = "shout"
	range = 3
	cooldown_min = 75
	selection_type = "range"
	var/list/compatible_mobs = list(/mob/living/carbon/human)
	action_icon = 'icons/mob/actions.dmi'
	action_icon_state = "cluwne"

/obj/effect/proc_holder/spell/targeted/cluwnecurse/cast(list/targets, mob/user = usr)
	if(!targets.len)
		to_chat(user, "<span class='notice'>W zasięgu nie znaleziono celu.</span>")
		return
	var/mob/living/carbon/target = targets[1]
	if(!(target.type in compatible_mobs))
		to_chat(user, "<span class='notice'>Nie możesz przekląć [target]!</span>")
		return
	if(!(target in oview(range)))
		to_chat(user, "<span class='notice'>Cel jest za daleko!</span>")
		return
	var/mob/living/carbon/human/H = target
	H.cluwneify()

/datum/spellbook_entry/cluwnecurse
	name = "Klątwa cluwne'a"
	spell_type = /obj/effect/proc_holder/spell/targeted/cluwnecurse

/datum/action/spell_action/New(Target)
	..()
	var/obj/effect/proc_holder/spell/S = Target
	icon_icon = S.action_icon
