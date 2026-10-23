/obj/item/kitchen/knife/butcher/heretic
	name = "\improper Crimson Cleaver"
	desc = "Tasak o misternie zdobionej czerwonej rękojeści i lekko zakrzywionym grzbiecie. Bez wątpienia narzędzie wojny, nie kuchni."
	icon = 'aquila/icons/obj/weapons/khopesh.dmi'
	force = 20
	throwforce = 20
	toolspeed = 0.25
	armour_penetration = 50
	throw_speed = 4
	throw_range = 7
	materials = list()
	/// Cooldown between lifesteal triggers
	COOLDOWN_DECLARE(lifesteal_cd)
	/// Range that which it will boomerang back to the wielder
	var/boomerange_range = 5
	/// AQUILA - właśnie wraca do rzucającego (u nas nie ma komponentu boomerang z tg)
	var/returning = FALSE
	/// AQUILA - właśnie tnie sąsiednie pola (zamiast attack_modifiers z tg)
	var/cleaving = FALSE

/obj/item/kitchen/knife/butcher/heretic/Initialize(mapload)
	. = ..()
	add_lifesteal_filter()

/obj/item/kitchen/knife/butcher/heretic/examine(mob/user)
	. = ..()
	. += span_mansus("Ostrze [src] jest wygięte tak subtelnie, że po rzucie może wrócić do ręki...")

/obj/item/kitchen/knife/butcher/heretic/equipped(mob/living/user, slot, initial)
	. = ..()
	if(!isliving(user))
		return
	if(!IS_HERETIC_OR_MONSTER(user))
		user.apply_status_effect(/datum/status_effect/crimson_cleaver_curse)

/obj/item/kitchen/knife/butcher/heretic/proc/add_lifesteal_filter()
	add_filter("lifesteal_filter", 1.5, outline_filter(1.5, LIGHT_COLOR_BLOOD_MAGIC))
	var/the_filter = get_filter("lifesteal_filter")
	animate(the_filter, alpha = 0) // start at 0 alpha
	animate(the_filter, alpha = 150, time = 3 SECONDS, loop = -1, easing = SINE_EASING) // fade in and out
	animate(alpha = 50, time = 3 SECONDS, loop = -1, easing = SINE_EASING)

/obj/item/kitchen/knife/butcher/heretic/proc/remove_lifesteal_filter()
	var/the_filter = get_filter("lifesteal_filter")
	animate(the_filter, alpha = 0, time = 1 SECONDS, easing = SINE_EASING)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, remove_filter), "lifesteal_filter"), 2 SECONDS)

// AQUILA - powrót po rzucie (tg: /datum/component/boomerang)
/obj/item/kitchen/knife/butcher/heretic/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = MOVE_FORCE_STRONG, quickstart = TRUE)
	if(!returning && isliving(thrower))
		callback = CALLBACK(src, PROC_REF(boomerang_return), thrower)
	return ..()

/// Wraca do rzucającego, jeśli jest dość blisko
/obj/item/kitchen/knife/butcher/heretic/proc/boomerang_return(mob/living/thrower)
	if(QDELETED(src) || QDELETED(thrower) || !isturf(loc))
		return
	if(get_dist(src, thrower) > boomerange_range || thrower.z != z)
		return
	returning = TRUE
	visible_message(span_warning("[src] zawraca w powietrzu!"))
	throw_at(thrower, boomerange_range + 2, throw_speed, null, TRUE, callback = CALLBACK(src, PROC_REF(boomerang_caught), thrower))

/// Heretyk łapie wracający tasak bez trudu
/obj/item/kitchen/knife/butcher/heretic/proc/boomerang_caught(mob/living/thrower)
	returning = FALSE
	if(QDELETED(src) || QDELETED(thrower) || !isturf(loc))
		return
	if(!IS_HERETIC_OR_MONSTER(thrower) || get_dist(src, thrower) > 1)
		return
	if(thrower.put_in_hands(src))
		thrower.visible_message(span_warning("[thrower] łapie wracający [src]!"))

/obj/item/kitchen/knife/butcher/heretic/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	var/mob/living/thrower = throwingdatum?.thrower
	if(returning || !isliving(hit_atom) || !isliving(thrower) || hit_atom == thrower || !COOLDOWN_FINISHED(src, lifesteal_cd))
		return

	lifesteal(hit_atom, thrower, coefficient = 0.75, amount = throwforce)

