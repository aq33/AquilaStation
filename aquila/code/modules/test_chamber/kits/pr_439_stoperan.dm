/datum/test_chamber_kit/pr_439
	name = "Stoperan i bluespace tyłek"
	pr = "aq33/AquilaStation#439"
	description = "1) Automat górników (masz kartę z 500 punktami) → oczekiwane: jest pozycja „Pigułka stoperanu”, da się ją kupić. \
		2) Połknij pigułkę i zjedz pizzę → oczekiwane: przez 5 minut potrzeba wypróżnienia nie rośnie, po czasie wraca do normy z komunikatem. Druga pigułka połknięta w trakcie odświeża czas. \
		3) Negatyw: bez pigułki zjedzenie pizzy podnosi potrzebę wypróżnienia. \
		4) Toaleta (jest w zestawie) → oczekiwane: nadal zmniejsza potrzebę, także pod stoperanem. \
		5) Autochirurg z butt of holding (masz ustawioną potrzebę wypróżnienia): użyj go na sobie → oczekiwane: dostajesz tyłek przechowywania i przycisk akcji; użycie przycisku zeruje potrzebę, na podłodze nie ma kupy, komunikat o bluespace. \
		6) Użyj przycisku ponownie od razu → oczekiwane: „Kieszeń bluespace jeszcze się nie ustabilizowała.” (cooldown 30 s); po zerowej potrzebie: „Nie masz czego wysyłać w bluespace.” \
		7) Protolat (ma materiały, a węzeł „Pośladki bluespace” jest odblokowany w badaniach rundy - UWAGA, to zmiana trwała do końca rundy): wybierz „Tyłek przechowywania” w kategorii Medical Designs → oczekiwane: da się wydrukować, bez odblokowanego węzła pozycji by nie było."
	items = list(
		/obj/item/reagent_containers/pill/stoperan = 3,
		/obj/item/pizzabox/margherita = 2,
		/obj/machinery/vendor/mining = 1,
		/obj/item/card/id/mining = 1,
		/obj/item/autosurgeon/bluebutt_test = 1,
		/obj/structure/toilet = 1,
		/obj/machinery/rnd/production/protolathe = 1,
	)

/datum/test_chamber_kit/pr_439/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	// Punkty na zakup pigułki w automacie
	for(var/obj/item/card/id/mining/card in spawned)
		card.mining_points = 500
	// Potrzeba wypróżnienia, żeby przycisk tyłka miał co wysyłać w bluespace
	if(isliving(user))
		var/mob/living/tester = user
		tester.set_defecation(DEFECATION_SOMEWHAT)
	// Węzeł z projektem tyłka i materiały na kilka wydruków
	SSresearch.science_tech?.research_node_id("bluespace_butt", TRUE, FALSE, FALSE)
	for(var/obj/machinery/rnd/production/protolathe/lathe in spawned)
		var/datum/component/material_container/container = lathe.materials?.mat_container
		if(container)
			container.insert_amount_mat(3000, /datum/material/iron)
			container.insert_amount_mat(3000, /datum/material/silver)
			container.insert_amount_mat(1500, /datum/material/diamond)
			container.insert_amount_mat(3000, /datum/material/bluespace)
		break

/obj/item/autosurgeon/bluebutt_test
	uses = 1
	starting_organ = list(/obj/item/organ/butt/bluebutt)
