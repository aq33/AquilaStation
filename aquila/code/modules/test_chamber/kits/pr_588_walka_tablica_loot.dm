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

// Druga część tego samego PR-a: zupy (tg#74205) i halucynacje (Bee#13095, tg#89865)
/datum/test_chamber_kit/pr_588_kuchnia
	name = "Zupy z garnka i halucynacje"
	pr = "aq33/AquilaStation#588"
	description = "Zestaw stawia kuchenkę obok środka areny, a zlewka ma 100 jednostek wody. \
	1) Zupa: postaw garnek na kuchence, wlej 50 wody, wrzuć klopsik, marchewkę i ziemniak, włącz palniki prawym przyciskiem albo Alt+klikiem. Po chwili w garnku jest zupa z klopsikami (examine, skaner). Chochlą przelej porcję do miski: miska wygląda jak zupa z klopsikami i nazywa się „miska: zupa z klopsikami”. Wyjmij składnik prawym przyciskiem pustą ręką. Bez składników woda nie zmienia się w zupę. \
	2) Kuchnia z piekarnikiem: zbuduj z płytki (projekt w R&D, Przetwarzanie biologiczne) i sprawdź palniki oraz piekarnik. \
	3) Restauracja: robot zamawia „porcję zupy”, przyjmuje miskę z tą zupą. \
	4) Halucynacje: wstrzyknij sobie mindbreaker (syringe), krótko: zwykłe halucynacje (fałszywe dźwięki, czat), dłużej: rzadsze i skrajne. Sprawdź krwawienie, głos w głowie, oczy w ciemności (zgaś światło). Skaner zaawansowany pokazuje halucynacje. Mindbreaker na Zaburzeniach Dysocjacyjnych je zdejmuje. \
	5) Preferencje → Gra: przełącznik „Halucynacje bez limitu”."
	items = list(
		/obj/item/reagent_containers/glass/soup_pot = 1,
		/obj/item/reagent_containers/glass/soup_ladle = 1,
		/obj/item/reagent_containers/glass/bowl = 3,
		/obj/item/food/meatball = 2,
		/obj/item/food/grown/carrot = 2,
		/obj/item/food/grown/potato = 2,
		/obj/item/circuitboard/machine/range = 1,
		/obj/item/reagent_containers/syringe = 1,
	)

/datum/test_chamber_kit/pr_588_kuchnia/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/turf/stove_spot = locate(center.x + 2, center.y, center.z)
	if(stove_spot && !stove_spot.density)
		new /obj/machinery/stove(stove_spot)
	var/obj/item/reagent_containers/glass/beaker/large/water = new(center)
	water.reagents.add_reagent(/datum/reagent/water, 100)
	var/obj/item/reagent_containers/glass/beaker/large/mindbreaker = new(center)
	mindbreaker.reagents.add_reagent(/datum/reagent/toxin/mindbreaker, 30)
