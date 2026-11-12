// AQUILA - Alt+klik na broni trzymanej w ręce przełącza bezpiecznik.
// Broń, dla której Alt+klik to własna mechanika (bębenek rewolweru, osłona SAW, przełączanie tub strzelby),
// zostaje przy niej. Jednorazowy wybór wyglądu ma pierwszeństwo, a tłumik odkręca się Alt+klikiem tylko
// na zabezpieczonej broni. Bezpiecznik jest też pod klawiszem „Bezpiecznik broni” (firemodes.dm).

/obj/item/gun/AltClick(mob/user)
	if(aq_alt_click_safety(user))
		return
	return ..()

/obj/item/gun/ballistic/AltClick(mob/user)
	if(aq_alt_click_safety(user))
		return
	return ..()

/// Przełącza bezpiecznik po Alt+kliku; FALSE, gdy Alt+klik ma zrobić coś innego
/obj/item/gun/proc/aq_alt_click_safety(mob/living/user)
	if(!aq_alt_click_is_safety() || !istype(user) || !user.is_holding(src))
		return FALSE
	if(!user.canUseTopic(src, BE_CLOSE))
		return FALSE
	return toggle_safety(user)

/// Czy Alt+klik na tej broni przełącza teraz bezpiecznik
/obj/item/gun/proc/aq_alt_click_is_safety()
	return has_safety

/obj/item/gun/ballistic/aq_alt_click_is_safety()
	if(unique_reskin && !current_skin)
		return FALSE
	if(suppressed && can_unsuppress && aq_firemode == AQ_FIREMODE_SAFE)
		return FALSE
	return ..()

/obj/item/gun/ballistic/revolver/aq_alt_click_is_safety()
	return FALSE

/obj/item/gun/ballistic/automatic/l6_saw/aq_alt_click_is_safety()
	return FALSE

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/aq_alt_click_is_safety()
	return FALSE

/obj/item/gun/examine(mob/user)
	. = ..()
	if(aq_alt_click_is_safety())
		. += "<span class='notice'>Alt+klik na broni w ręce zabezpiecza ją albo odbezpiecza.</span>"

/obj/item/gun/add_context_self(datum/screentip_context/context, mob/user)
	. = ..()
	if(aq_alt_click_is_safety() && isliving(user) && user.is_holding(src))
		context.add_alt_click_action(aq_firemode == AQ_FIREMODE_SAFE ? "Odbezpiecz" : "Zabezpiecz")
