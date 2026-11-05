/datum/test_chamber_kit/pr_556
	name = "PR 556: wstępny rework botaniki"
	pr = "aq33/AquilaStation#556"
	description = "Dwie tace mają już podłoże (ziemia) i wodę, wiadro jest pełne. Maszyny stoją bez terminala. Sprawdź w obu trybach sterowania (combat mode i intencje). \
		1) Posadź pomidora i marchew w jednej tacy, poczekaj na owoce i kliknij pustą ręką tacę albo dowolną roślinę → oczekiwane: zbierają się owoce ze wszystkich roślin naraz; gdy nic nie dojrzało, komunikat to mówi. \
		2) Zeskanuj tacę skanerem roślin → oczekiwane: w czacie zwykłym kolorem podłoże, płyny, chwasty, miejsce i krótki stan roślin. Zeskanuj roślinę → oczekiwane: na górze okna sekcja „Stan”, szczegóły pod rozwijanym nagłówkiem; okno wygląda jak zwykła konsola NT. \
		3) Negatyw: w pustej tacy wykop ziemię łopatką, wsyp piasek z worka i posadź jabłoń → oczekiwane: nie da się, a komunikat mówi, że trzeba ziemi. Nazwa paczki w ręce też podaje podłoże. \
		4) Kliknij analizator, sekwencer i piec pustą ręką → oczekiwane: okno otwiera się bez terminala. \
		5) Włóż nasiona pomidora do pieca, zmutuj owoc i wciśnij „Wyjmij nasiona” → oczekiwane: paczka wraca z nową nazwą i nową częścią. \
		6) Złap tacę (ciągnij) i klikaj w kafel nad drugą tacą, gdzie wystają rośliny → oczekiwane: ciągnięta taca jedzie w stronę kliknięcia. To samo spróbuj z matrycą refrakcyjną i opisz, co się dzieje."
	items = list(
		/obj/machinery/plant_machine/plant_analyser = 1,
		/obj/machinery/plant_machine/seed_editor = 1,
		/obj/machinery/plant_machine/plant_mutator = 1,
		/obj/machinery/refraction_catalogue = 1,
		/obj/item/plant_tray = 2,
		/obj/item/substrate_bag/sand = 1,
		/obj/item/plant_scanner = 1,
		/obj/item/reagent_containers/glass/bucket = 1,
		/obj/item/shovel/spade = 1,
		/obj/item/plant_seeds/preset/tomato = 2,
		/obj/item/plant_seeds/preset/apple = 1,
		/obj/item/plant_seeds/preset/carrot = 1,
	)

/datum/test_chamber_kit/pr_556/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	for(var/obj/item/reagent_containers/glass/bucket/bucket in spawned)
		bucket.reagents.add_reagent(/datum/reagent/water, bucket.reagents.maximum_volume)
	for(var/obj/item/plant_tray/tray in spawned)
		var/datum/component/planter/planter = tray.GetComponent(/datum/component/planter)
		planter?.set_substrate(/datum/plant_subtrate/dirt)
		tray.reagents.add_reagent(/datum/reagent/water, tray.reagents.maximum_volume)