/obj/item/kitchen/knife/butcher/heretic/proc/lifesteal(mob/living/target, mob/living/user, coefficient = 1, amount = force)
	if(target == user)
		CRASH("[type] attempted to lifesteal from one guy to themselves")

	// you can brutalize corpses a little bit, but don't go too crazy
	if(target.stat == DEAD && target.getBruteLoss() > target.maxHealth * 2)
		return

	if(user.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY))
		start_lifesteal_cd(6 SECONDS)
		if(coefficient < 1)
			if(IS_HERETIC_OR_MONSTER(user))
				to_chat(user, span_warning("Nie udaje ci się uwolnić energii z [src] - coś ją tłumi!"))
			else
				to_chat(user, span_warning("Jakaś zła energia próbuje wyrwać się z [src], ale ją tłumisz!"))
		return

	if(target.can_block_magic(MAGIC_RESISTANCE))
		start_lifesteal_cd(8 SECONDS)
		if(IS_HERETIC_OR_MONSTER(user))
			to_chat(user, span_warning("[target] opiera się twojej próbie wyssania z niego sił życiowych!"))
		else
			to_chat(user, span_warning("Jakaś zła energia próbuje wpłynąć w [target], ale napotyka opór!"))
		return

	user.adjust_brute_loss(-0.5 * coefficient * amount)
	user.adjust_nutrition(0.75 * coefficient * amount)
	target.transfer_blood_to(user, coefficient * amount, TRUE)
	target.adjust_nutrition(-0.75 * coefficient * amount)
	to_chat(target, span_warning("Czujesz, jak uchodzą z ciebie siły życiowe..."))
	new /obj/effect/temp_visual/cleave(get_turf(target))

	// AQUILA - zamiast zmniejszania przepływu krwi z ran tamuje krwawienie
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		carbon_user.cauterise_wounds(0.1 * coefficient * amount)

	start_lifesteal_cd(10 SECONDS)

	// using the power satiates the curse
	if(!IS_HERETIC_OR_MONSTER(user))
		var/datum/status_effect/crimson_cleaver_curse/curse = user.has_status_effect(/datum/status_effect/crimson_cleaver_curse)
		curse?.curse_timer -= CEILING(4 * coefficient, 1)
		user.adjust_sanity(-0.5 * coefficient * amount)
		var/datum/component/mood/mood = user.get_mood()
		if(mood)
			switch(mood.sanity)
				if(SANITY_CRAZY + 1 to SANITY_UNSTABLE)
					user.adjustOrganLoss(ORGAN_SLOT_BRAIN, -0.2 * coefficient * amount)
				if(SANITY_INSANE + 1 to SANITY_CRAZY)
					user.adjustOrganLoss(ORGAN_SLOT_BRAIN, -0.4 * coefficient * amount)
				if(-INFINITY to SANITY_INSANE)
					user.adjustOrganLoss(ORGAN_SLOT_BRAIN, -0.8 * coefficient * amount)

/obj/item/kitchen/knife/butcher/heretic/proc/start_lifesteal_cd(duration = 10 SECONDS)
	if(!COOLDOWN_FINISHED(src, lifesteal_cd))
		return // if cooldown is already running, that's fine, but don't reset it

	COOLDOWN_START(src, lifesteal_cd, duration)
	remove_lifesteal_filter()
	addtimer(CALLBACK(src, PROC_REF(add_lifesteal_filter)), duration)

/obj/item/kitchen/knife/butcher/heretic/afterattack(atom/target, mob/living/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !isliving(target) || !isliving(user) || target == user)
		return

	if(cleaving || COOLDOWN_FINISHED(src, lifesteal_cd))
		lifesteal(target, user, coefficient = (cleaving ? 0.5 : 1), amount = force)

	if(cleaving)
		return

	// attacking satisfies the curse
	if(!IS_HERETIC_OR_MONSTER(user))
		var/datum/status_effect/crimson_cleaver_curse/curse = user.has_status_effect(/datum/status_effect/crimson_cleaver_curse)
		curse?.curse_timer -= 1

	var/dir_to_target = get_dir(user, target)
	var/turf/left_turf = get_step(target, turn(dir_to_target, 90))
	var/turf/right_turf = get_step(target, turn(dir_to_target, -90))

	cleaving = TRUE
	if(isopenturf(target.loc))
		cleave_attack(target.loc, user, click_parameters, list(target))
	if(isopenturf(left_turf))
		cleave_attack(left_turf, user, click_parameters)
	if(isopenturf(right_turf))
		cleave_attack(right_turf, user, click_parameters)
	cleaving = FALSE

