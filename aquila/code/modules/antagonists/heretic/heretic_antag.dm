

/*
 * Simple helper to generate a string of
 * garbled symbols up to [length] characters.
 *
 * Used in creating spooky-text for heretic ascension announcements.
 */
/proc/generate_heretic_text(length = 25)
	if(!isnum(length)) // stupid thing so we can use this directly in replacetext
		length = 25
	. = ""
	for(var/i in 1 to length)
		. += pick("!", "$", "^", "@", "&", "#", "*", "(", ")", "?")

/// The heretic antagonist itself.
/datum/antagonist/heretic
	name = "\improper Heretyk"
	roundend_category = "heretycy"
	antagpanel_category = "Heretic"
	ui_name = "AntagInfoHeretic"
	antag_moodlet = /datum/mood_event/heretics
	banning_key = ROLE_HERETIC
	hijack_speed = 0.5
	// AQUILA - u nas nie ma tych zmiennych na bazowym antagoniście, więc heretyk ma je u siebie
	/// Czy heretyk może jeszcze odrzucić wezwanie Mansusa i wpisać własny cel (traci wtedy wniebowstąpienie)
	var/can_assign_self_objectives = TRUE
	/// Podpowiedź w oknie własnego celu
	var/default_custom_objective = "Zamień jeden z działów w świadectwo swojej mrocznej wiedzy."
	/// Dźwięk przy zostaniu heretykiem
	var/stinger_sound = 'aquila/sound/music/antag/heretic/heretic_gain.ogg'

	/// Contains multiple separate heretic shops so you can choose between multiple when buying.
	var/list/heretic_shops = list(
		HERETIC_KNOWLEDGE_START = list(),
		HERETIC_KNOWLEDGE_TREE = list(),
		HERETIC_KNOWLEDGE_SHOP = list(),
		HERETIC_KNOWLEDGE_DRAFT = list()
	)
	/// A blacklist of turfs we cannot scribe on.
	var/static/list/blacklisted_rune_turfs = typecacheof(list(/turf/open/space, /turf/open/openspace, /turf/open/lava, /turf/open/chasm))
	/// A static list of all paths we can take and related info for the UI
	var/static/list/path_info = list()
	/// Assoc list of [typepath] = [knowledge instance]. A list of all knowledge this heretic's reserached.
	var/list/researched_knowledge = list()
	/// Lazy assoc list of [refs to humans] to [image previews of the human]. Humans that we have as sacrifice targets.
	var/list/mob/living/carbon/human/sac_targets
	/// List of all sacrifice target's names, used for end of round report
	var/list/all_sac_targets = list()
	/// Whether or not the heretic can make unlimited blades, but unable to blade break to teleport
	var/unlimited_blades = FALSE
	/// Whether we are allowed to ascend
	var/feast_of_owls = FALSE
	/// Whether we've ascended! (Completed one of the final rituals)
	var/ascended = FALSE
	/// Whether we're drawing a rune or not
	var/drawing_rune = FALSE
	/// The path our heretic has chosen.
	var/datum/heretic_knowledge_tree_column/heretic_path
	/// Reference to the overlay heretics get when they get strong enough
	var/static/mutable_appearance/eldritch_overlay = mutable_appearance('aquila/icons/mob/effects/heretic_aura.dmi', "heretic_aura")
	/// A sum of how many knowledge points this heretic CURRENTLY has. Used to research.
	var/knowledge_points = 1
	/// The time between gaining influence passively. The heretic gain +1 knowledge points every this duration of time.
	var/passive_gain_timer = 20 MINUTES
	/// Tracks how many knowledge points the heretic has aqcuired. Once you get enough points you lose the ability to blade break
	var/knowledge_gained = 0
	/// The organ slot we place our Living Heart in.
	var/living_heart_organ_slot = ORGAN_SLOT_HEART
	/// A list of TOTAL how many sacrifices completed. (Includes high value sacrifices)
	var/total_sacrifices = 0
	/// A list of TOTAL how many high value sacrifices completed. (Heads of staff)
	var/high_value_sacrifices = 0
	/// Controls what types of turf we can spread rust to
	var/rust_strength = 1
	/// Simpler version of above used to limit amount of loot that can be hoarded
	var/rewards_given = 0
	/// Our heretic passive level. Tracked here in case of body moving shenanigans
	var/passive_level = 1
	/// How many points are needed to gain a visible heretic aura
	var/points_to_aura = 8
	/// Lazylist of weakrefs of items we can track with the heart
	var/list/tracked_items

/datum/antagonist/heretic/Destroy()
	LAZYNULL(sac_targets)
	return ..()

/datum/antagonist/heretic/proc/get_icon_of_knowledge(datum/heretic_knowledge/knowledge)
	//basic icon parameters
	var/icon_path = 'icons/mob/actions/actions_ecult.dmi'
	var/icon_state = "eye"
	var/icon_frame = initial(knowledge.research_tree_icon_frame)
	var/icon_dir = initial(knowledge.research_tree_icon_dir)
	//can't imagine why you would want this one, so it can't be overridden by the knowledge
	var/icon_moving = 0

	//item transmutation knowledge does not generate its own icon due to implementation difficulties, the icons have to be specified in the override vars

	//if the knowledge has a special icon, use that
	if(!isnull(initial(knowledge.research_tree_icon_path)))
		icon_path = initial(knowledge.research_tree_icon_path)
		icon_state = initial(knowledge.research_tree_icon_state)

	//if the knowledge is a spell, use the spell's button
	else if(ispath(knowledge,/datum/heretic_knowledge/spell))
		var/datum/heretic_knowledge/spell/spell_knowledge = knowledge
		var/datum/action/result_action = initial(spell_knowledge.action_to_add)
		icon_path = initial(result_action.icon_icon)
		icon_state = initial(result_action.button_icon_state)

	//if the knowledge is a summon, use the mob sprite
	else if(ispath(knowledge,/datum/heretic_knowledge/summon))
		var/datum/heretic_knowledge/summon/summon_knowledge = knowledge
		var/mob/living/result_mob = initial(summon_knowledge.mob_to_summon)
		icon_path = initial(result_mob.icon)
		icon_state = initial(result_mob.icon_state)

	//if the knowledge is an ascension, use the achievement sprite
	else if(ispath(knowledge,/datum/heretic_knowledge/ultimate))
		var/datum/heretic_knowledge/ultimate/ascension_knowledge = knowledge
		var/achievement = initial(ascension_knowledge.ascension_achievement)
		// AQUILA - u nas nagrody mają ikony w spritesheecie, więc ikony z tg siedzą w osobnym pliku
		var/static/list/ascension_icon_states = list(
			"/datum/award/achievement/misc/ash_ascension" = "ashascend",
			"/datum/award/achievement/misc/flesh_ascension" = "fleshascend",
			"/datum/award/achievement/misc/rust_ascension" = "rustascend",
			"/datum/award/achievement/misc/void_ascension" = "voidascend",
			"/datum/award/achievement/misc/blade_ascension" = "bladeascend",
			"/datum/award/achievement/misc/cosmic_ascension" = "cosmicascend",
			"/datum/award/achievement/misc/lock_ascension" = "lockascend",
			"/datum/award/achievement/misc/moon_ascension" = "moonascend",
		)
		var/ascension_state = ascension_icon_states["[achievement]"]
		if(ascension_state)
			icon_path = 'aquila/icons/ui_icons/antags/heretic/ascension_achievements.dmi'
			icon_state = ascension_state

	var/list/result_parameters = list()
	result_parameters["icon"] = icon_path
	result_parameters["state"] = icon_state
	result_parameters["frame"] = icon_frame
	result_parameters["dir"] = icon_dir
	result_parameters["moving"] = icon_moving
	return result_parameters

