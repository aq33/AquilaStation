/*
	AQUILA - rośliny z Adhomai, lodowej planety Tajarów, z Aurory (Aurora-Station/Aurora.3, /datum/seed/earthenroot, dirtberries,
	sugartree w code/modules/hydroponics/seed_datums/adhomai.dm, sarezhi w unathi.dm, fjylozyn, wulumunusha i ylpha w nralakk.dm).
	Sprite'y plonów i torebek z Aurory (icons/obj/hydroponics_products.dmi, seeds.dmi), złożone i pokolorowane jak w grze, CC-BY-SA 3.0.

	Rosną w kapsule ksenoflory (ksenoflora.dm) na mrozie, każda z jednym gazem albo odczynnikiem, oraz dziko na planetach lodowych
	(struktury w planets/shiptest_flora/adhomai_flora.dm). Plon dzikiej rośliny niesie geny wersji kapsułowej, więc nasiona
	z siewnika rosną tylko w kapsule.
	Odczynniki Aurory, których nie mamy: soki z ziemnego korzenia, brudnych jagód, sareżi i ylfy przeniesione niżej; żelatyna
	drzewa cukrowego -> odżywka; ekstrakt wulumunuszy (halucynacje i niemota) -> kosmiczne narkotyki i toksyna niemoty.
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
	var/obj/item/plant_seeds/capsule_seeds = new wild_capsule_seeds(null)
	var/species_id = capsule_seeds.species_id
	if(!SSbotany.gene_cache["[species_id]"])
		var/list/plant_genes = list()
		for(var/datum/plant_feature/gene as anything in capsule_seeds.plant_features)
			plant_genes += gene.copy()
		SSbotany.gene_cache[species_id] = plant_genes
	SEND_SIGNAL(new_fruit, COMSIG_PLANT_MODIFY_GENES, PLANT_GENE_INDEX_FEATURES, SSbotany.gene_cache["[species_id]"])
	SEND_SIGNAL(new_fruit, COMSIG_PLANT_MODIFY_GENES, PLANT_GENE_INDEX_ID, species_id)
	SEND_SIGNAL(new_fruit, COMSIG_PLANT_MODIFY_GENES, PLANT_GENE_INDEX_NAME, capsule_seeds.name_override)
	qdel(capsule_seeds)

/*
	Potrzeby w kapsule (Adhomai ma średnio −16 °C)
*/
/datum/plant_need/xenoflora/earthenroot
	required_gases = list(GAS_N2 = 0.05)
	min_temperature = T0C - 30
	max_temperature = T0C - 5

/datum/plant_need/xenoflora/dirtberries
	required_reagents = list(/datum/reagent/ammonia = 0.05)
	min_temperature = T0C - 35
	max_temperature = T0C - 5

/datum/plant_need/xenoflora/sarezhi
	required_gases = list(GAS_CO2 = 0.1)
	min_temperature = T0C - 25
	max_temperature = T0C

/datum/plant_need/xenoflora/ylpha
	required_reagents = list(/datum/reagent/iron = 0.05)
	min_temperature = T0C - 20
	max_temperature = T0C - 5

/datum/plant_need/xenoflora/sugartree
	required_gases = list(GAS_O2 = 0.1)
	required_reagents = list(/datum/reagent/carbon = 0.05)
	min_temperature = T0C - 40
	max_temperature = T0C - 10

/datum/plant_need/xenoflora/fjylozyn
	required_gases = list(GAS_PLASMA = 0.05)
	min_temperature = T0C - 40
	max_temperature = T0C - 15

/datum/plant_need/xenoflora/wulumunusha
	required_gases = list(GAS_NITROUS = 0.1)
	required_reagents = list(/datum/reagent/phosphorus = 0.05)
	min_temperature = T0C - 30
	max_temperature = T0C - 10

/*
	Owoce
*/
/datum/plant_feature/fruit/xenoflora/adhomai
	abstract_type = /datum/plant_feature/fruit/xenoflora/adhomai
	seed_icon = 'aquila/icons/obj/hydroponics/ported_kseno_adhomai_seeds.dmi'

