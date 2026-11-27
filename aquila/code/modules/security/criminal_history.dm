// AQUILA - kartoteka karna między rundami (pomysł z Apollo Station i Aurory). Wyroki od 15 minut i dożywocie
// zapisują się przy postaci (ckey + imię, plik data/criminal_history.json) na koniec rundy. Przy wejściu do gry
// trafiają do „Przeszłości” rekordu ochrony, więc Żandarmeria widzi recydywistę. Bez blokady postaci.

#define CRIMINAL_HISTORY_FILE "data/criminal_history.json"
/// Najkrótszy wyrok, który trafia do kartoteki (decysekundy)
#define CRIMINAL_HISTORY_MIN_SENTENCE (15 MINUTES)
/// Ile ostatnich wyroków pamiętać na postać
#define CRIMINAL_HISTORY_MAX_ENTRIES 10

/// Wyroki z tej rundy do zapisu: "ckey|imię" => lista wpisów (tekst)
GLOBAL_LIST_EMPTY(aq_round_sentences)
GLOBAL_VAR_INIT(aq_criminal_history_saved, FALSE)

/// Zapamiętuje wyrok osoby z tej rundy (GenPop, zegar celi). sentence w decysekundach
/proc/aq_record_sentence(name, crimes, sentence)
	if(!name || sentence < CRIMINAL_HISTORY_MIN_SENTENCE)
		return FALSE
	var/datum/mind/target_mind = aq_mind_by_name(name)
	if(!target_mind?.key)
		return FALSE
	var/key = "[ckey(target_mind.key)]|[name]"
	var/list/entries = GLOB.aq_round_sentences[key] || list()
	entries += "[time2text(world.realtime, "YYYY-MM-DD")], runda [GLOB.round_id || "?"]: [crimes || "bez zarzutów"], [sentence >= 60 MINUTES ? "dożywocie" : DisplayTimeText(sentence, 1)]"
	GLOB.aq_round_sentences[key] = entries
	return TRUE

/proc/aq_criminal_history_load()
	if(!fexists(CRIMINAL_HISTORY_FILE))
		return list()
	var/list/data = json_decode(rustg_file_read(CRIMINAL_HISTORY_FILE))
	return islist(data) ? data : list()

/// Dopisuje wyroki z tej rundy do pliku (raz na rundę)
/proc/aq_criminal_history_save()
	if(GLOB.aq_criminal_history_saved || !length(GLOB.aq_round_sentences))
		return
	GLOB.aq_criminal_history_saved = TRUE
	var/list/data = aq_criminal_history_load()
	for(var/key in GLOB.aq_round_sentences)
		var/list/old_entries = islist(data[key]) ? data[key] : list()
		var/list/entries = old_entries + GLOB.aq_round_sentences[key]
		if(length(entries) > CRIMINAL_HISTORY_MAX_ENTRIES)
			entries.Cut(1, length(entries) - CRIMINAL_HISTORY_MAX_ENTRIES + 1)
		data[key] = entries
	rustg_file_write(json_encode(data), CRIMINAL_HISTORY_FILE)

/datum/controller/subsystem/ticker/display_report(popcount)
	. = ..()
	aq_criminal_history_save()

/// Rekord ochrony powstaje w manifest_inject() (z robieniem zdjęć, więc z opóźnieniem): dawne wyroki dopisujemy chwilę później
/datum/datacore/manifest_inject(mob/living/carbon/human/H, client/C, force = FALSE, record_name, assignment_override)
	. = ..()
	if(H?.mind?.key)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(aq_attach_criminal_history), record_name || H.real_name, ckey(H.mind.key)), 5 SECONDS)

/// Dopisuje dawne wyroki do „Przeszłości” rekordu ochrony. Zwraca TRUE, gdy coś dopisał
/proc/aq_attach_criminal_history(name, player_ckey)
	var/list/entries = aq_criminal_history_load()["[player_ckey]|[name]"]
	if(!islist(entries) || !length(entries))
		return FALSE
	var/datum/data/record/record = find_record("name", name, GLOB.data_core.security)
	if(!record)
		return FALSE
	record.fields["past_records"] = "[record.fields["past_records"]]<br><b>Wyroki z poprzednich rund:</b><br>[jointext(entries, "<br>")]"
	return TRUE

#undef CRIMINAL_HISTORY_FILE
#undef CRIMINAL_HISTORY_MIN_SENTENCE
#undef CRIMINAL_HISTORY_MAX_ENTRIES
