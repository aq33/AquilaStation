// AQUILA - granat zniszczony wybuchem wybucha sam (deconstruct() -> prime()), a granat dymny usypia wtedy w prime() na kilka
// sekund przed usunięciem. Przez ten czas ma 0 wytrzymałości, a kolejna fala tego samego wybuchu trafiała go jeszcze raz:
// take_damage() zgłaszał „taking damage while having <= 0 integrity” (losowo padał test derelict_ruin_mission).

/obj/item/grenade/ex_act(severity, target)
	// Już się rozpada i wybucha: następne trafienia nic nie zmienią
	if(obj_integrity <= 0)
		return
	return ..()
