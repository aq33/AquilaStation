/*
	AQUILA - rośliny światów obcych ras z Baystation12 (code/modules/hydroponics/seed_datums.dm, łzy Merlina z code/modules/spells/aoe_turf/conjure/grove.dm),
	przeniesione jako ksenoflora: rosną tylko w kapsule ksenoflory, a jej warunki odpowiadają światu pochodzenia.
	Sprite'y plonów i torebek złożone z Baya (icons/obj/flora/hydroponics_products.dmi i seeds.dmi, pokolorowane jak w grze), licencja CC-BY-SA 3.0.
	- Moghes (Unathi): gorąco i dwutlenek węgla; guche z mórz Yeosa chce też dużo wody, aghrasz z pustyń popiołu.
	- Qerrbalak (Skrellowie): chłodno i mokro (woda w zbiorniku, para wodna pod kopułą).
	- Światy ludzi i pustynne (irydast, afelerin), fasola gummen (Bay nie podaje pochodzenia) na azocie jak u Voxów,
	  łzy Merlina (roślina czarodzieja) na plazmie i wodzie święconej.
	Odczynniki ras, których nie mamy, zamienione na nasze najbliższe (lista w nagłówkach roślin).
*/

/*
	Wymagania kapsuły
*/
/datum/plant_need/xenoflora/gukhe
	required_gases = list(GAS_CO2 = 0.05)
	required_reagents = list(/datum/reagent/water = 0.1)
	min_temperature = T0C + 30
	max_temperature = T0C + 60

/datum/plant_need/xenoflora/hrukhza
	required_gases = list(GAS_CO2 = 0.1)
	min_temperature = T0C + 20
	max_temperature = T0C + 55

/datum/plant_need/xenoflora/aghrassh
	required_gases = list(GAS_CO2 = 0.15)
	required_reagents = list(/datum/reagent/ash = 0.05)
	min_temperature = T0C + 45
	max_temperature = T0C + 90

/datum/plant_need/xenoflora/okrri
	required_gases = list(GAS_H2O = 0.05)
	min_temperature = T0C + 5
	max_temperature = T0C + 20

/datum/plant_need/xenoflora/ximikoa
	required_gases = list(GAS_O2 = 0.05)
	required_reagents = list(/datum/reagent/water = 0.15)
	min_temperature = T0C + 10
	max_temperature = T0C + 25

/datum/plant_need/xenoflora/qokkloa
	required_gases = list(GAS_H2O = 0.1)
	required_reagents = list(/datum/reagent/water = 0.1)
	min_temperature = T0C
	max_temperature = T0C + 15

/datum/plant_need/xenoflora/iridast
	required_gases = list(GAS_O2 = 0.1)
	required_reagents = list(/datum/reagent/plantnutriment/eznutriment = 0.05)
	min_temperature = T0C + 15
	max_temperature = T0C + 35

/datum/plant_need/xenoflora/affelerin
	required_gases = list(GAS_CO2 = 0.05)
	required_reagents = list(/datum/reagent/silicon = 0.05)
	min_temperature = T0C + 50
	max_temperature = T0C + 100

/datum/plant_need/xenoflora/gummen
	required_gases = list(GAS_N2 = 0.15)
	required_reagents = list(/datum/reagent/nitrogen = 0.05) //nie amoniak: z wodą w zbiorniku robi się z niego płyn czyszczący
	min_temperature = T0C - 30
	max_temperature = T0C + 10

/datum/plant_need/xenoflora/merlin_tears
	required_gases = list(GAS_PLASMA = 0.1)
	required_reagents = list(/datum/reagent/water/holywater = 0.1)
	min_temperature = T0C + 15
	max_temperature = T0C + 25

/*
	Owoce
*/
/datum/plant_feature/fruit/xenoflora/rasy
	abstract_type = /datum/plant_feature/fruit/xenoflora/rasy
	seed_icon = 'aquila/icons/obj/hydroponics/ported_kseno_rasy_seeds.dmi'

