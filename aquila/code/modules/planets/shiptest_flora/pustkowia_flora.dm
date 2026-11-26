// AQUILA - dzikie rośliny pustkowi z Mojave Sun (Mojave-Sun/mojave-sun-13, kod AGPLv3): mojave/flora/wasteplants.dm
// i wasteproduce.dm. Ikony z mojave/icons na licencji CC BY-NC-SA 3.0 (aquila/icons/planets/flora/pustkowia_flora*.dmi):
// sprite'y dzikich roślin z wastelandflora.dmi, plony z harvest_inventory.dmi, torebki to ich pusta torebka z małym plonem
// (harvest_world.dmi) i etykietą w kolorze rośliny. Tato, agawa, bieluń, punga, gejgerpunga i radjagoda nie mają u nich
// sprite'a dzikiej rośliny, więc w świecie stoi ich dojrzała roślina z growing.dmi z owocami w kolorze growing_color z ich kodu.
// U nas /obj/structure/flora/ash to prawdziwa roślina botaniki (wzór: ash_flora.dm), zbierana ręką i odrastająca.
// Mojave Sun daje plonom głównie odżywkę i witaminy; lecznicze działanie suszu (brokoł na oparzenia, xander na rany)
// i agawy („burn healing”) oddajemy małą ilością naszych leków. Zamienniki: trucizna Mojave Sun -> toksyna,
// bieluń -> toksyna i mindbreaker (ich „dark datura” z bielunia wywołuje halucynacje), promieniowanie gejgerpungi
// i radjagody -> uran (słabo napromieniowuje przy zjedzeniu), nalewka z agawy -> tequila.

// Struktury. Bazowe Initialize losuje stan "[base_icon_state][1-4]"; te rośliny mają mniej sprite'ów, więc ustawiają stan po ..()

/obj/structure/flora/ash/broc
	name = "brokoł"
	desc = "Smukła roślina z pomarańczowymi kwiatami brokołu."
	icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	icon_state = "brocflower1"
	base_icon_state = "brocflower"
	seed_type = /obj/item/plant_seeds/preset/broc

/obj/structure/flora/ash/broc/Initialize(mapload)
	. = ..()
	icon_state = "brocflower[rand(1, 2)]"

/obj/structure/flora/ash/xander
	name = "xander"
	desc = "Kępa roślin z ciemnymi korzeniami xandera."
	icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	icon_state = "xander1"
	base_icon_state = "xander"
	seed_type = /obj/item/plant_seeds/preset/xander

/obj/structure/flora/ash/xander/Initialize(mapload)
	. = ..()
	icon_state = "xander[rand(1, 2)]"

/obj/structure/flora/ash/mutfruit
	name = "krzew mutoowocu"
	desc = "Roślina obsypana mutoowocami."
	icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	icon_state = "mutfruit1"
	base_icon_state = "mutfruit"
	seed_type = /obj/item/plant_seeds/preset/mutfruit

/obj/structure/flora/ash/mutfruit/Initialize(mapload)
	. = ..()
	icon_state = "mutfruit[rand(1, 3)]"

/obj/structure/flora/ash/tato
	name = "krzak tato"
	desc = "Wiotki krzak z podłużnymi, czerwonymi owocami. Cuchnie."
	icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	icon_state = "tato"
	base_icon_state = "tato"
	seed_type = /obj/item/plant_seeds/preset/tato

/obj/structure/flora/ash/tato/Initialize(mapload)
	. = ..()
	icon_state = "tato"

/obj/structure/flora/ash/yucca
	name = "juka"
	desc = "Juka z mączystymi owocami."
	icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	icon_state = "yucca1"
	base_icon_state = "yucca"
	seed_type = /obj/item/plant_seeds/preset/yucca

/obj/structure/flora/ash/yucca/Initialize(mapload)
	. = ..()
	icon_state = "yucca1"

/obj/structure/flora/ash/agave
	name = "agawa"
	desc = "Rozety grubych, mięsistych liści agawy."
	icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	icon_state = "agave"
	base_icon_state = "agave"
	seed_type = /obj/item/plant_seeds/preset/agave

/obj/structure/flora/ash/agave/Initialize(mapload)
	. = ..()
	icon_state = "agave"

/obj/structure/flora/ash/datura
	name = "bieluń"
	desc = "Kępa bielunia z białymi kwiatami o dziwnym zapachu."
	icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	icon_state = "datura"
	base_icon_state = "datura"
	seed_type = /obj/item/plant_seeds/preset/datura

