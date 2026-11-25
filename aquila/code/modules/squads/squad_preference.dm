// Preferencja funkcji w kreatorze postaci: „Automatycznie” (domyślnie) albo rola drużyny (aq_pick_squad w squad_positions.dm).
// Do 25.11.2026 była to nazwa drużyny; stara nazwa w zapisie działa jak „Automatycznie”.
// Do 14.11.2026 domyślną wartością było „Alpha”, więc prawie każda zapisana postać ma Alpha, choć nikt jej nie wybierał.
// Jednorazowa migracja przestawia wszystkie zapisane postacie gracza na „Automatycznie”.

/// Nazwa migracji w keybind_migrations (lista jednorazowych migracji gracza zapisywana w bazie)
#define AQ_SQUAD_AUTO_MIGRATION "squad_pref_auto_2026_11"

/datum/preferences/load_characters()
	. = ..()
	if(isnull(.)) // błąd bazy; FALSE to poprawny odczyt bez postaci i migrację trzeba zapisać od razu
		return
	if(!islist(keybind_migrations))
		keybind_migrations = list()
	if(AQ_SQUAD_AUTO_MIGRATION in keybind_migrations)
		return
	keybind_migrations += AQ_SQUAD_AUTO_MIGRATION
	for(var/datum/character_save/changed as anything in aq_reset_squad_prefs(character_saves))
		changed.save(parent)
	// flaga migracji musi trafić do bazy od razu, inaczej przy następnym logowaniu migracja skasowałaby świeży wybór gracza
	save_preferences()

/// Przestawia preferowaną drużynę na „Automatycznie”; zwraca zmienione zapisy postaci (tylko te trzeba zapisać do bazy)
/proc/aq_reset_squad_prefs(list/saves)
	. = list()
	for(var/datum/character_save/save as anything in saves)
		if(save.preferred_squad != SQUAD_PREF_AUTO)
			save.preferred_squad = SQUAD_PREF_AUTO
			. += save

#undef AQ_SQUAD_AUTO_MIGRATION
