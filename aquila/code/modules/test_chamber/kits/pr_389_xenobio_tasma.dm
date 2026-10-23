// aq33/AquilaStation#389 - pasywna nauka z klatki xenobio, taśma na usta, toaleta w myśliwcach (maszynę do plortów z torbą bio zastąpił rynek ekstraktów z #487)

/datum/test_chamber_kit/pr_389
	name = "PR 389: nauka z okazów, taśma"
	pr = "aq33/AquilaStation#389"
	description = "Na arenie stoi niewidzialny monitor okazów (ten sam, który spawner klatki xenobio zostawia w klatce); małpy liczą się jako okazy. \
	Na konsoli B+R obserwuj punkty General Research: ma przybywać 25 pkt/s na każdą żywą małpę (max 5). Małp jest 6, więc pierwsza zabita nie zmienia przychodu, dopiero kolejne go obniżają. \
	Taśma klejąca na usta człowieka (cel: usta, nie harm): po 3 s (1 s na sobie) usta zaklejone, mowa wyciszona; po zerwaniu taśma się zgniata i znika. \
	Toaleta w myśliwcach nie jest w zestawie - sprawdź w hangarze: pilot myśliwca ma przycisk z sedesem (górniczy Sabre i kapsuły go nie mają)."
	items = list(
		/obj/effect/xenobio_specimen_monitor = 1,
		/mob/living/carbon/monkey = 6,
		/obj/machinery/computer/rdconsole/core = 1,
		/obj/item/stack/sticky_tape = 1,
		/mob/living/carbon/human = 1,
	)