/datum/antagonist/heretic/proc/get_knowledge_data(datum/heretic_knowledge/knowledge, list/source_list, done = FALSE, category = HERETIC_KNOWLEDGE_TREE)
	if(!length(source_list))
		CRASH("get_knowledge_data called without source_list! (Got: [source_list || "empty list"])")
	var/list/knowledge_data = list()

	knowledge_data["path"] = knowledge
	knowledge_data["icon_params"] = get_icon_of_knowledge(knowledge)
	knowledge_data["name"] = initial(knowledge.name)
	knowledge_data["gainFlavor"] = initial(knowledge.gain_text)
	knowledge_data["cost"] = source_list[knowledge][HKT_COST]
	knowledge_data["depth"] = source_list[knowledge][HKT_DEPTH]
	knowledge_data["bgr"] = source_list[knowledge][HKT_UI_BGR]
	knowledge_data[HKT_CATEGORY] = category
	knowledge_data["ascension"] = ispath(knowledge, /datum/heretic_knowledge/ultimate)

	knowledge_data["done"] = done
	//description of a knowledge might change, make sure we are not shown the initial() value in that case
	var/list/knowledge_info = researched_knowledge[knowledge]
	if(islist(knowledge_info))
		var/datum/heretic_knowledge/knowledge_instance = knowledge_info[HKT_INSTANCE]
		knowledge_data["desc"] = knowledge_instance.desc
		knowledge_data["info"] = knowledge_instance.transmute_text
		knowledge_data["notice"] = knowledge_instance.notice

	else
		knowledge_data["desc"] = initial(knowledge.desc)
		knowledge_data["info"] = initial(knowledge.transmute_text)
		knowledge_data["notice"] = initial(knowledge.notice)

	if(ispath(knowledge, /datum/heretic_knowledge/ultimate))
		var/ascension_check = can_ascend()
		if(ascension_check != HERETIC_CAN_ASCEND)
			knowledge_data["disabled"] = TRUE
			knowledge_data["notice"] += "<br>[ascension_check]"

	return knowledge_data

/datum/antagonist/heretic/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui?.set_autoupdate(FALSE)

/datum/antagonist/heretic/ui_data(mob/user)
	var/list/data = list("charges" = knowledge_points)

	data["objectives"] = get_objectives()
	data["can_change_objective"] = can_assign_self_objectives

	data["paths"] = path_info
	data["passive_level"] = passive_level

	data["total_sacrifices"] = total_sacrifices
	data["ascended"] = ascended
	data["points_to_aura"] = points_to_aura

	var/list/tree_data = list()
	var/list/shop_knowledge = list()

	// This should be cached in some way, but the fact that final knowledge
	// has to update its disabled state based on whether all objectives are complete,
	// makes this very difficult. I'll figure it out one day maybe
	for(var/knowledge_path in researched_knowledge)
		var/list/knowledge_info = researched_knowledge[knowledge_path]
		/// draft knowledges are only shown post-research
		var/list/knowledge_data = get_knowledge_data(knowledge_path, researched_knowledge, TRUE, knowledge_info[HKT_CATEGORY])
		var/category = knowledge_info[HKT_CATEGORY]

		var/depth = knowledge_info[HKT_DEPTH]
		while(depth > length(tree_data))
			tree_data += list(list("nodes" = list()))

		if(category == HERETIC_KNOWLEDGE_SHOP || category == HERETIC_KNOWLEDGE_DRAFT)
			shop_knowledge += list(knowledge_data)
			continue

		tree_data[depth]["nodes"] += list(knowledge_data)

	// TODO: sanity for purchasing categories as bypasses are likely rn
	var/list/heretic_tree = heretic_shops[HERETIC_KNOWLEDGE_TREE]
	var/list/researchable_knowledges = get_researchable_knowledge()
	for(var/datum/heretic_knowledge/knowledge_path as anything in heretic_tree)
		if(ispath(knowledge_path, /datum/heretic_knowledge/limited_amount/starting))
			continue
		var/list/knowledge_info = heretic_tree[knowledge_path]
		if(!(knowledge_info[HKT_ID] in researchable_knowledges))
			continue
		var/list/knowledge_data = get_knowledge_data(knowledge_path, heretic_tree, FALSE)
		var/depth = knowledge_data[HKT_DEPTH]

		while(depth > length(tree_data))
			tree_data += list(list("nodes" = list()))

		tree_data[depth]["nodes"] += list(knowledge_data)


	if(!heretic_path)
		data["knowledge_tiers"] = tree_data
		return data

	var/list/heretic_drafts = heretic_shops[HERETIC_KNOWLEDGE_DRAFT]
	for(var/datum/heretic_knowledge/knowledge_path as anything in heretic_drafts)
		var/list/knowledge_info = heretic_drafts[knowledge_path]
		if(!(knowledge_info[HKT_ID] in researchable_knowledges))
			continue
		var/list/knowledge_data = get_knowledge_data(knowledge_path, heretic_drafts, FALSE, HERETIC_KNOWLEDGE_DRAFT)

		var/depth = knowledge_data[HKT_DEPTH]
		while(depth > length(tree_data))
			tree_data += list(list("nodes" = list()))

		tree_data[depth]["nodes"] += list(knowledge_data)

	data["knowledge_tiers"] = tree_data
	var/list/shop = heretic_shops[HERETIC_KNOWLEDGE_SHOP]
	for(var/knowledge_path in shop)
		var/list/knowledge_info = shop[knowledge_path]
		if(!(knowledge_info[HKT_ID] in researchable_knowledges))
			continue

		var/list/knowledge_data = get_knowledge_data(knowledge_path, shop, FALSE, HERETIC_KNOWLEDGE_SHOP)
		shop_knowledge += list(knowledge_data)

	data["knowledge_shop"] = shop_knowledge

	return data

