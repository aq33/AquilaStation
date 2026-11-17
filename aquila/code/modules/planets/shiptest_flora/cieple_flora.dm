// AQUILA - dzika flora ciepłych planet (lawa, dżungla, piaski), port do naszej botaniki. Każda roślina to struktura
// /obj/structure/flora/ash (prawdziwa roślina z nasion seed_type, zbiór ręką, odrasta), cecha owocu, nasiona i plon.
// Źródła (kod AGPLv3, ikony CC BY-SA 3.0):
// - gwiaździsty kaktus: tgstation/tgstation, code/modules/mining/lavaland/ash_flora.dm (mutacja kaktusa popielnego);
// - grzyby świetlne: Monkestation/Monkestation2.0, monkestation/code/modules/map_gen_expansions/mushroom/flora.dm;
// - chinowiec, magnus purpura, kuku, bondżi, bianko, kapelusz liberała: yogstation13/Yogstation,
//   yogstation/code/modules/jungleland/ (jungle_items.dm, jungle_structures.dm);
// - opuncja, kaktus San Pedro, pejotl: ParadiseSS13/Paradise, code/modules/hydroponics/grown/cactus.dm.
// Odczynników, których nie mamy, nie przenosimy. Zamienniki: chinina -> spacylina, enzym magnus purpury -> antytoksyna,
// retrosacharyd -> trikordrazyna, polibycyna i LSD -> grzybowy halucynogen, helbital -> bikarydyna.
// Struktury w świecie z ostatniego etapu wzrostu w tacy, gdy oryginał nie ma osobnego sprite'a.

/// Mutacje w piecu z roślin, które już mamy
/datum/plant_mutation_set/cieple
	mutations = list(
		/datum/plant_feature/fruit/cactus = list(/datum/plant_feature/fruit/star_cactus = 3),
	)

/*
	Gwiaździsty kaktus (tg: star cactus), mutacja kaktusa popielnego i rzadka dzika roślina lawy
*/
/obj/structure/flora/ash/cacti/star
	name = "skupisko gwiaździstych kaktusów"
	desc = "Kolczaste, okrągłe kaktusy zbite w gromadkę. I nie, nie nazywają się gwiaździste dlatego, że rosną w kosmosie."
	icon = 'aquila/icons/planets/flora/cieple_flora.dmi'
	icon_state = "star_cactus"
	base_icon_state = "star_cactus"
	seed_type = /obj/item/plant_seeds/preset/star_cactus

/obj/structure/flora/ash/cacti/star/Initialize(mapload)
	. = ..()
	icon_state = "star_cactus"

/datum/plant_feature/fruit/star_cactus
	species_name = "astrophytum asterias"
	name = "gwiaździsty kaktus"
	icon = 'aquila/icons/planets/flora/cieple_flora_fruit.dmi'
	icon_state = "star_cactus"
	seed_icon = 'aquila/icons/planets/flora/cieple_flora.dmi'
	seed_icon_state = "seed-starcactus"
	fruit_product = /obj/item/food/grown/star_cactus
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/fruit/prickles)
	fast_reagents = list(/datum/reagent/water = PLANT_REAGENT_SMALL, /datum/reagent/medicine/bicaridine = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_MEDIUM
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

/obj/item/plant_seeds/preset/star_cactus
	name = "nasiona: gwiaździsty kaktus (dowolne podłoże)"
	name_override = "gwiaździsty kaktus"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/star_cactus)

