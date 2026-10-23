// aq33/AquilaStation#322 - infiltratorzy: poprawki portu + poprawki z Yogstation

/datum/test_chamber_kit/pr_322
	name = "PR 322: zrób mnie infiltratorem"
	pr = "aq33/AquilaStation#322"
	description = "Robi z ciebie infiltratora bez przenoszenia do bazy (trzeba być człowiekiem w komorze; dostajesz losowe imię i strój infiltratora). \
	Otwórz uplink przez lokalizator w prawym górnym rogu: mają być kategorie Services / Infiltration Gear, nie może być e-miecza ani C4. \
	Kup Access Kit (5 TC, tylko raz) i Manifest Spoof (4 TC, limit 1). Access Kit: wybierz pracę i przyłóż do ID - dostęp tej pracy. \
	Manifest Spoof z ID na sobie - wpis w manifeście. Dusting implant: zamknięcie okienka potwierdzenia NIE może cię spopielić. Leżący zestaw to zapas na wypadek braku TC."
	items = list(
		/obj/item/access_kit/syndicate = 1,
		/obj/item/service/manifest = 1,
		/obj/item/clothing/suit/space/hardsuit/infiltration = 1,
	)

/datum/test_chamber_kit/pr_322/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H) || !H.mind)
		to_chat(user, "<span class='warning'>Musisz być człowiekiem w komorze, żeby zostać infiltratorem. Przedmioty i tak leżą na arenie.</span>")
		return
	if(H.mind.has_antag_datum(/datum/antagonist/infiltrator))
		return
	var/datum/antagonist/infiltrator/infiltrator = new
	infiltrator.send_to_spawnpoint = FALSE
	H.mind.add_antag_datum(infiltrator)
