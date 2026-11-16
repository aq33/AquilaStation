/*
	AQUILA - rośliny przeniesione z tgstation do naszej botaniki (cechy owocu)
	Każda roślina: cecha owocu, preset nasion, plon. Owoc na krzaku to przekolorowany kształt z features/fruit.dmi,
	plon i torebka nasion ze sprite'ów tg (aquila/icons/obj/hydroponics/ported_tg_*.dmi, CC-BY-SA 3.0).
*/

/*
	Orzeszki ziemne (tg: peanut)
*/
/datum/plant_feature/fruit/peanut
	species_name = "arachis hypogaea"
	name = "orzeszki ziemne"
	icon_state = "pod"
	colour_override = "#c49a5c"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	seed_icon_state = "seed-peanut"
	fruit_product = /obj/item/food/grown/peanut
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/peanut
	name = "nasiona: orzeszki ziemne (ziemia)"
	name_override = "orzeszki ziemne"
	icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	icon_state = "seed-peanut"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine, /datum/plant_feature/fruit/peanut)

/obj/item/food/grown/peanut
	seed = /obj/item/plant_seeds/preset/peanut
	name = "orzeszki ziemne"
	desc = "Smaczna para orzeszków ukryta w twardej łupinie."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "peanut"
	foodtypes = VEGETABLES
	tastes = list("orzeszki ziemne" = 1)
	grind_results = list(/datum/reagent/consumable/peanut_butter = 0)

/datum/reagent/consumable/peanut_butter
	name = "Masło orzechowe"
	description = "Gęsta, kremowa pasta z mielonych orzeszków ziemnych."
	taste_description = "orzeszki ziemne"
	color = "#D9A066"
	nutriment_factor = 15 * REAGENTS_METABOLISM
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN

/*
	Aloes (tg: aloe)
*/
/datum/plant_feature/fruit/aloe
	species_name = "aloe spatii"
	name = "aloes"
	icon_state = "tabacco_2"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	seed_icon_state = "seed-aloe"
	fruit_product = /obj/item/food/grown/aloe
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/aloe
	name = "nasiona: aloes (piasek)"
	name_override = "aloes"
	icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	icon_state = "seed-aloe"
	plant_features = list(/datum/plant_feature/roots/sand, /datum/plant_feature/body/tuber, /datum/plant_feature/fruit/aloe)

/obj/item/food/grown/aloe
	seed = /obj/item/plant_seeds/preset/aloe
	name = "aloes"
	desc = "Ścięte liście aloesu."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "aloe"
	bite_consumption_mod = 3
	foodtypes = VEGETABLES
	tastes = list("aloes" = 1)
	juice_typepath = /datum/reagent/consumable/aloejuice
	distill_reagent = /datum/reagent/consumable/ethanol/tequila

/datum/reagent/consumable/aloejuice
	name = "Sok z aloesu"
	description = "Zdrowy i orzeźwiający sok."
	color = "#b3c5a7"
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "warzywa"
	glass_icon_state = "glass_green"
	glass_name = "szklanka soku z aloesu"
	glass_desc = "Zdrowy i orzeźwiający sok z aloesu."
	hydration_factor = 12 * REAGENTS_METABOLISM

/datum/reagent/consumable/aloejuice/on_mob_life(mob/living/carbon/M)
	if(M.getToxLoss() && prob(16))
		M.adjustToxLoss(-0.5 * REM, 0)
		. = 1
	..()

/*
	Groch (tg: peas), śmiejący się groch (laughin' peas), groch pokoju (world peas)
*/
/datum/plant_feature/fruit/peas
	species_name = "pisum vulgaris"
	name = "groch"
	icon_state = "pod"
	icon_uneven = TRUE
	colour_override = "#8fd06b"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	seed_icon_state = "seed-peas"
	fruit_product = /obj/item/food/grown/peas
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin/large)
	fast_reagents = list(/datum/reagent/water = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/peas/laugh = 5)

/obj/item/plant_seeds/preset/peas
	name = "nasiona: groch (ziemia)"
	name_override = "groch"
	icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	icon_state = "seed-peas"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine, /datum/plant_feature/fruit/peas)

/obj/item/food/grown/peas
	seed = /obj/item/plant_seeds/preset/peas
	name = "strąk grochu"
	desc = "Wreszcie... groch."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "peas"
	foodtypes = VEGETABLES
	tastes = list("groch" = 1, "kredowa słoność" = 1)
	wine_power = 50
	wine_flavor = "niepokojąco sfermentowany groch"