/obj/item/food/grown/star_cactus
	seed = /obj/item/plant_seeds/preset/star_cactus
	name = "gwiaździsty kaktus"
	desc = "Kolczaste, okrągłe skupisko gwiaździstych kaktusów. I nie, nie nazywają się gwiaździste dlatego, że rosną w kosmosie."
	icon = 'aquila/icons/planets/flora/cieple_flora_harvest.dmi'
	icon_state = "star_cactus"
	foodtypes = VEGETABLES
	tastes = list("kaktus" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/tequila

/*
	Grzyby świetlne (Monke: lightshroom), czerwone, niebieskie i zielone, w jaskiniach planet wulkanicznych
*/
/obj/structure/flora/ash/lightshroom
	name = "czerwone grzyby świetlne"
	desc = "Dziwne, świecące grzyby, które rosną tam, gdzie pod ziemią biją źródła ciekłej plazmy."
	icon = 'aquila/icons/planets/flora/cieple_flora.dmi'
	icon_state = "lightshroom_red"
	base_icon_state = "lightshroom_red"
	seed_type = /obj/item/plant_seeds/preset/lightshroom_red
	light_range = 2
	light_power = 1
	light_color = "#FF3333"

/obj/structure/flora/ash/lightshroom/Initialize(mapload)
	. = ..()
	icon_state = initial(icon_state)

/obj/structure/flora/ash/lightshroom/blue
	name = "niebieskie grzyby świetlne"
	icon_state = "lightshroom_blue"
	base_icon_state = "lightshroom_blue"
	seed_type = /obj/item/plant_seeds/preset/lightshroom_blue
	light_color = "#6699FF"

/obj/structure/flora/ash/lightshroom/green
	name = "zielone grzyby świetlne"
	icon_state = "lightshroom_green"
	base_icon_state = "lightshroom_green"
	seed_type = /obj/item/plant_seeds/preset/lightshroom_green
	light_color = "#99FF99"

// Podtyp świecącego grzyba: bierze od niego świecącą poświatę owocu w tacy, resztę ustawia od nowa
/datum/plant_feature/fruit/mushroom/glowshroom/lightshroom
	species_name = "lux fungus ruber"
	name = "czerwony grzyb świetlny"
	icon_state = "fly"
	colour_overlay = "fly_colour"
	colour_override = "#ff5050"
	seed_icon = 'aquila/icons/planets/flora/cieple_flora.dmi'
	seed_icon_state = "mycelium-lightshroom_red"
	fruit_product = /obj/item/food/grown/ash_flora/lightshroom_red
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	plant_traits = list(/datum/plant_trait/fruit/biolight/red, /datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/vitfro = PLANT_REAGENT_SMALL, /datum/reagent/uranium/radium = PLANT_REAGENT_SMALL)
	mutations = list()
	genetic_budget = 3

/datum/plant_feature/fruit/mushroom/glowshroom/lightshroom/blue
	species_name = "lux fungus caeruleus"
	name = "niebieski grzyb świetlny"
	colour_override = "#5080ff"
	seed_icon_state = "mycelium-lightshroom_blue"
	fruit_product = /obj/item/food/grown/ash_flora/lightshroom_blue
	plant_traits = list(/datum/plant_trait/fruit/biolight/blue, /datum/plant_trait/reagent/fruit/nutriment)

/datum/plant_feature/fruit/mushroom/glowshroom/lightshroom/green
	species_name = "lux fungus viridis"
	name = "zielony grzyb świetlny"
	colour_override = "#60e060"
	seed_icon_state = "mycelium-lightshroom_green"
	fruit_product = /obj/item/food/grown/ash_flora/lightshroom_green
	plant_traits = list(/datum/plant_trait/fruit/biolight/green, /datum/plant_trait/reagent/fruit/nutriment)

/obj/item/plant_seeds/preset/lightshroom_red
	name = "zarodniki: czerwony grzyb świetlny (dowolne podłoże)"
	name_override = "czerwony grzyb świetlny"
	plant_features = list(/datum/plant_feature/roots/hyphae, /datum/plant_feature/body/mushroom, /datum/plant_feature/fruit/mushroom/glowshroom/lightshroom)

/obj/item/plant_seeds/preset/lightshroom_blue
	name = "zarodniki: niebieski grzyb świetlny (dowolne podłoże)"
	name_override = "niebieski grzyb świetlny"
	plant_features = list(/datum/plant_feature/roots/hyphae, /datum/plant_feature/body/mushroom, /datum/plant_feature/fruit/mushroom/glowshroom/lightshroom/blue)

/obj/item/plant_seeds/preset/lightshroom_green
	name = "zarodniki: zielony grzyb świetlny (dowolne podłoże)"
	name_override = "zielony grzyb świetlny"
	plant_features = list(/datum/plant_feature/roots/hyphae, /datum/plant_feature/body/mushroom, /datum/plant_feature/fruit/mushroom/glowshroom/lightshroom/green)

/obj/item/food/grown/ash_flora/lightshroom_red
	name = "czerwony grzyb świetlny"
	desc = "Świecący grzyb."
	icon = 'aquila/icons/planets/flora/cieple_flora_harvest.dmi'
	icon_state = "lightshroom_red"
	seed = /obj/item/plant_seeds/preset/lightshroom_red
	wine_power = 40

/obj/item/food/grown/ash_flora/lightshroom_blue
	name = "niebieski grzyb świetlny"
	desc = "Świecący grzyb."
	icon = 'aquila/icons/planets/flora/cieple_flora_harvest.dmi'
	icon_state = "lightshroom_blue"
	seed = /obj/item/plant_seeds/preset/lightshroom_blue
	wine_power = 40

/obj/item/food/grown/ash_flora/lightshroom_green
	name = "zielony grzyb świetlny"
	desc = "Świecący grzyb."
	icon = 'aquila/icons/planets/flora/cieple_flora_harvest.dmi'
	icon_state = "lightshroom_green"
	seed = /obj/item/plant_seeds/preset/lightshroom_green
	wine_power = 40

/*
	Chinowiec (Yoga: cinchona), dżungla
*/
/obj/structure/flora/ash/cinchona
	name = "chinowiec egzotyczny"
	desc = "Małe, krzewiaste drzewko o bardzo osobliwej korze..."
	icon = 'aquila/icons/planets/flora/cieple_flora.dmi'
	icon_state = "cinchona"
	base_icon_state = "cinchona"
	seed_type = /obj/item/plant_seeds/preset/cinchona

/obj/structure/flora/ash/cinchona/Initialize(mapload)
	. = ..()
	icon_state = "cinchona"

/datum/plant_feature/fruit/cinchona
	species_name = "cinchona officinalis"
	name = "chinowiec"
	icon = 'aquila/icons/planets/flora/cieple_flora_fruit.dmi'
	icon_state = "cinchona"
	seed_icon = 'aquila/icons/planets/flora/cieple_flora.dmi'
	seed_icon_state = "seed-cinchona"
	fruit_product = /obj/item/food/grown/cinchona_bark
	fast_reagents = list(/datum/reagent/medicine/spaceacillin = PLANT_REAGENT_MEDIUM, /datum/reagent/medicine/atropine = PLANT_REAGENT_SMALL, /datum/reagent/medicine/omnizine = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

/obj/item/plant_seeds/preset/cinchona
	name = "nasiona: chinowiec (dowolne podłoże)"
	name_override = "chinowiec"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/cinchona)

/obj/item/food/grown/cinchona_bark
	seed = /obj/item/plant_seeds/preset/cinchona
	name = "kora chinowca"
	desc = "Silnie lecznicze zioło, które pomaga na wiele egzotycznych chorób."
	icon = 'aquila/icons/planets/flora/cieple_flora_harvest.dmi'
	icon_state = "cinchona_bark"
	tastes = list("gorycz" = 1)
	distill_reagent = /datum/reagent/space_cleaner/sterilizine

/*
	Magnus purpura (Yoga), dżungla
*/
/obj/structure/flora/ash/magnus_purpura
	name = "magnus purpura"
	desc = "Dziwny kwiat, który przetrwa w najcięższych zakątkach dżungli. Rośnie tam, gdzie inne rośliny rozpuszczają się i więdną."
	icon = 'aquila/icons/planets/flora/cieple_flora.dmi'
	icon_state = "magnus_purpura"
	base_icon_state = "magnus_purpura"
	seed_type = /obj/item/plant_seeds/preset/magnus_purpura

/obj/structure/flora/ash/magnus_purpura/Initialize(mapload)
	. = ..()
	icon_state = "magnus_purpura"

/datum/plant_feature/fruit/magnus_purpura
	species_name = "magnus purpura"
	name = "magnus purpura"
	icon_state = "flower_2"
	colour_overlay = "flower_2_colour"
	colour_override = "#d0307a"
	seed_icon = 'aquila/icons/planets/flora/cieple_flora.dmi'
	seed_icon_state = "seed-magnus_purpura"
	fruit_product = /obj/item/food/grown/magnus_purpura
	fast_reagents = list(/datum/reagent/medicine/antitoxin = PLANT_REAGENT_LARGE)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

/obj/item/plant_seeds/preset/magnus_purpura
	name = "nasiona: magnus purpura (dowolne podłoże)"
	name_override = "magnus purpura"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/magnus_purpura)

