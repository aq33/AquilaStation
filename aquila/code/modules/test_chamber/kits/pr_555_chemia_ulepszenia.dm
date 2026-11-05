/datum/test_chamber_kit/pr_555
	name = "Chemia: lodówka, oczyszczanie w ChemMasterze, bufory z objętością"
	pr = "aq33/AquilaStation#555"
	description = "1) Lodówka: włóż do niej pigułki i butelki z zestawu – w oknie nazwa zaczyna się od zawartości, np. „Węgiel aktywny (pigułka)”. \
	2) ChemMaster: włóż zlewkę „nieczysta okulina”, przenieś okulinę do bufora i kliknij przycisk z lejkiem „Oczyść” – ze 100u (30%) zostaje 30u czystej okuliny, czat podaje ilości. \
	3) Podgrzewacz: włóż zlewkę z wodą, wstrzyknij kilka jednostek buforu – objętość w zlewce rośnie, pojawia się „Zużyty bufor”, pH się zmienia. \
	4) Ta sama zlewka z samą wodą w podgrzewaczu: ustaw 400 K i włącz – temperatura rośnie bez żadnej reakcji, przy 200 K spada."
	items = list(
		/obj/machinery/smartfridge/chemistry = 1,
		/obj/machinery/chem_master = 1,
		/obj/machinery/chem_heater/debug = 1,
		/obj/item/reagent_containers/pill/charcoal = 3,
		/obj/item/reagent_containers/glass/bottle/charcoal = 2,
	)

/datum/test_chamber_kit/pr_555/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/turf/drop = turfs[min(length(items) + 1, length(turfs))]

	var/obj/item/reagent_containers/glass/beaker/large/impure = new(drop)
	impure.name = "zlewka: nieczysta okulina (30%)"
	impure.reagents.add_reagent(/datum/reagent/medicine/oculine, 100, added_purity = 0.3)

	var/obj/item/reagent_containers/glass/beaker/large/water = new(drop)
	water.name = "zlewka: woda"
	water.reagents.add_reagent(/datum/reagent/water, 50)
