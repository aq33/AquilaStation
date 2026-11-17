/*
	AQUILA - odmiany roślin, które już mamy, z Goona (partia „inne”). Mutacje dopisuje /datum/plant_mutation_set/inne w inne.dm:
	w piecu albo od odczynnika w tacy (jak w Goonie: tomacco od nikotyny, wrzący pomidor od flogistonu, dynia korzenna od kapsaicyny).
	Gotowe nasiona są tylko dla map, skrzynek i testów, nie ma ich w automacie.
*/

/*
	Krwista pomarańcza (Goon: blood orange) - pomarańcza i krew w tacy
*/
/datum/plant_feature/fruit/orange/blood
	species_name = "citrum sanguineum"
	name = "krwista pomarańcza"
	colour_override = "#c8321e"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-bloodorange"
	fruit_product = /obj/item/food/grown/citrus/orange/blood
	fast_reagents = list(/datum/reagent/blood = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/orange)

/obj/item/plant_seeds/preset/blood_orange
	name = "nasiona: krwista pomarańcza (piasek)"
	name_override = "krwista pomarańcza"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-bloodorange"
	plant_features = list(/datum/plant_feature/roots/sand, /datum/plant_feature/body/tree/orange, /datum/plant_feature/fruit/orange/blood)

/obj/item/food/grown/citrus/orange/blood
	seed = /obj/item/plant_seeds/preset/blood_orange
	name = "krwista pomarańcza"
	desc = "Soczysta."
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "bloodorange"
	tastes = list("pomarańcza" = 1, "metal" = 1)

/*
	Mechaniczna pomarańcza (Goon: clockwork orange) - pomarańcza i żelazo w tacy
*/
/datum/plant_feature/fruit/orange/clockwork
	species_name = "citrum horologium"
	name = "mechaniczna pomarańcza"
	colour_override = "#d8c48a"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-clockworkorange"
	fruit_product = /obj/item/food/grown/citrus/orange/clockwork
	fast_reagents = list(/datum/reagent/iron = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/orange)

/obj/item/plant_seeds/preset/clockwork_orange
	name = "nasiona: mechaniczna pomarańcza (piasek)"
	name_override = "mechaniczna pomarańcza"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-clockworkorange"
	plant_features = list(/datum/plant_feature/roots/sand, /datum/plant_feature/body/tree/orange, /datum/plant_feature/fruit/orange/clockwork)

/obj/item/food/grown/citrus/orange/clockwork
	seed = /obj/item/plant_seeds/preset/clockwork_orange
	name = "mechaniczna pomarańcza"
	desc = "Lepiej jej nie jedz, chyba że trawisz metal."
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "clockworkorange"
	foodtypes = FRUIT | GROSS
	juice_typepath = null
	tastes = list("pomarańcza" = 1, "metal" = 2)

/*
	Grejpfrut (Goon: grapefruit) - mutacja winorośli w piecu
*/
/datum/plant_feature/fruit/grape/grapefruit
	species_name = "citrus paradisi"
	name = "grejpfrut"
	icon_state = "citrus"
	icon_uneven = TRUE
	colour_override = "#f07850"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-grapefruit"
	fruit_product = /obj/item/food/grown/grapefruit
	fast_reagents = list()
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/grape)

/obj/item/plant_seeds/preset/grapefruit
	name = "nasiona: grejpfrut (ziemia)"
	name_override = "grejpfrut"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-grapefruit"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine/grape, /datum/plant_feature/fruit/grape/grapefruit)

/obj/item/food/grown/grapefruit
	seed = /obj/item/plant_seeds/preset/grapefruit
	name = "grejpfrut"
	desc = "Pyszny owoc winogronowy. Tak przynajmniej twierdzi angielska nazwa."
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "grapefruit"
	foodtypes = FRUIT
	wine_power = 30
	tastes = list("grejpfrut" = 1)

/*
	Białe winogrona - mutacja zielonych winogron w piecu
*/
/datum/plant_feature/fruit/grape/white
	species_name = "uva alba"
	name = "białe winogrono"
	colour_override = "#eef0b8"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-whitegrapes"
	fruit_product = /obj/item/food/grown/grapes/white
	fast_reagents = list(/datum/reagent/consumable/sugar = PLANT_REAGENT_LARGE)
	mutations = list(/datum/plant_feature/fruit/grape/green)