/datum/plant_feature/fruit/peas/laugh
	species_name = "pisum ridens"
	name = "śmiejący się groch"
	colour_override = "#f0a0c8"
	seed_icon_state = "seed-laughpeas"
	fruit_product = /obj/item/food/grown/laugh
	plant_traits = list(/datum/plant_trait/fruit/biolight/purple, /datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/laughter = PLANT_REAGENT_SMALL, /datum/reagent/consumable/sugar = PLANT_REAGENT_SMALL)
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	mutations = list(/datum/plant_feature/fruit/peas/peace = 10)

/obj/item/food/grown/laugh
	name = "strąk śmiejącego się grochu"
	desc = "Ridens Cicer, gwarantowana poprawa nastroju po zjedzeniu!"
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "laughpeas"
	foodtypes = VEGETABLES
	tastes = list("skaczący królik" = 1)
	juice_typepath = /datum/reagent/consumable/laughsyrup
	wine_power = 90
	wine_flavor = "wektorowy królik tańczący na języku"

/datum/reagent/consumable/laughsyrup
	name = "Syrop śmiechu"
	description = "Sok wyciśnięty ze śmiejącego się grochu. Musujący, a jego smak zmienia się zależnie od tego, z czym go połączysz!"
	color = "#803280"
	nutriment_factor = 5 * REAGENTS_METABOLISM
	taste_mult = 2
	taste_description = "musująca słodycz"
	chem_flags = CHEMICAL_RNG_BOTANY

/datum/plant_feature/fruit/peas/peace
	species_name = "pisum pax mundi"
	name = "groch pokoju"
	icon_state = "grapes"
	colour_override = "#5b8fd6"
	seed_icon_state = "seed-worldpeas"
	fruit_product = /obj/item/food/grown/peace
	plant_traits = list(/datum/plant_trait/fruit/biolight/blue, /datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/pax = PLANT_REAGENT_SMALL, /datum/reagent/drug/happiness = PLANT_REAGENT_SMALL)
	growth_time = PLANT_FRUIT_GROWTH_SLOW
	mutations = list(/datum/plant_feature/fruit/peas)

/obj/item/food/grown/peace
	name = "kiść grochu pokoju"
	desc = "Roślina wyhodowana dzięki żmudnej inżynierii genetycznej i wielu szczepieniom. Podobno przynosi spokój każdemu, kto ją zje. W środowisku agronaukowców zyskała przydomek „Pax Mundi”."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "worldpeas"
	bite_consumption_mod = 2
	foodtypes = VEGETABLES
	tastes = list("otępiający spokój" = 2, "ciepło" = 1)
	wine_power = 100
	wine_flavor = "otępiający spokój i ciepło"

/*
	Fasolka szparagowa (tg: green beans), skacząca fasolka (jumping bean)
*/
/datum/plant_feature/fruit/greenbean
	species_name = "phaseolus viridis"
	name = "fasolka szparagowa"
	icon_state = "pod"
	icon_uneven = TRUE
	colour_override = "#5fbf3a"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	seed_icon_state = "seed-greenbean"
	fruit_product = /obj/item/food/grown/greenbeans
	plant_traits = list(/datum/plant_trait/reagent/fruit/vitamin)
	fast_reagents = list(/datum/reagent/medicine/charcoal = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/greenbean/jump = 5)

/obj/item/plant_seeds/preset/greenbean
	name = "nasiona: fasolka szparagowa (ziemia)"
	name_override = "fasolka szparagowa"
	icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	icon_state = "seed-greenbean"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine, /datum/plant_feature/fruit/greenbean)

/obj/item/food/grown/greenbeans
	seed = /obj/item/plant_seeds/preset/greenbean
	name = "fasolka szparagowa"
	desc = "Prosta i zdrowa. Czego chcieć więcej?"
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "greenbean"
	foodtypes = FRUIT
	tastes = list("fasola" = 1)

/datum/plant_feature/fruit/greenbean/jump
	species_name = "phaseolus saltans"
	name = "skacząca fasolka"
	icon_state = "chili"
	colour_override = "#a8323a"
	seed_icon_state = "seed-jumpingbean"
	fruit_product = /obj/item/food/grown/jumpingbeans
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/ants = PLANT_REAGENT_SMALL)
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	mutations = list(/datum/plant_feature/fruit/greenbean)

/obj/item/food/grown/jumpingbeans
	name = "skacząca fasolka"
	desc = "Yyy, co sprawia, że tak się rusza?"
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "jumpingbean"
	foodtypes = FRUIT | BUGS
	tastes = list("robaki" = 1)

