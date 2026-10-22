// AQUILA - warstwa zgodności dla wampira z BeeStation. Nowe akcje Bee (cooldown_time, on_activate,
// update_buttons, set_click_ability) przepięte na nasze stare /datum/action/cooldown.
// U nas icon_icon to plik ikony zdolności, a button_icon to plik TŁA (w Bee: button_icon i background_icon).

/datum/action/vampire
	parent_type = /datum/action/cooldown
	/// Bee: typ abstrakcyjny, którego nie dajemy graczom
	var/abstract_type = /datum/action/vampire
	/// Kursor na czas wybierania celu
	var/ranged_mousepointer

/datum/action/vampire/Trigger()
	if(!owner)
		return FALSE
	if(!is_available(TRUE))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER, src) & COMPONENT_ACTION_BLOCK_TRIGGER)
		return FALSE
	INVOKE_ASYNC(src, PROC_REF(on_activate), owner, null)
	return TRUE

/datum/action/vampire/IsAvailable()
	return is_available()

/// Bee: czy akcję można teraz użyć
/datum/action/vampire/proc/is_available(feedback = FALSE)
	return next_use_time <= world.time

/// Bee: właściwe działanie po kliknięciu przycisku
/datum/action/vampire/proc/on_activate(mob/user, atom/target)
	return

/// Bee: odświeża przycisk
/datum/action/vampire/proc/update_buttons(force = FALSE)
	UpdateButtonIcon(force = force)

/// Bee: odnowienie z opcjonalnym czasem
/datum/action/vampire/proc/start_cooldown(override_cooldown_time)
	next_use_time = world.time + (isnum(override_cooldown_time) ? override_cooldown_time : cooldown_time)
	if(next_use_time > world.time)
		button.maptext = MAPTEXT("<b>[round((next_use_time - world.time) / 10, 0.1)]</b>")
		START_PROCESSING(SSfastprocess, src)
	update_buttons()

/datum/action/vampire/StartCooldown()
	start_cooldown()

/datum/action/vampire/proc/reset_next_use_time()
	next_use_time = 0
	button.maptext = ""
	update_buttons()

/datum/action/vampire/proc/set_click_ability(mob/on_who)
	on_who.click_intercept = src
	if(ranged_mousepointer && on_who.client)
		on_who.client.mouse_pointer_icon = ranged_mousepointer
	update_buttons()
	return TRUE

/datum/action/vampire/proc/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	if(!on_who)
		return FALSE
	if(on_who.click_intercept == src)
		on_who.click_intercept = null
	if(ranged_mousepointer)
		on_who.update_mouse_pointer()
	update_buttons()
	return TRUE

/// Kliknięcie w cel, gdy akcja przechwytuje kliknięcia. TRUE = kliknięcie zużyte.
/datum/action/vampire/proc/InterceptClickOn(mob/living/clicker, params, atom/target)
	return FALSE

/datum/action/vampire/Remove(mob/remove_from)
	if(remove_from?.click_intercept == src)
		unset_click_ability(remove_from)
	return ..()

// Obrażenia pięści: w Bee siedzą na rękach (unarmed_damage), u nas na gatunku (punchdamage)

/mob/living/carbon/human
	/// AQUILA - premia do obrażeń ciosów pięścią (dolicza ją species.dm przy uderzeniu)
	var/unarmed_damage_bonus = 0

/// Bee: dodaje obrażenia ciosów obu rąk; u nas jedna premia do ciosu
/mob/living/carbon/human/proc/add_unarmed_damage_to_arms(amount)
	unarmed_damage_bonus += amount

/proc/examine_block(str)
	return EXAMINE_BLOCK(str)

// HUD drużyny: w Bee add_team_hud() i alternatywne wyglądy, u nas wspólny atom_hud ANTAG_HUD_VAMPIRE
// (widoczny dla wampirów i wasali) z ikonami z aquila/icons/vampires/vampire_hud.dmi

/datum/antagonist/vampire
	/// Stan ikony na HUD-zie antagonistów
	var/antag_hud_name = "vampire"