/datum/antagonist/heretic/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	// AQUILA - tylko sam heretyk może klikać w swoim oknie (jak w bazowym ui_act z tg)
	if(usr != owner?.current)
		return

	switch(action)
		if("research")
			var/datum/heretic_knowledge/researched_path = text2path(params["path"])
			if(!ispath(researched_path, /datum/heretic_knowledge))
				CRASH("Heretic attempted to learn non-heretic_knowledge path! (Got: [researched_path || "invalid path"])")
			var/shop_category = params["category"]
			if(!researchable_knowledge(researched_path, shop_category))
				message_admins("Heretyk [key_name(owner)] prawdopodobnie próbował exploitu href, by zbadać niedostępną wiedzę!")
				CRASH("Heretic attempted to learn knowledge they can't learn! (Got: [researched_path])")
			if(ispath(researched_path, /datum/heretic_knowledge/ultimate) && can_ascend() != HERETIC_CAN_ASCEND)
				message_admins("Heretyk [key_name(owner)] prawdopodobnie próbował exploitu href, by zbadać wiedzę wniebowstąpienia bez wykonania celów!")
				CRASH("Heretic attempted to learn a final knowledge despite not being able to ascend!")


			if(!purchase_knowledge(researched_path, shop_category))
				return FALSE
			update_data_for_all_viewers()
			log_heretic_knowledge("[key_name(owner)] gained knowledge: [initial(researched_path.name)]")
			return TRUE

		// AQUILA - z bazowego ui_act tg: przycisk odrzucenia wezwania (własny cel)
		if("change_objectives")
			INVOKE_ASYNC(src, PROC_REF(submit_player_objective))
			return TRUE

/datum/antagonist/heretic/proc/researchable_knowledge(datum/heretic_knowledge/knowledge_path, shop_category = HERETIC_KNOWLEDGE_TREE)
	var/list/shop_list = heretic_shops[shop_category]
	if(!islist(shop_list))
		return FALSE
	var/list/knowledge_info = shop_list[knowledge_path]
	if(!islist(knowledge_info))
		return FALSE
	if(knowledge_info[HKT_ID] in get_researchable_knowledge())
		return TRUE
	return FALSE

/**
 * AQUILA - tg: /datum/antagonist/proc/submit_player_objective, u nas tylko dla heretyka.
 * Allows player to replace their objectives with a new one they wrote themselves.
 * Returns true if they did it successfully.
 * * retain_existing - If true, will just be added as a new objective instead of replacing existing ones.
 * * retain_escape - If true, will retain specifically 'escape alive' objectives (or similar)
 * * force - Skips the check about whether this antagonist is supposed to set its own objectives, for badminning
 */
/datum/antagonist/heretic/proc/submit_player_objective(retain_existing = FALSE, retain_escape = TRUE, force = FALSE)
	if (isnull(owner) || isnull(owner.current))
		return FALSE
	var/mob/living/owner_mob = owner.current
	if (!force && !can_assign_self_objectives)
		owner_mob.balloon_alert(owner_mob, "nie możesz tego zrobić!")
		return FALSE
	var/confirmed = tgui_alert(
		owner_mob,
		message = "Na pewno? Już nigdy nie dostąpisz wniebowstąpienia.",
		title = "Odrzucić wezwanie?",
		buttons = list("Tak", "Nie"),
	) == "Tak"
	if (!confirmed || QDELETED(src))
		return FALSE
	var/custom_objective_text = tgui_input_text(
		owner_mob,
		message = "Wpisz swój nowy cel.",
		title = "Własny cel",
		default = default_custom_objective,
		max_length = 300,
	)
	if (QDELETED(src) || QDELETED(owner_mob) || isnull(custom_objective_text) || !can_assign_self_objectives && !force)
		return FALSE // Some people take a long-ass time to type maybe they got dusted

	log_game("[key_name(owner_mob)] [retain_existing ? "" : "opted out of their original objectives and "]chose a custom objective: [custom_objective_text]")
	message_admins("[ADMIN_LOOKUPFLW(owner_mob)] wybiera własny cel antagonisty: [custom_objective_text]")

	var/datum/objective/custom/custom_objective = new()
	custom_objective.owner = owner
	custom_objective.explanation_text = custom_objective_text
	custom_objective.completed = TRUE

	if (retain_existing)
		objectives.Insert(1, custom_objective)
	else if (!retain_escape)
		objectives = list(custom_objective)
	else
		var/static/list/escape_objectives = list(
			/datum/objective/escape,
			/datum/objective/survive,
			/datum/objective/martyr,
		)
		for (var/datum/objective/check_objective in objectives)
			if (is_type_in_list(check_objective, escape_objectives))
				continue
			objectives -= check_objective
		objectives.Insert(1, custom_objective)

	can_assign_self_objectives = FALSE
	owner.announce_objectives()
	update_heretic_aura()
	update_data_for_all_viewers()
	return TRUE

/datum/antagonist/heretic/ui_status(mob/user, datum/ui_state/state)
	if(isnull(owner.current) || owner.current.stat == DEAD) // If the owner is dead, we can't show the UI.
		return UI_UPDATE
	return ..()

/datum/antagonist/heretic/greet()
	. = ..()
	if(silent || !owner.current)
		return
	if(stinger_sound)
		owner.current.playsound_local(get_turf(owner.current), stinger_sound, 100, FALSE, channel = CHANNEL_ANTAG_GREETING, pressure_affected = FALSE, use_reverb = FALSE)
	var/list/msg = list()
	msg += "<span class='big'>Jesteś <span class='bold umbra'>Heretykiem</span>!</span>"
	msg += "Księga szepcze, zakazana wiedza znów kroczy po świecie!"
	msg += "Najpierw wybierz ścieżkę w oknie Zakazanej Wiedzy - czytaj je uważnie, wyboru nie da się cofnąć!"
	msg += "Punkty wiedzy zdobywasz, wysysając wpływy i składając w ofierze osoby namierzone przez żywe serce."
	msg += "Runę transmutacji narysujesz długopisem, trzymając Uchwyt Mansusa w drugiej ręce."
	to_chat(owner.current, span_cult(msg.Join("\n")))
	owner.current.client?.tgui_panel?.give_antagonist_popup("Heretyk",
		"Wybierz ścieżkę, zbieraj wpływy i składaj ofiary, by poszerzać zakazaną wiedzę.")

/datum/antagonist/heretic/farewell()
	if(!silent && owner.current)
		to_chat(owner.current, span_userdanger("Twój umysł płonie, gdy nieziemska wiedza wymyka ci się z rąk!"))
	return ..()

/datum/antagonist/heretic/on_gain()
	generate_heretic_starting_knowledge(heretic_shops[HERETIC_KNOWLEDGE_START])
	if(!length(path_info))
		for(var/datum/heretic_knowledge_tree_column/path as anything in valid_subtypesof(/datum/heretic_knowledge_tree_column))
			path = new path()
			path_info += list(path.get_ui_data(src, HERETIC_KNOWLEDGE_START))
			qdel(path)

	if(give_objectives)
		var/datum/objective/pick_path/pick_a_path = new()
		pick_a_path.owner = owner
		objectives += pick_a_path

	for(var/starting_knowledge in GLOB.heretic_start_knowledge)
		gain_knowledge(starting_knowledge, HERETIC_KNOWLEDGE_START, update = FALSE)

	owner.current.AddElement(/datum/element/rust_healing, FALSE, 1.5, 5)

	ADD_TRAIT(owner, TRAIT_SEE_BLESSED_TILES, REF(src))
	addtimer(CALLBACK(src, PROC_REF(passive_influence_gain)), passive_gain_timer) // Gain +1 knowledge every 20 minutes.

	return ..()