/*
	Bób maślany (tg: butterbean), mutacja soi
*/
/datum/plant_feature/fruit/soybean/butter
	species_name = "faba butyri"
	name = "bób maślany"
	colour_override = "#f2e8c4"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	seed_icon_state = "seed-butterbean"
	fruit_product = /obj/item/food/grown/butterbeans
	plant_traits = list(/datum/plant_trait/reagent/fruit/vitamin)
	fast_reagents = list(/datum/reagent/consumable/milk = PLANT_REAGENT_SMALL, /datum/reagent/consumable/cream = PLANT_REAGENT_SMALL)
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/soybean)

/obj/item/food/grown/butterbeans
	name = "bób maślany"
	desc = "Miękki, kremowy i mleczny... Prawie dałoby się go posmarować na grzance."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "butterbeans"
	foodtypes = VEGETABLES | DAIRY
	tastes = list("kremowe masło" = 1)

/obj/item/food/grown/butterbeans/attack_self(mob/living/user)
	user.visible_message(span_notice("[user] zgniata bób maślany na kostkę masła."), span_notice("Zgniatasz bób maślany na coś, co przypomina masło."))
	playsound(user, 'sound/effects/blobattack.ogg', 50, TRUE)
	var/obj/item/food/butter/butter = new(null)
	qdel(src)
	user.put_in_hands(butter)
	return TRUE

/*
	Róża (tg: rose), węglowa róża (carbon rose)
*/
/datum/plant_feature/fruit/flower/rose
	species_name = "rosa amoris"
	name = "róża"
	icon_state = "flower_1"
	colour_overlay = "flower_1_colour"
	colour_override = "#c8102e"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	seed_icon_state = "seed-rose"
	fruit_product = /obj/item/food/grown/rose
	plant_traits = list(/datum/plant_trait/fruit/prickles, /datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/oil = PLANT_REAGENT_MICRO)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/flower/rose/carbon = 3)

/obj/item/plant_seeds/preset/rose
	name = "nasiona: róża (ziemia)"
	name_override = "róża"
	icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	icon_state = "seed-rose"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine/flower, /datum/plant_feature/fruit/flower/rose)

/obj/item/food/grown/rose
	seed = /obj/item/plant_seeds/preset/rose
	name = "róża"
	desc = "Klasyczny fleur d'amour, kwiat miłości. Uważaj na kolce!"
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "rose"
	bite_consumption_mod = 2
	foodtypes = VEGETABLES | GROSS
	tastes = list("płatki róży" = 1)

/datum/plant_feature/fruit/flower/rose/carbon
	species_name = "rosa carbonis"
	name = "węglowa róża"
	colour_override = "#6b6b78"
	seed_icon_state = "seed-carbonrose"
	fruit_product = /obj/item/grown/carbon_rose
	plant_traits = list()
	fast_reagents = list(/datum/reagent/plastic_polymers = PLANT_REAGENT_SMALL, /datum/reagent/carbon = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/flower/rose)

/obj/item/grown/carbon_rose
	name = "węglowa róża"
	desc = "Zupełnie nowy fleur d'amour gris, kwiat miłości po modernizacji, bez ostrych kolców."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "carbonrose"
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 3

/*
	Ogórek (tg: cucumber)
*/
/datum/plant_feature/fruit/cucumber
	species_name = "cucumis sativus"
	name = "ogórek"
	icon_state = "eggplant-2"
	colour_override = "#4f9a3a"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	seed_icon_state = "seed-cucumber"
	fruit_product = /obj/item/food/grown/cucumber
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/cucumber
	name = "nasiona: ogórek (glina)"
	name_override = "ogórek"
	icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	icon_state = "seed-cucumber"
	plant_features = list(/datum/plant_feature/roots/clay, /datum/plant_feature/body/bush_vine, /datum/plant_feature/fruit/cucumber)

/obj/item/food/grown/cucumber
	seed = /obj/item/plant_seeds/preset/cucumber
	name = "ogórek"
	desc = "Podłużny, zielony i pryszczaty, podstawa każdej sałatki."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "cucumber"
	foodtypes = VEGETABLES
	tastes = list("ogórek" = 1)
	juice_typepath = /datum/reagent/consumable/cucumberjuice

/datum/reagent/consumable/cucumberjuice
	name = "Sok z ogórka"
	description = "Zwykły sok z ogórka, nic z krainy fantazji."
	color = "#B1D861"
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "lekki ogórek"
	glass_icon_state = "glass_green"
	glass_name = "szklanka soku z ogórka"
	glass_desc = "Szklanka zwykłego soku z ogórka."
	hydration_factor = 12 * REAGENTS_METABOLISM

