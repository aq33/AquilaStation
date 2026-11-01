/datum/mutation/shock
	name = "Porażający dotyk"
	desc = "Nosiciel potrafi przepuszczać nadmiar elektryczności przez dłonie, nie rażąc samego siebie, więc może razić innych."
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	text_gain_indication = "<span class='notice'>Czujesz, jak przez twoje dłonie przepływa moc.</span>"
	text_lose_indication = "<span class='notice'>Energia w twoich dłoniach słabnie.</span>"
	power = /obj/effect/proc_holder/spell/targeted/touch/shock
	instability = 30
	locked = TRUE

/obj/effect/proc_holder/spell/targeted/touch/shock
	name = "Porażający dotyk"
	desc = "Skieruj elektryczność do dłoni, żeby razić nią ludzi."
	drawmessage = "Kierujesz elektryczność do dłoni."
	dropmessage = "Pozwalasz, by elektryczność z twojej dłoni się rozwiała."
	hand_path = /obj/item/melee/touch_attack/shock
	charge_max = 100
	clothes_req = FALSE
	action_icon_state = "zap"

/obj/item/melee/touch_attack/shock
	name = "\improper porażający dotyk"
	desc = "To trochę jak pocieranie stopami o dywan, żeby kopnąć prądem kumpli, tylko dużo mniej bezpieczne."
	catchphrase = null
	on_use_sound = 'sound/weapons/zapbang.ogg'
	icon_state = "zapper"
	item_state = "zapper"

/obj/item/melee/touch_attack/shock/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity) // AQUILA EDIT - tylko w zasięgu ręki; na odległość działa Extended Shock Touch
		return
	user.Beam(target, icon_state="lightning[rand(1,12)]", time=5, maxdistance = 32)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.electrocute_act(15, user, 1, FALSE, FALSE, FALSE, FALSE, FALSE))//doesnt stun. never let this stun
			C.dropItemToGround(C.get_active_held_item())
			C.dropItemToGround(C.get_inactive_held_item())
			C.confused += 15
			C.visible_message("<span class='danger'>[user] razi [target] prądem!</span>","<span class='userdanger'>[user] razi cię prądem!</span>")
			use_charge(user)
			return ..()
		else
			user.visible_message("<span class='warning'>[user] nie udaje się porazić [target]!</span>")
			use_charge(user)
			return ..()
	else if(isliving(target))
		var/mob/living/L = target
		L.electrocute_act(15, user, 1, FALSE, FALSE, FALSE, FALSE)
		L.visible_message("<span class='danger'>[user] razi [target] prądem!</span>","<span class='userdanger'>[user] razi cię prądem!</span>")
		use_charge(user)
		return ..()
	else
		to_chat(user,"<span class='warning'>Elektryczność chyba nie działa na [target]...</span>")
		use_charge(user)
		return ..()
