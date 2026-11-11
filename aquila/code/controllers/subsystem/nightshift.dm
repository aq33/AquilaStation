// AQUILA - zegar stacji i oświetlenie nocne
// - zmiana zawsze zaczyna się o 7:00 czasu stacji (bez SHIFT_TIME_REALTIME i RANDOMIZE_SHIFT_TIME w configu)
// - noc kończy się o 7:00, żeby runda nie startowała przy przyciemnionych światłach
// - kapitan może z konsoli komunikacji wyłączyć oświetlenie nocne na całym statku

/datum/controller/subsystem/ticker
	gametime_offset = 7 HOURS

/datum/controller/subsystem/nightshift
	nightshift_end_time = 7 HOURS
	/// Kapitan wyłączył oświetlenie nocne z konsoli komunikacji: automat go nie włącza
	var/captain_disabled = FALSE

/datum/controller/subsystem/nightshift/check_nightshift()
	if(captain_disabled)
		if(nightshift_active)
			update_nightshift(FALSE, FALSE)
		return
	return ..()

/// Przełącznik z konsoli komunikacji. Zwraca nowy stan captain_disabled.
/datum/controller/subsystem/nightshift/proc/toggle_captain_disabled(mob/user)
	captain_disabled = !captain_disabled
	if(captain_disabled)
		announce("Na polecenie dowództwa oświetlenie nocne zostało wyłączone. Światła pozostaną w pełnej jasności.")
		if(nightshift_active)
			update_nightshift(FALSE, FALSE)
	else
		announce("Na polecenie dowództwa przywrócono automatyczne oświetlenie nocne.")
		check_nightshift()
	log_game("[key_name(user)] [captain_disabled ? "disabled" : "re-enabled"] night shift lighting from a communications console.")
	message_admins("[ADMIN_LOOKUPFLW(user)] [captain_disabled ? "wyłącza" : "przywraca"] oświetlenie nocne z konsoli komunikacji.")
	return captain_disabled