/*
	Oliwka (tg: olive)
*/
/datum/plant_feature/fruit/olive
	species_name = "olea europaea"
	name = "oliwka"
	icon_state = "cherry"
	colour_override = "#9bb24a"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	seed_icon_state = "seed-olive"
	fruit_product = /obj/item/food/grown/olive
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/olive
	name = "nasiona: drzewo oliwne (piasek)"
	name_override = "drzewo oliwne"
	icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	icon_state = "seed-olive"
	plant_features = list(/datum/plant_feature/roots/sand, /datum/plant_feature/body/tree/mini, /datum/plant_feature/fruit/olive)

/obj/item/food/grown/olive
	seed = /obj/item/plant_seeds/preset/olive
	name = "oliwka"
	desc = "Mały, podłużny, słony owoc, bliski krewny mango. Po zmieleniu daje oliwę."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "olive"
	foodtypes = FRUIT
	tastes = list("oliwka" = 1)
	grind_results = list(/datum/reagent/consumable/nutriment/fat/oil/olive = 0)

/*
	Śliwka (tg: plum), śliwka ołowiana (plumb)
*/
/datum/plant_feature/fruit/plum
	species_name = "prunus domestica"
	name = "śliwka"
	icon_state = "apple-2"
	icon_uneven = TRUE
	colour_override = "#a3175a"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	seed_icon_state = "seed-plum"
	fruit_product = /obj/item/food/grown/plum
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	fast_reagents = list(/datum/reagent/impurity/rosenol = PLANT_REAGENT_MICRO)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/plum/plumb = 5)

/obj/item/plant_seeds/preset/plum
	name = "nasiona: śliwa (ziemia)"
	name_override = "śliwa"
	icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	icon_state = "seed-plum"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/tree/mini, /datum/plant_feature/fruit/plum)

/obj/item/food/grown/plum
	seed = /obj/item/plant_seeds/preset/plum
	name = "śliwka"
	desc = "Ulubiony owoc poetów."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "plum"
	foodtypes = FRUIT
	tastes = list("śliwka" = 1)
	juice_typepath = /datum/reagent/consumable/plumjuice

/datum/reagent/consumable/plumjuice
	name = "Sok śliwkowy"
	description = "Orzeźwiający, lekko kwaskowaty napój."
	color = "#b6062c"
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "śliwki"
	glass_icon_state = "glass_red"
	glass_name = "szklanka soku śliwkowego"
	glass_desc = "Szklanka orzeźwiającego soku ze śliwek."
	hydration_factor = 12 * REAGENTS_METABOLISM

/datum/plant_feature/fruit/plum/plumb
	species_name = "prunus plumbum"
	name = "śliwka ołowiana"
	colour_override = "#6a3f5a"
	seed_icon_state = "seed-plumb"
	fruit_product = /obj/item/food/grown/plumb
	fast_reagents = list(/datum/reagent/mercury/lead_acetate = PLANT_REAGENT_MICRO)
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	mutations = list(/datum/plant_feature/fruit/plum)

/obj/item/food/grown/plumb
	name = "śliwka ołowiana"
	desc = "Jest wyjątkowo ciężka."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "plumb"
	foodtypes = FRUIT
	tastes = list("śliwka" = 1, "metal" = 1)
	wine_power = 50

/*
	Papryka (tg: bell pepper)
*/
/datum/plant_feature/fruit/bell_pepper
	species_name = "capsicum annuum"
	name = "papryka"
	icon_state = "tomato-2"
	colour_override = "#d42a1a"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	seed_icon_state = "seed-bell-pepper"
	fruit_product = /obj/item/food/grown/bell_pepper
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin/large)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/obj/item/plant_seeds/preset/bell_pepper
	name = "nasiona: papryka (ziemia)"
	name_override = "papryka"
	icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	icon_state = "seed-bell-pepper"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine/chili, /datum/plant_feature/fruit/bell_pepper)

/obj/item/food/grown/bell_pepper
	seed = /obj/item/plant_seeds/preset/bell_pepper
	name = "papryka"
	desc = "Duża, łagodna papryka, która nadaje się do wielu rzeczy."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "bell_pepper"
	foodtypes = VEGETABLES
	tastes = list("papryka" = 1)

/*
	Pieprzokukurydza (tg: pepper-corn), mutacja kukurydzy
*/
/datum/plant_feature/fruit/corn/pepper
	species_name = "frumentum piperis"
	name = "pieprzokukurydza"
	icon_state = "corn-2"
	colour_override = "#5a5a40"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	seed_icon_state = "seed-peppercorn"
	fruit_product = /obj/item/food/grown/peppercorn
	fast_reagents = list(/datum/reagent/consumable/blackpepper = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/corn)

