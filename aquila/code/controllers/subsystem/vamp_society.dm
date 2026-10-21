SUBSYSTEM_DEF(vsociety)
	name = "Vampire Society"
	wait = 10 MINUTES	// For some reason this actually fires at HALF this time.
	flags = SS_NO_INIT | SS_BACKGROUND
	can_fire = FALSE

	// Are we currently polling?
	var/currently_polling = FALSE

	// Ref to the prince datum
	var/datum/weakref/princedatum

/datum/controller/subsystem/vsociety/fire(resumed = FALSE)
	var/time_elapsed = world.time - SSticker.round_start_time

	// Give them some breathing room
	if(time_elapsed < 9 MINUTES)
		return

	if(!princedatum && !currently_polling)
		for(var/datum/antagonist/vampire as anything in GLOB.all_vampires)
			to_chat(vampire.owner.current, span_announce("* Wskazówka wampira: wkrótce odbędzie się wybór Księcia. Jeśli chcesz przewodzić innym Spokrewnionym, przeczytaj teraz o Książętach w Przewodniku wampira!"))
		addtimer(CALLBACK(src, PROC_REF(poll_for_prince)), 2 MINUTES)
		message_admins("Społeczność wampirów ruszyła, za 2 minuty odbędzie się głosowanie na Księcia.")
		log_game("Vampire society has fired, and a prince poll will occur soon.")

/datum/controller/subsystem/vsociety/proc/poll_for_prince()
	message_admins("Społeczność wampirów wybiera teraz nowego Księcia.")
	log_game("Vampire society is now polling for a new prince.")

	//Build a list of mobs in GLOB.all_vampires
	var/list/vampire_living_candidates = list()

	for(var/datum/antagonist/vampire as anything in GLOB.all_vampires)
		var/currentmob = vampire.owner?.current

		if(!isliving(currentmob)) //Are we mob/living?
			continue

		var/mob/living/livingmob = currentmob
		if(livingmob.stat != CONSCIOUS) // Are we alive?
			continue

		vampire_living_candidates += currentmob

	// Build a poll_config datum to match the new polling API
	currently_polling = TRUE
	var/datum/poll_config/config = new()
	config.question = "Możesz zostać Księciem."
	config.poll_time = 3 MINUTES
	config.flash_window = TRUE
	config.role_name_text = "Książę"
	config.amount_to_pick = length(GLOB.all_vampires)
	config.announce_chosen = FALSE
	config.requires_confirmation = TRUE
	config.custom_response_messages = list(
		POLL_RESPONSE_SIGNUP = "Zgłaszasz swoją kandydaturę na Księcia. <br>* Uwaga: od Księcia wiele się oczekuje. Jeśli nie możesz pilnować przestrzegania Maskarady, pozwól, by ten ciężar wziął ktoś inny.",
		POLL_RESPONSE_UNREGISTERED = "Wycofujesz swoją kandydaturę na Księcia."
	)

	var/list/pollers = SSpolling.poll_candidates(config, vampire_living_candidates)
	currently_polling = FALSE

	var/datum/antagonist/vampire/chosen_datum
	var/mob/living/chosen_candidate

	// We have to do this shit because the polling proc doesn't always return a list. Sometimes it just returns a mob.
	var/list/candidates = list()
	candidates += pollers

	for(var/mob/living/current_candidate in candidates) // Pick the ideal one from the list.
		var/datum/antagonist/vampire/current_datum = IS_VAMPIRE(current_candidate)

		if(!chosen_candidate)	// If we are the first in line, just be the prince by default
			chosen_candidate = current_candidate
			chosen_datum = IS_VAMPIRE(current_candidate)
			continue

		if(current_datum.get_princely_score() >= chosen_datum.get_princely_score())
			chosen_candidate = current_candidate
			chosen_datum = IS_VAMPIRE(current_candidate)

	if(chosen_datum)
		chosen_datum.princify()
