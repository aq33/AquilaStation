/*
	AQUILA - rośliny obcych z ksenoarcheologii (Baystation12, /vg/station13, Skyrat/Bubberstation)
	Każda roślina: cecha owocu, preset nasion, plon. Owoc na krzaku to przekolorowany kształt z features/fruit.dmi.
	Plony i torebki: Skyrat/Bubberstation modular_skyrat/modules/xenoarch (amauri, gelthi, jurl'mah, surik, telriis,
	thaa'dra, vale, wapniak gazowy) i /vg/station13 (Dłoń S'randara, Łza Messy), CC-BY-SA 3.0.
	Odczynniki obcych ras zamienione na nasze najbliższe.
*/

/// Wszystkie nasiona obcych roślin (ksenoarcheologia, rośliny-artefakty, kapsuła ksenoflory). Sam typ jest abstrakcyjny.
/obj/item/plant_seeds/preset/alien
	name = "nasiona obcej rośliny"
	abstract_type = /obj/item/plant_seeds/preset/alien

/*
	Amauri
*/
/datum/plant_feature/fruit/amauri
	species_name = "amauri venenata"
	name = "amauri"
	icon_state = "orb"
	colour_override = "#4b3a8a"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	seed_icon_state = "seed-amauri"
	fruit_product = /obj/item/food/grown/amauri
	fast_reagents = list(/datum/reagent/toxin = PLANT_REAGENT_SMALL, /datum/reagent/toxin/venom = PLANT_REAGENT_SMALL, /datum/reagent/toxin/plasma = PLANT_REAGENT_MICRO)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/obj/item/plant_seeds/preset/alien/amauri
	name = "nasiona: amauri (glina)"
	name_override = "amauri"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-amauri"
	plant_features = list(/datum/plant_feature/roots/clay, /datum/plant_feature/body/bush_vine, /datum/plant_feature/fruit/amauri)

/obj/item/food/grown/amauri
	seed = /obj/item/plant_seeds/preset/alien/amauri
	name = "bulwa amauri"
	desc = "Trująca bulwa amauri. Lepiej tego nie jeść."
	icon = 'aquila/icons/obj/hydroponics/ported_obce_harvest.dmi'
	icon_state = "amauri"
	bite_consumption_mod = 0.5
	foodtypes = FRUIT | TOXIC
	tastes = list("trucizna" = 1)