/obj/item/food/grown/peppercorn
	name = "kolba pieprzokukurydzy"
	desc = "Ten zakurzony potwór potrzebuje Boga..."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "peppercorn"
	trash_type = /obj/item/grown/corncob
	foodtypes = VEGETABLES
	tastes = list("pieprz" = 1, "kichanie" = 1)
	grind_results = list(/datum/reagent/consumable/blackpepper = 0)

/*
	Zioła (tg: herbs)
*/
/datum/plant_feature/fruit/herbs
	species_name = "herbae mixtae"
	name = "zioła"
	icon_state = "tea"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	seed_icon_state = "seed-herbs"
	fruit_product = /obj/item/food/grown/herbs
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/herbs
	name = "nasiona: zioła (ziemia)"
	name_override = "zioła"
	icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	icon_state = "seed-herbs"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine, /datum/plant_feature/fruit/herbs)

/obj/item/food/grown/herbs
	seed = /obj/item/plant_seeds/preset/herbs
	name = "pęczek ziół"
	desc = "Pęczek różnych ziół. Jakimś cudem zawsze udaje ci się wyłuskać to, czego potrzebujesz."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "herbs"
	foodtypes = VEGETABLES
	tastes = list("nieokreślone zioła" = 1)
	grind_results = list(/datum/reagent/consumable/nutriment = 0)
	juice_typepath = /datum/reagent/consumable/nutriment
	distill_reagent = /datum/reagent/consumable/ethanol/fernet

/*
	Dyptam (tg: fraxinella), mutacja pelargonii
*/
/datum/plant_feature/fruit/flower/fraxinella
	species_name = "dictamnus albus"
	name = "dyptam"
	icon_state = "flower_2"
	colour_overlay = "flower_2_colour"
	colour_override = "#f4a6d0"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	seed_icon_state = "seed-fraxinella"
	fruit_product = /obj/item/food/grown/fraxinella
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/oil = PLANT_REAGENT_SMALL)
	mutations = list(/datum/plant_feature/fruit/flower/geranium)

/obj/item/food/grown/fraxinella
	name = "dyptam"
	desc = "Piękny jasnoróżowy kwiat."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "fraxinella"
	foodtypes = VEGETABLES
	tastes = list("kwiaty" = 1)
	distill_reagent = /datum/reagent/ash

/*
	Orzech korta (tg: korta nut), słodki orzech korta (sweet korta nut)
*/
/datum/plant_feature/fruit/korta_nut
	species_name = "nux tiziranus"
	name = "orzech korta"
	icon_state = "potato-2"
	colour_override = "#7d4b32"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	seed_icon_state = "seed-korta"
	fruit_product = /obj/item/food/grown/korta_nut
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	mutations = list(/datum/plant_feature/fruit/korta_nut/sweet = 3)

/obj/item/plant_seeds/preset/korta_nut
	name = "nasiona: krzew korta (piasek)"
	name_override = "krzew korta"
	icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	icon_state = "seed-korta"
	plant_features = list(/datum/plant_feature/roots/sand, /datum/plant_feature/body/bush_vine/berry, /datum/plant_feature/fruit/korta_nut)

/obj/item/food/grown/korta_nut
	seed = /obj/item/plant_seeds/preset/korta_nut
	name = "orzech korta"
	desc = "Mały orzech o wielkim znaczeniu. Ma pieprzną łupinę, z której mieli się mąkę, i miękki, papkowaty środek, który po wyciśnięciu daje mleczny płyn. Można go też zjeść w całości jako przekąskę."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "korta_nut"
	foodtypes = VEGETABLES
	tastes = list("pieprzny żar" = 1)
	grind_results = list(/datum/reagent/consumable/flour = 0)
	juice_typepath = /datum/reagent/consumable/korta_milk

/datum/reagent/consumable/korta_milk
	name = "Mleko korta"
	description = "Mleczny płyn wyciśnięty ze środka orzecha korta."
	color = "#FFFFFF"
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "słodkie mleko"
	glass_icon_state = "glass_white"
	glass_name = "szklanka mleka korta"
	glass_desc = "Szklanka mlecznego płynu z orzechów korta."
	hydration_factor = 12 * REAGENTS_METABOLISM

/datum/plant_feature/fruit/korta_nut/sweet
	species_name = "nux tiziranus dulcis"
	name = "słodki orzech korta"
	colour_override = "#a8743a"
	seed_icon_state = "seed-sweetkorta"
	fruit_product = /obj/item/food/grown/korta_nut/sweet
	fast_reagents = list(/datum/reagent/consumable/korta_nectar = PLANT_REAGENT_SMALL)
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	mutations = list(/datum/plant_feature/fruit/korta_nut)