/datum/antagonist/heretic/on_removal()
	if(owner.current)
		for(var/knowledge_path in researched_knowledge)
			var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_path][HKT_INSTANCE]
			knowledge.on_lose(owner.current, src)
			QDEL_NULL(researched_knowledge[knowledge_path][HKT_INSTANCE])
		owner.current.RemoveElement(/datum/element/rust_healing, FALSE, 1.5, 5)
		owner.current.cut_overlay(eldritch_overlay)

	REMOVE_TRAIT(owner, TRAIT_SEE_BLESSED_TILES, REF(src))
	QDEL_NULL(heretic_path)
	return ..()

/datum/antagonist/heretic/apply_innate_effects(mob/living/mob_override)
	var/mob/living/our_mob = mob_override || owner.current
	handle_clown_mutation(our_mob, "Przekazana ci pradawna wiedza pozwala przezwyciężyć klaunią naturę i używać broni, nie raniąc samego siebie.")
	our_mob.add_faction(FACTION_HERETIC)
	our_mob.apply_status_effect(/datum/status_effect/grouped/heretic_dreams, type)
	// AQUILA - ikonka heretyka w HUD-zie antagonistów i obrazy widoczne tylko dla heretyków (wpływy, statusy)
	add_antag_hud(ANTAG_HUD_HERETIC, "heretic", our_mob)
	update_heretic_alt_appearances(our_mob)

	if(!issilicon(our_mob))
		GLOB.reality_smash_track.add_tracked_mind(owner)

	ADD_TRAIT(our_mob, TRAIT_MANSUS_TOUCHED, REF(src))
	// AQUILA - u nas nie ma COMSIG_USER_ITEM_INTERACTION; runę rysuje się kliknięciem długopisem w podłogę (afterattack)
	RegisterSignal(our_mob, COMSIG_MOB_ITEM_AFTERATTACK, PROC_REF(on_item_afterattack))
	RegisterSignal(our_mob, COMSIG_LIVING_POST_FULLY_HEAL, PROC_REF(after_fully_healed))
	RegisterSignal(our_mob, COMSIG_PARENT_EXAMINE, PROC_REF(on_heretic_examine))
	RegisterSignal(our_mob, COMSIG_MOB_LOGIN, PROC_REF(on_login))

	RegisterSignals(
		our_mob,
		list(SIGNAL_ADDTRAIT(TRAIT_HERETIC_AURA_HIDDEN), SIGNAL_REMOVETRAIT(TRAIT_HERETIC_AURA_HIDDEN)),
		PROC_REF(update_heretic_aura)
	)
	RegisterSignal(our_mob, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(add_aura_overlay))
	our_mob.update_appearance(UPDATE_OVERLAYS)

/datum/antagonist/heretic/remove_innate_effects(mob/living/mob_override)
	var/mob/living/our_mob = mob_override || owner.current
	handle_clown_mutation(our_mob, removing = FALSE)
	our_mob.remove_faction(FACTION_HERETIC)
	our_mob.remove_status_effect(/datum/status_effect/grouped/heretic_dreams, type)
	remove_antag_hud(ANTAG_HUD_HERETIC, our_mob)
	update_heretic_alt_appearances(our_mob, force_remove = TRUE)

	if(owner in GLOB.reality_smash_track.tracked_heretics)
		GLOB.reality_smash_track.remove_tracked_mind(owner)

	REMOVE_TRAIT(our_mob, TRAIT_MANSUS_TOUCHED, REF(src))
	UnregisterSignal(
		our_mob,
		list(
			COMSIG_MOB_ITEM_AFTERATTACK,
			COMSIG_LIVING_POST_FULLY_HEAL,
			COMSIG_PARENT_EXAMINE,
			COMSIG_MOB_LOGIN,
			COMSIG_ATOM_UPDATE_OVERLAYS,
			SIGNAL_ADDTRAIT(TRAIT_HERETIC_AURA_HIDDEN),
			SIGNAL_REMOVETRAIT(TRAIT_HERETIC_AURA_HIDDEN),
		)
	)
	our_mob.update_appearance(UPDATE_OVERLAYS)

/// AQUILA - po przelogowaniu odświeżamy obrazy widoczne tylko dla heretyków
/datum/antagonist/heretic/proc/on_login(mob/source)
	SIGNAL_HANDLER
	update_heretic_alt_appearances(source)

/// Removes the ability to blade break, removes cloak of shadows and removes the cap on how many blades you can craft
/datum/antagonist/heretic/proc/disable_blade_breaking()
	if(unlimited_blades)
		return
	var/mob/heretic_mob = owner.current
	unlimited_blades = TRUE
	to_chat(heretic_mob, span_boldwarning("Zyskałeś wielką moc. Mansus nie pozwoli ci już łamać ostrzy, ale możesz tworzyć ich, ile zechcesz."))
	heretic_mob.balloon_alert(heretic_mob, "łamanie ostrzy wyłączone!")
	update_heretic_aura()
	var/datum/action/cooldown/spell/shadow_cloak/cloak_spell = locate() in heretic_mob.actions
	cloak_spell?.Remove(heretic_mob)

/datum/antagonist/heretic/proc/add_aura_overlay(mob/living/source, list/overlays)
	SIGNAL_HANDLER
	if(!should_show_aura())
		return
	overlays += eldritch_overlay
	// AQUILA - bez nakładki emissive: u nas na mobie rysowała się jako biały prostokąt

/// Adds an overlay to the heretic
/datum/antagonist/heretic/proc/update_heretic_aura()
	SIGNAL_HANDLER
	if(!QDELETED(owner?.current))
		owner.current.update_appearance(UPDATE_OVERLAYS)

/datum/antagonist/heretic/proc/should_show_aura()
	if(!can_assign_self_objectives)
		return FALSE // We spurned the offer of the Mansus :(
	if(!unlimited_blades || HAS_TRAIT(owner.current, TRAIT_HERETIC_AURA_HIDDEN))
		return FALSE // No aura if we have the trait or is too early still
	if(feast_of_owls)
		return FALSE // No use in giving the aura to a heretic that can't ascend
	if(heretic_path?.route == PATH_LOCK)
		return FALSE // Lock heretics never get this aura
	return TRUE

/datum/antagonist/heretic/proc/on_heretic_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!should_show_aura())
		return
	var/potential_string = "Wokół tej postaci wiruje trzaskający, zielony wir energii."
	if(can_ascend() == HERETIC_CAN_ASCEND)
		potential_string += " Zrzuca z siebie śmiertelną powłokę!"
	examine_list += span_green(potential_string)

