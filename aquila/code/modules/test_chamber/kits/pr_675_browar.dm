// Browar w drewnianej beczce, polskie trunki, sprzedaż beczek

/datum/test_chamber_kit/pr_675_browar
	name = "PR 675: browar w beczce"
	pr = "aq33/AquilaStation#675"
	description = "1) Beczka po lewej ma już wybrany rum (nie wybieraj go ponownie, bo wybór wysypuje składniki i zeruje trzcinę). Examine pokazuje, czego brakuje (trzcina już wliczona, woda i sól są w beczce). Wrzuć 5 kłód z zestawu, Alt+klik i „Rozpocznij warzenie”: po 3 minutach 200 j. rumu w beczce, woda zostaje (bez grogu). 2) Beczka środkowa ma gotowe jasne piwo: Alt+klik, na liście jest „Piwo (drugi etap)”. Wlej 60 j. wody (zlewka z zestawu, otwórz beczkę kliknięciem) i wybierz przepis, potem dorzuć pszenicę z hydroponiki albo zostaw, żeby zobaczyć braki. 3) Beczka po prawej bez przepisu: wrzuć owoc, po chwili wino z owocu (jak dotąd). 4) Krupnik: pusta beczka, Alt+klik „Krupnik”, wlej wódkę, miód i wodę z zestawu, start, 5 minut. 5) PDA kucharza, Książka kucharska: zakładka „Browar” z przepisami (wymaga przebudowanego TGUI). 6) Beczka z rumem na promie zaopatrzenia sprzedaje się (pusta nie). 7) Drinki z tg: dyspenser alkoholi ma nowe bazy (bitter, amaretto, curaçao, aperitivo, shochu i inne), dyspenser napojów oranżadę melonową i Sol Dry. W szklance: 10 j. wody sodowej, 5 j. lodu i 1 j. bittera daje Bitter z wodą sodową ze sprite’em z tg; Negroni to 3 j. martini, 2 j. aperitivo i 1 j. wermutu. Pusta szklanka wraca do zwykłego wyglądu."
	items = list(
		/obj/item/grown/log = 5,
		/obj/item/modular_computer/tablet/pda/cook = 1,
		/obj/item/reagent_containers/food/drinks/drinkingglass = 3,
	)

/datum/test_chamber_kit/pr_675_browar/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/obj/structure/fermenting_barrel/rum_barrel = new(locate(center.x - 2, center.y + 2, center.z))
	rum_barrel.selected_recipe = locate(/datum/brewing_recipe/rum) in GLOB.brewing_recipes
	rum_barrel.crop_units[/obj/item/food/grown/sugarcane] = 60
	rum_barrel.reagents.add_reagent(/datum/reagent/water, 150)
	rum_barrel.reagents.add_reagent(/datum/reagent/consumable/sodiumchloride, 5)

	var/obj/structure/fermenting_barrel/beer_barrel = new(locate(center.x, center.y + 2, center.z))
	beer_barrel.reagents.add_reagent(/datum/reagent/consumable/ethanol/beer/light, 200)

	new /obj/structure/fermenting_barrel(locate(center.x + 2, center.y + 2, center.z))
	new /obj/structure/fermenting_barrel(locate(center.x + 3, center.y + 2, center.z))
	new /obj/machinery/chem_dispenser/drinks/beer(locate(center.x - 3, center.y, center.z))
	new /obj/machinery/chem_dispenser/drinks(locate(center.x - 3, center.y - 1, center.z))

	var/turf/table_spot = locate(center.x - 2, center.y - 2, center.z)
	for(var/list/beaker_contents in list(list(/datum/reagent/water, 100), list(/datum/reagent/consumable/ethanol/vodka, 60), list(/datum/reagent/consumable/honey, 30)))
		var/obj/item/reagent_containers/glass/beaker/large/beaker = new(table_spot)
		beaker.reagents.add_reagent(beaker_contents[1], beaker_contents[2])