/obj/structure/flora/ash/datura/Initialize(mapload)
	. = ..()
	icon_state = "datura"

/obj/structure/flora/ash/punga
	name = "krzew pungi"
	desc = "Niski krzew z mięsistymi, żółtobrązowymi owocami pungi."
	icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	icon_state = "punga"
	base_icon_state = "punga"
	seed_type = /obj/item/plant_seeds/preset/punga

/obj/structure/flora/ash/punga/Initialize(mapload)
	. = ..()
	icon_state = "punga"

/obj/structure/flora/ash/geigerpunga
	name = "krzew gejgerpungi"
	desc = "Krzew pungi z owocami świecącymi na zielono. Licznik Geigera by tu zatrzeszczał."
	icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	icon_state = "geigerpunga"
	base_icon_state = "geigerpunga"
	seed_type = /obj/item/plant_seeds/preset/geigerpunga

/obj/structure/flora/ash/geigerpunga/Initialize(mapload)
	. = ..()
	icon_state = "geigerpunga"

/obj/structure/flora/ash/radberry
	name = "krzew radjagód"
	desc = "Krzew obsypany ciepłymi, świecącymi radjagodami."
	icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	icon_state = "radberry"
	base_icon_state = "radberry"
	seed_type = /obj/item/plant_seeds/preset/radberry

/obj/structure/flora/ash/radberry/Initialize(mapload)
	. = ..()
	icon_state = "radberry"

// Cechy owoców. Owoce na roślinie w tacy to przekolorowane kształty z naszego fruit.dmi. Stałe cechy kosztują najwyżej 2 pkt
// z budżetu 3, bo dzika roślina dostaje przy Initialize jeszcze jedną losową cechę (inaczej losowałaby potrzeby).

/datum/plant_feature/fruit/broc
	species_name = "flos broccus"
	name = "brokoł"
	icon_state = "flower_1"
	colour_overlay = "flower_1_colour"
	colour_override = "#d2691e"
	seed_icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	seed_icon_state = "seed_broc"
	fruit_product = /obj/item/food/grown/broc
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/medicine/kelotane = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

/datum/plant_feature/fruit/xander
	species_name = "radix xanderi"
	name = "xander"
	icon_state = "potato-2"
	colour_override = "#5a4038"
	seed_icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	seed_icon_state = "seed_xander"
	fruit_product = /obj/item/food/grown/xander
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/medicine/bicaridine = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

/datum/plant_feature/fruit/mutfruit
	species_name = "fructus mutatus"
	name = "mutoowoc"
	icon_state = "apple-2"
	colour_override = "#8a4fa0"
	seed_icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	seed_icon_state = "seed_mutfruit"
	fruit_product = /obj/item/food/grown/mutfruit
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

/datum/plant_feature/fruit/tato
	species_name = "solanum tato"
	name = "tato"
	icon_state = "tomato-2"
	colour_override = "#a8402e"
	seed_icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	seed_icon_state = "seed_tato"
	fruit_product = /obj/item/food/grown/tato
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

/datum/plant_feature/fruit/yucca
	species_name = "yucca deserti"
	name = "juka"
	icon_state = "eggplant-2"
	colour_override = "#7a7a32"
	seed_icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	seed_icon_state = "seed_yucca"
	fruit_product = /obj/item/food/grown/yucca
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment/large, /datum/plant_trait/reagent/fruit/vitamin)
	total_volume = PLANT_FRUIT_VOLUME_MEDIUM
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

/datum/plant_feature/fruit/agave
	species_name = "agave deserti"
	name = "agawa"
	icon_state = "pod"
	colour_override = "#4f7a6e"
	seed_icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	seed_icon_state = "seed_agave"
	fruit_product = /obj/item/food/grown/agave
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/medicine/kelotane = PLANT_REAGENT_MICRO)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_SLOW
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

/datum/plant_feature/fruit/datura
	species_name = "datura stramonium"
	name = "bieluń"
	icon_state = "flower_2"
	colour_overlay = "flower_2_colour"
	colour_override = "#f4f4f4"
	seed_icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	seed_icon_state = "seed_datura"
	fruit_product = /obj/item/food/grown/datura
	fast_reagents = list(/datum/reagent/toxin = PLANT_REAGENT_SMALL, /datum/reagent/toxin/mindbreaker = PLANT_REAGENT_MICRO)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