/datum/antagonist/heretic/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	if(old_body == new_body) // if they were using a temporary body
		return

	for(var/knowledge_path in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_path][HKT_INSTANCE]
		knowledge.on_lose(old_body, src)
		knowledge.on_gain(new_body, src)

/*
 * AQUILA - tg: sygnał COMSIG_USER_ITEM_INTERACTION; u nas COMSIG_MOB_ITEM_AFTERATTACK.
 *
 * If a heretic is holding a pen in their main hand,
 * and have mansus grasp active in their offhand,
 * they're able to draw a transmutation rune.
 */
/datum/antagonist/heretic/proc/on_item_afterattack(mob/living/source, atom/target, obj/item/weapon, proximity_flag, click_parameters)
	SIGNAL_HANDLER
	if(!IS_WRITING_UTENSIL(weapon))
		return NONE
	if(!isturf(target) || !isliving(source) || !proximity_flag)
		return NONE

	var/obj/item/offhand = source.get_inactive_held_item()
	if(QDELETED(offhand) || !istype(offhand, /obj/item/melee/spell_hand/mansus_fist))
		return NONE

	try_draw_rune(source, target, additional_checks = CALLBACK(src, PROC_REF(check_mansus_grasp_offhand), source))
	return COMPONENT_CANCEL_ATTACK_CHAIN

/**
 * Attempt to draw a rune on [target_turf].
 *
 * Arguments
 * * user - the mob drawing the rune
 * * target_turf - the place the rune's being drawn
 * * drawing_time - how long the do_after takes to make the rune
 * * additional checks - optional callbacks to be ran while drawing the rune
 */
/datum/antagonist/heretic/proc/try_draw_rune(mob/living/user, turf/target_turf, drawing_time = 20 SECONDS, additional_checks)
	for(var/turf/nearby_turf as anything in RANGE_TURFS(1, target_turf))
		if(!isopenturf(nearby_turf) || is_type_in_typecache(nearby_turf, blacklisted_rune_turfs))
			target_turf.balloon_alert(user, "nie można tu postawić runy!")
			return

	if(locate(/obj/effect/heretic_rune) in range(3, target_turf))
		target_turf.balloon_alert(user, "za blisko innej runy!")
		return

	if(drawing_rune)
		target_turf.balloon_alert(user, "już kreślisz runę!")
		return

	INVOKE_ASYNC(src, PROC_REF(draw_rune), user, target_turf, drawing_time, additional_checks)

/**
 * The actual process of drawing a rune.
 *
 * Arguments
 * * user - the mob drawing the rune
 * * target_turf - the place the rune's being drawn
 * * drawing_time - how long the do_after takes to make the rune
 * * additional checks - optional callbacks to be ran while drawing the rune
 */
/datum/antagonist/heretic/proc/draw_rune(mob/living/user, turf/target_turf, drawing_time = 20 SECONDS, additional_checks)
	drawing_rune = TRUE

	var/rune_colour = GLOB.heretic_path_to_color[heretic_path?.route || PATH_START]
	target_turf.balloon_alert(user, "kreślisz runę...")
	var/obj/effect/temp_visual/drawing_heretic_rune/drawing_effect
	if (drawing_time < (10 SECONDS))
		drawing_effect = new /obj/effect/temp_visual/drawing_heretic_rune/fast(target_turf, rune_colour)
	else
		drawing_effect = new(target_turf, rune_colour)

	if(!do_after(user, drawing_time, target = target_turf, extra_checks = additional_checks, hidden = TRUE))
		target_turf.balloon_alert(user, "przerwano!")
		new /obj/effect/temp_visual/drawing_heretic_rune/fail(target_turf, rune_colour)
		qdel(drawing_effect)
		drawing_rune = FALSE
		return

	qdel(drawing_effect)
	target_turf.balloon_alert(user, "runa gotowa")
	new /obj/effect/heretic_rune/big(target_turf, rune_colour)
	drawing_rune = FALSE

/**
 * Callback to check that the user's still got their Mansus Grasp out when drawing a rune.
 *
 * Arguments
 * * user - the mob drawing the rune
 */
/datum/antagonist/heretic/proc/check_mansus_grasp_offhand(mob/living/user)
	var/obj/item/offhand = user.get_inactive_held_item()
	return !QDELETED(offhand) && istype(offhand, /obj/item/melee/spell_hand/mansus_fist)

/// Signal proc for [COMSIG_LIVING_POST_FULLY_HEAL],
/// Gives the heretic aliving heart on aheal or organ refresh
/datum/antagonist/heretic/proc/after_fully_healed(mob/living/source, heal_flags)
	SIGNAL_HANDLER

	if(heal_flags & (HEAL_REFRESH_ORGANS|HEAL_ADMIN))
		var/datum/heretic_knowledge/living_heart/heart_knowledge = get_knowledge(/datum/heretic_knowledge/living_heart)
		if(heart_knowledge && has_living_heart() == HERETIC_NO_LIVING_HEART)
			heart_knowledge.on_research(source, src)

/**
 * Creates an animation of the item slowly lifting up from the floor with a colored outline, then slowly drifting back down.
 * Arguments:
 * * outline_color: Default is between pink and light blue, is the color of the outline filter.
 * * ray_color: Null by default. If not set, just copies outline. Used for the ray filter.
 * * anim_time: Total time of the animation. Split into two different calls.
 * * do_float: Lets you disable the sprite floating up and down.
 * * do_layer: Lets you disable the layering increase.
 */
/obj/proc/gender_reveal(
	outline_color = null,
	ray_color = null,
	anim_time = 10 SECONDS,
	do_float = TRUE,
	do_layer = TRUE,
)

	var/og_layer
	if(do_layer)
		// Layering above to stand out!
		og_layer = layer
		layer = ABOVE_MOB_LAYER

	// Slowly floats up, then slowly goes down.
	if(do_float)
		animate(src, pixel_y = 12, time = anim_time * 0.5, easing = QUAD_EASING | EASE_OUT)
		animate(pixel_y = 0, time = anim_time * 0.5, easing = QUAD_EASING | EASE_IN)

	// Adding a cool outline effect
	if(outline_color)
		add_filter("gender_reveal_outline", 3, list("type" = "outline", "color" = outline_color, "size" = 0.5))
		// Animating it!
		var/gay_filter = get_filter("gender_reveal_outline")
		animate(gay_filter, alpha = 110, time = 1.5 SECONDS, loop = -1)
		animate(alpha = 40, time = 2.5 SECONDS)

	// Adding a cool ray effect
	if(ray_color)
		add_filter("gender_reveal_ray", 1, list(
				type = "rays",
				size = 45,
				color = ray_color,
				density = 6
			))
		// Animating it!
		var/ray_filter = get_filter("gender_reveal_ray")
		// I understand nothing but copypaste saves lives
		animate(ray_filter, offset = 100, time = 30 SECONDS, loop = -1, flags = ANIMATION_PARALLEL)

	addtimer(CALLBACK(src, PROC_REF(remove_gender_reveal_fx), og_layer), anim_time)

