// Haki tłumaczenia OOC, adminhelpów i PW z adminami (AQ EDIT w ooc.dm, adminpm.dm i adminhelp.dm).
// Bez modułu wersji angielskiej nic nie zmieniają. Moduł nadpisuje je w aquila/code/modules/i18n/chat_translation.dm.

/// Treść OOC (po sanitize) w języku odbiorcy albo null, gdy tłumaczenie nie jest potrzebne. Może czekać na API.
/client/proc/aq_ooc_for(client/recipient, raw_msg)
	return null

/// Wiadomość do admina albo od admina z dopisanym tłumaczeniem dla odbiorcy (null = wszyscy admini). Może czekać na API.
/// sanitized: czy msg jest już po sanitize() (PW), czy dopiero będzie (treść nowego adminhelpa)
/client/proc/aq_admin_msg_for(client/recipient, msg, sanitized = TRUE)
	return msg
