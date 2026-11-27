// AQUILA - Spam na faksie: wszystkie faksy okrętu drukują tę samą ulotkę reklamową (port z Bubberstation modular_zubbers/code/modules/events/mundane/fax_spam.dm)
// Bubberstation prints one of its advertisement papers with their own sprites. We have no advertisement sprites, so
// the flyer is a plain paper with its name and text set by the event; the flyers and senders are written anew in Polish
// for the NSV setting. Like Bubberstation only faxes on the ship visible to the network print, unannounced.

/datum/round_event_control/aquila_hex_fax_spam
	name = "Spam na faksie"
	typepath = /datum/round_event/aquila_hex_fax_spam
	weight = 10
	min_players = 5
	max_occurrences = 2
	earliest_start = 20 MINUTES

/datum/round_event/aquila_hex_fax_spam
	fakeable = FALSE
	startWhen = 1
	/// list(name, text) of the flyer every fax prints
	var/list/flyer

/datum/round_event/aquila_hex_fax_spam/setup()
	flyer = pick_flyer()

/datum/round_event/aquila_hex_fax_spam/start()
	var/sender = pick("Nieznany nadawca", "Promocje Sektora", "Biuro Ogłoszeń Tortugi", "Dział Marketingu NanoTransen")
	var/printed = 0
	for(var/obj/machinery/fax/fax in GLOB.machines)
		if(!fax.visible_to_network || fax.syndicate_network || !fax.is_operational)
			continue
		var/turf/T = get_turf(fax)
		if(!T || !is_station_level(T.z))
			continue
		if(send_flyer(fax, sender))
			printed++
	log_game("Fax Spam: [printed] fax(es) printed \"[flyer[1]]\".")

/// Prints the flyer on the fax, returns the paper
/datum/round_event/aquila_hex_fax_spam/proc/send_flyer(obj/machinery/fax/fax, sender)
	if(QDELETED(fax) || !length(flyer))
		return null
	var/obj/item/paper/spam = new
	spam.name = flyer[1]
	spam.desc = "Ulotka pełna bezużytecznych reklam."
	spam.add_raw_text(flyer[2])
	spam.update_appearance()
	fax.receive(spam, sender)
	return spam

/// list(name, text) of a random flyer
/datum/round_event/aquila_hex_fax_spam/proc/pick_flyer()
	switch(rand(1, 6))
		if(1)
			return list("ulotka „Solidna skrzynka”", "<center><b>SOLIDNA SKRZYNKA NA NARZĘDZIA</b></center><br>Pokaż, że jesteś najlepszy z najlepszych! Nowa linia skrzynek na narzędzia w siedmiu kolorach, w tym w całkiem nowym różowym. Już od 500 kr.<br><br><i>Skrzynka nie służy do bicia. Producent nie odpowiada za wstrząśnienia mózgu.</i>")
		if(2)
			return list("list od księcia", "Szanowny Panie,<br><br>Jestem zaginionym księciem układu Rubikon. Uznano mnie za zmarłego po ataku na mój prom, ale przeżyłem i ukrywam się na pańskim okręcie. Proszę zostawić 1000 kr w worku z pańskim nazwiskiem w utylizacji, abym mógł kupić dyskretny lot do pałacu. Po powrocie obsypię pana królewskimi bogactwami.<br><br>Z wyrazami szacunku,<br>Książę Barnaba IV")
		if(3)
			return list("ulotka Orlenu", "<center><b>ORLEN – PALIWO FLOTOWE</b></center><br>Tylko w tym tygodniu: tankując 100 litrów plazmy, dostajesz hot-doga gratis! Promocja ważna na wszystkich stacjach Orlen w sektorze, z wyjątkiem tych, które akurat zajęli piraci.")
		if(4)
			return list("zaproszenie na kurs", "<center><b>KURS PILOTAŻU W 3 DNI!</b></center><br>Zawsze chciałeś latać myśliwcem? Nasz kurs nauczy cię wszystkiego: startu, lądowania i wypełniania formularza o szkodach. Absolwenci mają 40% szans na pierwsze lądowanie bez kraksy!")
		if(5)
			return list("oferta ubezpieczenia", "<center><b>UBEZPIECZENIE NA ŻYCIE „KLON PLUS”</b></center><br>Zginąłeś na zmianie? Nie szkodzi! Z pakietem Klon Plus twój klon dostaje 10% zniżki na nowy mundur. Ubezpieczenie nie obejmuje zgonów od karpi, meteorów, Syndykatu ani własnej głupoty.")
		if(6)
			return list("ulotka wyborcza", "<center><b>GŁOSUJ NA KLAUNA!</b></center><br>Klaun Bobo kandyduje na przedstawiciela załogi! Program: więcej bananów, mniej pracy, darmowe piszczałki dla wszystkich. Honk!")