/**
 * Removes the non-animate effects from above proc
 */
/obj/proc/remove_gender_reveal_fx(og_layer)
	remove_filter("gender_reveal_outline")
	remove_filter("gender_reveal_ray")
	if(!isnull(og_layer))
		layer = og_layer

/**
 * Create our objectives for our heretic.
 */
/datum/antagonist/heretic/proc/forge_primary_objectives()
	for(var/datum/objective/pick_path/filler in objectives)
		filler.owner = null
		objectives -= filler
		qdel(filler)

	var/datum/objective/heretic_research/research_objective = new(heretic_research_tree = heretic_shops)
	research_objective.owner = owner
	objectives += research_objective

	// AQUILA - u nas nie ma GLOB.alive_player_list ani flag prac; szefowie to GLOB.command_positions
	var/num_heads = 0
	for(var/mob/living/player in GLOB.player_list)
		if(player.stat == DEAD || !player.mind)
			continue
		if(player.mind.assigned_role in GLOB.command_positions)
			num_heads++

	var/datum/objective/minor_sacrifice/sac_objective = new()
	sac_objective.owner = owner
	if(num_heads < 2) // They won't get major sacrifice, so bump up minor sacrifice a bit
		sac_objective.target_amount = 5
		sac_objective.update_explanation_text()
	objectives += sac_objective

	if(num_heads >= 2)
		var/datum/objective/major_sacrifice/other_sac_objective = new()
		other_sac_objective.owner = owner
		objectives += other_sac_objective

/**
 * Add [target] as a sacrifice target for the heretic.
 * Generates a preview image and associates it with a weakref of the mob.
 */
/datum/antagonist/heretic/proc/add_sacrifice_target(mob/living/carbon/human/target)

	var/image/target_image = image(icon = target.icon, icon_state = target.icon_state)
	target_image.overlays = target.overlays

	LAZYSET(sac_targets, target, target_image)
	RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(on_target_deleted))
	all_sac_targets += target.real_name

/**
 * Removes [target] from the heretic's sacrifice list.
 * Returns FALSE if no one was removed, TRUE otherwise
 */
/datum/antagonist/heretic/proc/remove_sacrifice_target(mob/living/carbon/human/target)
	if(!(target in sac_targets))
		return FALSE

	LAZYREMOVE(sac_targets, target)
	UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	return TRUE

/**
 * Signal proc for [COMSIG_PARENT_QDELETING] registered on sac targets
 * if sacrifice targets are deleted (gibbed, dusted, whatever), free their slot and reference
 */
/datum/antagonist/heretic/proc/on_target_deleted(mob/living/carbon/human/source)
	SIGNAL_HANDLER

	remove_sacrifice_target(source)

/**
 * Increments knowledge by one.
 * Used in callbacks for passive gain over time.
 */
/datum/antagonist/heretic/proc/passive_influence_gain()
	if(QDELETED(src) || !owner)
		return
	adjust_knowledge_points(1)
	if(owner.current && !IS_UNCONSCIOUS(owner.current))
		to_chat(owner.current, "[span_hear("Słyszysz szept...")] [span_mansus(pick_list(HERETIC_INFLUENCE_FILE, "drain_message"))]")
	addtimer(CALLBACK(src, PROC_REF(passive_influence_gain)), passive_gain_timer)

/datum/antagonist/heretic/proc/adjust_knowledge_points(amount, update = TRUE)
	knowledge_points = max(0, knowledge_points + amount) // Don't allow negative knowledge points
	knowledge_gained += max(0, amount)
	if(knowledge_gained > points_to_aura && !unlimited_blades)
		disable_blade_breaking()
	if(update)
		update_data_for_all_viewers()

/datum/antagonist/heretic/roundend_report()
	var/list/parts = list()

	var/succeeded = TRUE

	parts += printplayer(owner)
	parts += "<b>Złożone ofiary:</b> [total_sacrifices]"
	parts += "Cele ofiarne heretyka: [english_list(all_sac_targets, nothing_text = "nikt", and_text = " i ")]."
	if(length(objectives))
		var/count = 1
		for(var/datum/objective/objective as anything in objectives)
			if(objective.check_completion())
				parts += "<b>Cel nr [count]</b>: [objective.explanation_text] [span_greentext("Sukces!")]"
			else
				parts += "<b>Cel nr [count]</b>: [objective.explanation_text] [span_redtext("Porażka.")]"
				succeeded = FALSE
			count++
	if(feast_of_owls)
		parts += span_greentext("Wyrzekł się wniebowstąpienia")
	if(ascended)
		parts += span_greentext(span_big("HERETYK DOSTĄPIŁ WNIEBOWSTĄPIENIA!"))

	else
		if(succeeded)
			parts += span_greentext("Heretyk odniósł sukces, ale nie dostąpił wniebowstąpienia!")
		else
			parts += span_redtext("Heretyk poniósł porażkę.")

	parts += "<b>Zbadana wiedza:</b> "

	var/list/string_of_knowledge = list()

	for(var/knowledge_path in researched_knowledge)
		var/list/knowledge_info = researched_knowledge[knowledge_path]
		var/datum/heretic_knowledge/knowledge = knowledge_info[HKT_INSTANCE]
		string_of_knowledge += knowledge.name

	parts += english_list(string_of_knowledge, and_text = " i ")

	return parts.Join("<br>")

/datum/antagonist/heretic/get_admin_commands()
	. = ..()

	switch(has_living_heart())
		if(HERETIC_NO_LIVING_HEART)
			.["Daj Żywe Serce"] = CALLBACK(src, PROC_REF(give_living_heart))
		if(HERETIC_HAS_LIVING_HEART)
			.["Dodaj cel serca (oznaczony mob)"] = CALLBACK(src, PROC_REF(add_marked_as_target))
			.["Usuń cel serca"] = CALLBACK(src, PROC_REF(remove_target))

	.["Zmień punkty wiedzy"] = CALLBACK(src, PROC_REF(admin_change_points))
	.["Daj skupienie"] = CALLBACK(src, PROC_REF(admin_give_focus))

/**
 * Admin proc for giving a heretic a Living Heart easily.
 */
/datum/antagonist/heretic/proc/give_living_heart(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("Nie powinieneś tego używać!"))
		return

	var/datum/heretic_knowledge/living_heart/heart_knowledge = get_knowledge(/datum/heretic_knowledge/living_heart)
	if(!heart_knowledge)
		to_chat(admin, span_warning("Heretyk z jakiegoś powodu nie ma wiedzy o żywym sercu. Co?"))
		return

	heart_knowledge.on_research(owner.current, src)

/**
 * Admin proc for adding a marked mob to a heretic's sac list.
 */
