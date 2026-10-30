/obj/effect/proc_holder/spell/targeted/emplosion
	name = "Emplozja"
	desc = "To zaklęcie wywołuje emplozję na obszarze."

	var/emp_heavy = 2
	var/emp_light = 3

	action_icon_state = "emp"
	sound = 'sound/weapons/zapbang.ogg'

/obj/effect/proc_holder/spell/targeted/emplosion/cast(list/targets,mob/user = usr)
	playsound(get_turf(user), sound, 50,1)
	for(var/mob/living/target in targets)
		if(target.anti_magic_check() && target != user)
			continue
		empulse(target.loc, emp_heavy, emp_light, magic=TRUE)
	return
