/*
	AQUILA - kwiaty i zioła lecznicze z Goona (partia „inne”). Kwiaty da się nosić na głowie (sprite'y Goona).
	Odczynniki ziół Goona zamienione na nasze leki o tym samym działaniu: kwas salicylowy, jodek potasu, efedryna,
	sulfadiazyna srebra i węgiel aktywny są u nas pod tymi samymi nazwami; ipekakuana (Goon: ipecac) daje rzygium,
	tojad (Goon: wolfsbane) zwykłą toksynę.
*/

/// Wspólny rodzic kwiatów z tej partii: bez mutacji i leków niezapominajki, nektar zostaje
/datum/plant_feature/fruit/flower/inne
	abstract_type = /datum/plant_feature/fruit/flower/inne
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	fast_reagents = list()
	mutations = list()

/// Plon-kwiat, który można włożyć za ucho
/obj/item/food/grown/inne_flower
	abstract_type = /obj/item/food/grown/inne_flower
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	worn_icon = 'aquila/icons/obj/hydroponics/ported_inne_worn.dmi'
	slot_flags = ITEM_SLOT_HEAD
	bite_consumption_mod = 3
	foodtypes = VEGETABLES | GROSS
	distill_reagent = /datum/reagent/consumable/ethanol/vermouth

/*
	Lawenda (Goon: lavender)
*/
/datum/plant_feature/fruit/flower/inne/lavender
	species_name = "lavandula angustifolia"
	name = "lawenda"
	icon_state = "flower_1"
	colour_override = "#a77fd6"
	seed_icon_state = "seed-lavender"
	fruit_product = /obj/item/food/grown/inne_flower/lavender
	fast_reagents = list(/datum/reagent/medicine/psicodine = PLANT_REAGENT_MICRO)

/obj/item/plant_seeds/preset/lavender
	name = "nasiona: lawenda (piasek)"
	name_override = "lawenda"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-lavender"
	plant_features = list(/datum/plant_feature/roots/sand, /datum/plant_feature/body/corn_stalk/flower, /datum/plant_feature/fruit/flower/inne/lavender)

/obj/item/food/grown/inne_flower/lavender
	seed = /obj/item/plant_seeds/preset/lavender
	name = "lawenda"
	desc = "Lawendę zwykle dodaje się do potraw albo robi się z niej olejek, ale gałązka za uchem też wygląda ładnie."
	icon_state = "lavender"
	tastes = list("lawenda" = 1)

/*
	Gardenia (Goon: gardenia)
*/
/datum/plant_feature/fruit/flower/inne/gardenia
	species_name = "gardenia jasminoides"
	name = "gardenia"
	icon_state = "flower_2"
	colour_override = "#fffbe8"
	seed_icon_state = "seed-gardenia"
	fruit_product = /obj/item/food/grown/inne_flower/gardenia

/obj/item/plant_seeds/preset/gardenia
	name = "nasiona: gardenia (ziemia)"
	name_override = "gardenia"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-gardenia"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine/flower, /datum/plant_feature/fruit/flower/inne/gardenia)

/obj/item/food/grown/inne_flower/gardenia
	seed = /obj/item/plant_seeds/preset/gardenia
	name = "gardenia"
	desc = "Delikatny biały kwiat z ziemskiego krzewu gardenii, przycięty do noszenia. Pachnie mocno i słodko."
	icon_state = "gardenia"
	tastes = list("kwiaty" = 1)

/*
	Strelicja (Goon: bird of paradise)
*/
/datum/plant_feature/fruit/flower/inne/bird_of_paradise
	species_name = "strelitzia reginae"
	name = "strelicja"
	icon_state = "flower_3"
	colour_overlay = "flower_3_colour"
	colour_override = "#ff8c1a"
	seed_icon_state = "seed-birdofparadise"
	fruit_product = /obj/item/food/grown/inne_flower/bird_of_paradise
	growth_time = PLANT_FRUIT_GROWTH_SLOW

/obj/item/plant_seeds/preset/bird_of_paradise
	name = "nasiona: strelicja (piasek)"
	name_override = "strelicja"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-birdofparadise"
	plant_features = list(/datum/plant_feature/roots/sand, /datum/plant_feature/body/corn_stalk/flower, /datum/plant_feature/fruit/flower/inne/bird_of_paradise)

