/obj/effect/proc_holder/spell/aoe_turf/conjure/summon_mirror
	name = "Przywołaj lustro"
	desc = "Przywołuje na chwilę lustro grzechu, przy którym ty i inni możecie zmienić w sobie, co tylko chcecie."
	invocation = "Czyż nie jestem wspaniały?"
	invocation_type = "whisper"
	clothes_req = FALSE
	charge_max = 600
	cooldown_min = 200
	summon_type = list(/obj/structure/mirror/magic/lesser)
	summon_lifespan = 60 SECONDS
	range = 1
	action_icon = 'aquila/icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "magic_mirror"
	action_background_icon_state = "bg_demon"

/obj/effect/proc_holder/spell/targeted/touch/mend
	name = "Uleczenie"
	desc = "Spowija twoją rękę leczniczą mocą. Uderzenie nią umiarkowanie leczy cel. Nie działa na ciebie."
	hand_path = /obj/item/melee/touch_attack/mend
	school = "evocation"
	charge_max = 12 SECONDS
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_changeling.dmi'
	action_icon_state = "fleshmend"
	action_background_icon_state = "bg_demon"

/obj/item/melee/touch_attack/mend
	name = "Lecząca dłoń"
	desc = "Pozornie przyjemna masa leczniczej energii, gotowa do uzdrawiania."
	icon_state = "disintegrate"
	item_state = "disintegrate"
	color = "#d4a017"
	catchphrase = "Smak Grzechu"

/obj/item/melee/touch_attack/mend/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || !isliving(target) || target == user)
		return
	var/mob/living/victim = target
	if(victim.anti_magic_check())
		to_chat(user, span_warning("[victim] opiera się twojej pysze!"))
		to_chat(victim, span_warning("Wokół twojego umysłu tańczy zwodnicze uczucie przyjemności, po czym nagle się rozwiewa."))
		return ..()
	playsound(user, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	victim.adjustBruteLoss(-20)
	victim.adjustFireLoss(-20)
	victim.visible_message(span_bold("[victim] błyska na czerwono, po czym wydaje się zdrowszy!"))
	to_chat(victim, span_warning("Czujesz złowrogie uczucie powrotu do zdrowia."))
	return ..()
