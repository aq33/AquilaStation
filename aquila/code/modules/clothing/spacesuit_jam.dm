// AQUILA - zacinający się skafander (AquilaMed 5, etap 9). Mocny cios w tors może zablokować zamki skafandra:
// nosiciel nie zdejmie go sam ani nikt nie ściągnie go zwykłym rozbieraniem. Ktoś inny musi go wyciąć spawarką albo
// piłą (bez trybu walki, celując w tors, kilkanaście sekund). Wycięty skafander traci szczelność, dopóki nie
// zaklei się go taśmą. Wzór rozdarcia: awaryjny skafander (code/modules/clothing/spacesuits/miscellaneous.dm).

#define AQ_SUIT_JAM_TRAIT "aq_suit_jam"
/// Brute to the torso at or above this can jam the suit
#define AQ_SUIT_JAM_DAMAGE 20
#define AQ_SUIT_JAM_CHANCE 8
#define AQ_SUIT_CUT_TIME (15 SECONDS)

/obj/item/clothing/suit/space
	/// The locks are jammed: the wearer cannot take it off
	var/aq_jammed = FALSE
	/// Cut open to get someone out: leaks until taped
	var/aq_cut = FALSE

/obj/item/clothing/suit/space/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_OCLOTHING)
		RegisterSignal(user, COMSIG_MOB_APPLY_DAMGE, PROC_REF(aq_on_wearer_damaged), override = TRUE)
		RegisterSignal(user, COMSIG_PARENT_ATTACKBY, PROC_REF(aq_on_wearer_attackby), override = TRUE)
	else
		UnregisterSignal(user, list(COMSIG_MOB_APPLY_DAMGE, COMSIG_PARENT_ATTACKBY))

/obj/item/clothing/suit/space/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, list(COMSIG_MOB_APPLY_DAMGE, COMSIG_PARENT_ATTACKBY))
	// Taken off by force (admin, gib, death drop): the locks stay broken open, nobody is left inside to cut out
	if(aq_jammed)
		aq_jammed = FALSE
		REMOVE_TRAIT(src, TRAIT_NODROP, AQ_SUIT_JAM_TRAIT)

/// The suit is one listener for COMSIG_MOB_APPLY_DAMGE, so this handler also drives the armor insert one
/// (munitions_forge/armor_insert.dm), which this registration replaces
/obj/item/clothing/suit/space/proc/aq_on_wearer_damaged(mob/living/carbon/source, damage, damagetype, def_zone)
	SIGNAL_HANDLER
	if(aq_insert_slot)
		aq_insert_on_damage(source, damage, damagetype, def_zone)
	var/zone = aq_damage_zone(def_zone)
	if(aq_jammed || damagetype != BRUTE || (zone && zone != BODY_ZONE_CHEST))
		return
	if(source.aq_damage_after_armor(damage, def_zone) < AQ_SUIT_JAM_DAMAGE)
		return
	if(prob(AQ_SUIT_JAM_CHANCE))
		aq_jam()

/obj/item/clothing/suit/space/proc/aq_jam()
	if(aq_jammed)
		return
	aq_jammed = TRUE
	ADD_TRAIT(src, TRAIT_NODROP, AQ_SUIT_JAM_TRAIT)
	var/mob/living/wearer = loc
	if(istype(wearer))
		playsound(wearer, 'sound/effects/clang.ogg', 40, TRUE)
		to_chat(wearer, "<span class='userdanger'>Coś trzaska w zamkach [src]. Skafander się zaciął, nie zdejmiesz go sam!</span>")

/// Someone else cuts the wearer out with a welder or a saw
/obj/item/clothing/suit/space/proc/aq_on_wearer_attackby(mob/living/carbon/human/wearer, obj/item/tool, mob/living/user, params)
	SIGNAL_HANDLER
	if(!aq_jammed || user == wearer || user.combat_mode || user.zone_selected != BODY_ZONE_CHEST)
		return
	if(tool.tool_behaviour != TOOL_WELDER && tool.tool_behaviour != TOOL_SAW)
		return
	INVOKE_ASYNC(src, PROC_REF(aq_cut_out), wearer, tool, user)
	return COMPONENT_NO_AFTERATTACK

/obj/item/clothing/suit/space/proc/aq_cut_out(mob/living/carbon/human/wearer, obj/item/tool, mob/living/user)
	user.visible_message("<span class='notice'>[user] zaczyna wycinać [wearer] z zaciętego skafandra za pomocą [tool].</span>", "<span class='notice'>Zaczynasz wycinać [wearer] z zaciętego skafandra...</span>")
	// Only a welder spends fuel; a saw has no amount to use (use_tool would refuse it)
	if(!tool.use_tool(wearer, user, AQ_SUIT_CUT_TIME, amount = tool.tool_behaviour == TOOL_WELDER ? 1 : 0, volume = 50))
		return
	if(!aq_jammed || wearer.wear_suit != src)
		return
	aq_jammed = FALSE
	REMOVE_TRAIT(src, TRAIT_NODROP, AQ_SUIT_JAM_TRAIT)
	aq_cut = TRUE
	clothing_flags &= ~STOPSPRESSUREDAMAGE
	name = "[initial(name)] (rozcięty)"
	wearer.dropItemToGround(src)
	user.visible_message("<span class='notice'>[user] rozcina skafander i wyciąga z niego [wearer].</span>", "<span class='notice'>Rozcinasz skafander i wyciągasz z niego [wearer]. Bez łatania będzie przepuszczał próżnię.</span>")

/// Tape closes the cut
/obj/item/clothing/suit/space/attackby(obj/item/I, mob/user, params)
	if(aq_cut && istype(I, /obj/item/stack/sticky_tape))
		var/obj/item/stack/sticky_tape/tape = I
		to_chat(user, "<span class='notice'>Zaklejasz rozcięcie [src]...</span>")
		if(!do_after(user, 5 SECONDS, target = src) || !aq_cut || !tape.use(2))
			return TRUE
		aq_cut = FALSE
		name = initial(name)
		if(initial(clothing_flags) & STOPSPRESSUREDAMAGE)
			clothing_flags |= STOPSPRESSUREDAMAGE
			to_chat(user, "<span class='notice'>Zaklejasz rozcięcie, [src] znowu trzyma ciśnienie.</span>")
		else
			to_chat(user, "<span class='notice'>Zaklejasz rozcięcie w [src].</span>")
		return TRUE
	return ..()

/obj/item/clothing/suit/space/examine(mob/user)
	. = ..()
	if(aq_jammed)
		. += "<span class='warning'>Zamki są zacięte. Nosiciel musi zostać wycięty spawarką albo piłą.</span>"
	if(aq_cut)
		. += "<span class='warning'>Jest rozcięty i przepuszcza próżnię. Zaklej go taśmą.</span>"

#undef AQ_SUIT_JAM_TRAIT
#undef AQ_SUIT_JAM_DAMAGE
#undef AQ_SUIT_JAM_CHANCE
#undef AQ_SUIT_CUT_TIME
