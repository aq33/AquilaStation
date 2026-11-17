/*
	AQUILA - owoce z Goona, Paradise i Baya (partia „inne”), wspólne rzeczy w inne.dm
*/

/*
	Brzoskwinia (Goon: peach)
*/
/datum/plant_feature/fruit/peach
	species_name = "prunus persica"
	name = "brzoskwinia"
	icon_state = "apple-2"
	colour_override = "#f6b48a"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-peach"
	fruit_product = /obj/item/food/grown/peach
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	fast_reagents = list(/datum/reagent/consumable/sugar = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	fruit_size = PLANT_FRUIT_SIZE_MEDIUM

/obj/item/plant_seeds/preset/peach
	name = "nasiona: brzoskwinia (ziemia)"
	name_override = "brzoskwinia"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-peach"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/tree/mini, /datum/plant_feature/fruit/peach)

/obj/item/food/grown/peach
	seed = /obj/item/plant_seeds/preset/peach
	name = "brzoskwinia"
	desc = "Czujesz się teraz brzoskwiniowo, ale po zjedzeniu zostanie ci tylko pestka."
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "peach"
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/peachjuice
	tastes = list("brzoskwinia" = 1)

/*
	Gruszka (Goon: pear)
*/
/datum/plant_feature/fruit/pear
	species_name = "pyrus communis"
	name = "gruszka"
	icon_state = "apple-2"
	colour_override = "#c9d64e"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-pear"
	fruit_product = /obj/item/food/grown/pear
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	fruit_size = PLANT_FRUIT_SIZE_MEDIUM

/obj/item/plant_seeds/preset/pear
	name = "nasiona: grusza (glina)"
	name_override = "grusza"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-pear"
	plant_features = list(/datum/plant_feature/roots/clay, /datum/plant_feature/body/tree/apple, /datum/plant_feature/fruit/pear)

/obj/item/food/grown/pear
	seed = /obj/item/plant_seeds/preset/pear
	name = "gruszka"
	desc = "Smak smakiem, ale świeżości nie można jej odmówić."
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "pear"
	foodtypes = FRUIT
	tastes = list("gruszka" = 1)

/*
	Truskawka (Goon: strawberry)
*/
/datum/plant_feature/fruit/strawberry
	species_name = "fragaria ananassa"
	name = "truskawka"
	icon_state = "tomato-2"
	icon_uneven = TRUE
	colour_override = "#ff3348"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-strawberry"
	fruit_product = /obj/item/food/grown/strawberry
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	fast_reagents = list(/datum/reagent/consumable/sugar = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/strawberry
	name = "nasiona: truskawka (ziemia)"
	name_override = "truskawka"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-strawberry"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine/berry, /datum/plant_feature/fruit/strawberry)

/obj/item/food/grown/strawberry
	seed = /obj/item/plant_seeds/preset/strawberry
	name = "truskawka"
	desc = "Świeżo zerwana truskawka."
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "strawberry"
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/berryjuice
	tastes = list("truskawka" = 1)

/*
	Malina (Goon: raspberry) i jej odmiany z pieca: jeżyna i niebieska malina
*/
/datum/plant_feature/fruit/raspberry
	species_name = "rubus idaeus"
	name = "malina"
	icon_state = "grapes"
	colour_override = "#d6345a"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-raspberry"
	fruit_product = /obj/item/food/grown/raspberry
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/raspberry/blackberry = 2, /datum/plant_feature/fruit/raspberry/blue = 3)

/obj/item/plant_seeds/preset/raspberry
	name = "nasiona: malina (glina)"
	name_override = "malina"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-raspberry"
	plant_features = list(/datum/plant_feature/roots/clay, /datum/plant_feature/body/bush_vine/berry, /datum/plant_feature/fruit/raspberry)

/obj/item/food/grown/raspberry
	seed = /obj/item/plant_seeds/preset/raspberry
	name = "malina"
	desc = "Świeżo zerwana malina."
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "raspberry"
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/berryjuice
	tastes = list("malina" = 1)

/datum/plant_feature/fruit/raspberry/blackberry
	species_name = "rubus fruticosus"
	name = "jeżyna"
	colour_override = "#2b2140"
	seed_icon_state = "seed-blackberry"
	fruit_product = /obj/item/food/grown/raspberry/blackberry
	mutations = list(/datum/plant_feature/fruit/raspberry)

/obj/item/plant_seeds/preset/blackberry
	name = "nasiona: jeżyna (glina)"
	name_override = "jeżyna"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-blackberry"
	plant_features = list(/datum/plant_feature/roots/clay, /datum/plant_feature/body/bush_vine/berry, /datum/plant_feature/fruit/raspberry/blackberry)

/obj/item/food/grown/raspberry/blackberry
	seed = /obj/item/plant_seeds/preset/blackberry
	name = "jeżyna"
	desc = "Świeżo zerwana jeżyna."
	icon_state = "blackberry"
	tastes = list("jeżyna" = 1)

/datum/plant_feature/fruit/raspberry/blue
	species_name = "rubus caeruleus"
	name = "niebieska malina"
	colour_override = "#4cc9e0"
	seed_icon_state = "seed-blueraspberry"
	fruit_product = /obj/item/food/grown/raspberry/blue
	mutations = list(/datum/plant_feature/fruit/raspberry)

/obj/item/plant_seeds/preset/blue_raspberry
	name = "nasiona: niebieska malina (glina)"
	name_override = "niebieska malina"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-blueraspberry"
	plant_features = list(/datum/plant_feature/roots/clay, /datum/plant_feature/body/bush_vine/berry, /datum/plant_feature/fruit/raspberry/blue)

/obj/item/food/grown/raspberry/blue
	seed = /obj/item/plant_seeds/preset/blue_raspberry
	name = "niebieska malina"
	desc = "Świeżo zerwana niebieska malina."
	icon_state = "blueraspberry"
	tastes = list("niebieska malina" = 1)

/*
	Borówka (Goon, Bay: blueberry), mutacja krzewu jagodowego w piecu
*/
/datum/plant_feature/fruit/berry/blueberry
	species_name = "vaccinium corymbosum"
	name = "borówka"
	colour_override = "#3b55d0"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-blueberry"
	fruit_product = /obj/item/food/grown/blueberry
	trait_power = 1
	fast_reagents = list()
	mutations = list(/datum/plant_feature/fruit/berry)

/obj/item/plant_seeds/preset/blueberry
	name = "nasiona: borówka (glina)"
	name_override = "borówka"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-blueberry"
	plant_features = list(/datum/plant_feature/roots/clay, /datum/plant_feature/body/bush_vine/berry, /datum/plant_feature/fruit/berry/blueberry)

/obj/item/food/grown/blueberry
	seed = /obj/item/plant_seeds/preset/blueberry
	name = "borówka"
	desc = "Świeżo zerwana borówka."
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "blueberry"
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/berryjuice
	tastes = list("borówka" = 1)

/*
	Melon miodowy (Monke: honeydew), mutacja arbuza w piecu
*/
/datum/plant_feature/fruit/watermelon/honeydew
	species_name = "cucumis melo inodorus"
	name = "melon miodowy"
	icon_state = "watermelon-2"
	colour_override = "#d8eaa0"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-honeydew"
	fruit_product = /obj/item/food/grown/honeydew
	fast_reagents = list(/datum/reagent/consumable/sugar = PLANT_REAGENT_SMALL)
	trait_power = 1
	mutations = list(/datum/plant_feature/fruit/watermelon)

/obj/item/plant_seeds/preset/honeydew
	name = "nasiona: melon miodowy (glina)"
	name_override = "melon miodowy"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-honeydew"
	plant_features = list(/datum/plant_feature/roots/clay, /datum/plant_feature/body/corn_stalk/ground, /datum/plant_feature/fruit/watermelon/honeydew)

/obj/item/food/grown/honeydew
	seed = /obj/item/plant_seeds/preset/honeydew
	name = "melon miodowy"
	desc = "Słodka odmiana melona, która w destylatorze, nie wiedzieć czemu, zamienia się w miód."
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "honeydew"
	bite_consumption_mod = 2
	w_class = WEIGHT_CLASS_NORMAL
	foodtypes = FRUIT
	distill_reagent = /datum/reagent/consumable/honey
	tastes = list("melon miodowy" = 1)

/*
	Awokado (Goon, Paradise: avocado)
*/
/datum/plant_feature/fruit/avocado
	species_name = "persea americana"
	name = "awokado"
	icon_state = "eggplant-2"
	colour_override = "#4a6a24"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-avocado"
	fruit_product = /obj/item/food/grown/avocado
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	fast_reagents = list(/datum/reagent/consumable/nutriment/fat/oil = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	fruit_size = PLANT_FRUIT_SIZE_MEDIUM

/obj/item/plant_seeds/preset/avocado
	name = "nasiona: awokado (piasek)"
	name_override = "awokado"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-avocado"
	plant_features = list(/datum/plant_feature/roots/sand, /datum/plant_feature/body/tree/mini, /datum/plant_feature/fruit/avocado)

/obj/item/food/grown/avocado
	seed = /obj/item/plant_seeds/preset/avocado
	name = "awokado"
	desc = "Ogromna jagoda meksykańskiego drzewa, pełna nienasyconych tłuszczów, błonnika i potasu."
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "avocado"
	foodtypes = FRUIT
	tastes = list("awokado" = 1)

/*
	Mango (Paradise: mango)
*/
/datum/plant_feature/fruit/mango
	species_name = "mangifera indica"
	name = "mango"
	icon_state = "apple-2"
	colour_override = "#f2a93b"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-mango"
	fruit_product = /obj/item/food/grown/mango
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	fast_reagents = list(/datum/reagent/consumable/sugar = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	fruit_size = PLANT_FRUIT_SIZE_MEDIUM

/obj/item/plant_seeds/preset/mango
	name = "nasiona: mango (piasek)"
	name_override = "mango"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-mango"
	plant_features = list(/datum/plant_feature/roots/sand, /datum/plant_feature/body/tree/mini, /datum/plant_feature/fruit/mango)

/obj/item/food/grown/mango
	seed = /obj/item/plant_seeds/preset/mango
	name = "mango"
	desc = "Podłużny owoc o niejadalnej skórce w kolorze od bladożółtego po ciemnoczerwony."
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "mango"
	foodtypes = FRUIT
	tastes = list("słodycz" = 1, "soczystość" = 1)

/*
	Kiwi (Paradise: kiwi)
*/
/datum/plant_feature/fruit/kiwi
	species_name = "actinidia deliciosa"
	name = "kiwi"
	icon_state = "potato-2"
	colour_override = "#8a6b3d"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-kiwi"
	fruit_product = /obj/item/food/grown/kiwi
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	fast_reagents = list(/datum/reagent/consumable/sugar = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/kiwi
	name = "nasiona: kiwi (ziemia)"
	name_override = "kiwi"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-kiwi"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine/grape, /datum/plant_feature/fruit/kiwi)

/obj/item/food/grown/kiwi
	seed = /obj/item/plant_seeds/preset/kiwi
	name = "kiwi"
	desc = "Jajowaty owoc różnej wielkości, pokryty cienką, brązową, puszystą skórką."
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "kiwi"
	foodtypes = FRUIT
	tastes = list("kwaśność" = 1, "słodycz" = 1)

/*
	Migdał (Bay: almond)
*/
/datum/plant_feature/fruit/almond
	species_name = "prunus dulcis"
	name = "migdał"
	icon_state = "pod"
	icon_uneven = TRUE
	colour_override = "#c9a27a"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-almond"
	fruit_product = /obj/item/food/grown/almond
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	fast_reagents = list(/datum/reagent/consumable/nutriment/fat/oil = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/obj/item/plant_seeds/preset/almond
	name = "nasiona: migdałowiec (glina)"
	name_override = "migdałowiec"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-almond"
	plant_features = list(/datum/plant_feature/roots/clay, /datum/plant_feature/body/tree/mini, /datum/plant_feature/fruit/almond)

/obj/item/food/grown/almond
	seed = /obj/item/plant_seeds/preset/almond
	name = "migdały"
	desc = "Garść migdałów w twardej łupinie."
	gender = PLURAL
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "almond"
	foodtypes = VEGETABLES
	tastes = list("migdały" = 1)
