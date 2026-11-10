// AQUILA - narzędzia chirurgiczne w rękach ze sprite'ami z tgstation (CC-BY-SA 3.0, icons/mob/inhands/equipment/medical_*hand.dmi).
// Rozwieracz i kleszczyki mają własne stany zamiast wspólnego "clamps", wiertło leży w pliku medycznym jak w tg
// (w narzędziowym "drill" to wiertarka inżynierów), a narzędzia zaawansowane zmieniają wygląd w rękach razem z trybem.

/obj/item/retractor
	item_state = "retractor"

/obj/item/hemostat
	item_state = "hemostat"

/obj/item/surgicaldrill
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	item_state = "drill"

/obj/item/scalpel/advanced
	item_state = "e_scalpel"

/obj/item/scalpel/advanced/attack_self(mob/user)
	. = ..()
	item_state = tool_behaviour == TOOL_SAW ? "e_scalpel_on" : "e_scalpel"
	user.update_inv_hands()

/obj/item/retractor/advanced
	item_state = "adv_retractor"

/obj/item/retractor/advanced/attack_self(mob/user)
	. = ..()
	item_state = tool_behaviour == TOOL_HEMOSTAT ? "adv_retractor_on" : "adv_retractor"
	user.update_inv_hands()

/obj/item/surgicaldrill/advanced
	item_state = "e_cautery_on"

/obj/item/surgicaldrill/advanced/attack_self(mob/user)
	. = ..()
	item_state = tool_behaviour == TOOL_CAUTERY ? "e_cautery" : "e_cautery_on"
	user.update_inv_hands()

/// Złożone łóżko na kółkach w rękach (tg emergency_bed)
/obj/item/roller
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	item_state = "emergencybed"