/obj/item/food/grown/inne_flower/bird_of_paradise
	seed = /obj/item/plant_seeds/preset/bird_of_paradise
	name = "strelicja"
	desc = "Strelicja, zwana też rajskim ptakiem, wygląda jak prawdziwy ptak o tej nazwie. Na głowie oba prezentują się świetnie."
	icon_state = "birdofparadise"
	tastes = list("kwiaty" = 1)

/*
	Raflezja (Goon: rafflesia) - cuchnie rozkładem, także gdy jeszcze wisi na roślinie
*/
/datum/plant_feature/fruit/flower/inne/rafflesia
	species_name = "rafflesia arnoldii"
	name = "raflezja"
	icon_state = "flower_2"
	colour_overlay = "flower_2_colour"
	colour_override = "#b02020"
	seed_icon_state = "seed-rafflesia"
	fruit_product = /obj/item/food/grown/inne_flower/rafflesia
	fruit_size = PLANT_FRUIT_SIZE_LARGE
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/obj/item/plant_seeds/preset/rafflesia
	name = "nasiona: raflezja (gruz)"
	name_override = "raflezja"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-rafflesia"
	plant_features = list(/datum/plant_feature/roots/debris, /datum/plant_feature/body/tuber, /datum/plant_feature/fruit/flower/inne/rafflesia)

/obj/item/food/grown/inne_flower/rafflesia
	seed = /obj/item/plant_seeds/preset/rafflesia
	name = "raflezja"
	desc = "Zwana kwiatem trupim przez okropny zapach. Idealna, żeby zamaskować smród własnej głowy."
	icon_state = "rafflesia"
	foodtypes = VEGETABLES | GROSS | TOXIC
	tastes = list("zgnilizna" = 1)

/obj/item/food/grown/inne_flower/rafflesia/Initialize(mapload, skip_genes)
	. = ..()
	AddElement(/datum/element/pollution_emitter, /datum/pollutant/decaying_waste, 10)

/*
	Tojad (Goon: aconite) - trujący kwiat, tylko w zhakowanym automacie
*/
/datum/plant_feature/fruit/flower/inne/aconite
	species_name = "aconitum napellus"
	name = "tojad"
	icon_state = "flower_1"
	colour_override = "#7048d8"
	seed_icon_state = "seed-aconite"
	fruit_product = /obj/item/food/grown/aconite
	plant_traits = list()
	fast_reagents = list(/datum/reagent/toxin = PLANT_REAGENT_LARGE)
	total_volume = PLANT_FRUIT_VOLUME_SMALL

/obj/item/plant_seeds/preset/aconite
	name = "nasiona: tojad (ziemia)"
	name_override = "tojad"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-aconite"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/corn_stalk/flower, /datum/plant_feature/fruit/flower/inne/aconite)

/obj/item/food/grown/aconite
	seed = /obj/item/plant_seeds/preset/aconite
	name = "tojad"
	desc = "Profesor zapytał kiedyś: „Jaka jest różnica, panie Potter, między mordownikiem a wilczym zielem?”. „Tojad”, odpowiedziała Hermiona. I wszystko było dobrze."
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	icon_state = "aconite"
	foodtypes = VEGETABLES | TOXIC
	tastes = list("gorycz" = 1)

/*
	Hortensja (Goon: hydrangea) - kolor kwiatów zależy od podłoża, jak odczyn gleby u prawdziwej hortensji:
	glina niebieska, piasek różowa, ziemia fioletowa, inne podłoże biała
*/
/datum/plant_feature/fruit/flower/inne/hydrangea
	species_name = "hydrangea macrophylla"
	name = "hortensja"
	icon_state = "flower_2"
	colour_override = "#f4f0ff"
	seed_icon_state = "seed-hydrangea"
	fruit_product = /obj/item/food/grown/inne_flower/hydrangea

/// Kolor kwiatów według podłoża tacy, w której rośnie roślina
/datum/plant_feature/fruit/flower/inne/hydrangea/proc/bloom_colour()
	var/datum/component/planter/planter = parent?.plant_item?.loc?.GetComponent(/datum/component/planter)
	var/datum/plant_subtrate/substrate = planter?.substrate
	if(istype(substrate, /datum/plant_subtrate/clay))
		return "blue"
	if(istype(substrate, /datum/plant_subtrate/sand))
		return "pink"
	if(istype(substrate, /datum/plant_subtrate/dirt))
		return "purple"
	return "white"