/// Guche (Bay: gukhe bloom), Moghes, kuchnia Unathi Yeosa
/datum/plant_feature/fruit/xenoflora/rasy/gukhe
	species_name = "alga yeosa"
	name = "guche"
	icon_state = "flower_2"
	colour_override = "#e93e1c"
	seed_icon_state = "seed-gukhe"
	fruit_product = /obj/item/food/grown/xenoflora/rasy/gukhe
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/gukhe)
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/capsaicin = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/// Hruchza (Bay: hrukhza), Moghes. Wyciąg z liści hrukhzy (unathijuice) zamieniony na herbatę
/datum/plant_feature/fruit/xenoflora/rasy/hrukhza
	species_name = "folium moghesianum"
	name = "hruchza"
	icon_state = "tabacco_2"
	seed_icon_state = "seed-hrukhza"
	fruit_product = /obj/item/food/grown/xenoflora/rasy/hrukhza
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/hrukhza)
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/tea = PLANT_REAGENT_LARGE)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/// Aghrasz (Bay: aghrassh tree), pustynie Moghes
/datum/plant_feature/fruit/xenoflora/rasy/aghrassh
	species_name = "arbor deserti moghesiani"
	name = "aghrasz"
	icon_state = "coconut"
	seed_icon_state = "seed-aghrassh"
	fruit_product = /obj/item/food/grown/xenoflora/rasy/aghrassh
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/aghrassh)
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment/large, /datum/plant_trait/reagent/fruit/vitamin)
	total_volume = PLANT_FRUIT_VOLUME_MEDIUM
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	fruit_size = PLANT_FRUIT_SIZE_MEDIUM

/// Ksimikoa (Bay: ximi'koa), Qerrbalak
/datum/plant_feature/fruit/flower/ksimikoa
	species_name = "flos qerrbalakensis"
	name = "ksimikoa"
	family = "Xenoflora"
	icon_state = "flower_1"
	colour_override = "#e12626"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_kseno_rasy_seeds.dmi'
	seed_icon_state = "seed-ximikoa"
	fruit_product = /obj/item/food/grown/xenoflora/rasy/ximikoa
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/ximikoa)
	plant_traits = list(/datum/plant_trait/nectar, /datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/sugar = PLANT_REAGENT_LARGE)
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list()

/// Mech kokloa (Bay: qokk'loa moss), Qerrbalak. Hextro zamieniony na grzybowy halucynogen, alkohol qokk'loa na etanol
/datum/plant_feature/fruit/xenoflora/rasy/qokkloa
	species_name = "muscus qerrbalakensis"
	name = "mech kokloa"
	icon_state = "shamrock"
	colour_override = "#8c4637"
	seed_icon_state = "seed-qokkloa"
	fruit_product = /obj/item/food/grown/xenoflora/rasy/qokkloa
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/qokkloa)
	fast_reagents = list(/datum/reagent/consumable/ethanol = PLANT_REAGENT_MEDIUM, /datum/reagent/drug/mushroomhallucinogen = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/// Irydast (Bay: iridast bush), światy ludzi. Sok z jagód irydastu (alkohol) zamieniony na wino, psylocybina na grzybowy halucynogen
/datum/plant_feature/fruit/xenoflora/rasy/iridast
	species_name = "bacca iridastis"
	name = "irydast"
	icon_state = "berry"
	colour_override = "#fa68ff"
	seed_icon_state = "seed-iridast"
	fruit_product = /obj/item/food/grown/xenoflora/rasy/iridast
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/iridast)
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/ethanol/wine = PLANT_REAGENT_LARGE, /datum/reagent/drug/mushroomhallucinogen = PLANT_REAGENT_MICRO)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/// Afelerin (Bay: affelerin flower), światy pustynne. Nektar afelerinu zamieniony na miód
/datum/plant_feature/fruit/flower/afelerin
	species_name = "flos deserti"
	name = "afelerin"
	family = "Xenoflora"
	icon_state = "flower_3"
	colour_override = "#31d496"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_kseno_rasy_seeds.dmi'
	seed_icon_state = "seed-affelerin"
	fruit_product = /obj/item/food/grown/xenoflora/rasy/affelerin
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/affelerin)
	plant_traits = list(/datum/plant_trait/nectar, /datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/honey = PLANT_REAGENT_LARGE)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	mutations = list()

