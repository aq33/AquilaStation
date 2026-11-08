// AQUILA EDIT - zmiana głośności muzyki z przeglądarki w trakcie odtwarzania (jukebox YouTube cichnie z odległością).

/**
 * Ustawia mnożnik głośności (0-1) aktualnie granej muzyki, bez restartu utworu.
 * Suwak głośności muzyki gracza dalej działa - wynikowa głośność to suwak * gain.
 * echo (0-1) - ilość echa/pogłosu z oddali, muffle (0-1) - przytłumienie jak zza ściany (inny pokład).
 */
/datum/tgui_panel/proc/set_music_gain(gain, echo = 0, muffle = 0)
	if(!is_ready())
		return
	window.send_message("audio/setMusicGain", list("gain" = clamp(gain, 0, 1), "echo" = clamp(echo, 0, 1), "muffle" = clamp(muffle, 0, 1)))

// Przeglądarka ma jeden odtwarzacz. Gdy muzykę zmienia coś innego niż jukebox (admin, pokonana flota),
// SSjukeboxes musi o tym wiedzieć: po zatrzymaniu wysyła swój utwór od nowa, a cudzej muzyki nie wycisza ani nie ucina.
/datum/tgui_panel/play_music(url, extra_data)
	. = ..()
	if(client && is_ready() && findtext(url, GLOB.is_http_protocol)) // jak w ..(): tylko gdy muzyka naprawdę poszła
		SSjukeboxes.on_foreign_music(client, FALSE)

/datum/tgui_panel/stop_music()
	. = ..()
	if(client)
		SSjukeboxes.on_foreign_music(client, TRUE)

/// Nowy odtwarzacz po przeładowaniu panelu (reconnect, „Fix chat”) nic nie gra: utwór jukeboxa trzeba wysłać od nowa
/datum/tgui_panel/on_message(type, payload)
	. = ..()
	if(type == "ready" && client)
		SSjukeboxes.on_foreign_music(client, TRUE)