/datum/plant_feature/fruit/flower/inne/hydrangea/setup_fruit(datum/source, harvest_amount, list/_visual_fruits, _skip_growth = FALSE)
	. = ..()
	var/colour = GLOB.hydrangea_colours[bloom_colour()]
	for(var/timer in visual_fruits)
		var/obj/effect/fruit_effect = visual_fruits[timer]
		fruit_effect?.color = colour

/datum/plant_feature/fruit/flower/inne/hydrangea/build_fruit()
	var/obj/item/food/grown/inne_flower/hydrangea/flower = ..()
	if(istype(flower))
		flower.set_bloom(bloom_colour())
	return flower

GLOBAL_LIST_INIT(hydrangea_colours, list("white" = "#f4f0ff", "pink" = "#ff9ad8", "blue" = "#7ab0ff", "purple" = "#b88aff"))

/obj/item/plant_seeds/preset/hydrangea
	name = "nasiona: hortensja (dowolne podłoże)"
	name_override = "hortensja"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-hydrangea"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/bush_vine/flower, /datum/plant_feature/fruit/flower/inne/hydrangea)

/obj/item/food/grown/inne_flower/hydrangea
	seed = /obj/item/plant_seeds/preset/hydrangea
	name = "hortensja"
	desc = "Hortensje są naturalnym wskaźnikiem odczynu gleby: na kwaśnej kwitną na niebiesko, na zasadowej na różowo. Ta jest ładnie przycięta do noszenia."
	icon_state = "hydrangea-white"
	tastes = list("kwiaty" = 1)
	/// Kolor kwiatów: white, pink, blue albo purple
	var/bloom = "white"

/obj/item/food/grown/inne_flower/hydrangea/proc/set_bloom(new_bloom)
	if(!GLOB.hydrangea_colours[new_bloom])
		return
	bloom = new_bloom
	icon_state = "hydrangea-[bloom]"
	switch(bloom)
		if("pink")
			name = "różowa hortensja"
		if("blue")
			name = "niebieska hortensja"
		if("purple")
			name = "fioletowa hortensja"
		else
			name = "biała hortensja"
	update_appearance()

/*
	Zioła lecznicze Goona
*/
/// Wspólny rodzic ziół: suche liście, kora i korzenie bez wartości odżywczych
/obj/item/food/grown/inne_herb
	abstract_type = /obj/item/food/grown/inne_herb
	icon = 'aquila/icons/obj/hydroponics/ported_inne_harvest.dmi'
	foodtypes = VEGETABLES | GROSS
	can_distill = FALSE

