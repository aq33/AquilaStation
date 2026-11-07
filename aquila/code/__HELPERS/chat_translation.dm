// Haki tłumaczenia OOC, adminhelpów i PW z adminami (AQ EDIT w ooc.dm, adminpm.dm i adminhelp.dm).
// Bez modułu wersji angielskiej nic nie zmieniają. Moduł nadpisuje je w aquila/code/modules/i18n/chat_translation.dm.

/// Przed rozesłaniem OOC: client -> treść (po sanitize) w języku odbiorcy, tylko dla tych, którzy wiadomość zobaczą
/// i mówią innym językiem niż autor. null, gdy nikomu nie trzeba tłumaczyć. Może czekać na API (raz na całą wiadomość).
/client/proc/aq_ooc_prepare(raw_msg)
	return null

/// Wiadomość do admina albo od admina z dopisanym tłumaczeniem dla odbiorcy (null = wszyscy admini). Może czekać na API.
/// sanitized: msg jest już po sanitize() (PW), a FALSE: surowy tekst, który sanitize() przejdzie dopiero później (nowy adminhelp)
/// html: msg to HTML od wyższego admina, który nie przechodzi sanitize(), więc do tłumaczenia idzie bez znaczników
/client/proc/aq_admin_msg_for(client/recipient, msg, sanitized = TRUE, html = FALSE)
	return msg
