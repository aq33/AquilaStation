/*
	AQUILA - rośliny z Adhomai, lodowej planety Tajarów, z Aurory (Aurora-Station/Aurora.3, fjylozyn i wulumunusha
	w code/modules/hydroponics/seed_datums/nralakk.dm). Pozostałe rośliny Adhomai usunięte (soki bez zastosowania,
	raport/bloat_09_rosliny_po_kuchni.md).
	Sprite'y plonów i torebek z Aurory (icons/obj/hydroponics_products.dmi, seeds.dmi), złożone i pokolorowane jak w grze, CC-BY-SA 3.0.

	Rosną w kapsule ksenoflory (ksenoflora.dm) na mrozie, każda z jednym gazem albo odczynnikiem, oraz dziko na planetach lodowych
	(struktury w planets/shiptest_flora/adhomai_flora.dm). Plon dzikiej rośliny niesie geny wersji kapsułowej, więc nasiona
	z siewnika rosną tylko w kapsule.
	Odczynniki Aurory, których nie mamy: ekstrakt wulumunuszy (halucynacje i niemota) -> kosmiczne narkotyki i toksyna niemoty.
*/

/*
	Mechanika: owoc dzikiej rośliny dostaje geny wersji kapsułowej (siewnik robi z niego nasiona do kapsuły)
*/
/datum/plant_feature/fruit/xenoflora
	/// Preset kapsułowy, którego geny dostaje plon (dzika odmiana bez potrzeb); null = zwykłe geny rośliny
	var/obj/item/plant_seeds/wild_capsule_seeds

/datum/plant_feature/fruit/xenoflora/build_fruit()
	. = ..()
	var/obj/item/new_fruit = .
	if(!wild_capsule_seeds || QDELETED(new_fruit))
		return
	//Gatunek i nazwa paczki kapsułowej są stałe dla typu: paczkę tworzymy raz na typ, a nie przy każdym owocu
	var/static/list/capsule_ids = list()
	var/list/capsule_info = capsule_ids[wild_capsule_seeds]
	if(!capsule_info)
		var/obj/item/plant_seeds/capsule_seeds = new wild_capsule_seeds(null)
		capsule_info = list(capsule_seeds.species_id, capsule_seeds.name_override)
		if(!SSbotany.gene_cache["[capsule_seeds.species_id]"])
			var/list/plant_genes = list()
			for(var/datum/plant_feature/gene as anything in capsule_seeds.plant_features)
				plant_genes += gene.copy()
			SSbotany.gene_cache[capsule_seeds.species_id] = plant_genes
		//Paczka nasion nie usuwa swoich części w Destroy, a części trzymają potrzeby i cechy w cyklach referencji
		QDEL_LIST(capsule_seeds.plant_features)
		qdel(capsule_seeds)
		capsule_ids[wild_capsule_seeds] = capsule_info
	var/species_id = capsule_info[1]
	SEND_SIGNAL(new_fruit, COMSIG_PLANT_MODIFY_GENES, PLANT_GENE_INDEX_FEATURES, SSbotany.gene_cache["[species_id]"])
	SEND_SIGNAL(new_fruit, COMSIG_PLANT_MODIFY_GENES, PLANT_GENE_INDEX_ID, species_id)
	SEND_SIGNAL(new_fruit, COMSIG_PLANT_MODIFY_GENES, PLANT_GENE_INDEX_NAME, capsule_info[2])

/*
	Potrzeby w kapsule (Adhomai ma średnio −16 °C)
*/

/datum/plant_need/xenoflora/fjylozyn
	required_gases = list(GAS_PLASMA = 0.05)
	min_temperature = T0C - 40
	max_temperature = T0C - 15

/datum/plant_need/xenoflora/wulumunusha
	required_gases = list(GAS_NITROUS = 0.1)
	required_reagents = list(/datum/reagent/iodine = 0.05) //nie fosfor (lista toksyn łodygi) ani potas (wybucha z wodą w zbiorniku)
	min_temperature = T0C - 30
	max_temperature = T0C - 10

/*
	Owoce
*/
/datum/plant_feature/fruit/xenoflora/adhomai
	abstract_type = /datum/plant_feature/fruit/xenoflora/adhomai
	seed_icon = 'aquila/icons/obj/hydroponics/ported_kseno_adhomai_seeds.dmi'

/datum/plant_feature/fruit/xenoflora/adhomai/fjylozyn
	species_name = "fjylozyn lucens"
	name = "fjylozyn"
	icon_state = "cherry"
	colour_override = "#990000"
	seed_icon_state = "seed-fjylozyn"
	fruit_product = /obj/item/food/grown/xenoflora/adhomai/fjylozyn
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/fjylozyn)
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/fruit/biolight/red)
	fast_reagents = list(/datum/reagent/toxin = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/datum/plant_feature/fruit/xenoflora/adhomai/wulumunusha
	species_name = "vitis mutans"
	name = "wulumunusza"
	icon_state = "orange"
	colour_override = "#61E2EC"
	seed_icon_state = "seed-wulumunusha"
	fruit_product = /obj/item/food/grown/xenoflora/adhomai/wulumunusha
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/wulumunusha)
	fast_reagents = list(/datum/reagent/drug/space_drugs = PLANT_REAGENT_MEDIUM, /datum/reagent/toxin/mutetoxin = PLANT_REAGENT_MICRO)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/*
	Nasiona do kapsuły
*/
/obj/item/plant_seeds/preset/alien/xenoflora/adhomai
	icon = 'aquila/icons/obj/hydroponics/ported_kseno_adhomai_seeds.dmi'
	abstract_type = /obj/item/plant_seeds/preset/alien/xenoflora/adhomai

/obj/item/plant_seeds/preset/alien/xenoflora/adhomai/fjylozyn
	name = "nasiona: fjylozyn (kapsuła ksenoflory)"
	name_override = "fjylozyn"
	icon_state = "seed-fjylozyn"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/bush_vine, /datum/plant_feature/fruit/xenoflora/adhomai/fjylozyn)

/obj/item/plant_seeds/preset/alien/xenoflora/adhomai/wulumunusha
	name = "nasiona: wulumunusza (kapsuła ksenoflory)"
	name_override = "wulumunusza"
	icon_state = "seed-wulumunusha"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/bush_vine/grape, /datum/plant_feature/fruit/xenoflora/adhomai/wulumunusha)

/*
	Plony
*/
/obj/item/food/grown/xenoflora/adhomai
	abstract_type = /obj/item/food/grown/xenoflora/adhomai
	icon = 'aquila/icons/obj/hydroponics/ported_kseno_adhomai_harvest.dmi'

/obj/item/food/grown/xenoflora/adhomai/fjylozyn
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/adhomai/fjylozyn
	name = "fjylozyn"
	desc = "Ciemnoczerwony, słabo świecący owoc pnącza fjylozyn. Jest jadalny, ale lekko trujący."
	icon_state = "fjylozyn"
	tastes = list("gorzki owoc" = 1, "metal" = 1)
	foodtypes = FRUIT | TOXIC

/obj/item/food/grown/xenoflora/adhomai/wulumunusha
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/adhomai/wulumunusha
	name = "owoc wulumunuszy"
	desc = "Błękitny owoc pnącza wulumunuszy. Jego wyciąg wywołuje halucynacje i odbiera mowę."
	icon_state = "wulumunusha"
	tastes = list("ziemistość" = 1)
	foodtypes = FRUIT
	grind_results = list(/datum/reagent/drug/space_drugs = 0)