/datum/antagonist/vassal
	/// Stan ikony na HUD-zie antagonistów
	var/antag_hud_name = "vassal"

/// Bee: drugi argument to typ antagonisty widzącego ikonę; u nas wszyscy wampiry i wasale widzą się nawzajem,
/// a tekst w drugim argumencie (prince, scourge) traktujemy jak stan ikony
/datum/antagonist/vampire/proc/add_team_hud(mob/target, antag_to_check)
	vampire_team_hud_add(target, istext(antag_to_check) ? antag_to_check : antag_hud_name)

/datum/antagonist/vassal/proc/add_team_hud(mob/target, antag_to_check)
	vampire_team_hud_add(target, istext(antag_to_check) ? antag_to_check : antag_hud_name)

/datum/antagonist/vampire/remove_innate_effects(mob/living/mob_override)
	. = ..()
	vampire_team_hud_remove(mob_override || owner.current)

/datum/antagonist/vassal/remove_innate_effects(mob/living/mob_override)
	. = ..()
	vampire_team_hud_remove(mob_override || owner.current)

/proc/vampire_team_hud_add(mob/living/target, icon_state)
	if(!istype(target) || !target.mind)
		return
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_VAMPIRE]
	hud.join_hud(target)
	set_antag_hud(target, icon_state)
	var/image/holder = target.hud_list?[ANTAG_HUD]
	if(holder)
		holder.icon = 'aquila/icons/vampires/vampire_hud.dmi'

/proc/vampire_team_hud_remove(mob/living/target)
	if(!istype(target))
		return
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_VAMPIRE]
	if(!hud.hudusers[target] && !(target in hud.hudatoms))
		return
	hud.leave_hud(target)
	set_antag_hud(target, null)
	var/image/holder = target.hud_list?[ANTAG_HUD]
	if(holder)
		holder.icon = 'icons/mob/hud.dmi'

// Ogólne procedury z nowego Bee, których nie mamy

/// Bee: podtypy bez typów abstrakcyjnych (u nas abstract_type mają tylko akcje wampira i typy botaniki)
/proc/valid_subtypesof(datum/sometype)
	. = list()
	for(var/path in subtypesof(sometype))
		if(is_heretic_abstract_type(path)) // AQUILA - abstrakcyjne typy wiedzy heretyka
			continue
		if(ispath(path, /datum/action/vampire))
			var/datum/action/vampire/power_path = path
			if(initial(power_path.abstract_type) == path)
				continue
		else if(ispath(path, /datum/plant_trait) || ispath(path, /datum/plant_feature) || ispath(path, /datum/dictionary_entry) || ispath(path, /obj/item/plant_seeds))
			var/datum/plant_trait/plant_path = path // initial() czyta zmienną po nazwie, więc działa dla każdego z tych typów
			if(initial(plant_path.abstract_type) == path)
				continue
		. += path

/// Bee: odświeża statyczne dane we wszystkich otwartych oknach TGUI tego datumu
/datum/proc/update_static_data_for_all_viewers()
	for(var/datum/tgui/window as anything in SStgui.get_all_open_uis(src))
		window.send_full_update()

/datum/antagonist/vampire/proc/forge_objectives()
	return

/datum/antagonist/vampire/proc/add_objective(datum/objective/new_objective, find_target = FALSE)
	new_objective.owner = owner
	if(find_target)
		new_objective.find_target()
	objectives += new_objective
	log_objective(owner, new_objective.explanation_text)

/datum/antagonist/vassal/proc/forge_objectives()
	return

/datum/antagonist/vassal/proc/add_objective(datum/objective/new_objective, find_target = FALSE)
	new_objective.owner = owner
	if(find_target)
		new_objective.find_target()
	objectives += new_objective
	log_objective(owner, new_objective.explanation_text)