/*
	Gelthi
*/
/datum/plant_feature/fruit/gelthi
	species_name = "gelthi dulcis"
	name = "gelthi"
	icon_state = "grapes"
	colour_override = "#f5c7a9"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	seed_icon_state = "seed-gelthi"
	fruit_product = /obj/item/food/grown/gelthi
	plant_traits = list(/datum/plant_trait/fruit/liquid_contents)
	fast_reagents = list(/datum/reagent/consumable/honey = PLANT_REAGENT_MEDIUM, /datum/reagent/consumable/sprinkles = PLANT_REAGENT_SMALL, /datum/reagent/consumable/astrotame = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/obj/item/plant_seeds/preset/alien/gelthi
	name = "nasiona: gelthi (ziemia)"
	name_override = "gelthi"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-gelthi"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine/berry, /datum/plant_feature/fruit/gelthi)

/obj/item/food/grown/gelthi
	seed = /obj/item/plant_seeds/preset/alien/gelthi
	name = "strąki gelthi"
	desc = "Kiść strąków gelthi. Każdy strąk kryje inny słodzik, a z całości da się wycisnąć surowy cukier."
	icon = 'aquila/icons/obj/hydroponics/ported_obce_harvest.dmi'
	icon_state = "gelthi"
	gender = PLURAL
	bite_consumption_mod = 0.5
	foodtypes = FRUIT | SUGAR
	tastes = list("przytłaczająca słodycz" = 1)
	juice_typepath = /datum/reagent/consumable/sugar

/*
	Jurl'mah
*/
/datum/plant_feature/fruit/jurlmah
	species_name = "jurlmah glacialis"
	name = "jurl'mah"
	icon_state = "pod"
	colour_override = "#5fd3e0"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	seed_icon_state = "seed-jurlmah"
	fruit_product = /obj/item/food/grown/jurlmah
	plant_traits = list(/datum/plant_trait/fruit/biolight/blue)
	fast_reagents = list(/datum/reagent/medicine/cryoxadone = PLANT_REAGENT_SMALL, /datum/reagent/consumable/frostoil = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_SLOW

/obj/item/plant_seeds/preset/alien/jurlmah
	name = "nasiona: jurl'mah (ziemia)"
	name_override = "jurl'mah"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-jurlmah"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/tree/mini, /datum/plant_feature/fruit/jurlmah)

/obj/item/food/grown/jurlmah
	seed = /obj/item/plant_seeds/preset/alien/jurlmah
	name = "owoc jurl'mah"
	desc = "Mroźny owoc jurl'mah, zimny w dotyku."
	icon = 'aquila/icons/obj/hydroponics/ported_obce_harvest.dmi'
	icon_state = "jurlmah"
	bite_consumption_mod = 0.5
	foodtypes = FRUIT
	tastes = list("śnieg" = 1)

/*
	Surik
*/
/datum/plant_feature/fruit/surik
	species_name = "surik vulcanica"
	name = "surik"
	icon_state = "star"
	colour_override = "#3355dd"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	seed_icon_state = "seed-surik"
	fruit_product = /obj/item/food/grown/surik
	plant_traits = list(/datum/plant_trait/fruit/fireproof)
	fast_reagents = list(/datum/reagent/ash = PLANT_REAGENT_SMALL, /datum/reagent/iron = PLANT_REAGENT_SMALL, /datum/reagent/medicine/omnizine = PLANT_REAGENT_MICRO)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/obj/item/plant_seeds/preset/alien/surik
	name = "nasiona: surik (gruz)"
	name_override = "surik"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-surik"
	plant_features = list(/datum/plant_feature/roots/debris, /datum/plant_feature/body/tuber, /datum/plant_feature/fruit/surik)

/obj/item/food/grown/surik
	seed = /obj/item/plant_seeds/preset/alien/surik
	name = "kryształ surik"
	desc = "Mieniący się kryształ surik. W jego wnętrzu pulsuje wulkaniczne ciepło."
	icon = 'aquila/icons/obj/hydroponics/ported_obce_harvest.dmi'
	icon_state = "surik"
	bite_consumption_mod = 0.5
	foodtypes = FRUIT
	tastes = list("kryształy" = 1)

/*
	Telriis
*/
/datum/plant_feature/fruit/telriis
	species_name = "telriis lactea"
	name = "telriis"
	icon_state = "wheat_2"
	colour_override = "#8fae5f"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	seed_icon_state = "seed-telriis"
	fruit_product = /obj/item/food/grown/telriis
	fast_reagents = list(/datum/reagent/consumable/milk = PLANT_REAGENT_SMALL, /datum/reagent/consumable/soymilk = PLANT_REAGENT_SMALL, /datum/reagent/diethylamine = PLANT_REAGENT_MICRO)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/alien/telriis
	name = "nasiona: telriis (ziemia)"
	name_override = "telriis"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-telriis"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/corn_stalk/wheat, /datum/plant_feature/fruit/telriis)

/obj/item/food/grown/telriis
	seed = /obj/item/plant_seeds/preset/alien/telriis
	name = "snopek telriis"
	desc = "Snopek trawy telriis. Po zmieleniu albo wyciśnięciu daje mleczny płyn."
	icon = 'aquila/icons/obj/hydroponics/ported_obce_harvest.dmi'
	icon_state = "telriis"
	bite_consumption_mod = 0.5
	foodtypes = VEGETABLES
	tastes = list("mleko" = 1)
	juice_typepath = /datum/reagent/consumable/milk

/*
	Thaa'dra
*/
/datum/plant_feature/fruit/thaadra
	species_name = "thaadra argentea"
	name = "thaa'dra"
	icon_state = "flower_2"
	colour_override = "#c9a6f0"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	seed_icon_state = "seed-thaadra"
	fruit_product = /obj/item/food/grown/thaadra
	fast_reagents = list(/datum/reagent/silver = PLANT_REAGENT_SMALL, /datum/reagent/consumable/frostoil = PLANT_REAGENT_SMALL, /datum/reagent/medicine/silibinin = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/obj/item/plant_seeds/preset/alien/thaadra
	name = "nasiona: thaa'dra (glina)"
	name_override = "thaa'dra"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-thaadra"
	plant_features = list(/datum/plant_feature/roots/clay, /datum/plant_feature/body/bush_vine, /datum/plant_feature/fruit/thaadra)

/obj/item/food/grown/thaadra
	seed = /obj/item/plant_seeds/preset/alien/thaadra
	name = "płatki thaa'dra"
	desc = "Garść płatków thaa'dra, pełnych rzadkich leczniczych związków."
	icon = 'aquila/icons/obj/hydroponics/ported_obce_harvest.dmi'
	icon_state = "thaadra"
	gender = PLURAL
	bite_consumption_mod = 0.5
	foodtypes = VEGETABLES
	tastes = list("srebro" = 1)

/*
	Vale
*/
/datum/plant_feature/fruit/vale
	species_name = "vale ardens"
	name = "vale"
	icon_state = "tea_2"
	colour_override = "#e5a6d6"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	seed_icon_state = "seed-vale"
	fruit_product = /obj/item/food/grown/vale
	plant_traits = list(/datum/plant_trait/fruit/biolight/pink)
	fast_reagents = list(/datum/reagent/stable_plasma = PLANT_REAGENT_SMALL, /datum/reagent/toxin/plasma = PLANT_REAGENT_SMALL, /datum/reagent/napalm = PLANT_REAGENT_MICRO)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/obj/item/plant_seeds/preset/alien/vale
	name = "nasiona: vale (ziemia)"
	name_override = "vale"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-vale"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/tree, /datum/plant_feature/fruit/vale)

/obj/item/food/grown/vale
	seed = /obj/item/plant_seeds/preset/alien/vale
	name = "liście vale"
	desc = "Pęk liści vale. Trzymać z dala od otwartego ognia."
	icon = 'aquila/icons/obj/hydroponics/ported_obce_harvest.dmi'
	icon_state = "vale"
	gender = PLURAL
	bite_consumption_mod = 0.5
	foodtypes = VEGETABLES | TOXIC
	tastes = list("plazma" = 1)

/*
	Wapniak gazowy (vaporsac) - ksenoflora, rośnie tylko w kapsule (wymagania w ksenoflora_gazowe.dm)
*/
/datum/plant_feature/fruit/vaporsac
	species_name = "vesica vaporis"
	name = "wapniak gazowy"
	icon_state = "orb"
	colour_override = "#e4f7d0"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	seed_icon_state = "seed-vaporsac"
	fruit_product = /obj/item/food/grown/vaporsac
	genetic_budget = 3
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/vaporsac)
	plant_traits = list(/datum/plant_trait/fruit/liquid_contents, /datum/plant_trait/fruit/gaseous)
	fast_reagents = list(/datum/reagent/nitrous_oxide = PLANT_REAGENT_MEDIUM, /datum/reagent/medicine/ephedrine = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/obj/item/plant_seeds/preset/alien/xenoflora/vaporsac
	name = "nasiona: wapniak gazowy (kapsuła ksenoflory)"
	name_override = "wapniak gazowy"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-vaporsac"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/bush_vine, /datum/plant_feature/fruit/vaporsac)

/obj/item/food/grown/vaporsac
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/vaporsac
	name = "wapniak gazowy"
	desc = "Lekki pęcherz pełen rozpylonych związków chemicznych."
	icon = 'aquila/icons/obj/hydroponics/ported_obce_harvest.dmi'
	icon_state = "vaporsac"
	bite_consumption_mod = 0.5
	foodtypes = VEGETABLES
	tastes = list("sen" = 1)

/*
	Dłoń S'randara (S'randar's hand) - liście na okłady na stłuczenia
*/
/datum/plant_feature/fruit/srandar
	species_name = "manus srandari"
	name = "Dłoń S'randara"
	icon_state = "tea"
	colour_override = "#378c61"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	seed_icon_state = "seed-srandar"
	fruit_product = /obj/item/food/grown/srandar
	fast_reagents = list(/datum/reagent/medicine/bicaridine = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/obj/item/plant_seeds/preset/alien/srandar
	name = "nasiona: Dłoń S'randara (ziemia)"
	name_override = "Dłoń S'randara"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-srandar"
	plant_features = list(/datum/plant_feature/roots/dirt, /datum/plant_feature/body/bush_vine/tea, /datum/plant_feature/fruit/srandar)

/obj/item/food/grown/srandar
	seed = /obj/item/plant_seeds/preset/alien/srandar
	name = "liście Dłoni S'randara"
	desc = "Miękkie, oleiste liście. Pokrojone nożem dają okłady na stłuczenia."
	icon = 'aquila/icons/obj/hydroponics/ported_obce_harvest.dmi'
	icon_state = "srandar"
	gender = PLURAL
	foodtypes = VEGETABLES
	tastes = list("gorzkie zioła" = 1)

/obj/item/food/grown/srandar/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/stack/medical/poultice/srandar, 2, 2 SECONDS)

/*
	Łza Messy (Messa's tear) - płatki na okłady na oparzenia
*/
/datum/plant_feature/fruit/messa
	species_name = "lacrima messae"
	name = "Łza Messy"
	icon_state = "flower_1"
	colour_override = "#4c7fd7"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	seed_icon_state = "seed-messa"
	fruit_product = /obj/item/food/grown/messa
	fast_reagents = list(/datum/reagent/medicine/kelotane = PLANT_REAGENT_MEDIUM, /datum/reagent/consumable/honey = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/obj/item/plant_seeds/preset/alien/messa
	name = "nasiona: Łza Messy (glina)"
	name_override = "Łza Messy"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_seeds.dmi'
	icon_state = "seed-messa"
	plant_features = list(/datum/plant_feature/roots/clay, /datum/plant_feature/body/bush_vine, /datum/plant_feature/fruit/messa)

/obj/item/food/grown/messa
	seed = /obj/item/plant_seeds/preset/alien/messa
	name = "płatki Łzy Messy"
	desc = "Chłodne, niebieskie płatki. Pokrojone nożem dają okłady na oparzenia."
	icon = 'aquila/icons/obj/hydroponics/ported_obce_harvest.dmi'
	icon_state = "messa"
	gender = PLURAL
	foodtypes = VEGETABLES
	tastes = list("miód" = 1)

/obj/item/food/grown/messa/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/stack/medical/poultice/messa, 2, 2 SECONDS)

/*
	Okłady z liści (/vg/: bruise_pack/tajaran, ointment/tajaran)
*/
/obj/item/stack/medical/poultice
	name = "okład z liści"
	singular_name = "okład z liści"
	icon = 'aquila/icons/obj/hydroponics/ported_obce_harvest.dmi'
	icon_state = "srandar_poultice"
	amount = 1
	novariants = TRUE

/obj/item/stack/medical/poultice/srandar
	name = "okład z Dłoni S'randara"
	singular_name = "okład z Dłoni S'randara"
	desc = "Okład z miękkich liści, który wciera się w stłuczenia."
	icon_state = "srandar_poultice"
	heal_brute = 8

/obj/item/stack/medical/poultice/messa
	name = "okład z Łzy Messy"
	singular_name = "okład z Łzy Messy"
	desc = "Okład z chłodnych, niebieskich płatków, który wciera się w oparzenia."
	icon_state = "messa_poultice"
	heal_burn = 8
