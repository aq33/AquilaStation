// Port BeeStation #13247: głosowanie własne admina (jedno lub wiele wyborów, sposób wyłonienia zwycięzcy).

/// The max amount of options someone can have in a custom vote.
#define MAX_CUSTOM_VOTE_OPTIONS 10

/datum/vote/custom_vote
	name = "Custom"
	default_message = "Kliknij tutaj, żeby rozpocząć własne głosowanie."

// Custom votes ares always accessible.
/datum/vote/custom_vote/is_accessible_vote()
	return TRUE

/datum/vote/custom_vote/reset()
	default_choices = null
	override_question = null
	count_method = VOTE_COUNT_METHOD_SINGLE
	return ..()

/datum/vote/custom_vote/can_be_initiated(forced)
	. = ..()
	if(. != VOTE_AVAILABLE)
		return .
	if(forced)
		return .

	// Custom votes can only be created if they're forced to be made.
	// (Either an admin makes it, or otherwise.)
	return "Własne głosowania mogą tworzyć tylko admini."

/datum/vote/custom_vote/create_vote(mob/vote_creator)
	var/custom_count_method = tgui_input_list(
		user = vote_creator,
		message = "Jeden wybór czy wiele?",
		title = "Sposób wyboru",
		items = list("Jeden", "Wiele"),
		default = "Jeden",
	)
	switch(custom_count_method)
		if("Jeden")
			count_method = VOTE_COUNT_METHOD_SINGLE
		if("Wiele")
			count_method = VOTE_COUNT_METHOD_MULTI
		if(null)
			return FALSE
		else
			stack_trace("Got '[custom_count_method]' in create_vote() for custom voting.")
			to_chat(vote_creator, "<span class='boldwarning'>Nieznany sposób wyboru. Skontaktuj się z koderem.</span>")
			return FALSE

	var/custom_win_method = tgui_input_list(
		user = vote_creator,
		message = "Jak wyłonić zwycięzcę głosowania?",
		title = "Sposób wyłonienia zwycięzcy",
		items = list("Zwykła większość", "Losowanie ważone", "Bez zwycięzcy"),
		default = "Zwykła większość",
	)
	switch(custom_win_method)
		if("Zwykła większość")
			winner_method = VOTE_WINNER_METHOD_SIMPLE
		if("Losowanie ważone")
			winner_method = VOTE_WINNER_METHOD_WEIGHTED_RANDOM
		if("Bez zwycięzcy")
			winner_method = VOTE_WINNER_METHOD_NONE
		if(null)
			return FALSE
		else
			stack_trace("Got '[custom_win_method]' in create_vote() for custom voting.")
			to_chat(vote_creator, "<span class='boldwarning'>Nieznany sposób wyłonienia zwycięzcy. Skontaktuj się z koderem.</span>")
			return FALSE

	var/display_stats = tgui_alert(
		vote_creator,
		"Czy statystyki głosowania mają być jawne?",
		"Pokazać statystyki?",
		list("Tak", "Nie"),
	)

	if(isnull(display_stats))
		return FALSE
	display_statistics = display_stats == "Tak"

	override_question = tgui_input_text(vote_creator, "Czego dotyczy głosowanie?", "Własne głosowanie")
	if(!override_question)
		return FALSE

	default_choices = list()
	for(var/i in 1 to MAX_CUSTOM_VOTE_OPTIONS)
		var/option = tgui_input_text(vote_creator, "Wpisz opcję albo naciśnij Anuluj, żeby skończyć. Maksymalnie [MAX_CUSTOM_VOTE_OPTIONS].", "Opcje", max_length = MAX_NAME_LEN)
		if(!vote_creator?.client)
			return FALSE
		if(!option)
			break

		default_choices += capitalize(option)

	if(!length(default_choices))
		return FALSE
	// Sanity for all the tgui input stalling we are doing
	if(isnull(vote_creator.client?.holder))
		return FALSE

	return ..()

/datum/vote/custom_vote/initiate_vote(initiator, duration)
	. = ..()
	. += "\n[override_question]"

#undef MAX_CUSTOM_VOTE_OPTIONS