/datum/antagonist/heretic/proc/add_marked_as_target(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("Nie powinieneś tego używać!"))
		return

	var/mob/living/carbon/human/new_target = admin.client?.holder.marked_datum
	if(!istype(new_target))
		to_chat(admin, span_warning("Aby to zrobić, musisz oznaczyć człowieka!"))
		return

	if(tgui_alert(admin, "Powiadomić heretyka, że jego cele się zmieniły?", "Szepty Mansusa", list("Tak", "Nie")) == "Tak")
		to_chat(owner.current, span_danger("Mansus zmienił twoje cele. Idź ich szukać!"))
		to_chat(owner.current, span_danger("[new_target.real_name], [new_target.mind?.assigned_role || "człowiek"]."))

	add_sacrifice_target(new_target)

/**
 * Admin proc for removing a mob from a heretic's sac list.
 */
/datum/antagonist/heretic/proc/remove_target(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("Nie powinieneś tego używać!"))
		return

	var/list/removable = list()
	for(var/mob/living/carbon/human/old_target as anything in sac_targets)
		removable[old_target.name] = old_target

	var/name_of_removed = tgui_input_list(admin, "Wybierz człowieka do usunięcia", "Kogo oszczędzić", removable)
	if(QDELETED(src) || !admin.client?.holder || isnull(name_of_removed))
		return
	var/mob/living/carbon/human/chosen_target = removable[name_of_removed]
	if(QDELETED(chosen_target) || !ishuman(chosen_target))
		return

	if(!remove_sacrifice_target(chosen_target))
		to_chat(admin, span_warning("Nie udało się usunąć [name_of_removed] z listy ofiar [owner]. Może już i tak go na niej nie ma."))
		return

	if(tgui_alert(admin, "Powiadomić heretyka, że jego cele się zmieniły?", "Szepty Mansusa", list("Tak", "Nie")) == "Tak")
		to_chat(owner.current, span_danger("Mansus zmienił twoje cele."))

/**
 * Admin proc for easily adding / removing knowledge points.
 */
/datum/antagonist/heretic/proc/admin_change_points(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("Nie powinieneś tego używać!"))
		return

	var/change_num = tgui_input_number(admin, "Dodaj lub odejmij punkty wiedzy", "Punkty", 0, 100, -100)
	if(!change_num || QDELETED(src))
		return

	adjust_knowledge_points(change_num)
	message_admins("[key_name_admin(admin)] zmienia punkty wiedzy [key_name_admin(owner)] o [change_num].")

/**
 * Admin proc for giving a heretic a focus.
 */
/datum/antagonist/heretic/proc/admin_give_focus(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, span_warning("Nie powinieneś tego używać!"))
		return

	var/mob/living/pawn = owner.current
	pawn.equip_to_slot_if_possible(new /obj/item/clothing/neck/heretic_focus(get_turf(pawn)), ITEM_SLOT_NECK, TRUE, TRUE)
	to_chat(pawn, span_mansus("Mansus zesłał ci skupienie."))

/datum/antagonist/heretic/antag_panel_data()
	var/list/string_of_knowledge = list()

	for(var/knowledge_path in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_path][HKT_INSTANCE]
		if(istype(knowledge, /datum/heretic_knowledge/ultimate))
			string_of_knowledge += "<b>[knowledge.name]</b>"
		else
			string_of_knowledge += knowledge.name

	return "<br><b>Zbadana wiedza:</b><br>[english_list(string_of_knowledge, and_text = " i ")]<br>"

/datum/antagonist/heretic/antag_panel_objectives()
	. = ..()

	. += "<br>"
	. += "<i><b>Obecne cele:</b></i><br>"
	if(LAZYLEN(sac_targets))
		for(var/mob/living/carbon/human/target as anything in sac_targets)
			. += " - <b>[target.real_name]</b>, [target.mind?.assigned_role || "człowiek"].<br>"

	else
		. += "<i>Brak!</i><br>"
	. += "<br>"

/datum/antagonist/heretic/proc/purchase_knowledge(datum/heretic_knowledge/knowledge_type, category = HERETIC_KNOWLEDGE_TREE, update = TRUE)
	var/list/shop_list = heretic_shops[category]
	if(!shop_list)
		stack_trace("Heretic attempted to learn knowledge from a non-existent category! (Got: [category])")
		return FALSE

	var/list/knowledge_data = shop_list[knowledge_type]
	if(!knowledge_data)
		stack_trace("[type] purchase_knowledge was given a path that doesn't exist in the heretic [category] knowledge list! (Got: [knowledge_type])")
		return FALSE

	var/cost = knowledge_data[HKT_COST]
	if(cost > knowledge_points)
		return FALSE
	if(!gain_knowledge(knowledge_type, category, update))
		return FALSE
	adjust_knowledge_points(-cost, FALSE)
	return TRUE
/**
 * Learns the passed [typepath] of knowledge, creating a knowledge datum
 * and adding it to our researched knowledge list.
 *
 * Returns TRUE if the knowledge was added successfully. FALSE otherwise.
 */
/datum/antagonist/heretic/proc/gain_knowledge(datum/heretic_knowledge/knowledge_type, category = HERETIC_KNOWLEDGE_TREE, update = TRUE)
	var/list/knowledge_list = heretic_shops[category]
	if(!ispath(knowledge_type))
		stack_trace("[type] gain_knowledge was given an invalid path! (Got: [knowledge_type])")
		return FALSE
	var/list/knowledge_data = knowledge_list[knowledge_type]
	if(!islist(knowledge_data))
		knowledge_data = make_knowledge_entry(knowledge_type, null, category)
		heretic_shops[category][knowledge_type] = knowledge_data
	if(get_knowledge(knowledge_type))
		return FALSE
	var/datum/heretic_knowledge/initialized_knowledge = new knowledge_type()
	if(!initialized_knowledge.pre_research(owner.current, src))
		qdel(initialized_knowledge)
		return FALSE
	researched_knowledge[knowledge_type] = knowledge_data.Copy()
	researched_knowledge[knowledge_type][HKT_INSTANCE] = initialized_knowledge
	researched_knowledge[knowledge_type][HKT_CATEGORY] = category

	// case for letting you modify depth post-purchase
	var/purchased_depth = knowledge_data[HKT_PURCHASED_DEPTH]
	if(purchased_depth != 0 && isnum(purchased_depth))
		researched_knowledge[knowledge_type][HKT_DEPTH] = purchased_depth

	knowledge_list -= knowledge_type

	initialized_knowledge.on_research(owner.current, src)
	if(update)
		update_data_for_all_viewers()

	return TRUE

/**
 * Get a list of all knowledge IDs that we can currently research.
 */
/datum/antagonist/heretic/proc/get_researchable_knowledge()
	var/list/researchable_knowledge = list()
	var/list/banned_knowledge = list()
	for(var/knowledge_type in researched_knowledge)
		var/list/knowledge_info = researched_knowledge[knowledge_type]
		researchable_knowledge |= knowledge_info[HKT_NEXT]
		banned_knowledge |= knowledge_info[HKT_BAN]
		banned_knowledge |= knowledge_type
	researchable_knowledge -= banned_knowledge
	return researchable_knowledge

/**
 * Get a list of all knowledge datums that we've researched.
 */