/datum/plant_feature/fruit/xenoflora/adhomai/earthenroot
	species_name = "radix terrena"
	name = "ziemny korzeń"
	icon_state = "carrot"
	colour_override = "#87CEEB"
	seed_icon_state = "seed-earthenroot"
	fruit_product = /obj/item/food/grown/xenoflora/adhomai/earthenroot
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/earthenroot)
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/sugar = PLANT_REAGENT_SMALL, /datum/reagent/consumable/earthenrootjuice = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_MEDIUM
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/datum/plant_feature/fruit/xenoflora/adhomai/dirtberries
	species_name = "bacca terrea"
	name = "brudne jagody"
	icon_state = "berry"
	colour_override = "#C4AE7A"
	seed_icon_state = "seed-dirtberries"
	fruit_product = /obj/item/food/grown/xenoflora/adhomai/dirtberries
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/dirtberries)
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/nutriment/fat/oil = PLANT_REAGENT_SMALL, /datum/reagent/consumable/dirtberryjuice = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/datum/plant_feature/fruit/xenoflora/adhomai/sarezhi
	species_name = "bacca sarezhi"
	name = "sareżi"
	icon_state = "berry"
	colour_override = "#bf8fbc"
	seed_icon_state = "seed-sarezhi"
	fruit_product = /obj/item/food/grown/xenoflora/adhomai/sarezhi
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/sarezhi)
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/sarezhijuice = PLANT_REAGENT_LARGE)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/datum/plant_feature/fruit/xenoflora/adhomai/ylpha
	species_name = "bacca ylpha"
	name = "ylfa"
	icon_state = "berry"
	colour_override = "#d46423"
	seed_icon_state = "seed-ylpha"
	fruit_product = /obj/item/food/grown/xenoflora/adhomai/ylpha
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/ylpha)
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/ylphajuice = PLANT_REAGENT_LARGE)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/datum/plant_feature/fruit/xenoflora/adhomai/sugartree
	species_name = "arbor sacchari"
	name = "drzewo cukrowe"
	icon_state = "orb"
	colour_override = "#fffdf7"
	seed_icon_state = "seed-sugartree"
	fruit_product = /obj/item/food/grown/xenoflora/adhomai/sugartree
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/sugartree)
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/sugar = PLANT_REAGENT_LARGE)
	total_volume = PLANT_FRUIT_VOLUME_MEDIUM
	growth_time = PLANT_FRUIT_GROWTH_SLOW

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

/obj/item/plant_seeds/preset/alien/xenoflora/adhomai/earthenroot
	name = "nasiona: ziemny korzeń (kapsuła ksenoflory)"
	name_override = "ziemny korzeń"
	icon_state = "seed-earthenroot"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/tuber, /datum/plant_feature/fruit/xenoflora/adhomai/earthenroot)

/obj/item/plant_seeds/preset/alien/xenoflora/adhomai/dirtberries
	name = "nasiona: krzew brudnych jagód (kapsuła ksenoflory)"
	name_override = "krzew brudnych jagód"
	icon_state = "seed-dirtberries"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/bush_vine, /datum/plant_feature/fruit/xenoflora/adhomai/dirtberries)

/obj/item/plant_seeds/preset/alien/xenoflora/adhomai/sarezhi
	name = "nasiona: krzew sareżi (kapsuła ksenoflory)"
	name_override = "krzew sareżi"
	icon_state = "seed-sarezhi"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/bush_vine/berry, /datum/plant_feature/fruit/xenoflora/adhomai/sarezhi)

/obj/item/plant_seeds/preset/alien/xenoflora/adhomai/ylpha
	name = "nasiona: krzew ylfy (kapsuła ksenoflory)"
	name_override = "krzew ylfy"
	icon_state = "seed-ylpha"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/bush_vine/berry, /datum/plant_feature/fruit/xenoflora/adhomai/ylpha)

/obj/item/plant_seeds/preset/alien/xenoflora/adhomai/sugartree
	name = "nasiona: drzewo cukrowe (kapsuła ksenoflory)"
	name_override = "drzewo cukrowe"
	icon_state = "seed-sugartree"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/corn_stalk, /datum/plant_feature/fruit/xenoflora/adhomai/sugartree)

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

