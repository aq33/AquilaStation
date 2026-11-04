// Natywne okienka BYOND po angielsku dla gracza z językiem EN. Wywołania w kodzie owija
// tools/i18n/wrap_dialogs.py (z markerem "AQ EDIT - i18n okienka"):
// - alert() -> i18n_alert(usr, ...): gracz widzi przetłumaczony tekst, tytuł i przyciski, a kod dostaje
//   z powrotem polski przycisk, więc porównania typu `if(alert(...) != "Tak")` dalej działają;
// - input(): teksty komunikatu i tytułu przez i18n_dialog_text. Lista wyboru zostaje, bo kod
//   porównuje zwracaną wartość.

/// Klient odbiorcy okienka (mob albo klient), inaczej null
/proc/i18n_dialog_viewer(target)
	if(ismob(target))
		var/mob/viewer = target
		return viewer.client
	if(istype(target, /client))
		return target
	return null

/**
 * alert(Usr = usr, Message, Title, Button1 = "Ok", Button2, Button3) z tłumaczeniem dla gracza z EN.
 * implicit_usr: usr z miejsca wywołania (pierwszy argument alert() można pominąć).
 */
/proc/i18n_alert(implicit_usr, target, message, title, button1, button2, button3)
	var/list/call_args = i18n_alert_args(implicit_usr, target, message, title, button1, button2, button3)
	target = call_args[1]
	message = call_args[2]
	title = call_args[3]
	var/list/original = call_args.Copy(4)
	var/client/viewer = i18n_dialog_viewer(target)
	if(!viewer?.wants_english())
		return alert(target, message, title, original[1], original[2], original[3])
	var/list/shown = i18n_alert_buttons(original)
	var/result = alert(target, i18n_en_html("[message]"), isnull(title) ? null : i18n_en_html("[title]"), shown[1], shown[2], shown[3])
	var/index = shown.Find(result)
	return index ? original[index] : result

/**
 * Argumenty alert() po kolei: list(odbiorca, tekst, tytuł, przycisk1, przycisk2, przycisk3).
 * Bez odbiorcy (alert("tekst", ...)) wszystko przesuwa się o jedno, a odbiorcą jest usr.
 */
/proc/i18n_alert_args(implicit_usr, target, message, title, button1, button2, button3)
	if(!ismob(target) && !istype(target, /client))
		button3 = button2
		button2 = button1
		button1 = title
		title = message
		message = target
		target = implicit_usr
	return list(target, message, title, isnull(button1) ? "Ok" : button1, button2, button3)

/// Przyciski po angielsku. Gdy dwa dałyby ten sam tekst, zostają po polsku, żeby wybór był jednoznaczny.
/proc/i18n_alert_buttons(list/original)
	var/list/shown = new /list(length(original))
	var/list/seen = list()
	for(var/i in 1 to length(original))
		if(isnull(original[i]))
			continue
		var/translated = i18n_en_html("[original[i]]")
		if(seen[translated])
			return original.Copy()
		seen[translated] = TRUE
		shown[i] = translated
	return shown

/// Tekst okienka input() dla odbiorcy (mob, klient albo null = usr)
/proc/i18n_dialog_text(target, text)
	if(!istext(text))
		return text
	return i18n_for_client(i18n_dialog_viewer(target) || usr?.client, text)