/obj/item/food/grown/magnus_purpura
	seed = /obj/item/plant_seeds/preset/magnus_purpura
	name = "kwiat magnus purpury"
	desc = "Główka ogromnego kwiatu. Zawiera silne enzymy, które oczyszczają organizm z toksyn."
	icon = 'aquila/icons/planets/flora/cieple_flora_harvest.dmi'
	icon_state = "magnus_purpura_flower"
	tastes = list("słodycz" = 1)

/*
	Jagody kuku, bondżi i bianko (Yoga: kuku, bonji, bianco), dżungla
*/
/obj/structure/flora/ash/kuku
	name = "krzak kuku"
	desc = "Owocująca roślina. Ciekawe, jak smakują jej jagody?"
	icon = 'aquila/icons/planets/flora/cieple_flora.dmi'
	icon_state = "kuku"
	base_icon_state = "kuku"
	seed_type = /obj/item/plant_seeds/preset/kuku

/obj/structure/flora/ash/kuku/Initialize(mapload)
	. = ..()
	icon_state = initial(icon_state)

/obj/structure/flora/ash/kuku/bonji
	name = "krzak bondżi"
	icon_state = "bonji"
	base_icon_state = "bonji"
	seed_type = /obj/item/plant_seeds/preset/bonji

/obj/structure/flora/ash/kuku/bianco
	name = "krzak bianko"
	icon_state = "bianco"
	base_icon_state = "bianco"
	seed_type = /obj/item/plant_seeds/preset/bianco