/// Fasola gummen (Bay: gummen bean plant)
/datum/plant_feature/fruit/xenoflora/rasy/gummen
	species_name = "phaseolus gummenis"
	name = "fasola gummen"
	icon_state = "pod"
	colour_override = "#36a32f"
	seed_icon_state = "seed-gummen"
	fruit_product = /obj/item/food/grown/xenoflora/rasy/gummen
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/gummen)
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment/large)
	total_volume = PLANT_FRUIT_VOLUME_MEDIUM
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/*
	Łzy Merlina (Bay: merlin tears, roślina z zaklęcia czarodzieja „Sanctuary”).
	Zamiany: dermalina na kelotan, dylowen na antytoksynę, alkizyna na mannitol, imidazolina na okulinę, peridaksyna na korazon.
*/
/datum/plant_feature/fruit/xenoflora/rasy/merlin_tears
	species_name = "lacrimae merlini"
	name = "łzy Merlina"
	icon_state = "berry"
	colour_override = "#4d4dff"
	seed_icon_state = "seed-merlin_tears"
	fruit_product = /obj/item/food/grown/xenoflora/rasy/merlin_tears
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/merlin_tears)
	fast_reagents = list(
		/datum/reagent/medicine/bicaridine = PLANT_REAGENT_SMALL,
		/datum/reagent/medicine/kelotane = PLANT_REAGENT_SMALL,
		/datum/reagent/medicine/antitoxin = PLANT_REAGENT_SMALL,
		/datum/reagent/medicine/tricordrazine = PLANT_REAGENT_SMALL,
		/datum/reagent/medicine/mannitol = PLANT_REAGENT_MICRO,
		/datum/reagent/medicine/oculine = PLANT_REAGENT_MICRO,
		/datum/reagent/medicine/corazone = PLANT_REAGENT_MICRO,
	)
	total_volume = PLANT_FRUIT_VOLUME_MEDIUM
	growth_time = PLANT_FRUIT_GROWTH_SLOW

/// Grzyb okri (Bay: o'krri mushroom), Qerrbalak. Psylocybina zamieniona na grzybowy halucynogen
/datum/plant_feature/fruit/mushroom/okrri
	species_name = "fungus qerrbalakensis"
	name = "okri"
	family = "Xenoflora"
	icon_state = "cap"
	colour_overlay = "cap_colour"
	colour_override = "#e0e926"
	genetic_budget = 2
	seed_icon = 'aquila/icons/obj/hydroponics/ported_kseno_rasy_seeds.dmi'
	seed_icon_state = "seed-okrri"
	fruit_product = /obj/item/food/grown/mushroom/okrri
	plant_needs = list(/datum/plant_need/xenoflora/okrri)
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment/large)
	fast_reagents = list(/datum/reagent/drug/mushroomhallucinogen = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/// Grzybnia okri: zwykła grzybnia nie ma potrzeb, więc bez tego rosłaby w kapsule bez warunków (owocowałaby tylko z nimi)
/datum/plant_feature/body/mushroom/xenoflora
	species_name = "fungus corporis alienus"
	name = "grzybnia obca"
	plant_needs = list(/datum/plant_need/xenoflora_pod)

/*
	Nasiona (tylko ksenoflora: pula artefaktu „Seeding” i ruin planet)
*/
/obj/item/plant_seeds/preset/alien/xenoflora/rasy
	icon = 'aquila/icons/obj/hydroponics/ported_kseno_rasy_seeds.dmi'
	abstract_type = /obj/item/plant_seeds/preset/alien/xenoflora/rasy

/obj/item/plant_seeds/preset/alien/xenoflora/rasy/gukhe
	name = "nasiona: guche (kapsuła ksenoflory)"
	name_override = "guche"
	icon_state = "seed-gukhe"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/tuber, /datum/plant_feature/fruit/xenoflora/rasy/gukhe)

