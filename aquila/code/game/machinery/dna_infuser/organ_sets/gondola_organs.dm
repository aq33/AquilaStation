// AQUILA - port z tgstation (code/game/machinery/dna_infuser/organ_sets/gondola_organs.dm)

/// bonus obserwującej gondoli: obojętność na warunki otoczenia
/datum/status_effect/organ_set_bonus/gondola
	id = "organ_set_bonus_gondola"
	organs_needed = 3
	bonus_activate_text = "<span class='notice'>DNA gondoli przeniknęło cię do głębi! Jesteś ostatecznym obserwatorem, obojętnym na otoczenie...</span>"
	bonus_deactivate_text = "<span class='notice'>Twoje DNA nie jest już spokojne i gondolowate, więc zaczynasz sobie przypominać, że oddychanie jest, no, ważne...</span>"
	bonus_traits = list(TRAIT_RESISTHEAT, TRAIT_RESISTCOLD, TRAIT_NOBREATH, TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHIGHPRESSURE)

/// pacyfizm i większość wrogich mobów uznaje cię za swojego
/obj/item/organ/heart/gondola
	name = "zmutowane gondolowe serce"
	desc = "DNA gondoli wszczepione w coś, co kiedyś było zwykłym sercem."
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "gondola_heart"
	organ_traits = list(TRAIT_PACIFISM)
	/// frakcje, które faktycznie dodaliśmy (do zdjęcia przy usunięciu)
	var/list/factions_to_remove

/obj/item/organ/heart/gondola/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/gondola)
	AddElement(/datum/element/noticable_organ, "Promieniuje aurą spokoju.")

/obj/item/organ/heart/gondola/update_icon()
	icon_state = "gondola_heart"

/obj/item/organ/heart/gondola/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(owner != M)
		return
	factions_to_remove = list()
	for(var/new_faction in list("hostile", "mining"))
		if(!(new_faction in M.faction))
			M.faction += new_faction
			factions_to_remove += new_faction

/obj/item/organ/heart/gondola/Remove(mob/living/carbon/M, special = 0)
	if(M && owner == M && length(factions_to_remove))
		M.faction -= factions_to_remove
	factions_to_remove = null
	return ..()

/// Zen (język): nie możesz mówić, ale masz potężny dobry nastrój
/obj/item/organ/tongue/gondola
	name = "zmutowany gondolowy język"
	desc = "DNA gondoli wszczepione w coś, co kiedyś było zwykłym językiem."
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "gondola_tongue"
	organ_traits = list(TRAIT_MUTE)

/obj/item/organ/tongue/gondola/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "Usta ma na stałe wygięte w rozluźnionym uśmiechu.", BODY_ZONE_PRECISE_MOUTH)
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/gondola)

/obj/item/organ/tongue/gondola/Insert(mob/living/carbon/M, special = 0)
	. = ..()
	if(owner == M)
		M.add_mood_event("gondola_zen", /datum/mood_event/infuser_gondola_serenity)

/obj/item/organ/tongue/gondola/Remove(mob/living/carbon/M, special = 0)
	M?.clear_mood_event("gondola_zen")
	return ..()

/// Kochające ramiona: ręce za słabe, by coś unieść, ale przytulas wstrzykuje pax
/obj/item/organ/liver/gondola
	name = "zmutowana gondolowa wątroba"
	desc = "DNA gondoli wszczepione w coś, co kiedyś było zwykłą wątrobą."
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "gondola_liver"

/obj/item/organ/liver/gondola/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/gondola)
	AddElement(/datum/element/noticable_organ, "Z całej lewej ręki wystają mu drobne igiełki.", BODY_ZONE_L_ARM)
	AddElement(/datum/element/noticable_organ, "Z całej prawej ręki wystają mu drobne igiełki.", BODY_ZONE_R_ARM)

/obj/item/organ/liver/gondola/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(owner != M)
		return
	var/has_left = M.has_left_hand(FALSE)
	var/has_right = M.has_right_hand(FALSE)
	if(has_left && has_right)
		to_chat(M, "<span class='warning'>Twoje ręce strasznie słabną, gdy wyrastają na nich drobne, igiełkowate kolce!</span>")
	else if(has_left || has_right)
		to_chat(M, "<span class='warning'>Twoja ręka strasznie słabnie, gdy wyrastają na niej drobne, igiełkowate kolce!</span>")
	else
		to_chat(M, "<span class='warning'>Masz wrażenie, że coś działoby się teraz z twoimi rękami... gdybyś je jeszcze miał.</span>")
	to_chat(M, "<span class='notice'>Przytulenie kogoś go uspokoi, ale nie uniesiesz już prawie niczego.</span>")
	RegisterSignal(M, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_owner_equipped_item))
	RegisterSignal(M, COMSIG_LIVING_START_PULL, PROC_REF(on_owner_start_pull))
	RegisterSignal(M, COMSIG_LIVING_HUG_CARBON, PROC_REF(on_hug))
	for(var/obj/item/held in M.held_items)
		if(held.w_class > WEIGHT_CLASS_TINY)
			M.dropItemToGround(held)

/obj/item/organ/liver/gondola/Remove(mob/living/carbon/M, special = 0)
	if(M)
		UnregisterSignal(M, list(COMSIG_MOB_EQUIPPED_ITEM, COMSIG_LIVING_START_PULL, COMSIG_LIVING_HUG_CARBON))
	return ..()

/// po założeniu/podniesieniu czegoś większego od długopisu - wypuszczamy to
/obj/item/organ/liver/gondola/proc/on_owner_equipped_item(mob/living/carbon/source, obj/item/equipped, slot)
	SIGNAL_HANDLER
	if(equipped.w_class <= WEIGHT_CLASS_TINY || (equipped.item_flags & ABSTRACT))
		return
	if(!(equipped in source.held_items))
		return
	equipped.balloon_alert(source, "za słaby, żeby to trzymać!")
	addtimer(CALLBACK(source, TYPE_PROC_REF(/mob, dropItemToGround), equipped), 1)

/obj/item/organ/liver/gondola/proc/on_owner_start_pull(mob/living/carbon/source, atom/movable/pulled, state, force)
	SIGNAL_HANDLER
	var/too_heavy = FALSE
	if(isliving(pulled))
		var/mob/living/living_pulled = pulled
		too_heavy = living_pulled.mob_size > MOB_SIZE_TINY
	else if(isitem(pulled))
		var/obj/item/item_pulled = pulled
		too_heavy = item_pulled.w_class > WEIGHT_CLASS_TINY
	else
		too_heavy = TRUE
	if(!too_heavy)
		return
	pulled.balloon_alert(source, "za słaby, żeby to ciągnąć!")
	INVOKE_ASYNC(source, TYPE_PROC_REF(/atom/movable, stop_pulling))

/obj/item/organ/liver/gondola/proc/on_hug(mob/living/carbon/source, mob/living/carbon/hugged)
	SIGNAL_HANDLER
	var/pax_injected = 4
	if(ishuman(source))
		if(infuser_zone_covered(source, BODY_ZONE_L_ARM))
			pax_injected -= 2
		if(infuser_zone_covered(source, BODY_ZONE_R_ARM))
			pax_injected -= 2
	if(pax_injected > 0 && hugged.reagents?.add_reagent(/datum/reagent/pax, pax_injected))
		to_chat(hugged, "<span class='warning'>Czujesz drobne ukłucie!</span>")
