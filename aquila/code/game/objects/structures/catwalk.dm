/// Katwalk zasłania kafel przed kliknięciem (PREVENT_CLICK_UNDER_1), więc kliknięcie w niego przesuwa ciągnięty obiekt jak kliknięcie w podłogę
/obj/structure/lattice/catwalk/attack_hand(mob/user)
	. = ..()
	if(. || !user.pulling || !isturf(loc))
		return
	user.Move_Pulled(loc)
	return TRUE