/obj/item/plant_seeds/preset/alien/xenoflora/rasy/hrukhza
	name = "nasiona: hruchza (kapsuła ksenoflory)"
	name_override = "hruchza"
	icon_state = "seed-hrukhza"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/bush_vine/cannabis/tobacco, /datum/plant_feature/fruit/xenoflora/rasy/hrukhza)

/obj/item/plant_seeds/preset/alien/xenoflora/rasy/aghrassh
	name = "nasiona: drzewo aghrasz (kapsuła ksenoflory)"
	name_override = "drzewo aghrasz"
	icon_state = "seed-aghrassh"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/tree/sparse, /datum/plant_feature/fruit/xenoflora/rasy/aghrassh)

/obj/item/plant_seeds/preset/alien/xenoflora/rasy/okrri
	name = "zarodniki: okri (kapsuła ksenoflory)"
	name_override = "okri"
	icon_state = "seed-okrri"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/mushroom/xenoflora, /datum/plant_feature/fruit/mushroom/okrri)

/obj/item/plant_seeds/preset/alien/xenoflora/rasy/ximikoa
	name = "nasiona: ksimikoa (kapsuła ksenoflory)"
	name_override = "ksimikoa"
	icon_state = "seed-ximikoa"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/bush_vine/flower, /datum/plant_feature/fruit/flower/ksimikoa)

/obj/item/plant_seeds/preset/alien/xenoflora/rasy/qokkloa
	name = "nasiona: mech kokloa (kapsuła ksenoflory)"
	name_override = "mech kokloa"
	icon_state = "seed-qokkloa"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/tuber, /datum/plant_feature/fruit/xenoflora/rasy/qokkloa)

/obj/item/plant_seeds/preset/alien/xenoflora/rasy/iridast
	name = "nasiona: krzew irydastu (kapsuła ksenoflory)"
	name_override = "krzew irydastu"
	icon_state = "seed-iridast"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/bush_vine/berry, /datum/plant_feature/fruit/xenoflora/rasy/iridast)

/obj/item/plant_seeds/preset/alien/xenoflora/rasy/affelerin
	name = "nasiona: afelerin (kapsuła ksenoflory)"
	name_override = "afelerin"
	icon_state = "seed-affelerin"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/corn_stalk/flower, /datum/plant_feature/fruit/flower/afelerin)

/obj/item/plant_seeds/preset/alien/xenoflora/rasy/gummen
	name = "nasiona: fasola gummen (kapsuła ksenoflory)"
	name_override = "fasola gummen"
	icon_state = "seed-gummen"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/bush_vine/soybean, /datum/plant_feature/fruit/xenoflora/rasy/gummen)

/obj/item/plant_seeds/preset/alien/xenoflora/rasy/merlin_tears
	name = "nasiona: łzy Merlina (kapsuła ksenoflory)"
	name_override = "łzy Merlina"
	icon_state = "seed-merlin_tears"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/tree/mini, /datum/plant_feature/fruit/xenoflora/rasy/merlin_tears)

/*
	Plony
*/
/obj/item/food/grown/xenoflora/rasy
	abstract_type = /obj/item/food/grown/xenoflora/rasy
	icon = 'aquila/icons/obj/hydroponics/ported_kseno_rasy_harvest.dmi'

/obj/item/food/grown/xenoflora/rasy/gukhe
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/rasy/gukhe
	name = "zakwit guche"
	desc = "Czerwony, gorzko-ostry kożuch glonów z ciepłych mórz Moghes. Unathi Yeosa nacierają nim ryby przed suszeniem."
	icon_state = "gukhe"
	tastes = list("gorycz" = 2, "pikantność" = 2, "morze" = 1)
	foodtypes = VEGETABLES
	grind_results = list(/datum/reagent/consumable/capsaicin = 0)