/obj/item/food/grown/xenoflora/adhomai/earthenroot
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/adhomai/earthenroot
	name = "ziemny korzeń"
	desc = "Słodkie, twarde, niebieskie warzywo z Adhomai. Tajarzy jedzą je, pędzą z niego trunki, robią z niego cukier i niebieski barwnik."
	icon_state = "earthenroot"
	tastes = list("słodki korzeń" = 1)
	foodtypes = VEGETABLES
	juice_typepath = /datum/reagent/consumable/earthenrootjuice
	distill_reagent = /datum/reagent/consumable/ethanol/vodka

/obj/item/food/grown/xenoflora/adhomai/dirtberries
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/adhomai/dirtberries
	name = "brudne jagody"
	desc = "Garść adhomaiańskich jagód, które rosną pod ziemią w grubych strąkach jak orzeszki ziemne. Są tłuste i pożywne, Tajarzy tłoczą z nich olej."
	icon_state = "dirtberries"
	tastes = list("brudne jagody" = 1, "orzechy" = 1)
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/dirtberryjuice

/obj/item/food/grown/xenoflora/adhomai/sarezhi
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/adhomai/sarezhi
	name = "jagody sareżi"
	desc = "Cierpkie, gorzkawe jagody, z których fermentuje się słynne wino sareżi."
	icon_state = "sarezhi"
	tastes = list("cierpkie jagody" = 1)
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/sarezhijuice
	distill_reagent = /datum/reagent/consumable/ethanol/wine

/obj/item/food/grown/xenoflora/adhomai/ylpha
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/adhomai/ylpha
	name = "jagody ylfy"
	desc = "Pomarańczowe, soczyste jagody ylfy."
	icon_state = "ylpha"
	tastes = list("jagody ylfy" = 1)
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/ylphajuice

/obj/item/food/grown/xenoflora/adhomai/sugartree
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/adhomai/sugartree
	name = "owoc drzewa cukrowego"
	desc = "Kulisty owoc w białej, wełnistej skórce, który rośnie na szczycie każdej łodygi drzewa cukrowego. Jest bardzo słodki, na Adhomai robi się z niego cukierki."
	icon_state = "sugartree"
	tastes = list("cukier" = 3, "wata" = 1)
	foodtypes = FRUIT | SUGAR
	juice_typepath = /datum/reagent/consumable/sugar

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

/*
	Soki (w Aurorze napoje Tajarów, Unathi i Skrelli)
*/
/datum/reagent/consumable/earthenrootjuice
	name = "Sok z ziemnego korzenia"
	description = "Sok wyciśnięty z ziemnego korzenia, rośliny z Adhomai."
	color = "#679fb6"
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "słodycz"
	glass_icon_state = "glass_white"
	glass_name = "szklanka soku z ziemnego korzenia"
	glass_desc = "Słodki, niebieskawy sok z ziemnego korzenia."
	hydration_factor = 10 * REAGENTS_METABOLISM

/datum/reagent/consumable/dirtberryjuice
	name = "Sok z brudnych jagód"
	description = "Pyszna mieszanka kilku brudnych jagód."
	color = "#C4AE7A"
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "brudne jagody"
	glass_icon_state = "glass_brown"
	glass_name = "szklanka soku z brudnych jagód"
	glass_desc = "Gęsty, orzechowy sok z brudnych jagód."
	hydration_factor = 10 * REAGENTS_METABOLISM

/datum/reagent/consumable/sarezhijuice
	name = "Sok z jagód sareżi"
	description = "Cierpki sok z jagód sareżi, z którego fermentuje się słynne wino sareżi."
	color = "#bf8fbc"
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "cierpkie, gorzkie jagody"
	glass_icon_state = "glass_red"
	glass_name = "szklanka soku z jagód sareżi"
	glass_desc = "Cierpki, fioletowawy sok z jagód sareżi."
	hydration_factor = 10 * REAGENTS_METABOLISM

/datum/reagent/consumable/ylphajuice
	name = "Sok z jagód ylfy"
	description = "Pyszna mieszanka kilku jagód ylfy."
	color = "#d46423"
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "jagody ylfy"
	glass_icon_state = "glass_orange"
	glass_name = "szklanka soku z jagód ylfy"
	glass_desc = "Pomarańczowy sok z jagód ylfy."
	hydration_factor = 10 * REAGENTS_METABOLISM