/// Asomna (Goon: efedryna, u nas też efedryna)
/datum/plant_feature/fruit/asomna
	species_name = "asomna excitans"
	name = "asomna"
	icon_state = "tea"
	icon_uneven = TRUE
	colour_override = "#b8d8f0"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-asomna"
	fruit_product = /obj/item/food/grown/inne_herb/asomna
	fast_reagents = list(/datum/reagent/medicine/ephedrine = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/asomna
	name = "nasiona: asomna (ziemia)"
	name_override = "asomna"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-asomna"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine, /datum/plant_feature/fruit/asomna)

/obj/item/food/grown/inne_herb/asomna
	seed = /obj/item/plant_seeds/preset/asomna
	name = "kora asomny"
	desc = "Uchodzi za przysmak w herbacie, a do tego działa pobudzająco."
	icon_state = "asomna"
	tastes = list("kora" = 1)

/// Komol (Goon: commol, sulfadiazyna srebra)
/datum/plant_feature/fruit/commol
	species_name = "commolum ustionis"
	name = "komol"
	icon_state = "tea_2"
	icon_uneven = TRUE
	colour_override = "#f0b060"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-commol"
	fruit_product = /obj/item/food/grown/inne_herb/commol
	fast_reagents = list(/datum/reagent/medicine/silver_sulfadiazine = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/commol
	name = "nasiona: komol (glina)"
	name_override = "komol"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-commol"
	plant_features = list(/datum/plant_feature/roots/clay, /datum/plant_feature/body/bush_vine, /datum/plant_feature/fruit/commol)

/obj/item/food/grown/inne_herb/commol
	seed = /obj/item/plant_seeds/preset/commol
	name = "korzeń komolu"
	desc = "Twardy, woskowaty korzeń. Ceniony składnik maści na oparzenia."
	icon_state = "commol"
	tastes = list("wosk" = 1)

/// Kontuzyna (Goon: contusine, kwas salicylowy)
/datum/plant_feature/fruit/contusine
	species_name = "contusina vulneraria"
	name = "kontuzyna"
	icon_state = "tea"
	icon_uneven = TRUE
	colour_override = "#e070a0"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-contusine"
	fruit_product = /obj/item/food/grown/inne_herb/contusine
	fast_reagents = list(/datum/reagent/medicine/sal_acid = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/contusine
	name = "nasiona: kontuzyna (ziemia)"
	name_override = "kontuzyna"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-contusine"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine, /datum/plant_feature/fruit/contusine)

/obj/item/food/grown/inne_herb/contusine
	seed = /obj/item/plant_seeds/preset/contusine
	name = "liście kontuzyny"
	desc = "Suche, gorzkie liście znane z tego, że pomagają goić rany."
	gender = PLURAL
	icon_state = "contusine"
	tastes = list("gorycz" = 1)

/// Nureus (Goon: nureous, jodek potasu)
/datum/plant_feature/fruit/nureous
	species_name = "nureum radiatum"
	name = "nureus"
	icon_state = "tea_2"
	icon_uneven = TRUE
	colour_override = "#80f0d0"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-nureous"
	fruit_product = /obj/item/food/grown/inne_herb/nureous
	fast_reagents = list(/datum/reagent/medicine/potass_iodide = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/nureous
	name = "nasiona: nureus (piasek)"
	name_override = "nureus"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-nureous"
	plant_features = list(/datum/plant_feature/roots/sand, /datum/plant_feature/body/bush_vine, /datum/plant_feature/fruit/nureous)

/obj/item/food/grown/inne_herb/nureous
	seed = /obj/item/plant_seeds/preset/nureous
	name = "liście nureusa"
	desc = "Łykowate liście, z których robi się leki na chorobę popromienną."
	gender = PLURAL
	icon_state = "nureous"
	tastes = list("liście" = 1)

/// Wenna (Goon: venne, węgiel aktywny)
/datum/plant_feature/fruit/venne
	species_name = "venna antitoxica"
	name = "wenna"
	icon_state = "tea"
	icon_uneven = TRUE
	colour_override = "#d8f060"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-venne"
	fruit_product = /obj/item/food/grown/inne_herb/venne
	fast_reagents = list(/datum/reagent/medicine/charcoal = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/venne
	name = "nasiona: wenna (gruz)"
	name_override = "wenna"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-venne"
	plant_features = list(/datum/plant_feature/roots/debris, /datum/plant_feature/body/bush_vine, /datum/plant_feature/fruit/venne)

/obj/item/food/grown/inne_herb/venne
	seed = /obj/item/plant_seeds/preset/venne
	name = "włókna wenny"
	desc = "Włókna z łodygi pnącza wenny. Smakują paskudnie, ale świetnie usuwają toksyny."
	gender = PLURAL
	icon_state = "venne"
	tastes = list("paskudztwo" = 1)

/// Ipekakuana (Goon: ipecacuanha, wymiotny ipecac; u nas rzygium)
/datum/plant_feature/fruit/ipecacuanha
	species_name = "carapichea ipecacuanha"
	name = "ipekakuana"
	icon_state = "tea_2"
	icon_uneven = TRUE
	colour_override = "#c8a078"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	seed_icon_state = "seed-ipecacuanha"
	fruit_product = /obj/item/food/grown/inne_herb/ipecacuanha
	fast_reagents = list(/datum/reagent/toxin/spewium = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/ipecacuanha
	name = "nasiona: ipekakuana (glina)"
	name_override = "ipekakuana"
	icon = 'aquila/icons/obj/hydroponics/ported_inne_seeds.dmi'
	icon_state = "seed-ipecacuanha"
	plant_features = list(/datum/plant_feature/roots/clay, /datum/plant_feature/body/bush_vine, /datum/plant_feature/fruit/ipecacuanha)

/obj/item/food/grown/inne_herb/ipecacuanha
	seed = /obj/item/plant_seeds/preset/ipecacuanha
	name = "korzeń ipekakuany"
	desc = "Gruby korzeń pokryty nienaturalnie grubą korą. Można z niego wyciągnąć silny środek wymiotny."
	icon_state = "ipecacuanha"
	tastes = list("wymiociny" = 1)