/// Bee: do_after(user, delay, target, timed_action_flags, progress, extra_checks, interaction_key, max_interact_count, hidden).
/// U nas trzeci argument do_after to needhand, więc kod wampira woła tę procedurę. Flagi IGNORE_*_LOC_CHANGE
/// i IGNORE_INCAPACITATED obsługujemy własną pętlą, bo nasze do_after zawsze je sprawdza.
/proc/vampire_do_after(mob/user, delay, atom/target, timed_action_flags = NONE, progress = TRUE, datum/callback/extra_checks, interaction_key, max_interact_count = 1, hidden = FALSE)
	if(!user)
		return FALSE
	if(!(timed_action_flags & (IGNORE_USER_LOC_CHANGE | IGNORE_TARGET_LOC_CHANGE | IGNORE_INCAPACITATED)))
		return do_after(user, delay, needhand = !(timed_action_flags & IGNORE_HELD_ITEM), target = target, progress = progress, extra_checks = extra_checks, hidden = hidden)

	var/atom/user_loc = user.loc
	var/atom/target_loc = target?.loc
	var/obj/item/held = user.get_active_held_item()
	var/datum/progressbar/progbar
	if(progress)
		progbar = new(user, delay, target || user)
	var/endtime = world.time + delay
	var/starttime = world.time
	. = TRUE
	while(world.time < endtime)
		stoplag(1)
		progbar?.update(world.time - starttime)
		if(QDELETED(user) || (extra_checks && !extra_checks.Invoke()))
			. = FALSE
			break
		if(!(timed_action_flags & IGNORE_INCAPACITATED) && (user.stat || user.incapacitated()))
			. = FALSE
			break
		if(!(timed_action_flags & IGNORE_USER_LOC_CHANGE) && user.loc != user_loc)
			. = FALSE
			break
		if(target && !(timed_action_flags & IGNORE_TARGET_LOC_CHANGE) && (QDELETED(target) || target.loc != target_loc))
			. = FALSE
			break
		if(!(timed_action_flags & IGNORE_HELD_ITEM) && user.get_active_held_item() != held)
			. = FALSE
			break
	if(progbar)
		qdel(progbar)

// Narządy pod nazwami z nowego Bee

/mob/proc/get_organ_slot(slot)
	return getorganslot(slot)

/mob/proc/get_organ_by_type(typepath)
	return getorgan(typepath)

/obj/item/organ/proc/set_organ_damage(amount)
	setOrganDamage(amount)

// Zaimki z wielkiej litery z nowego Bee

/datum/proc/p_They(temp_gender)
	return p_they(TRUE, temp_gender)

/datum/proc/p_Them(temp_gender)
	return p_them(TRUE, temp_gender)

/datum/proc/p_Their(temp_gender)
	return p_their(TRUE, temp_gender)

/// Bee: czy mob stoi (STANDING_UP) czy leży (LYING_DOWN)
/mob/living/proc/get_body_position()
	return (mobility_flags & MOBILITY_STAND) ? STANDING_UP : LYING_DOWN

/// Bee: strefa ciała, w którą celuje mob
/mob/proc/get_combat_bodyzone()
	return zone_selected || BODY_ZONE_CHEST

/mob/living/proc/set_jitter(amount)
	jitteriness = max(CEILING(amount / 20, 1), 0)

/// Bee: krótkowzroczność bez okularów korekcyjnych
/mob/living/proc/is_nearsighted_currently()
	if(!HAS_TRAIT(src, TRAIT_NEARSIGHT))
		return FALSE
	if(ishuman(src))
		var/mob/living/carbon/human/human_src = src
		var/obj/item/clothing/glasses/glasses = human_src.glasses
		if(istype(glasses) && glasses.vision_correction)
			return FALSE
	return TRUE

// Bee: get_examine_text() statusu jest w rdzeniu (code/datums/status_effects/status_effect.dm), dokleja go examine człowieka

// Modyfikatory prędkości: w Bee to datumy, u nas stare add_movespeed_modifier(id, ...).
// Typ z Bee służy tylko jako opis wartości, a jego ścieżka jest identyfikatorem.

