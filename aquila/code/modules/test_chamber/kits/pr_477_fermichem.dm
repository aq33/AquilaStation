/datum/test_chamber_kit/pr_477
	name = "Fermichem (pH, czystość, reakcje w czasie)"
	pr = "aq33/AquilaStation#477"
	description = "Podgrzewacz debug ma po 1000 j. obu buforów. \
	1) Zlewka „amoniak”: włóż do podgrzewacza, ustaw 400 K i włącz – reakcja trwa kilka sekund, widać ją w oknie (pasek, jakość), zlewka się nagrzewa. \
	2) Zlewka „amoniak kwaśny” ma pH ~0,1 (poniżej okna 1–12): przed reakcją dolej bufor zasadowy z podgrzewacza i porównaj czystość z analizatorem chemicznym (klik zlewką). \
	3) Zlewka „meta”: grzej powyżej przegrzania (patrz wyszukiwarka receptur w dispenserze) – wybucha. \
	4) Strzykawka z nieczystą okuliną: wstrzyknij królikowi albo sobie – w ciele zmieni się w Oculater (ślepota). \
	5) Papierki pH z książeczki: kliknij nimi zlewkę, zmieniają kolor. \
	6) Komora reakcyjna plumbingu i RPLD: wejścia na bufory z boków, pH trzyma się w zadanym zakresie."
	items = list(
		/obj/machinery/chem_heater/debug = 1,
		/obj/item/ph_booklet = 1,
		/obj/item/ph_meter = 1,
		/obj/item/reagent_containers/glass/bottle/acidic_buffer = 1,
		/obj/item/reagent_containers/glass/bottle/basic_buffer = 1,
		/obj/item/reagent_containers/glass/bottle/inversing_buffer = 1,
		/obj/machinery/plumbing/reaction_chamber/chem = 1,
		/obj/item/construction/plumbing = 1,
	)

/datum/test_chamber_kit/pr_477/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/turf/drop = turfs[min(length(items) + 1, length(turfs))]

	var/obj/item/reagent_containers/glass/beaker/large/ammonia = new(drop)
	ammonia.name = "zlewka: amoniak (wodór + azot)"
	ammonia.reagents.add_reagent(/datum/reagent/hydrogen, 45, null, 90, TRUE)
	ammonia.reagents.add_reagent(/datum/reagent/nitrogen, 15, null, 90, TRUE)

	var/obj/item/reagent_containers/glass/beaker/large/acidic = new(drop)
	acidic.name = "zlewka: amoniak kwaśny (pH ~0,1)"
	acidic.reagents.add_reagent(/datum/reagent/hydrogen, 45, null, 90, TRUE, added_ph = 0.1)
	acidic.reagents.add_reagent(/datum/reagent/nitrogen, 15, null, 90, TRUE, added_ph = 0.1)

	var/obj/item/reagent_containers/glass/beaker/large/meth = new(drop)
	meth.name = "zlewka: składniki mety"
	for(var/reagent_type in list(/datum/reagent/medicine/ephedrine, /datum/reagent/iodine, /datum/reagent/phosphorus, /datum/reagent/hydrogen))
		meth.reagents.add_reagent(reagent_type, 10, null, 90, TRUE)

	var/obj/item/reagent_containers/syringe/impure = new(drop)
	impure.name = "strzykawka: nieczysta okulina (10%)"
	impure.reagents.add_reagent(/datum/reagent/medicine/oculine, 15, added_purity = 0.1)