/obj/item/food/grown/korta_nut/sweet
	seed = null
	name = "słodki orzech korta"
	desc = "Słodki przysmak uwielbiany przez jaszczury."
	tastes = list("pieprzna słodycz" = 1)
	juice_typepath = /datum/reagent/consumable/korta_nectar

/datum/reagent/consumable/korta_nectar
	name = "Nektar korta"
	description = "Słodki, cukrowy syrop ze zmiażdżonych słodkich orzechów korta."
	color = "#d3a308"
	nutriment_factor = 5 * REAGENTS_METABOLISM
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "pieprzna słodycz"

/*
	Töchtaüse (tg: töchtaüse berries)
*/
/datum/plant_feature/fruit/toechtauese
	species_name = "bacca mothica"
	name = "töchtaüse"
	icon_state = "berry"
	colour_override = "#c0502a"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	seed_icon_state = "seed-toechtauese"
	fruit_product = /obj/item/food/grown/toechtauese
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/toxin/itching_powder = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/toechtauese
	name = "nasiona: krzew töchtaüse (glina)"
	name_override = "krzew töchtaüse"
	icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	icon_state = "seed-toechtauese"
	plant_features = list(/datum/plant_feature/roots/clay, /datum/plant_feature/body/bush_vine/berry, /datum/plant_feature/fruit/toechtauese)

/obj/item/food/grown/toechtauese
	seed = /obj/item/plant_seeds/preset/toechtauese
	name = "jagody töchtaüse"
	desc = "Gałązka z jagodami töchtaüse. Ulubiony przysmak Floty Ćm, ale nie w tej postaci."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "toechtauese_branch"
	foodtypes = FRUIT
	tastes = list("ognisty, swędzący ból" = 1)
	juice_typepath = /datum/reagent/consumable/toechtauese_juice
	distill_reagent = /datum/reagent/toxin/itching_powder

/datum/reagent/consumable/toechtauese_juice
	name = "Sok z töchtaüse"
	description = "Nieprzyjemny sok z jagód töchtaüse. Lepiej zrobić z niego syrop, chyba że lubisz ból."
	color = "#554862"
	nutriment_factor = 0
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "ognisty, swędzący ból"
	glass_icon_state = "glass_brown"
	glass_name = "szklanka soku z töchtaüse"
	glass_desc = "Szklanka nieprzyjemnego soku z jagód töchtaüse."