/datum/plant_feature/fruit/punga
	species_name = "punga paludosa"
	name = "punga"
	icon_state = "orb"
	colour_override = "#8a7a2a"
	seed_icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	seed_icon_state = "seed_punga"
	fruit_product = /obj/item/food/grown/punga
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/toxin = PLANT_REAGENT_MICRO)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()
	mutations = list(/datum/plant_feature/fruit/geigerpunga = 3)
	reagent_mutations = list(/datum/plant_feature/fruit/geigerpunga = list(/datum/reagent/uranium = 10))

/datum/plant_feature/fruit/geigerpunga
	species_name = "punga radians"
	name = "gejgerpunga"
	icon_state = "orb"
	colour_override = "#55ff06"
	seed_icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	seed_icon_state = "seed_geigerpunga"
	fruit_product = /obj/item/food/grown/geigerpunga
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/toxin = PLANT_REAGENT_SMALL, /datum/reagent/uranium = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

/datum/plant_feature/fruit/radberry
	species_name = "rubus radians"
	name = "radjagoda"
	icon_state = "berry"
	colour_override = "#3cff4c"
	seed_icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	seed_icon_state = "seed_radberry"
	fruit_product = /obj/item/food/grown/radberry
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/uranium = PLANT_REAGENT_MICRO)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

// Nasiona (nie do automatu: tylko z dzikich roślin)

/obj/item/plant_seeds/preset/broc
	random_pool = FALSE
	name = "nasiona: brokoł (dowolne podłoże)"
	name_override = "brokoł"
	icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	icon_state = "seed_broc"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/broc)

/obj/item/plant_seeds/preset/xander
	random_pool = FALSE
	name = "nasiona: xander (dowolne podłoże)"
	name_override = "xander"
	icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	icon_state = "seed_xander"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/xander)

/obj/item/plant_seeds/preset/mutfruit
	random_pool = FALSE
	name = "nasiona: mutoowoc (dowolne podłoże)"
	name_override = "mutoowoc"
	icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	icon_state = "seed_mutfruit"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/mutfruit)

/obj/item/plant_seeds/preset/tato
	random_pool = FALSE
	name = "nasiona: tato (dowolne podłoże)"
	name_override = "tato"
	icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	icon_state = "seed_tato"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/tato)

/obj/item/plant_seeds/preset/yucca
	random_pool = FALSE
	name = "nasiona: juka (dowolne podłoże)"
	name_override = "juka"
	icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	icon_state = "seed_yucca"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/yucca)

/obj/item/plant_seeds/preset/agave
	random_pool = FALSE
	name = "nasiona: agawa (dowolne podłoże)"
	name_override = "agawa"
	icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	icon_state = "seed_agave"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/agave)

/obj/item/plant_seeds/preset/datura
	random_pool = FALSE
	name = "nasiona: bieluń (dowolne podłoże)"
	name_override = "bieluń"
	icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	icon_state = "seed_datura"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/datura)

/obj/item/plant_seeds/preset/punga
	random_pool = FALSE
	name = "nasiona: punga (dowolne podłoże)"
	name_override = "punga"
	icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	icon_state = "seed_punga"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/punga)

/obj/item/plant_seeds/preset/geigerpunga
	random_pool = FALSE
	name = "nasiona: gejgerpunga (dowolne podłoże)"
	name_override = "gejgerpunga"
	icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	icon_state = "seed_geigerpunga"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/geigerpunga)

/obj/item/plant_seeds/preset/radberry
	random_pool = FALSE
	name = "nasiona: radjagoda (dowolne podłoże)"
	name_override = "radjagoda"
	icon = 'aquila/icons/planets/flora/pustkowia_flora.dmi'
	icon_state = "seed_radberry"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/radberry)

// Plony

/obj/item/food/grown/broc
	seed = /obj/item/plant_seeds/preset/broc
	name = "kwiat brokołu"
	desc = "Jaskrawopomarańczowy kwiat. Bardzo miękki w dotyku i łatwo go uszkodzić."
	icon = 'aquila/icons/planets/flora/pustkowia_flora_harvest.dmi'
	icon_state = "broc"
	foodtypes = VEGETABLES
	tastes = list("brokoł" = 1)
	wine_power = 20