/datum/plant_feature/fruit/kuku
	species_name = "bacca kuku"
	name = "kuku"
	icon = 'aquila/icons/planets/flora/cieple_flora_fruit.dmi'
	icon_state = "kuku"
	seed_icon = 'aquila/icons/planets/flora/cieple_flora.dmi'
	seed_icon_state = "seed-kuku"
	fruit_product = /obj/item/food/grown/kuku
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/medicine/tricordrazine = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

/datum/plant_feature/fruit/bonji
	species_name = "bacca bonji"
	name = "bondżi"
	icon = 'aquila/icons/planets/flora/cieple_flora_fruit.dmi'
	icon_state = "bonji"
	seed_icon = 'aquila/icons/planets/flora/cieple_flora.dmi'
	seed_icon_state = "seed-bonji"
	fruit_product = /obj/item/food/grown/bonji
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment/large, /datum/plant_trait/fruit/liquid_contents)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

/datum/plant_feature/fruit/bianco
	species_name = "bacca bianco"
	name = "bianko"
	icon = 'aquila/icons/planets/flora/cieple_flora_fruit.dmi'
	icon_state = "bianco"
	seed_icon = 'aquila/icons/planets/flora/cieple_flora.dmi'
	seed_icon_state = "seed-bianco"
	fruit_product = /obj/item/food/grown/bianco
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment/large, /datum/plant_trait/reagent/fruit/vitamin, /datum/plant_trait/fruit/biolight/white)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

/obj/item/plant_seeds/preset/kuku
	name = "nasiona: kuku (dowolne podłoże)"
	name_override = "kuku"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/kuku)

/obj/item/plant_seeds/preset/bonji
	name = "nasiona: bondżi (dowolne podłoże)"
	name_override = "bondżi"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/bonji)

/obj/item/plant_seeds/preset/bianco
	name = "nasiona: bianko (dowolne podłoże)"
	name_override = "bianko"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/bianco)

/obj/item/food/grown/kuku
	seed = /obj/item/plant_seeds/preset/kuku
	name = "jagoda kuku"
	desc = "Co za śliczna jagoda!"
	icon = 'aquila/icons/planets/flora/cieple_flora_harvest.dmi'
	icon_state = "kuku_fruit"
	foodtypes = FRUIT
	tastes = list("jagody" = 1)

