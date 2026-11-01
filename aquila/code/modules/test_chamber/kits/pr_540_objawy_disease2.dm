/datum/test_chamber_kit/pr_540
	name = "PR 540: objawy wirusów z disease2"
	pr = "aq33/AquilaStation#540"
	description = "Skrzynia z butelkami kultur: jedna butelka na każdy nowy objaw, każda z chorobą o maksymalnych statystykach, \
		żeby wszystkie progi z opisu objawu były aktywne. Wstrzyknij sobie strzykawką albo wlej małpie i odczekaj do 5. stadium. \
		Sprawdź zwłaszcza: Adaptację kosmiczną (wyjdź w próżnię, potem wylecz się), Zespół kruchej osoby (wytrzymałość kończyn \
		musi wrócić po wyleczeniu), Zespół długowieczności (po wyleczeniu nawrót obrażeń i postarzenie), Rogowacenie kolczaste \
		(wpadnij na kogoś i daj się dotknąć), Rezonans szklisty (weź szklankę do ręki), Jaszczurzycę i Ćmienie (rasa musi wrócić \
		po wyleczeniu), Zespół olejowy (rzadko wyskakuje robot). Leczysz spaceacillinem ze strzykawki. \
		W PANDEMIC-u wsyp butelkę do zlewki i sprawdź, czy objaw jest na liście z polskim opisem i progami."
	items = list(
		/obj/machinery/computer/pandemic = 1,
		/obj/item/extrapolator = 1,
		/obj/item/reagent_containers/syringe = 4,
		/obj/item/reagent_containers/glass/beaker/large = 2,
		/obj/item/clothing/mask/gas = 1,
		/obj/item/clothing/gloves/color/latex = 1,
		/obj/item/reagent_containers/food/drinks/drinkingglass = 2,
		/obj/item/storage/box/monkeycubes = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_540/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/obj/structure/closet/crate/cultures = new(center)
	cultures.name = "kultury nowych objawów"
	for(var/datum/symptom/symptom_type as anything in subtypesof(/datum/symptom))
		if(!initial(symptom_type.from_disease2) || initial(symptom_type.level) < 0)
			continue
		var/datum/disease/advance/virus = new
		virus.AddSymptom(new symptom_type)
		virus.Refresh()
		// maksymalne statystyki, żeby każdy próg z threshold_desc był aktywny
		virus.stealth = 10
		virus.resistance = 10
		virus.stage_rate = 10
		virus.transmission = 10
		virus.AssignName(initial(symptom_type.name))
		var/obj/item/reagent_containers/glass/bottle/bottle = new(cultures)
		bottle.name = "kultura: [initial(symptom_type.name)]"
		bottle.desc = "Mała butelka. Zawiera kulturę testową z jednym objawem: [initial(symptom_type.name)]."
		bottle.reagents.add_reagent(/datum/reagent/blood, 20, list("viruses" = list(virus)))
	// spaceacillin w jednej ze strzykawek z items: wyłącza chorobę, więc widać, czy objaw ładnie się cofa
	var/obj/item/reagent_containers/syringe/cure = locate() in spawned
	if(cure)
		cure.name = "strzykawka (spaceacillin)"
		cure.reagents.add_reagent(/datum/reagent/medicine/spaceacillin, 15)
