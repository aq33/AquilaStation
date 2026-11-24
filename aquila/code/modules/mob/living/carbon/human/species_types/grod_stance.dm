// Postawy Groda (BeeStation/BeeStation-Hornet#5442) i rzeczy w czterech dłoniach rysowane osobno dla każdego kierunku
// (BeeStation/BeeStation-Hornet#7202). Postawa ruchu: dwie ręce, Grod jest szybszy od człowieka.
// Postawa pracy: cztery ręce, ale Grod jest wolniejszy, szybciej się męczy i nie blokuje ciosów.

/datum/action/innate/grod_stance
	name = "Zmień postawę"
	desc = "Przełącz między postawą ruchu (dwie ręce, szybki chód) a postawą pracy (cztery ręce, ale wolny chód, szybsze zmęczenie i brak blokowania)."
	icon_icon = GROD_ICON_ACTIONS
	button_icon_state = "stanceswap"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/grod_stance/Activate()
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || !isgrod(H))
		return
	if(H.handcuffed)
		to_chat(H, "<span class='warning'>Nie zmienisz postawy w kajdankach.</span>")
		return
	var/datum/species/grod/grod = H.dna.species
	grod.grod_set_stance(H, grod.stance == GROD_STANCE_MOBILE ? GROD_STANCE_INTERACT : GROD_STANCE_MOBILE)

/// Zmienia postawę Groda. silent: bez komunikatów i bez kosztu w głodzie (zmiana rasy).
/datum/species/grod/proc/grod_set_stance(mob/living/carbon/human/H, new_stance, silent = FALSE)
	if(stance == new_stance)
		return
	stance = new_stance
	if(stance == GROD_STANCE_INTERACT)
		grod_set_hands(H, GROD_HANDS)
		ADD_TRAIT(H, TRAIT_NOBLOCK, TRAIT_SOURCE_GROD_STANCE)
		staminamod = GROD_STAMINAMOD + GROD_INTERACT_STAMINAMOD
		H.add_movespeed_modifier(MOVESPEED_ID_GROD_INTERACT, TRUE, 100, override = TRUE, multiplicative_slowdown = GROD_INTERACT_SLOWDOWN)
		if(!silent)
			H.adjust_nutrition(-GROD_STANCE_NUTRITION)
			to_chat(H, "<span class='warning'>Kierujesz siły w dodatkową parę rąk. Czujesz się słaby i powolny.</span>")
	else
		grod_set_hands(H, 2)
		REMOVE_TRAIT(H, TRAIT_NOBLOCK, TRAIT_SOURCE_GROD_STANCE)
		staminamod = GROD_STAMINAMOD
		H.remove_movespeed_modifier(MOVESPEED_ID_GROD_INTERACT)
		if(!silent)
			to_chat(H, "<span class='warning'>Kierujesz siły z powrotem w odnóża. Słabość mija.</span>")
	H.update_inv_hands()

/// Obrót: rzeczy w dłoniach rysujemy od nowa dla nowego kierunku (sygnał przychodzi przed zmianą dir)
/datum/species/grod/proc/grod_dir_changed(mob/living/carbon/human/source, olddir, newdir)
	SIGNAL_HANDLER
	if(olddir == newdir || !(locate(/obj/item) in source.held_items))
		return
	hands_render_dir = newdir
	source.update_inv_hands()
	hands_render_dir = null

/// Przesunięcia rzeczy w dłoniach jak w oryginale: dłonie 1 i 2 to zwykłe ręce nisko na tułowiu, 3 i 4 to górna para
/datum/species/grod/get_item_offsets_for_index(obj/item/I)
	var/mob/living/carbon/holder = I.loc
	if(!istype(holder))
		return null
	var/index = holder.get_held_index_of_item(I)
	if(!index)
		return null
	switch(hands_render_dir || holder.dir)
		if(NORTH)
			switch(index)
				if(1)
					return list("x" = 3, "y" = 0)
				if(2)
					return list("x" = -2, "y" = 0)
				if(3)
					return list("x" = 3, "y" = 5)
				if(4)
					return list("x" = -2, "y" = 5)
		if(EAST)
			switch(index)
				if(1)
					return list("x" = 4, "y" = -4)
				if(2)
					return list("x" = 10, "y" = -3)
				if(3)
					return list("x" = 6, "y" = 2)
				if(4)
					return list("x" = 10, "y" = 1)
		if(WEST)
			switch(index)
				if(1)
					return list("x" = -10, "y" = -3)
				if(2)
					return list("x" = -4, "y" = -4)
				if(3)
					return list("x" = -10, "y" = 1)
				if(4)
					return list("x" = -6, "y" = 2)
		else
			switch(index)
				if(1)
					return list("x" = -1, "y" = -4)
				if(2)
					return list("x" = 2, "y" = -4)
				if(3)
					return list("x" = -2, "y" = 1)
				if(4)
					return list("x" = 3, "y" = 1)
	return null

/// Czy rzecz w tej dłoni jest za ciałem: prawe dłonie przy patrzeniu w lewo i w górę, lewe przy patrzeniu w prawo i w górę
/datum/species/grod/proc/grod_hand_behind(index, facing)
	if(facing == NORTH)
		return TRUE
	if(index % 2 == 0)
		return facing == WEST
	return facing == EAST

/// Przenosi rzeczy z dłoni schowanych za ciałem pod sprite Groda. Wołane z update_inv_hands() przed animacją chodu.
/mob/living/carbon/human/proc/grod_layer_held_items()
	var/datum/species/grod/grod = dna?.species
	if(!istype(grod))
		return
	var/list/hand_overlays = overlays_standing[HANDS_LAYER]
	if(!length(hand_overlays))
		return
	var/facing = grod.hands_render_dir || dir
	remove_overlay(HANDS_LAYER)
	var/overlay_index = 0
	for(var/obj/item/I in held_items)
		overlay_index++
		if(overlay_index > length(hand_overlays))
			break
		var/mutable_appearance/hand_overlay = hand_overlays[overlay_index]
		if(istype(hand_overlay) && grod.grod_hand_behind(get_held_index_of_item(I), facing))
			hand_overlay.layer = -BODY_BEHIND_LAYER
	overlays_standing[HANDS_LAYER] = hand_overlays
	apply_overlay(HANDS_LAYER)