/obj/item/plant_seeds/preset/white_grapes
	name = "nasiona: białe winogrona (ziemia)"
	name_override = "białe winogrona"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-whitegrapes"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine/grape, /datum/plant_feature/fruit/grape/white)

/obj/item/food/grown/grapes/white
	seed = /obj/item/plant_seeds/preset/white_grapes
	name = "białe winogrona"
	desc = "Jasne, słodkie winogrona, z których robi się białe wino."
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "whitegrapes"
	tastes = list("białe winogrono" = 1)

/*
	Tomacco (Goon: tomato tomacco) - pomidor i nikotyna w tacy
*/
/datum/plant_feature/fruit/tomato/tomacco
	species_name = "lycopersicum nicotiana"
	name = "tomacco"
	colour_override = "#a0703a"
	icon_state = "tomato-2"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-tomacco"
	fruit_product = /obj/item/food/grown/tomato/tomacco
	fast_reagents = list(/datum/reagent/drug/nicotine = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/tomato)

/obj/item/plant_seeds/preset/tomacco
	name = "nasiona: tomacco (ziemia)"
	name_override = "tomacco"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-tomacco"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine/tomato, /datum/plant_feature/fruit/tomato/tomacco)

/obj/item/food/grown/tomato/tomacco
	seed = /obj/item/plant_seeds/preset/tomacco
	name = "tomacco"
	desc = "Smakuje jak pomidor, a uzależnia jak tytoń."
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "tomacco"
	tastes = list("pomidor" = 1, "tytoń" = 1)

/*
	Wrzący pomidor (Goon: seething tomato) - pomidor i flogiston w tacy, po aktywacji nagrzewa zawartość
*/
/datum/plant_feature/fruit/tomato/seething
	species_name = "lycopersicum ardens"
	name = "wrzący pomidor"
	icon_state = "tomato-2"
	colour_override = "#ff5a14"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-seethingtomato"
	fruit_product = /obj/item/food/grown/tomato/seething
	//liquid_contents/sensitive aktywuje grzanie przy użyciu i rzucie, bez rozlania zawartości (jak wiśniowa bomba).
	//Dwie cechy po 1 i dwa odczynniki po 0,25 to 2,5 punktu, więc budżet 3 (domyślne 2 dałoby losowe dodatkowe potrzeby)
	genetic_budget = 3
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/fruit/temperature, /datum/plant_trait/fruit/liquid_contents/sensitive)
	fast_reagents = list(/datum/reagent/fuel = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/tomato)
	trait_power = 1.5

/obj/item/plant_seeds/preset/seething_tomato
	name = "nasiona: wrzący pomidor (ziemia)"
	name_override = "wrzący pomidor"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-seethingtomato"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine/tomato, /datum/plant_feature/fruit/tomato/seething)

/obj/item/food/grown/tomato/seething
	seed = /obj/item/plant_seeds/preset/seething_tomato
	name = "wrzący pomidor"
	desc = "Ty mówisz pomidor, ja walę cię skrzynką z narzędziami."
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "seethingtomato"
	foodtypes = FRUIT | TOXIC
	tastes = list("pomidor" = 1, "paliwo" = 1)

/*
	Kwantomat (quantumato) - mutacja niebieskiego pomidora w piecu, teleportuje jak bluespace'owy pomidor
*/
/datum/plant_feature/fruit/tomato/quantum
	species_name = "lycopersicum quanticum"
	name = "kwantomat"
	icon_state = "tomato-2"
	colour_override = "#7a3cff"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-quantumato"
	fruit_product = /obj/item/food/grown/tomato/quantum
	genetic_budget = 4
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin,
	/datum/plant_trait/fruit/liquid_contents, /datum/plant_trait/fruit/bluespace)
	fast_reagents = list(/datum/reagent/bluespace = PLANT_REAGENT_SMALL)
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	mutations = list(/datum/plant_feature/fruit/tomato/blue)
	trait_power = 1.5

/obj/item/plant_seeds/preset/quantumato
	name = "nasiona: kwantomat (ziemia)"
	name_override = "kwantomat"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-quantumato"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine/tomato, /datum/plant_feature/fruit/tomato/quantum)