/obj/item/food/grown/xenoflora/rasy/hrukhza
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/rasy/hrukhza
	name = "liść hruchzy"
	desc = "Ciemnozielony liść hruchzy z Moghes. Gorzki wyciąg z niego trafia do większości przepisów Unathi, a korzeń krzewu jest symbolem jednej z ich wiar."
	icon_state = "hrukhza"
	tastes = list("mdła gorycz" = 3)
	foodtypes = VEGETABLES | GROSS
	juice_typepath = /datum/reagent/consumable/tea

/obj/item/food/grown/xenoflora/rasy/aghrassh
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/rasy/aghrassh
	name = "owoc aghrasza"
	desc = "Twardy, brązowy owoc pustynnego drzewa aghrasz z Moghes. Unathi wędrujący przez pustynie ucierają z niego sycącą pastę."
	icon_state = "aghrassh"
	tastes = list("orzechowa pasta" = 2, "piasek" = 1)
	foodtypes = FRUIT

/obj/item/food/grown/mushroom/okrri
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/rasy/okrri
	name = "grzyb okri"
	desc = "Żółta kiść grzybów okri z wilgotnych lasów Qerrbalak. Skrellowie jadają je na surowo, ludziom potrafią namieszać w głowie."
	icon = 'aquila/icons/obj/hydroponics/ported_kseno_rasy_harvest.dmi'
	icon_state = "okrri"
	tastes = list("grzyby" = 2, "wilgoć" = 1)

/obj/item/food/grown/xenoflora/rasy/ximikoa
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/rasy/ximikoa
	name = "kwiat ksimikoi"
	desc = "Drobny, czerwony kwiat ksimikoi z Qerrbalak, słodki jak cukierek."
	icon_state = "ximikoa"
	tastes = list("słodycz" = 3, "kwiaty" = 1)
	foodtypes = VEGETABLES | SUGAR
	w_class = WEIGHT_CLASS_TINY
	grind_results = list(/datum/reagent/consumable/sugar = 0)

/obj/item/food/grown/xenoflora/rasy/qokkloa
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/rasy/qokkloa
	name = "kępa mchu kokloa"
	desc = "Śliska, rdzawa kępa mchu kokloa z Qerrbalak. Skrellom nic nie robi, ludziom miesza w głowie, a z alkoholem bywa groźna."
	icon_state = "qokkloa"
	tastes = list("zimny, śliski grzyb" = 2, "alkohol" = 1)
	foodtypes = VEGETABLES | ALCOHOL
	juice_typepath = /datum/reagent/consumable/ethanol

/obj/item/food/grown/xenoflora/rasy/iridast
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/rasy/iridast
	name = "jagody irydastu"
	desc = "Garść różowych jagód irydastu, popularnych na światach ludzi. Ich sok sam z siebie upaja."
	icon_state = "iridast"
	tastes = list("niezwykła słodycz" = 3)
	foodtypes = FRUIT | ALCOHOL
	juice_typepath = /datum/reagent/consumable/ethanol/wine

/obj/item/food/grown/xenoflora/rasy/affelerin
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/rasy/affelerin
	name = "kwiat afelerinu"
	desc = "Turkusowy kwiat afelerinu, rosnącego na wielu pustynnych światach. W środku ma gęsty, słodki nektar."
	icon_state = "affelerin"
	tastes = list("gęsty syrop" = 3)
	foodtypes = VEGETABLES | SUGAR
	w_class = WEIGHT_CLASS_TINY
	juice_typepath = /datum/reagent/consumable/honey

/obj/item/food/grown/xenoflora/rasy/gummen
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/rasy/gummen
	name = "strąk fasoli gummen"
	desc = "Gruby, zielony strąk fasoli gummen. Mało smaku, dużo sytości."
	icon_state = "gummen"
	tastes = list("fasola" = 2, "guma" = 1)
	foodtypes = VEGETABLES

/obj/item/food/grown/xenoflora/rasy/merlin_tears
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/rasy/merlin_tears
	name = "łzy Merlina"
	desc = "Kiść niebieskich jagód, które podobno wyrosły z łez czarodzieja. Leczą rany, oparzenia i zatrucia."
	icon_state = "merlin_tears"
	tastes = list("jagody" = 2, "magia" = 1)
	foodtypes = FRUIT
