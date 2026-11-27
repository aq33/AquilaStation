// AQUILA - Nowe prawo kosmiczne: Dział Prawny Nanotrasen ogłasza żartobliwy zakaz, który załoga ma wdrożyć w 15 minut (port z ss220club/Paradise-SS220 modular_ss220/events/code/new_space_laws.dm)
// SS220 picks a line from strings/new_space_laws.txt (Russian). Our 25 bans are written anew in Polish for the NSV
// setting and kept in the code, so every ban is one whole sentence for the English version. Announcement only, like SS220:
// nothing enforces the ban, it is up to the crew and security how seriously they take it.

/datum/round_event_control/aquila_hex_new_space_law
	name = "Nowe prawo kosmiczne"
	typepath = /datum/round_event/aquila_hex_new_space_law
	weight = 10
	max_occurrences = 2
	earliest_start = 10 MINUTES

/datum/round_event/aquila_hex_new_space_law
	fakeable = FALSE
	announceWhen = 1
	/// The ban announced this time
	var/new_law

/datum/round_event/aquila_hex_new_space_law/setup()
	new_law = pick(aquila_hex_space_law_bans())

/datum/round_event/aquila_hex_new_space_law/announce(fake)
	priority_announce(law_text(), "Dział Prawny Nanotrasen")
	log_game("New Space Law: [new_law]")

/// Text of the announcement
/datum/round_event/aquila_hex_new_space_law/proc/law_text()
	return "W związku z ostatnimi wydarzeniami w polityce sektora z dniem dzisiejszym zakazuje się: [new_law] Zakaz wpisano do Prawa Kosmicznego jako artykuł 1xx. Załoga ma 15 minut na dostosowanie się do nowych przepisów. Zalecamy pośpiech."

/// Bans of the new space law event, each a whole sentence
/proc/aquila_hex_space_law_bans()
	var/static/list/bans = list(
		"noszenia skarpet do sandałów w strefach publicznych.",
		"nazywania kosmicznego karpia „rybką”.",
		"głaskania corgich bez pisemnej zgody kapitana.",
		"podgrzewania ryb w mikrofalówce w kuchni wspólnej.",
		"mówienia „to na pewno nie wybuchnie” w obecności inżynierów.",
		"noszenia kapeluszy w pomieszczeniach bez okien.",
		"gwizdania na korytarzach w pobliżu śluz.",
		"dotykania czerwonych przycisków, nawet jeśli bardzo kuszą.",
		"wkładania bananów do kieszeni munduru.",
		"spożywania kawy z kubków innych działów.",
		"wypowiadania słowa „Syndykat” trzy razy przed lustrem.",
		"tańczenia w windzie, jeśli jedzie z nią ktoś z dowództwa.",
		"noszenia okularów przeciwsłonecznych w nocy pokładowej.",
		"nazywania SI „kalkulatorem”.",
		"robienia zdjęć kapitanowi, gdy je.",
		"chodzenia boso po mostku.",
		"chowania kanapek w szafkach technicznych.",
		"wymieniania hot-dogów z Orlenu na kredyty pokładowe.",
		"śpiewania szant przez radio ogólne.",
		"rozmów z klaunem o podatkach.",
		"zostawiania skórek od bananów w promieniu pięciu kroków od ochrony.",
		"mówienia „za moich czasów” przez osoby młodsze niż trzydzieści lat.",
		"przytulania automatów z przekąskami.",
		"używania wykrzykników w komunikatach na kanale dowodzenia.",
		"wysyłania faksów do Centrali z życzeniami urodzinowymi dla samego siebie.",
	)
	return bans
