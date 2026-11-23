// AQUILA - granat zniszczony wybuchem wybucha sam (deconstruct() -> prime()), a granat dymny usypia wtedy w prime() na kilka
// sekund przed usunięciem. Przez ten czas ma 0 wytrzymałości, a kolejna fala tego samego wybuchu trafiała go jeszcze raz:
// /obj/ex_act zadaje obrażenia przed strażnikiem zerowej wytrzymałości w /obj/item/ex_act, więc take_damage() zgłaszał
// „taking damage while having <= 0 integrity” (losowo padał test derelict_ruin_mission).

/obj/item/grenade/ex_act(severity, target)
	// Już się rozpada i wybucha: wybuch dalej dociera do zawartości i odbiorców sygnału (jak w /atom/proc/ex_act), ale
	// obrażeń już nie dostaje
	if(obj_integrity <= 0)
		contents_explosion(severity, target)
		SEND_SIGNAL(src, COMSIG_ATOM_EX_ACT, severity, target)
		return
	return ..()