/obj/item/food/grown/bonji
	seed = /obj/item/plant_seeds/preset/bonji
	name = "jagoda bondżi"
	desc = "Co za śliczna jagoda!"
	icon = 'aquila/icons/planets/flora/cieple_flora_harvest.dmi'
	icon_state = "bonji_fruit"
	foodtypes = FRUIT
	tastes = list("jagody" = 1)

/obj/item/food/grown/bianco
	seed = /obj/item/plant_seeds/preset/bianco
	name = "jagoda bianko"
	desc = "Co za śliczna jagoda!"
	icon = 'aquila/icons/planets/flora/cieple_flora_harvest.dmi'
	icon_state = "bianco_fruit"
	foodtypes = FRUIT
	tastes = list("jagody" = 1)

/*
	Kapelusz liberała (Yoga: liberal hat), grzyb dżungli
*/
/obj/structure/flora/ash/liberal_hat
	name = "kapelusze liberała"
	desc = "Uwolnij się z kajdan ciała: zjedz je i zobacz świat w nowych kolorach."
	icon = 'aquila/icons/planets/flora/cieple_flora.dmi'
	icon_state = "liberal_hat"
	base_icon_state = "liberal_hat"
	seed_type = /obj/item/plant_seeds/preset/liberal_hat

/obj/structure/flora/ash/liberal_hat/Initialize(mapload)
	. = ..()
	icon_state = "liberal_hat"

/datum/plant_feature/fruit/mushroom/liberal_hat
	species_name = "libertatem fungus liberalis"
	name = "kapelusz liberała"
	icon_state = "cap"
	colour_overlay = "cap_colour"
	colour_override = "#5a5f8a"
	seed_icon = 'aquila/icons/planets/flora/cieple_flora.dmi'
	seed_icon_state = "mycelium-liberal-hat"
	fruit_product = /obj/item/food/grown/liberal_hat
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_FAST
	fast_reagents = list(/datum/reagent/drug/mushroomhallucinogen = PLANT_REAGENT_MEDIUM, /datum/reagent/consumable/nutriment = PLANT_REAGENT_MICRO)
	genetic_budget = 2

/obj/item/plant_seeds/preset/liberal_hat
	name = "zarodniki: kapelusz liberała (dowolne podłoże)"
	name_override = "kapelusz liberała"
	plant_features = list(/datum/plant_feature/roots/hyphae, /datum/plant_feature/body/mushroom, /datum/plant_feature/fruit/mushroom/liberal_hat)

/obj/item/food/grown/liberal_hat
	seed = /obj/item/plant_seeds/preset/liberal_hat
	name = "kapelusz liberała"
	desc = "Czapki z głów, wariacie. Zjedz mnie i uwolnij umysł..."
	icon = 'aquila/icons/planets/flora/cieple_flora_harvest.dmi'
	icon_state = "liberal_hat"
	foodtypes = VEGETABLES
	tastes = list("kolory" = 1)

/*
	Opuncja, kaktus San Pedro i pejotl (Paradise: prickly pear, san pedro, peyote), piaski. Mutują po kolei w piecu.
*/
/obj/structure/flora/ash/cacti/prickly_pear
	name = "opuncja"
	desc = "Kaktus o płaskich, kolczastych pędach obsypanych czerwonymi owocami."
	icon = 'aquila/icons/planets/flora/cieple_flora.dmi'
	icon_state = "prickly_pear"
	base_icon_state = "prickly_pear"
	seed_type = /obj/item/plant_seeds/preset/prickly_pear

/obj/structure/flora/ash/cacti/prickly_pear/Initialize(mapload)
	. = ..()
	icon_state = "prickly_pear"

/obj/structure/flora/ash/san_pedro
	name = "kaktus San Pedro"
	desc = "Wysoki, kolumnowy kaktus z ziemskich Andów."
	icon = 'aquila/icons/planets/flora/cieple_flora.dmi'
	icon_state = "san_pedro"
	base_icon_state = "san_pedro"
	seed_type = /obj/item/plant_seeds/preset/san_pedro

/obj/structure/flora/ash/san_pedro/Initialize(mapload)
	. = ..()
	icon_state = "san_pedro"

