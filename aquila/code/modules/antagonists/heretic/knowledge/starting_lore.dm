// Heretic starting knowledge.

/// Global list of all heretic knowledge that have is_starting_knowledge = TRUE. List of PATHS.
GLOBAL_LIST_INIT(heretic_start_knowledge, initialize_starting_knowledge())

/**
 * Returns a list of all heretic knowledge TYPEPATHS
 * that have route set to PATH_START.
 */
/proc/initialize_starting_knowledge()
	. = list()
	for(var/datum/heretic_knowledge/knowledge as anything in subtypesof(/datum/heretic_knowledge))
		if(initial(knowledge.is_starting_knowledge) == TRUE)
			. += knowledge

/*
 * The base heretic knowledge. Grants the Mansus Grasp spell.
 */
/datum/heretic_knowledge/spell/basic
	name = "Break of Dawn"
	desc = "Rozpoczyna twoją podróż w głąb Mansusa.<br>\
		Daje ci Mansus Grasp, potężne obezwładniające zaklęcie, które można ulepszać."
	action_to_add = /datum/action/cooldown/spell/touch/mansus_grasp
	cost = 0
	is_starting_knowledge = TRUE
	max_charges = 8
	focus_recharge_amount = 0.25
	holywater_drain_amount = 0.125
	transmute_text = "Wysysanie wpływów i składanie ofiar odnawia zaklęcie."

// AQUILA - w tg heretyk może tu też nasycić wędkę (wędkarstwo), u nas nie ma wędkarstwa
/datum/heretic_knowledge/spell/basic/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	RegisterSignal(our_heretic, COMSIG_HERETIC_INFLUENCE_DRAINED, PROC_REF(on_influence_tap))
	RegisterSignal(our_heretic, COMSIG_HERETIC_SACRIFICE, PROC_REF(on_sacrifice))

/datum/heretic_knowledge/spell/basic/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	UnregisterSignal(our_heretic, COMSIG_HERETIC_INFLUENCE_DRAINED)
	UnregisterSignal(our_heretic, COMSIG_HERETIC_SACRIFICE)

/datum/heretic_knowledge/spell/basic/proc/on_influence_tap(...)
	SIGNAL_HANDLER
	add_charges(max_charges)

/datum/heretic_knowledge/spell/basic/proc/on_sacrifice(...)
	SIGNAL_HANDLER
	add_charges(max_charges)

/**
 * The Living Heart heretic knowledge.
 *
 * Gives the heretic a living heart.
 * Also includes a ritual to turn their heart into a living heart.
 */
/datum/heretic_knowledge/living_heart
	name = "The Living Heart"
	desc = "Daje ci Żywe Serce, dzięki któremu namierzysz cele ofiarne."
	transmute_text = "Jeśli stracisz serce, możesz transmutować mak i kałużę krwi, \
		by obudzić nowe serce jako Żywe Serce."
	required_atoms = list(
		/obj/effect/decal/cleanable/blood = 1,
		/obj/item/food/grown/poppy = 1,
	)
	cost = 0
	priority = MAX_KNOWLEDGE_PRIORITY - 1 // Knowing how to remake your heart is important
	is_starting_knowledge = TRUE
	research_tree_icon_path = 'aquila/icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "living_heart"
	research_tree_icon_frame = 1
	notice = "Cybernetycznego serca nie da się obudzić."

/datum/heretic_knowledge/living_heart/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()

	var/obj/item/organ/where_to_put_our_heart = user.getorganslot(our_heretic.living_heart_organ_slot)
	// Our heart slot is not valid to put a heart
	if(!is_valid_heart(where_to_put_our_heart))
		where_to_put_our_heart = null

	// If a heretic is made from a species without a heart, we need to find a backup.
	if(!where_to_put_our_heart)
		var/static/list/backup_organs = list(
			ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
			ORGAN_SLOT_LIVER = /obj/item/organ/liver,
			ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		)

		for(var/backup_slot in backup_organs)
			var/obj/item/organ/look_for_backup = user.getorganslot(backup_slot)
			// This backup slot is not a valid slot to put a heart
			if(!is_valid_heart(look_for_backup))
				continue

			// We found a replacement place to put our heart
			where_to_put_our_heart = look_for_backup
			our_heretic.living_heart_organ_slot = backup_slot
			to_chat(user, span_boldnotice("Twój gatunek nie ma serca, więc Żywe Serce znajduje się w tym organie: [look_for_backup.name]."))
			break

	if(where_to_put_our_heart)
		where_to_put_our_heart.AddComponent(/datum/component/living_heart)
		desc = "Daje ci Żywe Serce związane z organem ([where_to_put_our_heart.name]), dzięki któremu namierzysz cele ofiarne."
		transmute_text = "Jeśli stracisz ten organ ([where_to_put_our_heart.name]), możesz transmutować mak i kałużę krwi, \
			by obudzić nowy jako Żywe Serce. \
			Cybernetyczny organ uniemożliwi rytuał!"

	else
		to_chat(user, span_boldnotice("Nie masz serca ani żadnych organów w klatce piersiowej, więc nie dostajesz Żywego Serca."))