/datum/antagonist/heretic/proc/get_researched_knowledge()
	var/list/knowledge_list = list()
	for(var/knowledge_type in researched_knowledge)
		knowledge_list += researched_knowledge[knowledge_type][HKT_INSTANCE]
	return knowledge_list

/**
 * Get a list of all knowledge datums that we've researched in a specific category.
 */
/datum/antagonist/heretic/proc/get_researched_knowledge_by_category(category_type)
	var/list/knowledge_list = list()
	for(var/knowledge_type in researched_knowledge)
		if(researched_knowledge[knowledge_type][HKT_CATEGORY] == category_type)
			knowledge_list += researched_knowledge[knowledge_type][HKT_INSTANCE]
	return knowledge_list


/**
 * Check if the wanted type-path is in the list of research knowledge.
 */
/datum/antagonist/heretic/proc/get_knowledge(wanted)
	var/list/knowledge_data = researched_knowledge[wanted]
	if(knowledge_data)
		return knowledge_data[HKT_INSTANCE]
	return null

/// Makes our heretic more able to rust things.
/// if side_path_only is set to TRUE, this function does nothing for rust heretics.
/datum/antagonist/heretic/proc/increase_rust_strength(side_path_only=FALSE)
	if(side_path_only && get_knowledge(/datum/heretic_knowledge/limited_amount/starting/base_rust))
		return

	rust_strength++

/**
 * Get a list of all rituals this heretic can invoke on a rune.
 * Iterates over all of our knowledge and, if we can invoke it, adds it to our list.
 *
 * Returns an associated list of [knowledge name] to [knowledge datum] sorted by knowledge priority.
 */
/datum/antagonist/heretic/proc/get_rituals()
	var/list/rituals = list()

	for(var/knowledge_path in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_path][HKT_INSTANCE]
		if(!knowledge.can_be_invoked(src))
			continue
		rituals += knowledge

	return sortTim(rituals, GLOBAL_PROC_REF(cmp_heretic_knowledge))

/**
 * Checks to see if our heretic can ccurrently ascend.
 *
 * Returns FALSE if not all of our objectives are complete, or TRUE otherwise.
 */
/datum/antagonist/heretic/proc/can_ascend()
	if(feast_of_owls)
		return "Sowy odebrały ci prawo do wniebowstąpienia." // We sold our ambition for immediate power :/
	if(!can_assign_self_objectives)
		return "Mansus cię odrzucił (brak wniebowstąpienia)."
	for(var/datum/objective/must_be_done as anything in objectives)
		if(!must_be_done.check_completion())
			return "Przed wniebowstąpieniem musisz wykonać wszystkie cele."
	var/config_time = CONFIG_GET(number/minimum_ascension_time) MINUTES

	var/time_passed = STATION_TIME_PASSED()
	if(config_time >= time_passed)
		return "Za wcześnie, musisz poczekać jeszcze [DisplayTimeText(config_time - time_passed)]."
	return HERETIC_CAN_ASCEND

/**
 * Helper to determine if a Heretic
 * - Has a Living Heart
 * - Has a an organ in the correct slot that isn't a living heart
 * - Is missing the organ they need in the slot to make a living heart
 *
 * Returns HERETIC_NO_HEART_ORGAN if they have no heart (organ) at all,
 * Returns HERETIC_NO_LIVING_HEART if they have a heart (organ) but it's not a living one,
 * and returns HERETIC_HAS_LIVING_HEART if they have a living heart
 */
/datum/antagonist/heretic/proc/has_living_heart()
	var/obj/item/organ/our_living_heart = owner.current?.getorganslot(living_heart_organ_slot)
	if(!our_living_heart)
		return HERETIC_NO_HEART_ORGAN

	if(!HAS_TRAIT(our_living_heart, TRAIT_LIVING_HEART))
		return HERETIC_NO_LIVING_HEART

	return HERETIC_HAS_LIVING_HEART

/datum/objective/pick_path
	name = "pick a path"
	explanation_text = "Wybierz ścieżkę, którą podążysz."

/// Heretic's minor sacrifice objective. "Minor sacrifices" includes anyone.
/datum/objective/minor_sacrifice
	name = "minor sacrifice"

/datum/objective/minor_sacrifice/New(text)
	. = ..()
	target_amount = 4
	update_explanation_text()

/datum/objective/minor_sacrifice/update_explanation_text()
	. = ..()
	explanation_text = "Złóż w ofierze co najmniej [target_amount] członków załogi."

/datum/objective/minor_sacrifice/check_completion()
	var/datum/antagonist/heretic/heretic_datum = owner?.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return FALSE
	return completed || (heretic_datum.total_sacrifices >= target_amount)

/// Heretic's major sacrifice objective. "Major sacrifices" are heads of staff.
/datum/objective/major_sacrifice
	name = "major sacrifice"
	target_amount = 1
	explanation_text = "Złóż w ofierze jednego szefa działu."

/datum/objective/major_sacrifice/check_completion()
	var/datum/antagonist/heretic/heretic_datum = owner?.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return FALSE
	return completed || (heretic_datum.high_value_sacrifices >= target_amount)

/// Heretic's research objective. "Research" is heretic knowledge nodes (You start with some).
/datum/objective/heretic_research
	name = "research"
	target_amount = 1 // You spawn with 1 point

/datum/objective/heretic_research/New(text, list/heretic_research_tree = list())
	. = ..()

	// Factor in the length of the main path
	target_amount += length(heretic_research_tree[HERETIC_KNOWLEDGE_TREE]) || 10
	// Factor in base research we spawn with (otherwise it'd be too easy)
	target_amount += length(GLOB.heretic_start_knowledge)
	// Factor in free knowledge, no challenge there
	target_amount += CEILING(length(heretic_research_tree[HERETIC_KNOWLEDGE_DRAFT]) / 3, 1) || 4

	// The actual challenge factor is introduced here, adding a random amount of additional knowledge needed
	target_amount += rand(2, 4)

	update_explanation_text()

/datum/objective/heretic_research/update_explanation_text()
	. = ..()
	explanation_text = "Zbadaj co najmniej [target_amount] wiedzy z Mansusa. Na start masz zbadanych: [length(GLOB.heretic_start_knowledge)]."

/datum/objective/heretic_research/check_completion()
	var/datum/antagonist/heretic/heretic_datum = owner?.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return FALSE
	return completed || (length(heretic_datum.researched_knowledge) >= target_amount)

/datum/objective/heretic_summon
	name = "summon monsters"
	target_amount = 2
	explanation_text = "Przywołaj do tego świata 2 potwory z Mansusa."
	/// The total number of summons the objective owner has done
	var/num_summoned = 0

/datum/objective/heretic_summon/check_completion()
	return completed || (num_summoned >= target_amount)

/datum/outfit/heretic
	name = "Heretic (Preview only)"

	suit = /obj/item/clothing/suit/hooded/cultrobes/eldritch/rust
	head = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust
	r_hand = /obj/item/melee/spell_hand/mansus_fist
