// Rework systemów okrętu (gałąź naped-okretu): dysze, podział mocy, matryce sensorów, maska tarczy, kalibracja FTL,
// stół projektowy pocisków i nowe ładunki, Echo, zlecenia działów

/datum/test_chamber_kit/pr_naped_missiles
	name = "Okręt: projekty pocisków i ładunki"
	pr = "aq33/AquilaStation#644"
	description = "Zestaw: stół projektowy pocisków, obudowy torped i rakiet, wszystkie nowe głowice, części i narzędzia, karta uzbrojenia. 1) Stół projektowy (karta z zestawu): wybierz silnik i naprowadzanie (brak, podczerwień, radar, z okrętu) i zapisz projekt. Połóż na stole układ napędowy albo układ naprowadzania i kliknij „Przerób”. Okno pokazuje prędkość, zasięg i odporność względem zwykłej torpedy. 2) Złóż torpedę z przerobionych części (napęd, naprowadzanie, karta IFF, głowica, kabel, śrubokręt); examine gotowej torpedy pokazuje projekt. 3) Nowe głowice: dyfuzor tarcz (torpeda zdejmuje celowi połowę tarczy, rakieta 1/3, sam rani słabo), sonda czujnikowa (nie rani, zostawia boję na 3 minuty, DRADIS pokazuje kontakty w promieniu 12 pól z dokładnym położeniem), rakieta zakłócająca (EMP). Strzelanie i efekty na overmapie sprawdź na statku: torpedy i rakiety z zestawu przenieś do wyrzutni (receptury głowic są w protolacie uzbrojenia: sondy w Amunicji kierowanej II, EMP i dyfuzory w Prototypie głowicy zakłócającej)."
	items = list(
		/obj/machinery/missile_design_table = 1,
		/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing = 2,
		/obj/item/ship_weapon/ammunition/missile/missile_casing = 2,
		/obj/item/ship_weapon/parts/missile/warhead/diffuser = 1,
		/obj/item/ship_weapon/parts/missile/warhead/sensor_probe = 1,
		/obj/item/ship_weapon/parts/missile/warhead/emp = 1,
		/obj/item/ship_weapon/parts/missile/warhead/diffuser_missile = 1,
		/obj/item/ship_weapon/parts/missile/warhead/sensor_probe_missile = 1,
		/obj/item/ship_weapon/parts/missile/propulsion_system = 4,
		/obj/item/ship_weapon/parts/missile/guidance_system = 4,
		/obj/item/ship_weapon/parts/missile/iff_card = 4,
		/obj/item/stack/cable_coil = 1,
		/obj/item/screwdriver = 1,
		/obj/item/wrench = 1,
		/obj/item/weldingtool/experimental = 1,
		/obj/item/multitool = 1,
		/obj/item/card/id = 1,
		/obj/item/ship_weapon/ammunition/torpedo/diffuser = 1,
		/obj/item/ship_weapon/ammunition/torpedo/sensor_probe = 1,
		/obj/item/ship_weapon/ammunition/missile/emp = 1,
	)

/datum/test_chamber_kit/pr_naped_missiles/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	for(var/obj/item/card/id/card in spawned)
		card.name = "karta uzbrojenia"
		card.access = list(ACCESS_MUNITIONS)

/datum/test_chamber_kit/pr_naped_ship
	name = "Okręt: dysze, moc, sensory, tarcza, FTL, Echo, zlecenia"
	pr = "aq33/AquilaStation#644"
	description = "Te systemy działają na całym okręcie, więc sprawdza się je na mapie (zestaw daje kartę z pełnym dostępem, multitool, plastal i palnik). 1) Dysze: rufa każdego statku ma dysze z podgrzewaczami; paliwo idzie rurą z atmosu. Wyłączone albo zniszczone dysze obniżają ciąg (minimum 10%). Zniszczoną dyszę naprawisz 5 arkuszami plastali i palnikiem. Mieszanka: plazma z tlenem w proporcji 1:2 daje +30%. 2) Podział mocy: konsola monitorowania zasilania, zakładka Podział mocy (dostęp inżynierii): limity i priorytety tarczy, silników, FTL, uzbrojenia, sensorów i pancerza, gotowe ustawienia Walka, Ucieczka, Skok, Cisza. 3) Matryce sensorów: cztery na kadłubie (dziób, burty, rufa). Wyłączona albo zniszczona matryca zostawia ślepą ćwiartkę radaru (tylko kamera). Zasięg i włączanie w konsoli sensorów; przegrzewają się przy dużym zasięgu. 4) Maska: w generatorze tarczy, sygnatura ×0,2, trwa dopóki jest prąd (bez limitu czasu i stygnięcia), w masce tarcza nie chroni. Na overmapie bańka tarczy. 5) Kalibracja FTL: zakładka w konsoli FTL, dostrój fale pylonów; zła kalibracja wydłuża ładowanie i zwiększa szansę wypadku przy skoku. 6) Echo: piloci trafiają do drużyny Echo sami, dowódcy dopisują ochotników w konsoli drużyn, dopóki członków jest mniej niż myśliwców; Echo daje dostęp do myśliwców i hangaru. 7) Zlecenia działów: u handlarza na stacji (zaopatrzenie albo dowództwo) zakładka Zlecenia dla działów; dostawy wysyła się torpedą transportową, zlecenie ochrony to abordaż na nasz okręt, medyczne to kapsuła z rannymi albo zwłokami, serwisu to goście w restauracji albo barze (portal otwiera się tylko na czas zlecenia). Przyjęte zlecenia widać w konsoli zgłoszeń."
	items = list(
		/obj/item/card/id/captains_spare = 1,
		/obj/item/multitool = 1,
		/obj/item/stack/sheet/plasteel/fifty = 1,
		/obj/item/weldingtool/experimental = 1,
	)
