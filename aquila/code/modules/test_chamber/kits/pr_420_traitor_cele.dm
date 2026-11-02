// aq33/AquilaStation#420 - nowe cele traitora, główny serwer B+R, historia zdrajcy

/datum/test_chamber_kit/pr_420
	name = "PR 420: cele traitora - przedmioty"
	pr = "aq33/AquilaStation#420"
	description = "Najpierw weź zestaw „zrób mnie zdrajcą”, dopiero potem ten (urządzenia do podkładania działają z celami). Zwłoki do testów leżą w zestawie. \
	1) Kliknij papierem z trucizną laser leżący na ziemi (3 s) i podnieś laser bez rękawic → oczekiwane: dostajesz dawkę trucizny do organizmu (UWAGA: initropidril jest groźny, miej antidotum). Podniesiony ponownie laser już nie truje (dawka zużyta). \
	2) Kliknij drugim papierem teleporter ręczny, załóż czarne rękawice i podnieś go → oczekiwane: brak dawki. Negatyw: papier po użyciu (pusty) → komunikat „Na papierze nie ma już trucizny!”. \
	3) Zrób aparatem zdjęcie leżących zwłok i połóż przy nich wizytówkę → oczekiwane: zdjęcie ze zwłokami w kadrze, wizytówka leży przy ciele (zaliczenie samych celów „zdjęcie zwłok” i „wizytówka” wymaga przydzielonej ofiary, której ten zestaw nie ustawia - sprawdzasz tylko mechanikę przedmiotów). \
	4) Implantem szantażu (tylko admin) oznacz zwłoki lub siebie → oczekiwane: implant wchodzi bez błędów. \
	5) Moduł prawa SI wgrywa się przez konsolę wgrywania praw SI (jest w zestawie), ale wymaga ducha: aktywnej SI (admin zrobi SI z gracza) → bez SI konsola odpowie „Nie wykryto aktywnych SI!”. \
	6) Dysk z serwera B+R i narzędzia do serwera (śrubokręt, łom, przecinak) → do użycia w zestawie z maszynami. \
	Nie do sprawdzenia w komorze: zdrajca na zdrajcę (wymaga drugiego zdrajcy z ostrzeżeniem dla ofiary) i kradzież przedmiotów działowych."
	items = list(
		/mob/living/carbon/human = 1,
		/obj/machinery/computer/upload/ai = 1,
		/obj/item/poison_paper = 2,
		/obj/item/gun/energy/laser/captain = 1,
		/obj/item/hand_tele = 1,
		/obj/item/clothing/gloves/color/black = 1,
		/obj/item/paper/calling_card = 1,
		/obj/item/implanter/blackmail = 1,
		/obj/item/computer_hardware/hard_drive/cluster/hdd_theft = 1,
		/obj/item/screwdriver = 1,
		/obj/item/crowbar = 1,
		/obj/item/wirecutters = 1,
		/obj/item/multitool = 1,
		/obj/item/camera = 1,
		/obj/item/aiModule/syndicate = 1,
	)

/// Zwłoki do testów celów z zestawu przedmiotów
/datum/test_chamber_kit/pr_420/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	for(var/mob/living/carbon/human/corpse in spawned)
		corpse.real_name = "zwłoki do celów"
		corpse.name = corpse.real_name
		corpse.death()

/datum/test_chamber_kit/pr_420_machines
	name = "PR 420: cele traitora - maszyny"
	pr = "aq33/AquilaStation#420"
	description = "Najpierw weź zestaw „zrób mnie zdrajcą”, potem ten (narzędzia: śrubokręt, łom i przecinak są w pasach z narzędziami). \
	1) Główny serwer B+R: śrubokręt → łom → przecinak jako zdrajca → oczekiwane: wyjmujesz dysk, generacja punktów badań spada o połowę. Negatyw: ta sama sekwencja jako zwykły gracz (bez statusu antagonisty) → oczekiwane: żadnej klapy, serwer się nie otwiera. \
	2) Hub telekomunikacji: włóż dysk z danymi → oczekiwane: cel „dane z tcomms” się zalicza. \
	3) Konsola łączności: użyj przechwytywacza (UWAGA: naprawdę ściąga zagrożenie na statek) → oczekiwane: cel włamania do łączności się zalicza. \
	4) Kloner i SMES: zniszcz je → oczekiwane: cel zniszczenia maszyn się zalicza. \
	5) Drzwi: podłóż wirusa T1de → oczekiwane: cel T1de się zalicza."
	items = list(
		/obj/machinery/rnd/server/master = 1,
		/obj/machinery/telecomms/hub = 1,
		/obj/machinery/computer/communications = 1,
		/obj/machinery/clonepod = 1,
		/obj/machinery/power/smes = 1,
		/obj/machinery/door/airlock = 2,
	)