/obj/item/food/grown/tomato/quantum
	seed = /obj/item/plant_seeds/preset/quantumato
	name = "kwantomat"
	desc = "Jest tu i jednocześnie gdzie indziej. Rzucony w kogoś przenosi go w losowe miejsce."
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "quantumato"
	discovery_points = 300
	tastes = list("pomidor" = 1, "niepewność" = 1)

/*
	Dwutoń (Goon: twobacco) - tytoń i dużo nikotyny w tacy
*/
/datum/plant_feature/fruit/tobacco/twobacco
	species_name = "folium fumigant duplex"
	name = "dwutoń"
	icon_state = "tabacco"
	colour_override = "#c8b070"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-twobacco"
	fruit_product = /obj/item/food/grown/tobacco/twobacco
	fast_reagents = list(/datum/reagent/drug/nicotine = PLANT_REAGENT_VERY_LARGE)
	mutations = list(/datum/plant_feature/fruit/tobacco)

/obj/item/plant_seeds/preset/twobacco
	name = "nasiona: dwutoń (gruz)"
	name_override = "dwutoń"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-twobacco"
	plant_features = list(/datum/plant_feature/roots/debris, /datum/plant_feature/body/bush_vine/cannabis/tobacco, /datum/plant_feature/fruit/tobacco/twobacco)

/obj/item/food/grown/tobacco/twobacco
	seed = /obj/item/plant_seeds/preset/twobacco
	name = "liść dwutoniu"
	desc = "Liść dwutoniu. Pewnie da się go zapalić... chwila, czy on już się nie tli?"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "twobacco"
	tastes = list("tytoń" = 2)

/*
	Żelkowa fasolka (Goon: jelly bean) - soja i syrop kukurydziany w tacy
*/
/datum/plant_feature/fruit/soybean/jelly
	species_name = "faba gelatina"
	name = "żelkowa fasolka"
	colour_override = list("#ff5a5a", "#7fe05a", "#ffd84a", "#5ab4ff", "#ff8ad8")
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-jellybeans"
	fruit_product = /obj/item/food/grown/jellybeans
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/sugar = PLANT_REAGENT_LARGE)
	mutations = list(/datum/plant_feature/fruit/soybean)

/obj/item/plant_seeds/preset/jelly_bean
	name = "nasiona: żelkowa fasolka (glina)"
	name_override = "żelkowa fasolka"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-jellybeans"
	plant_features = list(/datum/plant_feature/roots/clay, /datum/plant_feature/body/bush_vine/soybean, /datum/plant_feature/fruit/soybean/jelly)

/obj/item/food/grown/jellybeans
	seed = /obj/item/plant_seeds/preset/jelly_bean
	name = "żelkowe fasolki"
	desc = "Kolorowe, cukrowe fasolki prosto z krzaka. Każda smakuje trochę inaczej."
	gender = PLURAL
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "jellybeans"
	foodtypes = SUGAR | JUNKFOOD
	tastes = list("żelki" = 1, "cukier" = 1)

/*
	Dynia korzenna (Goon: spice pumpkin) - dynia i kapsaicyna w tacy
*/
/datum/plant_feature/fruit/pumpkin/spice
	species_name = "cucurbita aromatica"
	name = "dynia korzenna"
	icon_state = "pumpkin-2"
	colour_override = "#e08a30"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-spicepumpkin"
	fruit_product = /obj/item/food/grown/spice_pumpkin
	fast_reagents = list(/datum/reagent/consumable/pumpkin_latte = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/pumpkin)

/obj/item/plant_seeds/preset/spice_pumpkin
	name = "nasiona: dynia korzenna (gruz)"
	name_override = "dynia korzenna"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-spicepumpkin"
	plant_features = list(/datum/plant_feature/roots/debris, /datum/plant_feature/body/tuber, /datum/plant_feature/fruit/pumpkin/spice)

/obj/item/food/grown/spice_pumpkin
	seed = /obj/item/plant_seeds/preset/spice_pumpkin
	name = "dynia korzenna"
	desc = "Pachnie jesienią!"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "spicepumpkin"
	bite_consumption_mod = 2
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/pumpkin_latte
	tastes = list("dynia" = 1, "przyprawy" = 1)
