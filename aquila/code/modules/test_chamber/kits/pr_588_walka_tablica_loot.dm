// aq33/AquilaStation#588 - animacje ataku i pchnięcie (tg#88418), tablica detektywa (tg#85609), okno kafelka RPG Loot (tg#82533)

/datum/test_chamber_kit/pr_588
	name = "Animacje ataku, pchnięcie, tablica detektywa, okno kafelka"
	pr = "aq33/AquilaStation#588"
	description = "1) Animacje: w combat mode uderz obiekt testowy nożem, kataną, włócznią i skrzynką z narzędziami. Nóż i katana tną łukiem, włócznia pcha, skrzynka uderza jak dotąd. Sprawdź atak z każdego kierunku, także po skosie: ostrze ma iść czubkiem do celu, nie rękojeścią. \
	2) Pchnięcie: prawym przyciskiem nożem bojowym, kataną i włączonym mieczem energetycznym (w trybie intencji: intencja rozbrajania i lewy). W czacie „dźga/przebija”, obrażenia nieco mniejsze (nóż bojowy 15 zamiast 20), rana kłuta (skaner). Zwykły nóż kuchenny też pcha, ale bez zmniejszenia siły. Wyłączony miecz energetyczny nie pcha. Examine noża pokazuje podpowiedź. \
	3) Przebicie pancerza: uderz szafę (pancerz 20, wytrzymałość 200) włączonym mieczem energetycznym (siła 30, przebicie 35). Każdy cios zabiera 30 wytrzymałości (VV: obj_integrity), bez przebicia zabierałby 24. \
	4) Tablica: zamontuj ją na ścianie, kliknij, załóż sprawę, przypnij zdjęcie (aparat) i kartkę, przeciągnij dowody, połącz pinezki nitką, kliknij dowód (podgląd), usuń dowód i sprawę (jej dowody spadają). Załóż nową sprawę, przypnij do niej kartkę i dopiero wtedy prawym przyciskiem kluczem zdejmij tablicę: kartka spada na podłogę. \
	5) Okno kafelka: rozsyp przedmioty na jednym polu, Alt+klik na podłogę albo przedmiot: okno z ikonami, wyszukiwarka, grupowanie, klik bierze przedmiot, Shift+klik ogląda, Esc zamyka. Alt+klik na krzesło obraca je bez okna. Jako duch Alt+klik też otwiera okno."
	items = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/kitchen/knife/combat = 1,
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
		/obj/structure/closet = 1,
	)

// Druga część tego samego PR-a: zupy (tg#74205) i halucynacje (Bee#13095, tg#89865)
/datum/test_chamber_kit/pr_588_kuchnia
	name = "Zupy z garnka i halucynacje"
	pr = "aq33/AquilaStation#588"
	description = "Zestaw stawia kuchenkę na prawo od środka areny i kuchnię z piekarnikiem na lewo, a zlewka ma 100 jednostek wody. \
	1) Zupa: postaw garnek na kuchence, wlej 50 wody, wrzuć klopsik, marchewkę i ziemniak, włącz palniki prawym przyciskiem albo Alt+klikiem. Po chwili w garnku jest zupa z klopsikami (examine, skaner). Pustą chochlą kliknij garnek (nabiera porcję), potem miskę (przelewa): miska wygląda jak zupa z klopsikami i nazywa się „miska: zupa z klopsikami”. Wyjmij składnik prawym przyciskiem pustą ręką. Woda w garnku ma widoczny kolor, a para nad kuchenką nie jest ucinana. Bez składników woda nie zmienia się w zupę. \
	2) Kuchnia z piekarnikiem: postaw na niej garnek i sprawdź palniki, otwórz piekarnik, włóż blachę z ciastem (oba w zestawie) i upiecz chleb. Z płytki (projekt w R&D, Przetwarzanie biologiczne) zbudujesz kolejną. \
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
		/obj/item/plate/oven_tray = 1,
		/obj/item/food/dough = 1,
		/obj/item/reagent_containers/syringe = 1,
	)

/datum/test_chamber_kit/pr_588_kuchnia/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/turf/stove_spot = locate(center.x + 2, center.y, center.z)
	if(stove_spot && !stove_spot.density)
		new /obj/machinery/stove(stove_spot)
	var/turf/range_spot = locate(center.x - 2, center.y, center.z)
	if(range_spot && !range_spot.density)
		new /obj/machinery/oven/range(range_spot)
	var/obj/item/reagent_containers/glass/beaker/large/water = new(center)
	water.reagents.add_reagent(/datum/reagent/water, 100)
	var/obj/item/reagent_containers/glass/beaker/large/mindbreaker = new(center)
	mindbreaker.reagents.add_reagent(/datum/reagent/toxin/mindbreaker, 30)
