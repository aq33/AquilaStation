// AQUILA - chłodzony pojemnik na narządy (AquilaMed 5), port z tgstation (code/game/objects/items/storage/medkit.dm,
// /obj/item/storage/organbox), sprite'y z icons/obj/storage/case.dmi (CC-BY-SA 3.0).
// Pojemnik zużywa lód albo kriostylan (kriostylan wolniej). Dopóki ma czym chłodzić, narządy w środku nie gniją
// (ORGAN_FROZEN). Po wyjęciu albo gdy chłodziwo się skończy, zaczynają gnić jak zwykle.
// Różnica: tg zamraża wszystko w środku przez /obj/proc/freeze(), u nas tylko narządy (kończyny i tak nie gniją).

/obj/item/storage/organbox
	name = "chłodzony pojemnik na narządy"
	desc = "Walizka z obiegiem chłodzącym na lód albo kriostylan. Narządy w środku nie gniją, dopóki jest czym chłodzić. Wlej chłodziwo z pojemnika."
	icon = 'aquila/icons/obj/medical/medycyna5.dmi'
	icon_state = "organbox"
	w_class = WEIGHT_CLASS_BULKY
	throw_speed = 3
	throw_range = 7
	custom_premium_price = 160
	/// Is it cooling right now
	var/cooling = FALSE
	/// Organs this box froze, so it thaws only those
	var/list/obj/item/organ/frozen_by_us = list()

/obj/item/storage/organbox/Initialize(mapload)
	. = ..()
	create_reagents(100, OPENCONTAINER)
	START_PROCESSING(SSobj, src)

/obj/item/storage/organbox/Destroy()
	STOP_PROCESSING(SSobj, src)
	thaw_all()
	return ..()

/obj/item/storage/organbox/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.max_items = 8
	STR.max_combined_w_class = 21
	STR.can_hold = typecacheof(list(/obj/item/organ, /obj/item/bodypart, /obj/item/mmi))

/obj/item/storage/organbox/examine(mob/user)
	. = ..()
	var/coolant = reagents.get_reagent_amount(/datum/reagent/cryostylane) + reagents.get_reagent_amount(/datum/reagent/consumable/ice)
	. += cooling ? "<span class='notice'>Chłodzi. Zostało [round(coolant, 0.1)] j. chłodziwa.</span>" : "<span class='warning'>Nie chłodzi: wlej lód albo kriostylan.</span>"

/// An open container pours its coolant in instead of trying to fit inside
/obj/item/storage/organbox/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/reagent_containers) && I.is_open_container())
		var/obj/item/reagent_containers/container = I
		if(!container.reagents.total_volume)
			to_chat(user, "<span class='warning'>[container] jest pusty.</span>")
			return TRUE
		var/units = container.reagents.trans_to(src, container.amount_per_transfer_from_this, transfered_by = user)
		if(units)
			to_chat(user, "<span class='notice'>Wlewasz [units] j. do obiegu chłodzącego [src].</span>")
		else
			to_chat(user, "<span class='warning'>Obieg chłodzący jest pełny.</span>")
		return TRUE // handled: the beaker must not pour a second time in afterattack
	return ..()

/obj/item/storage/organbox/update_icon_state()
	icon_state = cooling ? "organbox-working" : "organbox"
	return ..()

/// Which coolant it is about to use, or null if there is none
/obj/item/storage/organbox/proc/coolant_to_spend()
	if(reagents.get_reagent_amount(/datum/reagent/cryostylane))
		return /datum/reagent/cryostylane
	if(reagents.get_reagent_amount(/datum/reagent/consumable/ice))
		return /datum/reagent/consumable/ice
	return null

/// Organs to keep cold: loose ones, the brain of an MMI and the organs inside a stored limb (a severed head keeps its brain)
/obj/item/storage/organbox/proc/organs_inside()
	. = list()
	for(var/obj/item/organ/organ in contents)
		. += organ
	for(var/obj/item/mmi/mmi in contents)
		if(mmi.brain)
			. += mmi.brain
	for(var/obj/item/bodypart/part in contents)
		for(var/obj/item/organ/organ in part.contents)
			. += organ

/obj/item/storage/organbox/process(delta_time)
	var/list/organs = organs_inside()
	if(!length(organs)) // empty: the coolant is not spent
		return
	var/coolant = coolant_to_spend()
	if(!coolant)
		if(cooling)
			cooling = FALSE
			update_icon()
			thaw_all()
		return
	reagents.remove_reagent(coolant, (coolant == /datum/reagent/cryostylane ? 0.05 : 0.1) * delta_time)
	if(!cooling)
		cooling = TRUE
		update_icon()
	for(var/obj/item/organ/organ as anything in organs)
		freeze_organ(organ)

/obj/item/storage/organbox/proc/freeze_organ(obj/item/organ/organ)
	if(organ.organ_flags & ORGAN_FROZEN)
		return
	organ.organ_flags |= ORGAN_FROZEN
	frozen_by_us += organ

/obj/item/storage/organbox/proc/thaw_all()
	for(var/obj/item/organ/organ as anything in frozen_by_us)
		if(!QDELETED(organ))
			organ.organ_flags &= ~ORGAN_FROZEN
	frozen_by_us.Cut()

/obj/item/storage/organbox/Exited(atom/movable/gone, direction)
	. = ..()
	var/list/leaving = list()
	if(isorgan(gone))
		leaving += gone
	else if(istype(gone, /obj/item/mmi))
		var/obj/item/mmi/mmi = gone
		if(mmi.brain)
			leaving += mmi.brain
	else if(isbodypart(gone))
		for(var/obj/item/organ/organ in gone.contents)
			leaving += organ
	for(var/obj/item/organ/organ as anything in leaving)
		if(organ in frozen_by_us)
			organ.organ_flags &= ~ORGAN_FROZEN
			frozen_by_us -= organ

/obj/item/storage/organbox/preloaded
	desc = "Walizka z obiegiem chłodzącym, napełniona lodem. Narządy w środku nie gniją, dopóki jest czym chłodzić."

/obj/item/storage/organbox/preloaded/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/consumable/ice, 50)
