// aq33/AquilaStation#622 - potrzeby: progi nawodnienia i najedzenia, napoje, składniki, przyprawy, urozmaicenie, wrzody żołądka

/datum/test_chamber_kit/pr_622_potrzeby
	name = "PR 622: potrzeby i wrzody żołądka"
	pr = "aq33/AquilaStation#622"
	description = "Zestaw: automat z przekąskami, chipsy, cola, kawa, mleko, sałatka, stek, chleb, ser, jabłko, marchewka, solniczka, młynek z pieprzem, ostry sos, butelka Omeprazolu i analizator zdrowia. \
	1) Nawodnienie: VV hydration = 600 → moodlet „Dobrze się nawodniłem”, stamina wraca szybciej. hydration = 200 → „Boli mnie głowa”, hydration = 100 → „Zasycham!”, czasem mroczki przed oczami. \
	2) Najedzenie: VV nutrition = 100 → „Ręce drżą ci z głodu”, czynności trwają dłużej, celownik broni szerszy. nutrition = 300 → co kilka minut burczy w brzuchu (słychać obok). Przejedz się ponad 600 → „robi ci się sennie”, stamina wolniej przez 2 minuty. \
	3) Cola albo cukier → po chwili „Cukier uderza ci do głowy”, stamina szybciej przez 2 minuty, potem „Cukier opada”. Kawa → stamina trochę szybciej, póki kofeina jest we krwi. \
	4) Posyp jabłko solą albo pieprzem (klik solniczką na jedzenie) → examine „Ktoś to doprawił”, przy jedzeniu posiłek o poziom lepszy. Ostry sos lekko tłumi ból. \
	5) Zjedz w ciągu kilku minut stek, marchewkę, jabłko i chleb (albo ser) → moodlet „Jem urozmaicone posiłki”. \
	6) Wrzody: kup coś w automacie i zjedz chipsy, analizatorem sprawdzaj stan. Żeby nie jeść godzinę, VV żołądka: aq_acid = 100, poczekaj ~5 minut → „Czujesz lekkie pieczenie”, analizator: stadium 1. aq_ulcer = 50 → stadium 2 (ból, wymioty po śmieciowym jedzeniu). aq_ulcer = 80 → krwawiący wrzód (wymioty krwią, nie utrzymasz dużo jedzenia), gastrektomia staje się dostępna. \
	7) Leczenie: mleko zbija kwas i przyspiesza gojenie, Omeprazol (siarka + sód + węgiel + azot) goi wrzód w kilka minut."
	items = list(
		/obj/machinery/vending/snack = 1,
		/obj/item/food/chips = 3,
		/obj/item/reagent_containers/food/drinks/soda_cans/cola = 2,
		/obj/item/reagent_containers/food/drinks/coffee = 1,
		/obj/item/reagent_containers/food/condiment/milk = 1,
		/obj/item/food/salad/aesirsalad = 1,
		/obj/item/food/meat/steak = 1,
		/obj/item/food/breadslice/plain = 2,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/grown/apple = 2,
		/obj/item/food/grown/carrot = 1,
		/obj/item/reagent_containers/food/condiment/saltshaker = 1,
		/obj/item/reagent_containers/food/condiment/peppermill = 1,
		/obj/item/reagent_containers/food/condiment/hotsauce = 1,
		/obj/item/reagent_containers/glass/bottle = 1,
		/obj/item/healthanalyzer = 1,
	)

/datum/test_chamber_kit/pr_622_potrzeby/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	for(var/obj/item/reagent_containers/glass/bottle/bottle in spawned)
		bottle.name = "Omeprazol"
		bottle.reagents.add_reagent(/datum/reagent/medicine/aq_omeprazole, 15)
