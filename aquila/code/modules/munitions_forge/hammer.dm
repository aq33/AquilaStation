// AQUILA - kuźnia amunicji: młot kowalski, bez którego nie da się kuć na kowadle (sprite z Monkestation, CC BY-SA 3.0).

/obj/item/forging_hammer
	name = "młot kowalski"
	desc = "Ciężki młot do kucia odlewów amunicji na kowadle. Trzymaj go w ręce, kiedy kujesz."
	icon = 'aquila/icons/obj/munitions_forge/forge_structures.dmi'
	icon_state = "hammer"
	item_state = "hammer"
	lefthand_file = 'aquila/icons/mob/inhands/munitions_forge_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/munitions_forge_righthand.dmi'
	force = 12
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	materials = list(/datum/material/iron = 4000)
	attack_verb = list("uderza", "wali", "grzmoci")
	hitsound = 'sound/effects/clang.ogg'