/obj/item/kitchen/knife/butcher/heretic/proc/cleave_attack(turf/open/cleaving_over, mob/user, click_parameters, list/blacklist_targets)
	var/list/attack_pool = list()
	// Collect viable mobs
	for(var/mob/living/cleaved in cleaving_over)
		if(cleaved == user || cleaved.invisibility > user.see_invisible || !user.CanReach(cleaved, src) || (cleaved in blacklist_targets))
			continue
		attack_pool += cleaved
	if(!length(attack_pool))
		return
	// Sort by health, most damaged first
	sortTim(attack_pool, GLOBAL_PROC_REF(cmp_mob_health_crimson))
	// Attack the first valid mob in the pool
	melee_attack_chain(user, attack_pool[1], click_parameters)

/// Najbardziej poranieni pierwsi
/proc/cmp_mob_health_crimson(mob/living/mob_a, mob/living/mob_b)
	return mob_a.health - mob_b.health

/datum/status_effect/crimson_cleaver_curse
	id = "crimson_cleaver_curse"
	alert_type = null
	remove_on_fullheal = TRUE
	/// Counter for the curse's progression
	VAR_FINAL/curse_timer = 0
	/// Tracks the level the curse is at
	VAR_PRIVATE/curse_level = 0
	/// AQUILA - kolor oczu sprzed klątwy
	var/old_eye_color
	/// Cząsteczki na wysokim poziomie klątwy
	var/particles/curse_particles
	/// Cechy z wysokiego poziomu klątwy
	var/static/list/curse_traits = list(
		TRAIT_BATON_RESISTANCE,
		TRAIT_DISCOORDINATED_TOOL_USER,
		TRAIT_EASYBLEED,
		TRAIT_FLESH_DESIRE,
		TRAIT_NOGUNS,
		TRAIT_UNNATURAL_RED_GLOWY_EYES,
		TRAIT_VORACIOUS,
	)

/datum/status_effect/crimson_cleaver_curse/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_equipped_item))
	RegisterSignal(owner, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(on_unequipped_item))

/datum/status_effect/crimson_cleaver_curse/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOB_EQUIPPED_ITEM)
	UnregisterSignal(owner, COMSIG_MOB_UNEQUIPPED_ITEM)

	for(var/obj/item/kitchen/knife/butcher/heretic/cleaver in owner)
		REMOVE_TRAIT(cleaver, TRAIT_NODROP, TRAIT_STATUS_EFFECT(id))

	owner.clear_mood_event(id)
	owner.clear_mood_event("[id]_lost")
	owner.remove_status_effect(/datum/status_effect/forced_combat)
	owner.remove_traits(curse_traits, TRAIT_STATUS_EFFECT(id))
	restore_eyes()
	curse_level = 0
	update_particles()

/// AQUILA - czerwone oczy (u nas bez systemu priorytetów koloru oczu)
/datum/status_effect/crimson_cleaver_curse/proc/redden_eyes()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	if(isnull(old_eye_color))
		old_eye_color = human_owner.eye_color
	human_owner.eye_color = "f00"
	human_owner.update_body()

/datum/status_effect/crimson_cleaver_curse/proc/restore_eyes()
	if(!ishuman(owner) || isnull(old_eye_color))
		return
	var/mob/living/carbon/human/human_owner = owner
	human_owner.eye_color = old_eye_color
	old_eye_color = null
	human_owner.update_body()

/datum/status_effect/crimson_cleaver_curse/update_particles()
	if(curse_level < 3)
		if(curse_particles && owner.particles == curse_particles)
			owner.particles = null
		curse_particles = null
		return

	if(!curse_particles)
		curse_particles = new /particles/crimson_curse
		owner.particles = curse_particles

/datum/status_effect/crimson_cleaver_curse/proc/on_equipped_item(datum/source, obj/item/equipped, slot)
	SIGNAL_HANDLER

	if(istype(equipped, /obj/item/kitchen/knife/butcher/heretic) && curse_level >= 3)
		ADD_TRAIT(equipped, TRAIT_NODROP, TRAIT_STATUS_EFFECT(id))

	for(var/obj/item/kitchen/knife/butcher/heretic/cleaver in owner)
		if(cleaver != equipped)
			return

	switch(curse_level)
		if(2)
			to_chat(owner, span_mansus("Cieszysz się, że tasak wrócił do twojej ręki."))
			owner.add_mood_event("[id]_lost", /datum/mood_event/crimson_curse/reunited/low)

		if(3)
			to_chat(owner, span_hypnophrase("Tasak wrócił! Czas brać się do roboty!"))
			owner.add_mood_event("[id]_lost", /datum/mood_event/crimson_curse/reunited/medium)

		if(4)
			to_chat(owner, span_hypnophrase("TAK! WCIĄŻ JEST KREW DO PRZELANIA!"))
			owner.add_mood_event("[id]_lost", /datum/mood_event/crimson_curse/reunited/severe)

