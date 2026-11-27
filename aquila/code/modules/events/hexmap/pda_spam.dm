// AQUILA - Spam na PDA: przez kilka minut na losowe PDA przychodzą automatyczne reklamy i próby oszustwa (port z ParadiseSS13 code/modules/events/money_spam.dm)
// Paradise sends through an active message server to an old-style PDA every tick with a 5% chance and gives up after
// five minutes without a delivered message. Our PDAs are modular tablets with the NT messenger, so the spam is an
// automated tablet message signal: it needs working telecomms and a message server like any PDA message, and tablets
// with the messenger switched off are skipped. The event lasts 3-5 minutes with a 15% chance per tick, and the
// messages are written anew in Polish for the NSV setting. Paradise's AI intercept is left out.

/datum/round_event_control/aquila_hex_pda_spam
	name = "Spam na PDA"
	typepath = /datum/round_event/aquila_hex_pda_spam
	weight = 10
	min_players = 3
	max_occurrences = 2
	earliest_start = 10 MINUTES

/datum/round_event/aquila_hex_pda_spam
	fakeable = FALSE
	startWhen = 1
	/// Chance per event tick (2 s) to spam one tablet
	var/spam_chance = 15
	/// Spam messages sent so far
	var/sent = 0

/datum/round_event/aquila_hex_pda_spam/setup()
	endWhen = rand(90, 150) // 3-5 minutes

/datum/round_event/aquila_hex_pda_spam/tick()
	if(!prob(spam_chance))
		return
	var/list/targets = spam_targets()
	if(!length(targets))
		return
	if(send_spam(pick(targets)))
		sent++

/datum/round_event/aquila_hex_pda_spam/end()
	log_game("PDA Spam: sent [sent] spam message(s).")

/// Tablets on the station that can receive messages
/datum/round_event/aquila_hex_pda_spam/proc/spam_targets()
	. = list()
	for(var/obj/item/modular_computer/tablet as anything in GLOB.TabletMessengers)
		if(QDELETED(tablet) || !tablet.saved_identification)
			continue
		var/turf/T = get_turf(tablet)
		if(!T || !is_station_level(T.z))
			continue
		if(tablet_messenger(tablet)?.sending_and_receiving)
			. += tablet

/// The messenger program of a tablet
/datum/round_event/aquila_hex_pda_spam/proc/tablet_messenger(obj/item/modular_computer/tablet)
	RETURN_TYPE(/datum/computer_file/program/messenger)
	var/obj/item/computer_hardware/hard_drive/drive = tablet.all_components[MC_HDD]
	if(!drive)
		return null
	for(var/datum/computer_file/program/messenger/app in drive.stored_files)
		return app

/// Sends one spam message to the tablet through telecomms
/datum/round_event/aquila_hex_pda_spam/proc/send_spam(obj/item/modular_computer/tablet)
	var/datum/signal/subspace/messaging/tablet_msg/signal = make_signal(tablet)
	if(!signal)
		return FALSE
	signal.send_to_receivers()
	return TRUE

/// Automated message signal with a random spam message for the tablet
/datum/round_event/aquila_hex_pda_spam/proc/make_signal(obj/item/modular_computer/tablet)
	if(QDELETED(tablet) || !get_turf(tablet))
		return null
	var/list/spam = pick_spam()
	return new /datum/signal/subspace/messaging/tablet_msg(tablet, list(
		"name" = spam[1],
		"job" = "Nieznany nadawca",
		"message" = spam[2],
		"targets" = list(tablet),
		"automated" = TRUE,
	))

