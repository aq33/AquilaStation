/// AQUILA - okno DRADIS-ów ze specjalną funkcją (Dradis.tsx): konsola dostaw ładunków, górniczy skaner asteroid i radar
/// myśliwców oraz małych jednostek. Mają ten sam wygląd co ekran taktyczny (tactical_screen.dm): okrągły radar, listę
/// i kartę kontaktu ze stanowiska rozpoznania (add_scope_data), a obok panel swojej funkcji. Zwykłe DRADIS-y okrętu
/// otwierają ekran taktyczny i tego okna nie używają.
/// Plik musi być dołączony po wszystkich innych nadpisaniach ui_data DRADIS-u (niepewność kontaktów, cywile, ładunki
/// pocisków), bo czyta ich blipy z data["ships"].

/// Rodzaj specjalnego DRADIS-u dla okna: "cargo", "mining", "craft" albo "dradis"
/obj/machinery/computer/ship/dradis/proc/special_dradis_kind()
	if(istype(src, /obj/machinery/computer/ship/dradis/minor/cargo))
		return "cargo"
	if(istype(src, /obj/machinery/computer/ship/dradis/mining))
		return "mining"
	if(istype(linked, /obj/structure/overmap/small_craft))
		return "craft"
	return "dradis"

/obj/machinery/computer/ship/dradis/ui_data(mob/user)
	. = ..()
	var/list/data = .
	if(!linked || tactical_screen_ship() || istype(src, /obj/machinery/computer/ship/dradis/sensors))
		return
	add_scope_data(data)
	data -= "ships"
	data["kind"] = special_dradis_kind()
	data["readonly"] = TRUE // sensorami steruje okręt, nie ta konsola: bez przycisków „Przekaż mostkowi”
	data["can_hail"] = TRUE
	data["hail_range"] = hail_range
	data["sensor_range"] = sensor_range
	data["mining_tier"] = mining_sensor_tier
	data["show_asteroids"] = show_asteroids
	// fala impulsu na radarze: zwykły DRADIS pulsuje dookoła na swój zasięg sensorów
	data["pulse_age"] = round((world.time - linked.last_radar_pulse) / 10, 0.1)
	data["pulse_reach"] = sensor_range
	data["pulse_width"] = 0
	data["pulse_bearing"] = 0
	if(show_asteroids)
		// skaner widzi tylko asteroidy do swojego poziomu (jak dawna mapa DRADIS)
		var/list/objects = list()
		for(var/list/thing as anything in data["objects"])
			if(thing["kind"] == "asteroid")
				var/obj/structure/overmap/asteroid/rock = locate(thing["id"])
				if(istype(rock) && rock.required_tier > mining_sensor_tier)
					continue
			objects += list(thing)
		data["objects"] = objects
	// ta sama akcja „hail” w karcie kontaktu robi na tych konsolach co innego
	if(data["kind"] == "cargo")
		data["hail_label"] = "Dostarcz ładunek"
		data["hail_tooltip"] = "Wysyła ładunek z wyrzutni ładowni połączonej z tą konsolą do wybranego okrętu (do [hail_range] pól)."
	else if(dradis_targeting && (linked.gunner == user || linked.pilot == user))
		data["hail_label"] = "Namierz"
		data["hail_tooltip"] = "Wrogi okręt: namierzanie. Sojusznik: wysyłasz mu swoje namiary (datalink)."
