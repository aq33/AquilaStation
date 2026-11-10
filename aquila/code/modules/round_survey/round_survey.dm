// AQUILA - end of round survey. The form is part of the round-end report window (RoundEndReport.tsx,
// aquila/code/modules/roundend/roundend_ui.dm), which also holds the end of round map vote.

/// Plik, do którego dopisywane są wszystkie ankiety (wspólny dla wszystkich rund)
#define ROUND_SURVEY_FILE "data/ankiety.txt"
#define ROUND_SURVEY_MAX_TEXT 1000

/// ckeys that already sent the survey this round
GLOBAL_LIST_EMPTY(round_survey_submitted)

/// Longest survey answer, in characters
/proc/round_survey_max_text()
	return ROUND_SURVEY_MAX_TEXT

/// One survey answer: at most ROUND_SURVEY_MAX_TEXT characters, in one line
/proc/round_survey_clean_text(t)
	t = trim(copytext_char("[t]", 1, ROUND_SURVEY_MAX_TEXT + 1))
	t = replacetext(t, ascii2text(13), "")
	return replacetext(t, "\n", " / ")

/// Saves the survey of the player ckey, user gets the messages. Returns TRUE when it was saved.
/// ckey has to come from the client that sent the form (usr.client.ckey), not from UI params: it is not checked here.
/proc/round_survey_submit(mob/user, ckey, list/params, survey_file = ROUND_SURVEY_FILE)
	if(!ckey || GLOB.round_survey_submitted[ckey])
		return FALSE
	var/fun = text2num(params["fun"])
	if(!(fun in 1 to 5) || fun != round(fun))
		to_chat(user, "<span class='warning'>Zaznacz ocenę wrażeń (od 1 do 5).</span>")
		return FALSE
	GLOB.round_survey_submitted[ckey] = TRUE
	var/list/entry = list()
	entry += "=== Runda [GLOB.round_id ? GLOB.round_id : "?"] | [time_stamp("YYYY-MM-DD hh:mm")] | [ckey] ==="
	entry += "Wrażenia: [fun]/5"
	entry += "Błędy: [round_survey_clean_text(params["bugs"]) || "-"]"
	entry += "Uwagi: [round_survey_clean_text(params["comments"]) || "-"]"
	text2file("[entry.Join("\n")]\n", survey_file)
	to_chat(user, "<span class='notice'>Dziękujemy za wypełnienie ankiety!</span>")
	return TRUE

#undef ROUND_SURVEY_FILE
#undef ROUND_SURVEY_MAX_TEXT
