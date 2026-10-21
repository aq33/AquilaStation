/datum/discipline/dominate
	name = "Dominacja"
	discipline_explanation = "Dominacja to dyscyplina, która przelewa wolę wampira w jego głos i obecność, zmuszając ofiary, by myślały i działały zgodnie z jego rozkazami."
	icon_state = "dominate"

	// Base only has mez, ventrue get command earlier and can upgrade it
	level_1 = list(/datum/action/vampire/targeted/mesmerize)
	level_2 = list(/datum/action/vampire/targeted/mesmerize/two)
	level_3 = list(/datum/action/vampire/targeted/mesmerize/three)
	level_4 = list(/datum/action/vampire/targeted/mesmerize/four, /datum/action/vampire/targeted/command)
	level_5 = null

/datum/discipline/dominate/ventrue
	level_3 = list(/datum/action/vampire/targeted/mesmerize/three, /datum/action/vampire/targeted/command)
	level_4 = list(/datum/action/vampire/targeted/mesmerize/four, /datum/action/vampire/targeted/command/two)

// Dominate grants a controlled Voice of God ability as a passive discipline quirk,
// similar to how Potence grants extra punch damage.
/datum/discipline/dominate/apply_discipline_quirks(datum/antagonist/vampire/clan_owner)
	. = ..()
	clan_owner.grant_power(new /datum/action/vampire/voice_of_domination)

/// Tiny ability datum just to get vampies a voice of god power
/datum/action/vampire/voice_of_domination
	name = "Głos Dominacji"
	desc = "Przemów przytłaczająco władczym głosem, zmuszając śmiertelników do krótkiego posłuszeństwa."
	button_icon_state = "power_command"
	power_explanation = "Aktywuj tę moc, żeby wydać rozkaz Głosem Boga.\n\
		Słuchacze będą musieli wykonać proste polecenia, takie jak 'stop', 'drop', 'sleep', 'come here' (po angielsku) itp.\n\
		To słabsza wersja boskiego Głosu Boga, którą biernie zapewnia ci opanowanie Dominacji."
	power_flags = NONE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 75
	cooldown_time = 60 SECONDS
	/// Gracz anulował okno komendy, więc bez kosztu i odnowienia
	var/command_cancelled = FALSE

/datum/action/vampire/voice_of_domination/can_use()
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	if(!carbon_owner.get_organ_slot(ORGAN_SLOT_TONGUE))
		owner.balloon_alert(owner, "nie masz języka!")
		return FALSE
	if(carbon_owner.is_mouth_covered() || !isturf(carbon_owner.loc))
		owner.balloon_alert(owner, "masz zasłonięte usta.")
		return FALSE
	if(HAS_TRAIT(carbon_owner, TRAIT_MUTE))
		owner.balloon_alert(owner, "nie możesz mówić!")
		return FALSE
	return TRUE

/datum/action/vampire/voice_of_domination/on_activate(mob/user, atom/target)
	. = ..()
	// Anulowana komenda nie zaczyna odnowienia
	if(command_cancelled)
		command_cancelled = FALSE
		reset_next_use_time()

/datum/action/vampire/voice_of_domination/activate_power()
	var/command = tgui_input_text(owner, "Przemów Głosem Dominacji", "Rozkaz")
	if(QDELETED(src) || QDELETED(owner) || !command)
		// Zwrot kosztu pobranego w on_activate() przed oknem komendy
		if(!QDELETED(src) && vampiredatum_power && !vampiredatum_power.frenzied)
			vampiredatum_power.adjust_vitae(vitaecost)
		command_cancelled = TRUE
		return
	playsound(get_turf(owner), 'sound/magic/clockwork/invoke_general.ogg', 100, TRUE, 3)
	var/command_cooldown = voice_of_god(command, owner, list("colossus","commands"), base_multiplier = 2)
	cooldown_time = max(command_cooldown, 60 SECONDS)
	. = ..()
	deactivate_power()