/obj/structure/flora/ash/peyote
	name = "pejotl"
	desc = "Niski kaktus bez kolców, z pozoru zupełnie bezużyteczny."
	icon = 'aquila/icons/planets/flora/cieple_flora.dmi'
	icon_state = "peyote"
	base_icon_state = "peyote"
	seed_type = /obj/item/plant_seeds/preset/peyote

/obj/structure/flora/ash/peyote/Initialize(mapload)
	. = ..()
	icon_state = "peyote"

/datum/plant_feature/fruit/prickly_pear
	species_name = "opuntia ficus-indica"
	name = "opuncja"
	icon_state = "cactus_2"
	seed_icon = 'aquila/icons/planets/flora/cieple_flora.dmi'
	seed_icon_state = "seed-prickly_pear"
	fruit_product = /obj/item/food/grown/prickly_pear
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	total_volume = PLANT_FRUIT_VOLUME_MEDIUM
	growth_time = PLANT_FRUIT_GROWTH_FAST
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()
	mutations = list(/datum/plant_feature/fruit/san_pedro = 3)

/datum/plant_feature/fruit/san_pedro
	species_name = "echinopsis pachanoi"
	name = "kaktus San Pedro"
	icon = 'aquila/icons/planets/flora/cieple_flora_fruit.dmi'
	icon_state = "san_pedro"
	seed_icon = 'aquila/icons/planets/flora/cieple_flora.dmi'
	seed_icon_state = "seed-san_pedro"
	fruit_product = /obj/item/food/grown/san_pedro
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/sugar = PLANT_REAGENT_SMALL, /datum/reagent/drug/mushroomhallucinogen = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_MEDIUM
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()
	mutations = list(/datum/plant_feature/fruit/peyote = 5)

/datum/plant_feature/fruit/peyote
	species_name = "lophophora williamsii"
	name = "pejotl"
	icon = 'aquila/icons/planets/flora/cieple_flora_fruit.dmi'
	icon_state = "peyote"
	seed_icon = 'aquila/icons/planets/flora/cieple_flora.dmi'
	seed_icon_state = "seed-peyote"
	fruit_product = /obj/item/food/grown/peyote
	fast_reagents = list(/datum/reagent/drug/mushroomhallucinogen = PLANT_REAGENT_LARGE)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

/obj/item/plant_seeds/preset/prickly_pear
	name = "nasiona: opuncja (dowolne podłoże)"
	name_override = "opuncja"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/prickly_pear)

/obj/item/plant_seeds/preset/san_pedro
	name = "nasiona: kaktus San Pedro (dowolne podłoże)"
	name_override = "kaktus San Pedro"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/san_pedro)

/obj/item/plant_seeds/preset/peyote
	name = "nasiona: pejotl (dowolne podłoże)"
	name_override = "pejotl"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/peyote)

/obj/item/food/grown/prickly_pear
	seed = /obj/item/plant_seeds/preset/prickly_pear
	name = "owoc opuncji"
	desc = "Czerwone owoce tego kaktusa nazywa się też tunami."
	icon = 'aquila/icons/planets/flora/cieple_flora_harvest.dmi'
	icon_state = "prickly_pear"
	foodtypes = FRUIT
	tastes = list("słodycz" = 1, "mdły smak" = 1)

/obj/item/food/grown/san_pedro
	seed = /obj/item/plant_seeds/preset/san_pedro
	name = "kaktus San Pedro"
	desc = "Kaktus z ziemskich Andów. Leczniczy, ozdobny, a dla rdzennych ludów symbol życia."
	icon = 'aquila/icons/planets/flora/cieple_flora_harvest.dmi'
	icon_state = "san_pedro"
	force = 7
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	foodtypes = VEGETABLES
	tastes = list("dziwny smak" = 1, "woda" = 1)

/obj/item/food/grown/peyote
	seed = /obj/item/plant_seeds/preset/peyote
	name = "pejotl"
	desc = "Teraz widzę przyszłość, przeszłość i całą prawdę."
	icon = 'aquila/icons/planets/flora/cieple_flora_harvest.dmi'
	icon_state = "peyote"
	foodtypes = VEGETABLES
	tastes = list("zabawa" = 1)
