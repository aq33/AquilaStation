// aq33/AquilaStation#440 - detektyw (luminol, ślady prochu, balistyka, logi drzwi, miejsce zbrodni) i genpop po polsku

/datum/test_chamber_kit/pr_440_forensics
	name = "PR 440: luminol, ślady prochu, balistyka"
	pr = "aq33/AquilaStation#440"
	description = "Zestaw ma dwóch ludzi do testów. \
	1) Zrań człowieka nożem, umyj krew mopem lub cleanerem, popsikaj luminolem → oczekiwane: po umyciu krew znika, luminol pokazuje świecące ślady; zeskanuj je skanerem detektywa → oczekiwane: wpis o krwi. \
	2) Strzel z Makarowa (ostra amunicja), zeskanuj swoje dłonie, broń, łuskę i ciało → oczekiwane: na dłoniach i broni ślady prochu, na łusce i pocisku sygnatura gwintu lufy, w ciele fragmenty pocisku (wyjmij je chirurgią ciał obcych). \
	3) Obejrzyj Makarowa z bliska, spiłuj numer seryjny śrubokrętem → oczekiwane: po 6 s przy examine „Numer seryjny został spiłowany”; drugie spiłowanie → „jest już spiłowany”. \
	4) Strzel z dwururki, zeskanuj łuskę, obetnij lufę piłą i strzel ponownie → oczekiwane: sygnatura po obcięciu lufy jest inna. \
	5) Negatyw: umyj ręce mydłem po strzale i zeskanuj → oczekiwane: śladów prochu na dłoniach brak. Strzał w czarnych rękawicach i zeskanowanie → ślady prochu zostają na rękawicach, nie na dłoniach. \
	6) Zabij obiekt (nóż, pięść, strzał, rzut), połóż na stole operacyjnym i zeskanuj skanerem do autopsji → oczekiwane: przy kończynach widać rany, czym zadane, kiedy, oraz kule w ciele."
	items = list(
		/obj/item/detective_scanner = 1,
		/obj/item/reagent_containers/spray/luminol = 2,
		/obj/item/kitchen/knife = 1,
		/obj/item/mop = 1,
		/obj/item/reagent_containers/spray/cleaner = 1,
		/obj/item/soap/nanotrasen = 1,
		/obj/item/gun/ballistic/automatic/pistol/glock/makarov/lethal = 1,
		/obj/item/gun/ballistic/shotgun/doublebarrel = 1,
		/obj/item/circular_saw = 1,
		/obj/item/screwdriver = 1,
		/obj/item/clothing/gloves/color/black = 1,
		/obj/item/storage/box/evidence = 1,
		/obj/structure/table/optable = 1,
		/obj/item/scalpel = 1,
		/obj/item/hemostat = 1,
		/obj/item/retractor = 1,
		/obj/item/autopsy_scanner = 1,
		/mob/living/carbon/human = 2,
	)

/datum/test_chamber_kit/pr_440_scene
	name = "PR 440: logi drzwi i miejsce zbrodni"
	pr = "aq33/AquilaStation#440"
	description = "Na kartę detektywa nie licz - karta kapitana w zestawie otwiera wszystko. \
	1) Drzwi i szafka ochrony wymagają dostępu: otwórz je kartą kapitana, potem w tablecie detektywa włącz „Czytnik logów dostępu” i kliknij tabletem w drzwi → oczekiwane: lista wejść z godziną, można ją wydrukować. Użyj emaga na drzwiach → log się czyści. \
	2) Rozciągnij taśmę (użyj rolki dwa razy). Przejdź przez nią z kartą ochrony/kapitana → oczekiwane: taśma się unosi, bez śladu. \
	3) Negatyw: przejdź przez taśmę bez karty ochrony (odłóż kartę) → oczekiwane: taśma się gniecie i zostaje na niej twój odcisk (skaner detektywa go pokaże). W trybie walki bez karty zrywasz taśmę. \
	4) Postaw znaczniki, obrysuj kredą leżące zwłoki (martwy człowiek jest w zestawie) → oczekiwane: obrys wokół ciała, numerowane znaczniki. \
	5) Postaw rażącą holobarierę detektywa; na projektorze ochrony włącz strefę zamkniętą (przycisk akcji) → oczekiwane: holobariera/strefa pojawia się i blokuje przejście osobom bez dostępu."
	items = list(
		/obj/item/modular_computer/tablet/pda/detective = 1,
		/obj/item/card/id/captains_spare = 1,
		/obj/machinery/door/airlock/security = 1,
		/obj/structure/closet/secure_closet/security = 1,
		/obj/item/barrier_tape_roll = 1,
		/obj/item/storage/box/csi_markers = 1,
		/obj/item/toy/crayon/white/chalk = 1,
		/obj/item/holosign_creator/detective = 1,
		/obj/item/holosign_creator/security = 1,
		/obj/item/detective_scanner = 1,
		/obj/item/card/emag = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_440_scene/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	for(var/obj/machinery/door/airlock/security/door in spawned)
		door.req_access = list(ACCESS_SECURITY)
	// Ciało do obrysowania kredą
	for(var/mob/living/carbon/human/corpse in spawned)
		corpse.real_name = "zwłoki do obrysowania"
		corpse.name = corpse.real_name
		corpse.death()

/datum/test_chamber_kit/pr_440_genpop
	name = "PR 440: genpop po polsku"
	pr = "aq33/AquilaStation#440"
	description = "1) Otwórz interfejs więźniów (karta kapitana daje dostęp) i zaznacz kilka zarzutów z różnych kategorii → oczekiwane: czas wyroku się sumuje. \
	2) Zaznacz modyfikatory (usiłowanie, recydywa, opór) → oczekiwane: czas zmienia się zgodnie z modyfikatorem. \
	3) Wydrukuj kartę, przyłóż „Zwolnij” i „Uciekł” do zwolnionej już karty → oczekiwane: wraca do odliczania. \
	4) Negatyw: odznacz wszystkie zarzuty i spróbuj wydrukować kartę → oczekiwane: brak karty, czas wyroku 0."
	items = list(
		/obj/machinery/genpop_interface = 1,
		/obj/item/card/id/captains_spare = 1,
	)