/datum/movespeed_modifier
	var/multiplicative_slowdown = 0
	var/movetypes = ALL
	var/blacklisted_movetypes = NONE
	var/flags = NONE
	var/priority = 0

/mob/proc/add_movespeed_modifier_type(datum/movespeed_modifier/modifier_type, update = TRUE)
	return add_movespeed_modifier("[modifier_type]", update, initial(modifier_type.priority), initial(modifier_type.flags), TRUE, initial(modifier_type.multiplicative_slowdown), initial(modifier_type.movetypes), initial(modifier_type.blacklisted_movetypes))

/mob/proc/remove_movespeed_modifier_type(datum/movespeed_modifier/modifier_type, update = TRUE)
	return remove_movespeed_modifier("[modifier_type]", update)

// Pranie mózgu z Bee: zwraca utworzone cele, żeby po komendzie dało się je zdjąć

/proc/vampire_brainwash(mob/living/victim, list/directives, source)
	. = list()
	if(!victim.mind)
		return
	if(!islist(directives))
		directives = list(directives)
	var/datum/mind/victim_mind = victim.mind
	var/datum/antagonist/brainwashed/brainwash = victim_mind.has_antag_datum(/datum/antagonist/brainwashed)
	var/new_datum = !brainwash
	if(new_datum)
		brainwash = new()
	for(var/directive in directives)
		var/datum/objective/brainwashing/objective = new(directive)
		brainwash.objectives += objective
		. += WEAKREF(objective)
		log_objective(victim_mind, objective.explanation_text)
	if(new_datum)
		victim_mind.add_antag_datum(brainwash)
	else
		brainwash.greet()

	var/source_message = source ? " by [source]" : ""
	var/rendered = "<span class='deadsay'><b>[victim]</b> has been brainwashed with the following objective[length(directives) > 1 ? "s" : ""][source_message]: [english_list(directives)]</span>"
	var/rendered_pl = "<span class='deadsay'><b>[victim]</b>: pranie mózgu[source ? " ([source])" : ""]. Cel[length(directives) > 1 ? "e" : ""]: [english_list(directives)]</span>"
	deadchat_broadcast(rendered_pl, follow_target = victim, turf_target = get_turf(victim), message_type = DEADCHAT_REGULAR)
	victim.log_message(rendered, LOG_ATTACK, color = "#960000")

/// Bee: zdejmuje wybrane cele prania mózgu, a gdy nic nie zostało, usuwa cały status
/proc/unbrainwash(mob/living/victim, list/directives)
	var/datum/antagonist/brainwashed/brainwash = victim?.mind?.has_antag_datum(/datum/antagonist/brainwashed)
	if(!brainwash)
		return FALSE
	if(directives)
		if(!islist(directives))
			directives = list(directives)
		var/list/removed_objectives = list()
		for(var/D in directives)
			var/datum/objective/directive
			if(istype(D, /datum/weakref))
				var/datum/weakref/directive_weakref = D
				directive = directive_weakref.resolve()
			else if(istype(D, /datum/objective))
				directive = D
			if(!directive || !istype(directive))
				continue
			brainwash.objectives -= directive
			removed_objectives += directive
		log_admin("[key_name(victim)] had the following brainwashing objective[length(removed_objectives) > 1 ? "s" : ""] removed: [english_list(removed_objectives)].")
		if(LAZYLEN(brainwash.objectives))
			to_chat(victim, "<big><span class='warning'><b>[length(removed_objectives) > 1 ? "Część twoich dyrektyw znika" : "Jedna z twoich dyrektyw znika"]! Musisz już tylko wykonywać pozostałe dyrektywy.</b></span></big>")
			victim.mind.announce_objectives()
		else
			victim.mind.remove_antag_datum(/datum/antagonist/brainwashed)
		QDEL_LIST(removed_objectives)
	else
		victim.mind.remove_antag_datum(/datum/antagonist/brainwashed)
	return TRUE

/datum/client_colour/glass_colour/pink
	colour = "#ffcfe9"
