// AQUILA - port z Yogstation (code/datums/mutations/touchfar.dm, /shock/far)
// Nasz Shock Touch jest na starym /obj/effect/proc_holder/spell, więc wersja z zasięgiem też.

/datum/mutation/shock/far
	name = "Porażający dotyk z dystansu"
	desc = "Pacjent przepuszcza nadmiar prądu przez dłonie bez porażania siebie i może razić innych z odległości."
	instability = 40
	text_gain_indication = "<span class='notice'>Czujesz, jak przez twoje dłonie przepływa nieograniczona moc.</span>"
	power = /obj/effect/proc_holder/spell/targeted/touch/shock/far
	conflicts = list(/datum/mutation/shock, /datum/mutation/insulated)

/obj/effect/proc_holder/spell/targeted/touch/shock/far
	name = "Porażający dotyk z dystansu"
	desc = "Skup prąd w dłoni, żeby razić ludzi, nawet z odległości."
	hand_path = /obj/item/melee/touch_attack/shock/far

/obj/item/melee/touch_attack/shock/far
	name = "\improper porażający dotyk z dystansu"
	/// Najdalej tyle pól
	var/shock_range = 5

/obj/item/melee/touch_attack/shock/far/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity && (get_dist(target, user) > shock_range || !(target in view(shock_range, user))))
		user.visible_message("<span class='notice'>[user] wyciąga rękę, ale nic się nie dzieje.</span>")
		return
	user.Beam(target, icon_state = "red_lightning", time = 15)
	return ..(target, user, TRUE)

/datum/generecipe/shockfar
	required = "/datum/mutation/shock; /datum/mutation/telekinesis"
	result = /datum/mutation/shock/far
