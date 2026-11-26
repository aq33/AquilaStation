// aq33/AquilaStation#715 - plan maszynowni E11, E20, D14: regenerator tlenu, premia CO2 dla roślin, biogazownia i metan z kanalizacji

/datum/test_chamber_kit/pr_715
	name = "PR 715: regenerator tlenu, biogazownia, CO2 dla roślin"
	pr = "aq33/AquilaStation#715"
	description = "Regenerator tlenu, biogazownia, kanister CO2, sedes, odpływ, taca z nasionami i narzędzia. \
	1) Regenerator: postaw go na rurach (rura z tyłu od kanistra CO2 przez port, rura z przodu do pustego kanistra albo zbiornika), kliknij, żeby włączyć. Jeśli stoi bokiem do rur: wyłącz, otwórz panel śrubokrętem, obróć kluczem, zamknij panel. Analizator na rurach: CO2 ubywa, w wyjściu przybywa tyle samo tlenu. Badanie maszyny pokazuje, ile węgla się zebrało; co 20 moli wypada bryłka węgla. \
	2) Premia roślin: posadź nasiona w tacy i wypuść obok trochę CO2 z kanistra, tak żeby analizator pokazał 1–10 kPa CO2. Owoce rosną półtora raza szybciej niż w drugiej tacy w zwykłym powietrzu; przy dużo większym stężeniu premii nie ma. \
	3) Biogazownia: podłącz ją rurą do pustego kanistra, włącz kliknięciem. Wlej mocz z dużej zlewki (jest pełna) lub wrzuć jedzenie (mięso): w rurze pojawia się metan i mniej CO2. Woda z wsadu powoli spływa, a zbiornik można zlać pustą zlewką. \
	4) Kanalizacja: zrób kupę albo siku do sedesu (otwórz klapę) i spłucz go prawym przyciskiem (w trybie intencji: na intencji rozbrajania); badanie biogazowni pokazuje, ile ścieków czeka w kanalizacji statku, a włączona biogazownia przerabia je sama. Połóż zestaw odpływu na podłodze i przykręć go kluczem, potem wylej na niego mocz: też trafia do ścieków. Zatkany sedes, który się przelewa, nic nie oddaje."
	items = list(
		/obj/machinery/atmospherics/components/binary/oxygen_regenerator = 1,
		/obj/machinery/atmospherics/components/unary/biogas_plant = 1,
		/obj/machinery/portable_atmospherics/canister/carbon_dioxide = 1,
		/obj/machinery/portable_atmospherics/canister = 2,
		/obj/structure/toilet = 1,
		/obj/item/drain_kit = 1,
		/obj/item/plant_tray = 2,
		/obj/item/plant_seeds/preset/tomato = 2,
		/obj/item/reagent_containers/glass/bucket = 1,
		/obj/item/reagent_containers/glass/beaker/large = 1,
		/obj/item/food/meat/slab = 3,
		/obj/item/analyzer = 1,
		/obj/item/pipe_dispenser = 1,
		/obj/item/wrench = 1,
		/obj/item/screwdriver = 1,
	)

/datum/test_chamber_kit/pr_715/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/large/beaker = locate() in spawned
	beaker?.reagents.add_reagent(/datum/reagent/ammonia/urine, 100)
