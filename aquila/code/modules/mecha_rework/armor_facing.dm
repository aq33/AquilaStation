// AQUILA - kierunkowy pancerz per podwozie. Rdzeń ma facing_modifiers (przód/bok/tył) i get_armour_facing(),
// ale wszystkie mechy miały te same 1,5/1/0,5. Tu każde podwozie dostaje własne mnożniki (wzór: Yogstation),
// a tarcza balistyczna i broń wręcz z bonusem do parowania dokładają ochronę od przodu.

/obj/mecha/working/ripley
	facing_modifiers = list(1.2, 1, 0.8)

/obj/mecha/working/lockermech
	facing_modifiers = list(1, 1, 0.8)

/obj/mecha/medical/odysseus
	facing_modifiers = list(1.1, 1, 0.8)

/obj/mecha/combat/gygax
	facing_modifiers = list(1.4, 1, 0.6)

/obj/mecha/combat/durand
	facing_modifiers = list(1.8, 1.1, 0.5)

/obj/mecha/combat/honker
	facing_modifiers = list(1, 1, 1)

/obj/mecha/combat/marauder
	facing_modifiers = list(1.6, 1.2, 0.7)

/obj/mecha/combat/phazon
	facing_modifiers = list(1.3, 1.3, 1) // fazowy pancerz: mała różnica między stronami

/obj/mecha/combat/reticence
	facing_modifiers = list(1.2, 1, 0.6)

/// Mnożnik pancerza od strony ataku (z tarczą i bronią do parowania)
/obj/mecha/proc/aq_facing_multiplier(attack_dir)
	if(!attack_dir)
		return 1
	var/relative = dir2angle(attack_dir) - dir2angle(dir)
	. = get_armour_facing(relative)
	if(abs(relative) in list(0, 45, 315))
		for(var/obj/item/mecha_parts/mecha_equipment/aq_ballistic_shield/shield in equipment)
			. *= shield.front_bonus

/obj/mecha/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	var/old_deflect = deflect_chance
	var/obj/item/mecha_parts/mecha_equipment/aq_melee/blade = selected
	if(istype(blade) && blade.deflect_bonus)
		deflect_chance += blade.deflect_bonus
	if(attack_dir && (abs(dir2angle(attack_dir) - dir2angle(dir)) in list(0, 45, 315)))
		for(var/obj/item/mecha_parts/mecha_equipment/aq_ballistic_shield/shield in equipment)
			deflect_chance += shield.deflect_bonus
	. = ..()
	deflect_chance = old_deflect
	if(. && attack_dir)
		// rdzeń dzieli obrażenia przez mnożnik strony, tarcza dokłada swój
		for(var/obj/item/mecha_parts/mecha_equipment/aq_ballistic_shield/shield in equipment)
			if(abs(dir2angle(attack_dir) - dir2angle(dir)) in list(0, 45, 315))
				. /= shield.front_bonus
				break
	if(.)
		for(var/obj/item/mecha_parts/mecha_equipment/aq_shield_droid/droid in equipment)
			. = droid.absorb(.)

/obj/mecha/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Pancerz kierunkowy: przód ×[facing_modifiers[MECHA_FRONT_ARMOUR]], boki ×[facing_modifiers[MECHA_SIDE_ARMOUR]], tył ×[facing_modifiers[MECHA_BACK_ARMOUR]].</span>"