/*
	Owoc latarniowy (tg: lanternfruit), w automacie po zhakowaniu
*/
/datum/plant_feature/fruit/lanternfruit
	species_name = "lucerna fructus"
	name = "owoc latarniowy"
	icon_state = "citrus"
	colour_override = "#f2d65a"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	seed_icon_state = "seed-lanternfruit"
	fruit_product = /obj/item/food/grown/lanternfruit
	plant_traits = list(/datum/plant_trait/fruit/biolight/yellow, /datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/sulfur = PLANT_REAGENT_SMALL, /datum/reagent/consumable/sugar = PLANT_REAGENT_SMALL, /datum/reagent/consumable/liquidelectricity = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/lanternfruit
	name = "nasiona: owoc latarniowy (gruz)"
	name_override = "owoc latarniowy"
	icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	icon_state = "seed-lanternfruit"
	plant_features = list(/datum/plant_feature/roots/debris, /datum/plant_feature/body/tree/mini, /datum/plant_feature/fruit/lanternfruit)

/obj/item/food/grown/lanternfruit
	seed = /obj/item/plant_seeds/preset/lanternfruit
	name = "owoc latarniowy"
	desc = "Delikatnie świecący owoc z ogonkiem w kształcie uchwytu, przysmak eteryków!"
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "lanternfruit"
	foodtypes = FRUIT
	tastes = list("szum telewizora" = 1, "kwaśna gruszka" = 1, "grejpfrut" = 1)

/*
	Kronkus (tg: kronkus), w automacie po zhakowaniu
*/
/datum/plant_feature/fruit/kronkus
	species_name = "vitis kronkus"
	name = "kronkus"
	icon_state = "ambrosia_2"
	colour_override = "#37946e"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	seed_icon_state = "seed-kronkus"
	fruit_product = /obj/item/food/grown/kronkus
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/obj/item/plant_seeds/preset/kronkus
	name = "nasiona: kronkus (gruz)"
	name_override = "kronkus"
	desc = "Paczka wysoce nielegalnych nasion kronkusa. Za ich posiadanie w 7 sektorach grozi kara śmierci."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	icon_state = "seed-kronkus"
	plant_features = list(/datum/plant_feature/roots/debris, /datum/plant_feature/body/bush_vine/grape, /datum/plant_feature/fruit/kronkus)

/obj/item/food/grown/kronkus
	seed = /obj/item/plant_seeds/preset/kronkus
	name = "pęd kronkusa"
	desc = "Kawałek dojrzałego pędu kronkusa. Wydziela ostry, szkodliwy zapach."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "kronkus"
	filling_color = "#37946e"
	foodtypes = VEGETABLES | TOXIC
	tastes = list("gorzka łodyga" = 1)

/*
	Purchawka cuchnąca (tg: odious puffball), w automacie po zhakowaniu
*/
/datum/plant_feature/fruit/mushroom/puffball
	species_name = "lycoperdon faetidus"
	name = "purchawka cuchnąca"
	icon_state = "ball"
	colour_overlay = "ball_colour"
	colour_override = "#7d5a8c"
	genetic_budget = 2
	seed_icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	seed_icon_state = "seed-odiouspuffball"
	fruit_product = /obj/item/food/grown/mushroom/odious_puffball
	plant_traits = list(/datum/plant_trait/fruit/gaseous, /datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/toxin/spore = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/puffball
	name = "zarodniki: purchawka cuchnąca (dowolne podłoże)"
	name_override = "purchawka cuchnąca"
	desc = "Te zarodniki cuchną. Obrzydliwe."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	icon_state = "seed-odiouspuffball"
	plant_features = list(/datum/plant_feature/roots/hyphae, /datum/plant_feature/body/mushroom, /datum/plant_feature/fruit/mushroom/puffball)

/obj/item/food/grown/mushroom/odious_puffball
	seed = /obj/item/plant_seeds/preset/puffball
	name = "purchawka cuchnąca"
	desc = "<I>Lycoperdon Faetidus</I>: ta purchawka uchodzi za wielkie utrapienie nie tylko przez silnie drażniące zarodniki, ale też przez spory rozmiar i odpychający wygląd."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "odious_puffball"
	tastes = list("zgniły czosnek" = 2, "grzyby" = 1, "zarodniki" = 1)
	wine_power = 50

/*
	Trzcina solna (tg: saltcane), mutacja trzciny cukrowej
*/
/datum/plant_feature/fruit/sugarcane/salt
	species_name = "salsa ferula"
	name = "trzcina solna"
	colour_override = "#d8e0c0"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	seed_icon_state = "seed-saltcane"
	fruit_product = /obj/item/food/grown/saltcane
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/sodiumchloride = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/sugarcane)

/obj/item/food/grown/saltcane
	name = "trzcina solna"
	desc = "Okropnie słona. Zmora ślimaków, skarb koni."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "saltcane"
	bite_consumption_mod = 2
	foodtypes = VEGETABLES | GROSS
	tastes = list("sól" = 1)

/*
	Beczkowy melon (tg: barrel melon), mutacja arbuza
*/
/datum/plant_feature/fruit/watermelon/barrel
	species_name = "pepo dolium"
	name = "beczkowy melon"
	icon_state = "watermelon-2"
	colour_override = "#8a5a2a"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	seed_icon_state = "seed-barrelmelon"
	fruit_product = /obj/item/food/grown/barrelmelon
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/ethanol/ale = PLANT_REAGENT_MEDIUM)
	mutations = list(/datum/plant_feature/fruit/watermelon)
	reagent_mutations = null

/obj/item/food/grown/barrelmelon
	name = "beczkowy melon"
	desc = "Składniki odżywcze w tym melonie sprasowały się i przefermentowały w mocny alkohol."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "barrelmelon"
	bite_consumption_mod = 2
	w_class = WEIGHT_CLASS_NORMAL
	foodtypes = FRUIT
	tastes = list("piwo" = 1, "melon" = 1)
	distill_reagent = /datum/reagent/medicine/antihol

/*
	Smoczy burak (tg: drake beet), mutacja czerwonego buraka
*/
/datum/plant_feature/fruit/whitebeet/drake
	species_name = "beta draconis"
	name = "smoczy burak"
	colour_override = "#5a3f8a"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	seed_icon_state = "seed-drakebeet"
	fruit_product = /obj/item/food/grown/drake_beet
	fast_reagents = list(/datum/reagent/consumable/sugar = PLANT_REAGENT_LARGE, /datum/reagent/consumable/capsaicin = PLANT_REAGENT_SMALL)
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	mutations = list(/datum/plant_feature/fruit/whitebeet/red)

/obj/item/food/grown/drake_beet
	name = "smoczy burak"
	desc = "Mimo groźnego wyglądu smocze buraki są bogate w cukry wyciągnięte z gleby. I odrobinę pikantne."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "drakebeet"
	bite_consumption_mod = 2
	foodtypes = VEGETABLES
	tastes = list("słodki burak" = 1, "ostrość" = 1)
	wine_power = 66

