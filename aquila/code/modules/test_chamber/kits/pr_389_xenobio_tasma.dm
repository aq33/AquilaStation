// aq33/AquilaStation#389 - pasywna nauka z klatki xenobio, torba bio w maszynie do plortów, taśma na usta, toaleta w myśliwcach

/datum/test_chamber_kit/pr_389
	name = "PR 389: nauka z okazów, torba bio, taśma"
	pr = "aq33/AquilaStation#389"
	description = "Na arenie stoi niewidzialny monitor okazów (ten sam, który spawner klatki xenobio zostawia w klatce); małpy liczą się jako okazy. \
	Na konsoli B+R obserwuj punkty General Research: ma przybywać 25 pkt/s na każdą żywą małpę (max 5). Zabij małpę - przychód spada. \
	Torba bio z rdzeniami slime'ów: kliknij nią maszynę do plortów - ma sprzedać wszystkie rdzenie naraz. \
	Taśma klejąca na usta człowieka (cel: usta, nie harm): po 3 s (1 s na sobie) usta zaklejone, mowa wyciszona; po zerwaniu taśma się zgniata i znika. \
	Toaleta w myśliwcach nie jest w zestawie - sprawdź w hangarze: pilot myśliwca ma przycisk z sedesem (górniczy Sabre i kapsuły go nie mają)."
	items = list(
		/obj/effect/xenobio_specimen_monitor = 1,
		/mob/living/carbon/monkey = 3,
		/obj/machinery/computer/rdconsole/core = 1,
		/obj/machinery/plortrefinery = 1,
		/obj/item/storage/bag/bio = 1,
		/obj/item/stack/sticky_tape = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_389/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/obj/item/storage/bag/bio/bag = locate() in spawned
	if(!bag)
		return
	for(var/i in 1 to 5)
		new /obj/item/slime_extract/grey(bag)