/datum/status_effect/crimson_cleaver_curse/proc/on_unequipped_item(datum/source, obj/item/unequipped, ...)
	SIGNAL_HANDLER

	if(istype(unequipped, /obj/item/kitchen/knife/butcher/heretic) && curse_level >= 3)
		REMOVE_TRAIT(unequipped, TRAIT_NODROP, TRAIT_STATUS_EFFECT(id))

	for(var/obj/item/kitchen/knife/butcher/heretic/cleaver in owner)
		if(cleaver != unequipped)
			return

	switch(curse_level)
		if(2)
			to_chat(owner, span_mansus("Niechętnie rozstajesz się z tasakiem."))
			owner.add_mood_event("[id]_lost", /datum/mood_event/crimson_curse/separated/low)

		if(3)
			to_chat(owner, span_hypnophrase("Nie! Tasak! Jak ja się teraz nasycę?!"))
			owner.add_mood_event("[id]_lost", /datum/mood_event/crimson_curse/separated/medium)

		if(4)
			to_chat(owner, span_hypnophrase("MOJE NARZĘDZIE! MOJA BROŃ! WYRWANO MI JĄ! MUSZĘ JĄ ODZYSKAĆ!"))
			owner.add_mood_event("[id]_lost", /datum/mood_event/crimson_curse/separated/severe)

/datum/status_effect/crimson_cleaver_curse/tick(seconds_between_ticks)
	var/curse_ticking = FALSE
	for(var/obj/item/kitchen/knife/butcher/heretic/cleaver in owner)
		// it's clearly mind based, and it's clearly magical, and it's clearly unholy. so everything fits
		if(owner.can_block_magic(ALL_MAGIC_RESISTANCE))
			to_chat(owner, span_notice("Tasak złowieszczo wibruje."))
		else
			curse_timer += seconds_between_ticks
			curse_ticking = TRUE

	if(!curse_ticking)
		curse_timer -= seconds_between_ticks
		if(curse_timer <= 0)
			qdel(src)
		return

	if(curse_timer > 10)
		if(curse_level < 1)
			curse_level = 1
			to_chat(owner, span_mansus("Tasak pewnie leży w dłoni. Jest nienaturalnie dobrze wyważony - machanie nim byłoby czystą przyjemnością."))
			owner.add_mood_event(id, /datum/mood_event/crimson_curse/low)
			return
	else
		if(curse_level == 1)
			curse_level = 0
			to_chat(owner, span_mansus("Umysł ci się rozjaśnia. Tasak wciąż leży w twojej dłoni. Niepokoi cię."))
			owner.clear_mood_event(id)
			return

	if(curse_timer > 30)
		if(curse_level < 2)
			curse_level = 2
			to_chat(owner, span_mansus("Tasak zaczyna ciążyć ci w dłoni. Masz ochotę go opuścić. Mocno."))
			owner.add_mood_event(id, /datum/mood_event/crimson_curse/medium)
			return
	else
		if(curse_level == 2)
			curse_level = 1
			to_chat(owner, span_mansus("Tasak zaczyna wyślizgiwać ci się z dłoni. Nie trzymasz go już tak pewnie."))
			owner.clear_mood_event(id)
			return

	if(curse_timer > 60)
		if(curse_level < 3)
			curse_level = 3
			to_chat(owner, span_mansus("Tasak stworzono, by przelewać krew i ciąć ciało. Ściskasz go z całych sił, zmuszony spełnić jego cel."))
			owner.add_mood_event(id, /datum/mood_event/crimson_curse/severe)
			for(var/obj/item/kitchen/knife/butcher/heretic/cleaver in owner)
				ADD_TRAIT(cleaver, TRAIT_NODROP, TRAIT_STATUS_EFFECT(id))

			owner.add_traits(curse_traits, TRAIT_STATUS_EFFECT(id))
			redden_eyes()
			curse_timer += 10 // little buffer
			update_particles()
			return

		if(SPT_PROB(30, seconds_between_ticks))
			owner.adjust_nutrition(-10 * HUNGER_FACTOR)
			if(iscarbon(owner))
				var/mob/living/carbon/carbon_owner = owner
				carbon_owner.overeatduration = max(carbon_owner.overeatduration - 200, 0)
			if(prob(33))
				to_chat(owner, span_notice(pick(
					"Tasak pragnie ciąć.",
					"Znowu ściska cię głód...",
					"Nie możesz przestać myśleć o mięsie...",
					"Łakniesz ciała.",
				)))
		if(SPT_PROB(10, seconds_between_ticks))
			owner.hallucination = min(owner.hallucination + 3, 30)
		if(SPT_PROB(20, seconds_between_ticks))
			owner.jitteriness = min(owner.jitteriness + 2, 15)
			owner.set_confusion_if_lower(2 SECONDS)
		if(SPT_PROB(20, seconds_between_ticks))
			owner.set_eye_blur_if_lower(2 SECONDS)

	else
		if(curse_level == 3)
			curse_level = 2
			to_chat(owner, span_mansus("Przymus tasaka słabnie. Palce puszczają rękojeść."))
			owner.clear_mood_event(id)
			for(var/obj/item/kitchen/knife/butcher/heretic/cleaver in owner)
				REMOVE_TRAIT(cleaver, TRAIT_NODROP, TRAIT_STATUS_EFFECT(id))

			owner.remove_status_effect(/datum/status_effect/eldritch_painting/desire)
			owner.remove_traits(curse_traits, TRAIT_STATUS_EFFECT(id))
			restore_eyes()
			update_particles()
			return

	if(curse_timer > 120)
		if(curse_level < 4)
			curse_level = 4
			to_chat(owner, span_mansus("Tasak jest przedłużeniem ciebie. Jest narzędziem do zdzierania ciała z kości. Ty jesteś narzędziem do zdzierania ciała z kości."))
			to_chat(owner, span_hypnophrase("Zamachnij się. Zamachnij się teraz."))
			owner.add_mood_event(id, /datum/mood_event/crimson_curse/extreme)
			owner.apply_status_effect(/datum/status_effect/forced_combat, INFINITY)
			curse_timer += 20 // medium buffer
			return

	else
		if(curse_level == 4)
			curse_level = 3
			to_chat(owner, span_mansus("Wracasz do zmysłów. A może wcale nie? Tasak wciąż jest w twoich rękach."))
			owner.clear_mood_event(id)
			owner.remove_status_effect(/datum/status_effect/forced_combat)
			return

