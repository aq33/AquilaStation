// AQUILA - u nas mak to /obj/item/food/grown/poppy, a zamiast ran (/datum/wound) leczy obrażenia kończyny i krwawienie.
/obj/item/food/grown/poppy/blessed
	name = "blessed poppy"
	desc = "Dziwny mak, który nigdy nie widział światła dnia."
	/// Counts how many time we picked someone out of crit condition
	var/save_count = 0

/obj/item/food/grown/poppy/blessed/Initialize(mapload, skip_genes)
	. = ..()
	color = COLOR_PINK
	animate(src, color = COLOR_YELLOW, loop = -1, time = 10 SECONDS)
	animate(color = COLOR_PINK, loop = -1, time = 10 SECONDS)

/obj/item/food/grown/poppy/blessed/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/food/grown/poppy/blessed/equipped(mob/user, slot, initial)
	. = ..()
	if(slot & slot_flags)
		ADD_TRAIT(user, TRAIT_NOCRITDAMAGE, REF(src))
		START_PROCESSING(SSobj, src)

/obj/item/food/grown/poppy/blessed/dropped(mob/user, silent)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_NOCRITDAMAGE, REF(src))
	STOP_PROCESSING(SSobj, src)

/obj/item/food/grown/poppy/blessed/process(seconds_per_tick)
	if(isliving(loc))
		heal_crit(seconds_per_tick)
		return

	if(isbodypart(loc))
		heal_limb(seconds_per_tick)
		return

	return PROCESS_KILL

/obj/item/food/grown/poppy/blessed/proc/heal_crit(seconds_per_tick)
	var/mob/living/wearer = loc
	if(wearer.stat == CONSCIOUS || wearer.stat == DEAD)
		return

	wearer.adjust_brute_loss(-0.5 * seconds_per_tick, updating_health = FALSE)
	wearer.adjust_fire_loss(-0.5 * seconds_per_tick, updating_health = FALSE)
	wearer.adjust_tox_loss(-0.25 * seconds_per_tick, updating_health = FALSE, forced = TRUE)
	wearer.adjust_oxy_loss(-0.25 * seconds_per_tick, updating_health = FALSE)
	wearer.updatehealth()
	if(wearer.stat == CONSCIOUS)
		save_count += 1
		if(prob(25 * save_count))
			to_chat(wearer, span_mansus("[src] usycha."))
			wither()

	else if(DT_PROB(33, seconds_per_tick))
		new /obj/effect/temp_visual/heal(get_turf(src), pick(COLOR_PINK, COLOR_YELLOW))
		if(prob(20))
			wearer.visible_message(span_mansus("Płatki [name] na głowie [wearer] lekko lśnią."))

/obj/item/food/grown/poppy/blessed/proc/heal_limb(seconds_per_tick)
	var/obj/item/bodypart/limb = loc
	var/mob/living/carbon/owner = limb.owner
	var/bleeding = owner?.is_bleeding()
	if(!limb.brute_dam && !limb.burn_dam && !bleeding && !length(limb.wounds))
		if(owner)
			to_chat(owner, span_mansus("[src] usycha."))
		wither()
		return

	limb.heal_damage(0.5 * seconds_per_tick, 0.5 * seconds_per_tick, null, null, FALSE)
	if(bleeding)
		owner.cauterise_wounds(0.1 * seconds_per_tick)
	// AQUILA - mak opatruje rany kończyny; te, które same się goją, goją się szybciej, resztę zamyka po chwili
	for(var/datum/wound/wound as anything in limb.wounds?.Copy())
		wound.treated = TRUE
		wound.heal_progress += 2 * seconds_per_tick SECONDS
		if(!wound.heal_time && wound.heal_progress >= 60 SECONDS)
			wound.remove_wound()
		else if(wound.heal_time && wound.heal_progress >= wound.heal_time)
			wound.remove_wound()
	owner?.update_wound_slowdown()
	owner?.updatehealth()

	if(owner && DT_PROB(33, seconds_per_tick))
		new /obj/effect/temp_visual/heal(get_turf(owner), pick(COLOR_PINK, COLOR_YELLOW))
		if(prob(20))
			owner.visible_message(span_mansus("Płatki [src] na [limb.name] [owner] lekko lśnią."))

/// Mak usycha i znika
/obj/item/food/grown/poppy/blessed/proc/wither()
	STOP_PROCESSING(SSobj, src)
	if(ismob(loc))
		var/mob/holder = loc
		holder.temporarilyRemoveItemFromInventory(src, TRUE)
	qdel(src)

/obj/item/food/grown/poppy/blessed/pre_attack(atom/target, mob/living/user, params)
	if(!iscarbon(target) || user.combat_mode)
		return ..()

	var/mob/living/carbon/carbon_target = target
	var/obj/item/bodypart/target_limb = carbon_target.get_bodypart(check_zone(user.zone_selected))
	if(isnull(target_limb))
		carbon_target.balloon_alert(user, "brak kończyny!")
		return FALSE

	if(!target_limb.brute_dam && !target_limb.burn_dam && !carbon_target.is_bleeding() && !length(target_limb.wounds))
		carbon_target.balloon_alert(user, "nie ma czego leczyć!")
		return FALSE

	if(locate(/obj/item/food/grown/poppy/blessed) in target_limb)
		carbon_target.balloon_alert(user, "już się leczy!")
		return FALSE

	INVOKE_ASYNC(src, PROC_REF(apply_to_limb), carbon_target, target_limb, user)
	return FALSE

/// Przykłada mak do kończyny - siedzi w niej i leczy, dopóki nie uschnie
/obj/item/food/grown/poppy/blessed/proc/apply_to_limb(mob/living/carbon/carbon_target, obj/item/bodypart/target_limb, mob/living/user)
	user.visible_message(
		span_notice("[user] przykłada [src] do [carbon_target == user ? "własnej kończyny" : "kończyny [carbon_target]"] ([target_limb.name])."),
		span_notice("Przykładasz [src] do [carbon_target == user ? "swojej kończyny" : "kończyny [carbon_target]"] ([target_limb.name])."),
		vision_distance = 5,
	)
	if(!do_after(user, 2 SECONDS, target = carbon_target))
		return
	if(QDELETED(target_limb) || target_limb.owner != carbon_target)
		return

	user.visible_message(
		span_mansus("Płatki [src] zaczynają lśnić, a pnącza oplatają kończynę [carbon_target]."),
		span_mansus("Płatki [src] zaczynają lśnić, a pnącza oplatają kończynę."),
		vision_distance = 5,
	)
	if(!user.temporarilyRemoveItemFromInventory(src))
		return
	forceMove(target_limb)
	START_PROCESSING(SSobj, src)
