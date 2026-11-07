// aq33/AquilaStation#588 - animacje ataku i pchnięcie (tg#88418), tablica detektywa (tg#85609), okno kafelka RPG Loot (tg#82533)

/datum/test_chamber_kit/pr_588
	name = "Animacje ataku, pchnięcie, tablica detektywa, okno kafelka"
	pr = "aq33/AquilaStation#588"
	description = "1) Animacje: w combat mode uderz obiekt testowy nożem, kataną, włócznią i skrzynką z narzędziami. Nóż i katana tną łukiem, włócznia pcha, skrzynka uderza jak dotąd. Sprawdź atak z każdego kierunku, także po skosie: ostrze ma iść czubkiem do celu, nie rękojeścią. \
	2) Pchnięcie: prawym przyciskiem nożem, kataną i włączonym mieczem energetycznym (w trybie intencji: intencja rozbrajania i lewy). W czacie „dźga/przebija”, obrażenia nieco mniejsze, rana kłuta (skaner). Wyłączony miecz energetyczny nie pcha. Examine noża pokazuje podpowiedź. \
	3) Przebicie pancerza: uderz skrzynkę albo maszynę bronią z przebiciem (miecz energetyczny): zadaje więcej niż bez przebicia. \
	4) Tablica: zamontuj ją na ścianie, kliknij, załóż sprawę, przypnij zdjęcie (aparat) i kartkę, przeciągnij dowody, połącz pinezki nitką, kliknij dowód (podgląd), usuń dowód i sprawę. Prawym przyciskiem kluczem zdejmij tablicę: dowody spadają na podłogę. \
	5) Okno kafelka: rozsyp przedmioty na jednym polu, Alt+klik na podłogę albo przedmiot: okno z ikonami, wyszukiwarka, grupowanie, klik bierze przedmiot, Shift+klik ogląda, Esc zamyka. Alt+klik na krzesło obraca je bez okna. Jako duch Alt+klik też otwiera okno."
	items = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/katana = 1,
		/obj/item/spear = 1,
		/obj/item/storage/toolbox/mechanical = 1,
		/obj/item/melee/transforming/energy/sword = 1,
		/obj/item/wallframe/detectiveboard = 1,
		/obj/item/camera = 1,
		/obj/item/paper = 3,
		/obj/item/pen = 1,
		/obj/item/wrench = 1,
		/obj/item/healthanalyzer = 1,
		/obj/structure/chair = 1,
	)