/datum/heretic_knowledge/living_heart/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	var/obj/item/organ/our_living_heart = user.getorganslot(our_heretic.living_heart_organ_slot)
	if(our_living_heart)
		qdel(our_living_heart.GetComponent(/datum/component/living_heart))

// Don't bother letting them invoke this ritual if they have a Living Heart already in their chest
/datum/heretic_knowledge/living_heart/can_be_invoked(datum/antagonist/heretic/invoker)
	if(invoker.has_living_heart() == HERETIC_HAS_LIVING_HEART)
		return FALSE
	return TRUE

/datum/heretic_knowledge/living_heart/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/our_heretic = GET_HERETIC(user)
	var/obj/item/organ/our_living_heart = user.getorganslot(our_heretic.living_heart_organ_slot)
	// No heart, nothing to give living heart to
	if(QDELETED(our_living_heart))
		loc.balloon_alert(user, "rytuał nieudany, brak organu!")
		return FALSE

	// For sanity's sake, check if they've got a living heart -
	// even though it's not invokable if you already have one,
	// they may have gained one unexpectantly in between now and then
	if(HAS_TRAIT(our_living_heart, TRAIT_LIVING_HEART))
		loc.balloon_alert(user, "rytuał nieudany, masz już żywe serce!")
		return FALSE

	// By this point they are making a new heart
	// If their current heart is organic / not synthetic, we can continue the ritual as normal
	if(is_valid_heart(our_living_heart))
		return TRUE

	loc.balloon_alert(user, "rytuał nieudany, tego organu nie da się obudzić!") // "heart can't be awakened!"
	return FALSE

/datum/heretic_knowledge/living_heart/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/our_heretic = GET_HERETIC(user)
	var/obj/item/organ/our_new_heart = user.getorganslot(our_heretic.living_heart_organ_slot)
	// Don't delete our shiny new heart
	selected_atoms -= our_new_heart
	// Make it the living heart
	our_new_heart.AddComponent(/datum/component/living_heart)
	to_chat(user, span_warning("Czujesz, jak twój organ ([our_new_heart.name]) bije coraz szybciej, budząc się do życia!"))
	playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)
	return TRUE

/// Checks if the passed heart is a valid heart to become a living heart
/datum/heretic_knowledge/living_heart/proc/is_valid_heart(obj/item/organ/new_heart)
	if(QDELETED(new_heart))
		return FALSE
	// AQUILA - u nas sztuczne organy mają flagę ORGAN_SYNTHETIC (tg: ORGAN_ROBOTIC)
	if(new_heart.organ_flags & (ORGAN_UNUSABLE|ORGAN_SYNTHETIC|ORGAN_FAILING))
		return FALSE

	return TRUE

/datum/heretic_knowledge/feast_of_owls
	name = "Feast of Owls"
	desc = "Pozwala odprawić rytuał, który daje pięć punktów wiedzy, ale odbiera możliwość wniebowstąpienia."
	gain_text = "W miękkim blasku nierozumu po nocy krąży bestia. Przywołam ją i pozwolę jej stanąć przede mną. Pożre moje ambicje i zostawi po sobie wiedzę."
	is_starting_knowledge = TRUE
	required_atoms = list()
	research_tree_icon_path = 'icons/mob/actions/actions_animal.dmi'
	research_tree_icon_state = "god_transmit"
	notice = "Można to zrobić tylko raz i nie da się tego cofnąć."
	/// amount of research points granted
	var/reward = 5

/datum/heretic_knowledge/feast_of_owls/can_be_invoked(datum/antagonist/heretic/invoker)
	return !invoker.feast_of_owls

/datum/heretic_knowledge/feast_of_owls/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/alert = tgui_alert(user,"Na pewno chcesz porzucić wniebowstąpienie? Tego nie da się cofnąć.", "Feast of Owls", list("Tak, na pewno", "Nie"), 30 SECONDS)
	if(alert != "Tak, na pewno" || QDELETED(user) || QDELETED(src) || get_dist(user, loc) > 2)
		return FALSE
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	if(QDELETED(heretic_datum) || heretic_datum.feast_of_owls)
		return FALSE

	. = TRUE

	heretic_datum.feast_of_owls = TRUE
	heretic_datum.update_heretic_aura()
	user.set_temp_blindness_if_lower(reward * 1 SECONDS)
	user.AdjustParalyzed(reward * 1 SECONDS)
	user.playsound_local(get_turf(user), 'aquila/sound/music/antag/heretic/heretic_gain_intense.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	for(var/i in 1 to reward)
		user.emote("scream")
		playsound(loc, 'sound/items/eatfood.ogg', 100, TRUE)
		heretic_datum.adjust_knowledge_points(1)

		to_chat(user, span_danger("Czujesz, jak coś niewidzialnego rozdziera twoją esencję!"))
		user.do_jitter_animation()
		sleep(1 SECONDS)
		if(QDELETED(user) || QDELETED(heretic_datum))
			return FALSE

	to_chat(user, span_danger(span_big("Twoja ambicja legła w gruzach, ale pozostało po niej coś potężnego...")))
	var/drain_message = pick_list(HERETIC_INFLUENCE_FILE, "drain_message")
	to_chat(user, span_hypnophrase(span_big("[drain_message]")))
	return .
