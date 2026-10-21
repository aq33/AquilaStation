/**
 * Given to Vampires at the start and taken away as soon as they select a clan.
 */
/datum/action/vampire/clanselect
	name = "Wybór klanu"
	desc = "Zrób pierwszy krok jako prawdziwy Spokrewniony i przypomnij sobie swój prawdziwy rodowód."
	button_icon_state = "clanselect"
	power_explanation = "Aktywuj, żeby wybrać swój wampirzy klan."
	power_flags = BP_AM_SINGLEUSE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 0
	cooldown_time = 5 SECONDS

/datum/action/vampire/clanselect/activate_power()
	. = ..()
	vampiredatum_power.assign_clan_and_bane()
	deactivate_power()

/**
 * Given to Vampires every levelup. Opens the radial.
 */
/datum/action/vampire/levelup
	name = "Awans"
	desc = "Zrób kolejny krok jako pełny Spokrewniony i przypomnij sobie swój prawdziwy rodowód."
	button_icon_state = "power_levelup"
	power_explanation = "Aktywuj, żeby podnieść poziom jednej ze swoich dyscyplin."
	power_flags = BP_AM_SINGLEUSE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 0
	cooldown_time = 5 SECONDS

/datum/action/vampire/levelup/activate_power()
	. = ..()
	vampiredatum_power.my_clan.spend_rank()
	deactivate_power()

/**
 * Given to Princes once chosen. Picks a scourge.
 */
/datum/action/vampire/targeted/scourgify
	name = "Mianuj Bicza"
	desc = "Wybierz innego Spokrewnionego albo jednego ze swoich wasali na swojego Bicza."
	button_icon_state = "power_scourge"
	power_explanation = "Aktywuj, żeby wybrać innego Spokrewnionego albo jednego ze swoich wasali na swojego osobistego Bicza.\n\n\
						Użyta na innym Spokrewnionym da mu kilka poziomów i cel posłuszeństwa wobec ciebie.\n\
						Użyta na twoim wasalu uczyni cię jego stwórcą i przemieni go w pełnokrwistego wampira.\n\
						Dołączy wtedy do twojego klanu i oczywiście też dostanie kilka dodatkowych poziomów.\n\n\
						Bicz to twój egzekutor, narzędzie, którym władasz w imieniu Kamarili. Używaj go, żeby pilnować Maskarady i trzymać w ryzach pozostałych Spokrewnionych."
	power_flags = BP_AM_SINGLEUSE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 0
	cooldown_time = 35 SECONDS
	power_activates_immediately = FALSE
	prefire_message = "Kogo wybierzesz?"

	/// Reference to the target antag datum
	var/datum/weakref/target_ref

/datum/action/vampire/targeted/scourgify/check_valid_target(atom/target_atom)
	. = ..()
	if(!isliving(target_atom))
		return FALSE

	var/mob/living/living_target = target_atom
	var/datum/antagonist/vampire/target_vampire = IS_VAMPIRE(living_target)

	// No mind
	if(!living_target.mind)
		owner.balloon_alert(owner, "bez umysłu")
		return FALSE

	// No client
	if(!living_target.client)
		owner.balloon_alert(owner, "to nie gracz")
		return FALSE

	// Is our target alive or unconcious?
	if(living_target.stat != CONSCIOUS)
		owner.balloon_alert(owner, "[(living_target.stat == DEAD || HAS_TRAIT(living_target, TRAIT_FAKEDEATH)) ? "cel nie żyje" : "cel jest nieprzytomny"]")
		return FALSE

	if(IS_VASSAL(living_target) && !(IS_VASSAL(living_target) in vampiredatum_power.vassals)) // Only our own vassal may be promoted.
		owner.balloon_alert(owner, "to nie twój wasal")
		return FALSE

	if(!IS_VAMPIRE(living_target) && !IS_VASSAL(living_target))
		owner.balloon_alert(owner, "to nie wasal ani wampir")
		return FALSE

	if(target_vampire && (target_vampire.prince || target_vampire.scourge))
		owner.balloon_alert(owner, "nie możesz awansować starszych!")
		return FALSE

	if(target_ref) // Already offering
		owner.balloon_alert(owner, "już złożono propozycję!")
		return FALSE

	return TRUE

/datum/action/vampire/targeted/scourgify/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/living_target = target_atom

	var/datum/antagonist/vassal/vassal_target = IS_VASSAL(living_target)
	if(vassal_target) // We don't need to ask a lowly vassal.
		var/datum/vampire_clan/masterclan_type = vampiredatum_power.my_clan?.type
		if(!masterclan_type) // How did a caitiff get prince, bro. Select a clan first at least...
			owner.balloon_alert(owner, "najpierw wybierz klan!")
			deactivate_power()
			return

		vassal_target.silent = TRUE // so we don't get the annoying deconversion message
		living_target.mind.remove_antag_datum(/datum/antagonist/vassal)

		// Make, then give the datum
		var/datum/antagonist/vampire/scourgedatum = new(living_target.mind)
		scourgedatum.should_forge_objectives = FALSE // they only get the scourge objective
		living_target.mind.add_antag_datum(scourgedatum)

		// Pull them into our clan
		scourgedatum.my_clan = new masterclan_type(scourgedatum)
		scourgedatum.my_clan.on_apply()

		// Scourgify and end power
		scourgedatum.scourgify()
		target_ref = null
		power_activated_sucessfully()
	else
		target_ref = WEAKREF(IS_VAMPIRE(living_target))

		tgui_alert_async(living_target,
			message = "Twój Książę wybrał cię na swojego egzekutora. Jeśli się zgodzisz, otrzymasz rangę Bicza, zostaniesz związany jego władzą, a twoja moc znacznie wzrośnie.",
			title = "Propozycja Bicza",
			buttons = list("Przyjmij", "Odmów"),
			callback = CALLBACK(src, PROC_REF(handle_choice)),
			timeout = cooldown_time - 5 SECONDS,
			autofocus = TRUE
		)

	addtimer(CALLBACK(src, PROC_REF(choice_timeout)), cooldown_time)
	deactivate_power()

/datum/action/vampire/targeted/scourgify/proc/accepted()
	var/datum/antagonist/vampire/target_datum = target_ref.resolve()
	target_datum.scourgify()
	target_ref = null
	power_activated_sucessfully()

/datum/action/vampire/targeted/scourgify/proc/refused()
	owner.balloon_alert(owner, "odrzucono propozycję")
	target_ref = null

/datum/action/vampire/targeted/scourgify/proc/choice_timeout()
	if(owner && target_ref) // This might happen AFTER we remove the power from our owner.
		owner.balloon_alert(owner, "zignorowano propozycję")
		target_ref = null

/datum/action/vampire/targeted/scourgify/proc/handle_choice(choice)
	switch(choice)
		if("Przyjmij")
			accepted()
			return
		if("Odmów")
			refused()
			return