/// list(sender, message) of a random spam message
/datum/round_event/aquila_hex_pda_spam/proc/pick_spam()
	switch(rand(1, 9))
		if(1)
			return list(pick("Kasyno MaxBet", "MaxBet Online"), pick(
				"Wpłać 100 kr, a dostaniesz 300 kr zupełnie za darmo! Tylko dziś w Kasynie MaxBet.",
				"Ponad 450 gier hazardowych czeka na ciebie. Pierwszy zakład stawia za ciebie kasyno!",
				"Twój bonus powitalny 200% wygasa za 5 minut. Nie pozwól mu przepaść!",
			))
		if(2)
			return list(pick("Szybkie Randki Kosmiczne", "Samotne serca sektora"), pick(
				"Twój profil wpadł mi w oko i postanowiłam napisać. Odpisz, a wyślę ci zdjęcie.",
				"Masz (3) nowe wiadomości od osób z twojego okrętu!",
				"Ktoś z twojego działu cię polubił. Zgadnij kto, za jedyne 50 kr.",
			))
		if(3)
			return list(pick("Książę układu Rubikon", "Kapitan Zbigniew Mugawe", "Profesor Alfred Nkem"), pick(
				"PANSKIE SRODKI ZOSTALY PRZENIESIONE DO BANKU ROZWOJU TORTUGI. PROSZE PODAC NUMER KONTA I PIN.",
				"Z powodu braku spadkobiercow wybrałem pana do odebrania 1,5 miliarda kredytow mojego majatku.",
				"Potrzebuje pozaplanetarnego konta, aby natychmiast wplacic PÓŁTORA MILIONA kredytow. Pan sie nadaje.",
			))
		if(4)
			return list(pick("Dział Finansów NanoTransen", "Bank Centralii"), pick(
				"Twoja premia została zablokowana. Aby ją odblokować, podaj numer konta i PIN w odpowiedzi.",
				"Wykryliśmy podejrzaną transakcję na twoim koncie. Potwierdź dane, odsyłając swój PIN.",
				"Masz zaległy zwrot podatku w wysokości 812 kr. Kliknij tutaj, aby go odebrać.",
			))
		if(5)
			return list("InPost Kosmiczny", pick(
				"Twoja paczka czeka w paczkomacie. Dopłać 1 kr cła pod adresem nt-paczka.syn",
				"Nie mogliśmy doręczyć przesyłki, bo okręt był w nadprzestrzeni. Potwierdź nowy adres.",
				"Paczka nr 77-SYN-01 została zatrzymana. Opłać magazynowanie, zanim trafi do karpi.",
			))
		if(6)
			return list(pick("Dr. Maksymilian", "Apteka Kosmiczna"), pick(
				"Suplement ROBUST: prawdziwi lekarze, prawdziwa nauka, prawdziwe wyniki!",
				"Zmęczenie po zmianie? Kapsułki z prawdziwym stimulum, bez recepty i bez pytań.",
				"Dr. Maksymilian wyleczył już 70 tysięcy pacjentów w całym sektorze. Ty możesz być następny!",
			))
		if(7)
			return list(pick("Wygrałeś nagrodę!", "Jesteś naszym tysięcznym gościem!"), pick(
				"Wygrałeś bilety na premierę filmu „Ostatni prom z Centrali”! Odbierz je w ciągu 10 minut.",
				"Gratulacje! Wylosowaliśmy cię w loterii floty. Nagroda: nowy myśliwiec (koszty wysyłki 999 kr).",
				"Kliknij tutaj, aby odebrać darmowego corgiego. Corgi gotowy do wysyłki.",
			))
		if(8)
			return list("Orlen Paliwo Flotowe", pick(
				"Tylko dziś: hot-dog i 10 litrów plazmy w cenie 9 litrów!",
				"Zbieraj punkty na każdej stacji Orlen w sektorze. 10 tysięcy punktów to darmowa kawa!",
				"Nowość w Orlenie: kawa z dostawą przez kapsułę zaopatrzeniową. Uwaga na głowy!",
			))
		if(9)
			return list(pick("Rekrutacja Syndykatu", "Twoja nowa praca"), pick(
				"Masz dość szefa? Czerwony skafander czeka. Dowództwo Floty Syndykatu zatrudnia od zaraz.",
				"Praca zdalna na okręcie Nanotrasen! Wystarczy otworzyć kilka drzwi w odpowiednim momencie.",
				"Szukamy ludzi z dostępem do zbrojowni. Atrakcyjne wynagrodzenie, elastyczne godziny.",
			))