/// Makes the user a traitor with test versions of the objectives, all targeting the chamber
/datum/test_chamber_kit/pr_420_traitor
	name = "PR 420: zrób mnie zdrajcą z celami testowymi"
	pr = "aq33/AquilaStation#420"
	description = "Kolejność: najpierw ten zestaw, potem „przedmioty” i „maszyny”. \
	1) Weź zestaw (trzeba być człowiekiem w komorze) → oczekiwane: jesteś zdrajcą, w czacie lista celów, otwiera się okno historii. \
	2) Wybierz frakcję i historię → oczekiwane: dopiero teraz pojawia się uplink (Syndykat z hasłami, czarny rynek i niezależny bez haseł). Negatyw: nie wybieraj nic - bez wyboru nie ma uplinka (po 5 minutach Syndykat automatycznie). \
	3) Cele celują w komorę: podsłuch, wirus T1de, bomba (wybuchnie w komorze!), zatrucie lasera i teleportera, dane z tcomms, włamanie do łączności, dysk B+R, beacon braci → oczekiwane: urządzenia do podkładania masz w ekwipunku. \
	4) Stan celów sprawdzisz w oknie zdrajcy albo przez Traitor Panel → oczekiwane: cele zmieniają się na zaliczone po wykonaniu. \
	Do łączności, huba i serwera weź zestaw z maszynami."
	items = list(
		/obj/item/gun/energy/laser/captain = 1,
		/obj/item/hand_tele = 1,
		/obj/item/clothing/gloves/color/black = 1,
	)

/datum/test_chamber_kit/pr_420_traitor/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H) || !H.mind)
		to_chat(user, "<span class='warning'>Musisz być człowiekiem w komorze, żeby zostać zdrajcą. Przedmioty i tak leżą na arenie.</span>")
		return
	var/area/chamber_area = get_area(center)
	var/datum/antagonist/traitor/traitor = H.mind.has_antag_datum(/datum/antagonist/traitor)
	if(!traitor)
		traitor = new
		traitor.give_objectives = FALSE
		H.mind.add_antag_datum(traitor)
	var/list/new_objectives = list()

	for(var/device_type in list(/datum/objective/plant_device/bug, /datum/objective/plant_device/tide, /datum/objective/plant_device/bomb))
		var/datum/objective/plant_device/plant = new device_type
		plant.owner = H.mind
		plant.target_areas = list(chamber_area)
		if(istype(plant, /datum/objective/plant_device/tide))
			var/datum/objective/plant_device/tide/tide = plant
			tide.department_name = "komora testowa"
		plant.update_explanation_text()
		plant.give_device()
		new_objectives += plant

	var/datum/objective/poison_items/poison = new
	poison.owner = H.mind
	poison.target_paths = list(/obj/item/gun/energy/laser/captain = "zabytkowy laser kapitana", /obj/item/hand_tele = "teleporter ręczny")
	poison.update_explanation_text()
	poison.give_papers()
	new_objectives += poison

	var/datum/objective/tcomms_data/tcomms = new
	tcomms.owner = H.mind
	tcomms.give_special_equipment(list(/obj/item/disk/tcomms_data))
	new_objectives += tcomms

	var/datum/objective/hack_comms/hack = new
	hack.owner = H.mind
	hack.give_special_equipment(list(/obj/item/comms_hacker))
	new_objectives += hack

	var/datum/objective/steal/hdd/hdd = new
	hdd.owner = H.mind
	var/datum/objective_item/steal/hdd_extraction/hdd_item = locate() in GLOB.possible_items
	if(hdd_item)
		hdd.set_steal_target(hdd_item)
		new_objectives += hdd
	else
		qdel(hdd)

	if(!GLOB.brother_beacon_site)
		GLOB.brother_beacon_site = center
	var/datum/objective/brother_beacon/beacon = new
	beacon.owner = H.mind
	if(beacon.setup_beacon())
		new_objectives += beacon
	else
		qdel(beacon)

	for(var/datum/objective/objective as anything in new_objectives)
		traitor.add_objective(objective)
	if(traitor.uses_backstory() && !traitor.faction)
		traitor.setup_backstories(FALSE, FALSE)
		traitor.update_static_data(H)
	H.mind.announce_objectives()
	traitor.ui_interact(H)
