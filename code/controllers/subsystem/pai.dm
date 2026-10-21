SUBSYSTEM_DEF(pai)
	name = "pAI"

	flags = SS_NO_INIT|SS_NO_FIRE

	var/list/candidates = list()
	var/ghost_spam = FALSE
	var/spam_delay = 100
	var/list/pai_card_list = list()

/// Returns (and creates if needed) the candidate datum of the given mob
/datum/controller/subsystem/pai/proc/get_candidate(mob/M)
	for(var/datum/paiCandidate/c in candidates)
		if(c.key == M.key)
			return c
	var/datum/paiCandidate/candidate = new /datum/paiCandidate()
	candidate.key = M.key
	candidates.Add(candidate)
	return candidate

/// Opens the pAI candidacy window (TGUI "PaiSubmit") for a ghost
/datum/controller/subsystem/pai/proc/recruitWindow(mob/M)
	get_candidate(M)
	ui_interact(M)

/datum/controller/subsystem/pai/ui_state(mob/user)
	return GLOB.observer_state

/datum/controller/subsystem/pai/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaiSubmit")
		ui.open()

/datum/controller/subsystem/pai/ui_data(mob/user)
	var/list/data = list()
	var/datum/paiCandidate/candidate = get_candidate(user)
	data["name"] = candidate.name || ""
	data["description"] = candidate.description || ""
	data["role"] = candidate.role || ""
	data["comments"] = candidate.comments || ""
	data["ready"] = candidate.ready
	return data

/datum/controller/subsystem/pai/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/mob/user = usr
	if(!isobserver(user))
		return
	var/datum/paiCandidate/candidate = get_candidate(user)
	switch(action)
		if("submit")
			candidate.set_from_params(params)
			candidate.ready = TRUE
			for(var/obj/item/paicard/p in pai_card_list)
				if(!p.pai)
					p.alertUpdate()
			to_chat(user, "<span class='notice'>Twoja kandydatura na pAI została zgłoszona.</span>")
			SStgui.close_user_uis(user, src)
			return TRUE
		if("save")
			candidate.set_from_params(params)
			if(candidate.savefile_save(user))
				to_chat(user, "<span class='notice'>Zapisano osobowość pAI.</span>")
			return TRUE
		if("load")
			if(!candidate.savefile_load(user))
				to_chat(user, "<span class='warning'>Nie znaleziono zapisanej osobowości pAI.</span>")
				return TRUE
			//In case people have saved unsanitized stuff.
			if(candidate.name)
				candidate.name = copytext_char(sanitize(candidate.name),1,MAX_NAME_LEN)
			if(candidate.description)
				candidate.description = copytext_char(sanitize(candidate.description),1,MAX_MESSAGE_LEN)
			if(candidate.role)
				candidate.role = copytext_char(sanitize(candidate.role),1,MAX_MESSAGE_LEN)
			if(candidate.comments)
				candidate.comments = copytext_char(sanitize(candidate.comments),1,MAX_MESSAGE_LEN)
			return TRUE
		if("withdraw")
			if(!candidate.ready)
				to_chat(user, "<span class='warning'>Nie zgłosiłeś jeszcze kandydatury.</span>")
				return TRUE
			candidate.ready = FALSE
			to_chat(user, "<span class='notice'>Wycofujesz swoją kandydaturę na pAI.</span>")
			return TRUE

/// Candidate list for the pAI card window (TGUI "PaiCard")
/datum/controller/subsystem/pai/proc/get_ready_candidates_ui_data()
	var/list/data = list()
	for(var/datum/paiCandidate/c in candidates)
		if(!check_ready(c))
			continue
		data += list(list(
			"ref" = REF(c),
			"name" = c.name,
			"description" = c.description,
			"role" = c.role,
			"comments" = c.comments,
		))
	return data

/// Downloads the candidate personality into the given card
/datum/controller/subsystem/pai/proc/download_candidate(obj/item/paicard/card, datum/paiCandidate/candidate)
	if(!istype(card) || !istype(candidate) || card.pai)
		return FALSE
	if(check_ready(candidate) != candidate)
		return FALSE
	var/mob/living/silicon/pai/pai = new(card)
	if(!candidate.name)
		pai.name = pick(GLOB.ninja_names)
	else
		pai.name = candidate.name
	pai.real_name = pai.name
	pai.key = candidate.key

	card.setPersonality(pai)

	SSticker.mode.update_cult_icons_removed(card.pai.mind)

	candidates -= candidate
	return TRUE

/datum/controller/subsystem/pai/proc/spam_again()
	ghost_spam = FALSE

/datum/controller/subsystem/pai/proc/check_ready(var/datum/paiCandidate/C)
	if(!C.ready)
		return FALSE
	for(var/mob/dead/observer/O in GLOB.player_list)
		if(O.key == C.key)
			return C
	return FALSE

/datum/controller/subsystem/pai/proc/findPAI(obj/item/paicard/p, mob/user)
	if(!(GLOB.ghost_role_flags & GHOSTROLE_SILICONS))
		to_chat(user, "<span class='warning'>Z powodu rosnącej liczby incydentów z SAMOUSZKODZONYMI niezależnymi sztucznymi inteligencjami urządzenia z dowolną osobowością zostały tymczasowo zakazane w tym sektorze.</span>")
		return
	if(ghost_spam)
		to_chat(user, "<span class='warning'>Prośba o osobowości została już wysłana. Spróbuj ponownie za chwilę.</span>")
		return
	ghost_spam = TRUE
	for(var/mob/dead/observer/G in GLOB.player_list)
		if(!G.key || !G.client)
			continue
		//NSV13 - Disabled until Beemerge, I don't know what to put here without porting from another PR so WEH
		//if(!(ROLE_PAI in G.client.prefs.be_special))
		//	continue
		//NSV13 - Stop
		to_chat(G, "<span class='ghostalert'>[user] prosi o osobowość pAI! Użyj przycisku pAI, by się zgłosić.</span>")
	addtimer(CALLBACK(src, PROC_REF(spam_again)), spam_delay)
	to_chat(user, "<span class='notice'>Wysłano prośbę o osobowości pAI.</span>")

/datum/paiCandidate
	var/name
	var/key
	var/description
	var/role
	var/comments
	var/ready = 0

/// Sets the candidate fields from the PaiSubmit window
/datum/paiCandidate/proc/set_from_params(list/params)
	var/new_name = sanitize_name(trim(copytext_char("[params["name"]]", 1, MAX_NAME_LEN)))
	name = new_name || null
	description = copytext_char(sanitize("[params["description"]]"), 1, MAX_MESSAGE_LEN)
	role = copytext_char(sanitize("[params["role"]]"), 1, MAX_MESSAGE_LEN)
	comments = copytext_char(sanitize("[params["comments"]]"), 1, MAX_MESSAGE_LEN)
