// AQ - stare okna HTML (browse(), /datum/browser: szafa grająca, księga kultu, konsole bez tgui)
// w języku gracza, który nie gra po polsku. Tłumaczymy po stronie serwera, węzeł tekstowy po węźle
// (stałe i szablony ze słownika strings/i18n/<język>_dm.json), bo okno nie ma tłumacza w JS.

/// HTML okna browse() w języku odbiorcy (mob albo klient)
/proc/i18n_browse_html(target, html)
	var/client/viewer = ismob(target) ? target:client : target
	var/language = istype(viewer) ? viewer.translated_language() : null
	if(!language || !istext(html))
		return html
	return i18n_html(html, TRUE, language)

/datum/browser/get_content()
	var/client/viewer = ismob(user) ? user.client : user
	var/language = istype(viewer) ? viewer.translated_language() : null
	if(!language)
		return ..()
	// tytuł i treść podmieniamy tylko na czas składania strony: obiekt okna bywa odświeżany
	var/polish_title = title
	var/polish_content = content
	title = i18n_html(title, TRUE, language)
	content = i18n_html(content, TRUE, language)
	. = ..()
	title = polish_title
	content = polish_content