/*
	Korzeń Cahna (tg: cahn'root), mutacja marchwi
*/
/datum/plant_feature/fruit/carrot/cahnroot
	species_name = "carota cahnmang"
	name = "korzeń Cahna"
	icon_state = "parsnip"
	colour_override = "#8a5a30"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	seed_icon_state = "seed-cahnroot"
	fruit_product = /obj/item/food/grown/cahnroot
	fast_reagents = list(/datum/reagent/consumable/sugar = PLANT_REAGENT_MICRO)
	mutations = list(/datum/plant_feature/fruit/carrot)

/obj/item/food/grown/cahnroot
	name = "korzeń Cahna"
	desc = "Mocno zmieniona ziemska marchew, wyhodowana z myślą o przetrwaniu w najuboższych warunkach przez przedsiębiorczego naukowca z Floty Ćm, Cahn'Manga."
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "cahnroot"
	foodtypes = VEGETABLES
	tastes = list("słodka ziemia" = 1)

/*
	Antykonopie (tg: anti weed), mutacja konopi
*/
/datum/plant_feature/fruit/cannabis/anti
	species_name = "anti folium"
	name = "antykonopie"
	icon_state = "cannabis-2"
	colour_override = "#d77fe0"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_tg_seeds.dmi'
	seed_icon_state = "seed-antiweed"
	fruit_product = /obj/item/food/grown/cannabis/anti
	plant_traits = list(/datum/plant_trait/fruit/biolight/dark)
	fast_reagents = list(/datum/reagent/medicine/antihol = PLANT_REAGENT_MEDIUM, /datum/reagent/medicine/synaphydramine = PLANT_REAGENT_SMALL)
	trait_power = 1.5
	mutations = list(/datum/plant_feature/fruit/cannabis)

/obj/item/food/grown/cannabis/anti
	seed = null
	name = "liść antykonopi"
	desc = "Patrząc na to, czujesz się zupełnie normalnie. Co jest, do cholery?"
	icon = 'aquila/icons/obj/hydroponics/ported_tg_harvest.dmi'
	icon_state = "antiweed"

/obj/item/food/grown/cannabis/anti/Initialize(mapload, skip_genes)
	. = ..()
	if(prob(0.05))
		name = "zły liść konopi"

/*
	Mutacje z roślin, które już mamy (dopiski bez nadpisywania ich list)
*/
/datum/plant_mutation_set/tg
	mutations = list(
		/datum/plant_feature/fruit/soybean = list(/datum/plant_feature/fruit/soybean/butter = 5),
		/datum/plant_feature/fruit/corn = list(/datum/plant_feature/fruit/corn/pepper = 3),
		/datum/plant_feature/fruit/flower/geranium = list(/datum/plant_feature/fruit/flower/fraxinella = 3),
		/datum/plant_feature/fruit/sugarcane = list(/datum/plant_feature/fruit/sugarcane/salt = 3),
		/datum/plant_feature/fruit/watermelon = list(/datum/plant_feature/fruit/watermelon/barrel = 3),
		/datum/plant_feature/fruit/whitebeet/red = list(/datum/plant_feature/fruit/whitebeet/drake = 5),
		/datum/plant_feature/fruit/carrot = list(/datum/plant_feature/fruit/carrot/cahnroot = 3),
		/datum/plant_feature/fruit/cannabis = list(/datum/plant_feature/fruit/cannabis/anti = 10),
	)

/obj/machinery/vending/hydroseeds/Initialize(mapload)
	products[/obj/item/plant_seeds/preset/peanut] = 3
	products[/obj/item/plant_seeds/preset/aloe] = 3
	products[/obj/item/plant_seeds/preset/peas] = 3
	products[/obj/item/plant_seeds/preset/greenbean] = 3
	products[/obj/item/plant_seeds/preset/rose] = 3
	products[/obj/item/plant_seeds/preset/cucumber] = 3
	products[/obj/item/plant_seeds/preset/olive] = 3
	products[/obj/item/plant_seeds/preset/plum] = 3
	products[/obj/item/plant_seeds/preset/bell_pepper] = 3
	products[/obj/item/plant_seeds/preset/herbs] = 3
	products[/obj/item/plant_seeds/preset/korta_nut] = 3
	products[/obj/item/plant_seeds/preset/toechtauese] = 3
	contraband[/obj/item/plant_seeds/preset/lanternfruit] = 2
	contraband[/obj/item/plant_seeds/preset/kronkus] = 2
	contraband[/obj/item/plant_seeds/preset/puffball] = 2
	return ..()