/datum/mood_event/crimson_curse/low
	description = "<span class='warning'>Co za dziwny tasak.</span>\n"

/datum/mood_event/crimson_curse/medium
	description = "<span class='warning'>Fajnie byłoby pomachać tym tasakiem.</span>\n"
	mood_change = -2

/datum/mood_event/crimson_curse/severe
	description = "<span class='boldwarning'>Czuję głód, który zaspokoi tylko tasak.</span>\n"
	mood_change = -4

/datum/mood_event/crimson_curse/extreme
	description = "<span class='boldwarning'>ZAMACH! ZAMACH! ZAMACH!</span>\n"
	mood_change = -8

/datum/mood_event/crimson_curse/separated
	timeout = 6 MINUTES

/datum/mood_event/crimson_curse/separated/low
	description = "<span class='warning'>Chyba potrzebuję z powrotem tasaka.</span>\n"
	mood_change = -5

/datum/mood_event/crimson_curse/separated/medium
	description = "<span class='boldwarning'>Muszę odzyskać tasak. Chyba nie przeżyję bez niego.</span>\n"
	mood_change = -12

/datum/mood_event/crimson_curse/separated/severe
	description = "<span class='boldwarning'>ODEBRANO MI MOJE NARZĘDZIE! MUSZĘ JE ODZYSKAĆ!</span>\n"
	mood_change = -48

/datum/mood_event/crimson_curse/reunited
	timeout = 1 MINUTES

/datum/mood_event/crimson_curse/reunited/low
	description = "<span class='nicegreen'>Czuję się trochę lepiej, odkąd tasak wrócił.</span>\n"
	mood_change = 2

/datum/mood_event/crimson_curse/reunited/medium
	description = "<span class='nicegreen'>Tasak znów jest w moich rękach. Czas brać się do roboty!</span>\n"
	mood_change = 6

/datum/mood_event/crimson_curse/reunited/severe
	description = "<span class='nicegreen'>Moje narzędzie, moja broń, moje ciało! Znów jestem cały!</span>\n"
	mood_change = 12

/particles/crimson_curse
	icon = 'aquila/icons/effects/particles/echo.dmi'
	icon_state = list("echo1" = 3, "echo2" = 1, "echo3" = 1)
	width = 40
	height = 80
	count = 100
	spawning = 1
	lifespan = 1.5 SECONDS
	fade = 1 SECONDS
	friction = 0.5
	position = generator(GEN_SPHERE, 12, 12, NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(-1, 1), list(1, 1), NORMAL_RAND)
	color = LIGHT_COLOR_BLOOD_MAGIC
