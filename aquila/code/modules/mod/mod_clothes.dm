/// Bazowe rękawice z Bee mają worn_icon_state = "wgloves", a takiego stanu nie ma w mod_clothing.dmi.
/// Rękawice MODa nie rysowały się wtedy wcale i spod kombinezonu było widać gołe dłonie.
/obj/item/clothing/gloves/mod
	worn_icon_state = null

/// Zamknięty hełm MODa chowa też czułki ćm (inaczej sterczą przez hełm). Dotyczy każdej skórki i motywu.
/datum/mod_theme/set_skin(obj/item/mod/control/mod, skin)
	. = ..()
	var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	if(!istype(helmet))
		return
	helmet.visor_flags_inv |= HIDEANTENNAE
	if(!mod.get_part_datum(helmet).sealed || (helmet.flags_inv & HIDEANTENNAE))
		return
	helmet.flags_inv |= HIDEANTENNAE
	if(mod.wearer && helmet.loc == mod.wearer)
		mod.wearer.update_obscured_slots(HIDEANTENNAE)

/// Zamknięcie i otwarcie napierśnika albo butów zmienia nogi digitigrade na zwykłe i z powrotem
/// (aquila_mod_forces_plantigrade() w species.dm). Same buty nie odświeżają nóg, więc robimy to tutaj.
/obj/item/mod/control/seal_part(obj/item/clothing/part, is_sealed)
	. = ..()
	if(wearer && (part.slot_flags & (ITEM_SLOT_OCLOTHING|ITEM_SLOT_FEET)))
		wearer.update_mutant_bodyparts()

/// TRUE, gdy noszący ma na sobie zamknięty napierśnik albo buty MODa. Te części nie mają sprite'ów digitigrade.
/mob/living/carbon/human/proc/aquila_mod_forces_plantigrade()
	for(var/obj/item/mod/control/mod in list(back, belt))
		if(mod.wearer != src)
			continue
		for(var/slot in list(ITEM_SLOT_OCLOTHING, ITEM_SLOT_FEET))
			var/datum/mod_part/part = mod.get_part_datum_from_slot(slot)
			if(part?.sealed && part.part_item?.loc == src)
				return TRUE
	return FALSE