/obj/item/food/grown/xander
	seed = /obj/item/plant_seeds/preset/xander
	name = "korzeń xandera"
	desc = "Ciemny, dość twardy korzeń. Nie ma wyraźnego zapachu."
	icon = 'aquila/icons/planets/flora/pustkowia_flora_harvest.dmi'
	icon_state = "xander"
	foodtypes = VEGETABLES | GROSS
	tastes = list("gorycz" = 1)
	wine_power = 15

/obj/item/food/grown/mutfruit
	seed = /obj/item/plant_seeds/preset/mutfruit
	name = "mutoowoc"
	desc = "Miękki, soczysty mutoowoc. Ogrzewa dłoń w dotyku."
	icon = 'aquila/icons/planets/flora/pustkowia_flora_harvest.dmi'
	icon_state = "mutfruit"
	foodtypes = FRUIT
	bite_consumption_mod = 2
	tastes = list("ciepło" = 5, "słodycz" = 2)
	wine_power = 30

/obj/item/food/grown/tato
	seed = /obj/item/plant_seeds/preset/tato
	name = "tato"
	desc = "Podłużny, twardy, czerwony owoc. Cuchnie obrzydliwie."
	icon = 'aquila/icons/planets/flora/pustkowia_flora_harvest.dmi'
	icon_state = "tato"
	foodtypes = VEGETABLES | GROSS
	bite_consumption_mod = 3
	tastes = list("surowe jajka" = 1)
	wine_power = 25

/obj/item/food/grown/yucca
	seed = /obj/item/plant_seeds/preset/yucca
	name = "owoc juki"
	desc = "Mięsisty, podłużny owoc. Pachnie lekko słodką skrobią."
	icon = 'aquila/icons/planets/flora/pustkowia_flora_harvest.dmi'
	icon_state = "yucca"
	foodtypes = FRUIT
	bite_consumption_mod = 4
	tastes = list("słodycz" = 5, "skrobia" = 2)
	wine_power = 25

/obj/item/food/grown/agave
	seed = /obj/item/plant_seeds/preset/agave
	name = "liść agawy"
	desc = "Mięsisty, twardy liść. Wygląda, jakby łatwo się łamał."
	icon = 'aquila/icons/planets/flora/pustkowia_flora_harvest.dmi'
	icon_state = "agave"
	foodtypes = VEGETABLES
	tastes = list("gorycz" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/tequila

/obj/item/food/grown/datura
	seed = /obj/item/plant_seeds/preset/datura
	name = "kwiat bielunia"
	desc = "Nieskazitelnie biały kwiat o dziwnym zapachu."
	icon = 'aquila/icons/planets/flora/pustkowia_flora_harvest.dmi'
	icon_state = "datura"
	foodtypes = GROSS | TOXIC
	tastes = list("gorycz" = 1)
	wine_power = 10

/obj/item/food/grown/punga
	seed = /obj/item/plant_seeds/preset/punga
	name = "owoc pungi"
	desc = "Mięsisty owoc o grubej, żółtobrązowej skórce. Dziwnie pachnie."
	icon = 'aquila/icons/planets/flora/pustkowia_flora_harvest.dmi'
	icon_state = "punga"
	foodtypes = FRUIT | TOXIC
	bite_consumption_mod = 2
	tastes = list("kwaśność" = 6, "ciepło" = 1)
	wine_power = 30

/obj/item/food/grown/geigerpunga
	seed = /obj/item/plant_seeds/preset/geigerpunga
	name = "owoc gejgerpungi"
	desc = "Świecący, mięsisty owoc o pulsującej zielonej skórce. Ma ostry, kwaśny zapach."
	icon = 'aquila/icons/planets/flora/pustkowia_flora_harvest.dmi'
	icon_state = "geigerpunga"
	foodtypes = FRUIT | TOXIC
	bite_consumption_mod = 2
	tastes = list("kwas" = 6, "pieczenie" = 5)
	wine_power = 45

/obj/item/food/grown/radberry
	seed = /obj/item/plant_seeds/preset/radberry
	name = "radjagoda"
	desc = "Świecąca, ciepła radjagoda. Skórka odchodzi płatami i odsłania miękki środek."
	icon = 'aquila/icons/planets/flora/pustkowia_flora_harvest.dmi'
	icon_state = "radberry"
	foodtypes = FRUIT | GROSS
	tastes = list("metal" = 5, "słodycz" = 1)
	wine_power = 35
