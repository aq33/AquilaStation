// AQ - stare okna HTML (browse(), /datum/browser: szafa grająca, księga kultu, konsole bez tgui)
// po angielsku dla gracza z językiem EN. Tłumaczymy po stronie serwera, węzeł tekstowy po węźle
// (stałe i szablony ze słownika strings/i18n/en_dm.json), bo okno nie ma tłumacza w JS.

/// HTML okna browse() w języku odbiorcy (mob albo klient)
/proc/i18n_browse_html(target, html)
	var/client/viewer = ismob(target) ? target:client : target
	if(!istype(viewer) || !viewer.wants_english() || !istext(html))
		return html
	return i18n_en_html(html, TRUE)

/datum/browser/get_content()
	var/client/viewer = ismob(user) ? user.client : user
	if(!istype(viewer) || !viewer.wants_english())
		return ..()
	// tytuł i treść podmieniamy tylko na czas składania strony: obiekt okna bywa odświeżany
	var/polish_title = title
	var/polish_content = content
	title = i18n_en_html(title, TRUE)
	content = i18n_en_html(content, TRUE)
	. = ..()
	title = polish_title
	content = polish_content
