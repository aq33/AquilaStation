// AQUILA - dzika flora z Adhomai na planetach lodowych (partia „adhomai”, rośliny z Aurory; wersje kapsułowe, plony i soki
// w botany/aquila/ported/ksenoflora_adhomai.dm). Jak paproć jaskiniowa (ash_flora.dm): struktura staje się rośliną naszej
// botaniki z dzikiego presetu bez potrzeb, zbiera się ją ręką i odrasta. Plon niesie geny wersji kapsułowej
// (wild_capsule_seeds), więc nasiona z siewnika rosną tylko w kapsule ksenoflory.
// Sprite'y w świecie: dojrzałe rośliny z Aurory (icons/obj/hydroponics_growing.dmi z owocami z hydroponics_products.dmi,
// pokolorowane jak w grze), CC BY-SA 3.0. Drzewo cukrowe nie ma w Aurorze własnego sprite'u rośliny: drzewo tree5.

/obj/structure/flora/ash/earthenroot
	name = "dziki ziemny korzeń"
	desc = "Zielne pędy ziemnego korzenia wystające ze śniegu. Ta tajarska roślina dobrze znosi surowy klimat, a pod ziemią rośnie słodki, niebieski korzeń."
	icon = 'aquila/icons/planets/flora/adhomai_flora.dmi'
	icon_state = "earthenroot"
	base_icon_state = "earthenroot"
	seed_type = /obj/item/plant_seeds/preset/earthenroot_wild

/obj/structure/flora/ash/dirtberries
	name = "kępa brudnych jagód"
	desc = "Zimozielony krzew, którego słodkie, mączyste jagody dojrzewają pod ziemią w grubych strąkach."
	icon = 'aquila/icons/planets/flora/adhomai_flora.dmi'
	icon_state = "dirtberries"
	base_icon_state = "dirtberries"
	seed_type = /obj/item/plant_seeds/preset/dirtberries_wild

/obj/structure/flora/ash/sarezhi
	name = "dziki krzew sareżi"
	desc = "Krzew obsypany fioletowymi, cierpkimi jagodami sareżi."
	icon = 'aquila/icons/planets/flora/adhomai_flora.dmi'
	icon_state = "sarezhi"
	base_icon_state = "sarezhi"
	seed_type = /obj/item/plant_seeds/preset/sarezhi_wild

/obj/structure/flora/ash/ylpha
	name = "dziki krzew ylfy"
	desc = "Krzew obsypany pomarańczowymi jagodami ylfy."
	icon = 'aquila/icons/planets/flora/adhomai_flora.dmi'
	icon_state = "ylpha"
	base_icon_state = "ylpha"
	seed_type = /obj/item/plant_seeds/preset/ylpha_wild

/obj/structure/flora/ash/sugartree
	name = "dzikie drzewo cukrowe"
	desc = "Twardy, śnieżny bambus z Adhomai o łodygach grubych jak udo. Na szczycie każdej łodygi rośnie jeden kulisty owoc w białej, wełnistej skórce."
	icon = 'aquila/icons/planets/flora/adhomai_flora.dmi'
	icon_state = "sugartree"
	base_icon_state = "sugartree"
	seed_type = /obj/item/plant_seeds/preset/sugartree_wild

/obj/structure/flora/ash/fjylozyn
	name = "pnącze fjylozynu"
	desc = "Ciemnoczerwone pnącze, którego owoce słabo świecą w mroku."
	icon = 'aquila/icons/planets/flora/adhomai_flora.dmi'
	icon_state = "fjylozyn"
	base_icon_state = "fjylozyn"
	seed_type = /obj/item/plant_seeds/preset/fjylozyn_wild
	light_range = 1.5
	light_power = 0.6
	light_color = "#990033"

/obj/structure/flora/ash/wulumunusha
	name = "pnącze wulumunuszy"
	desc = "Splątane pnącze z błękitnymi owocami. Ich wyciąg wywołuje halucynacje i odbiera mowę."
	icon = 'aquila/icons/planets/flora/adhomai_flora.dmi'
	icon_state = "wulumunusha"
	base_icon_state = "wulumunusha"
	seed_type = /obj/item/plant_seeds/preset/wulumunusha_wild

// Jeden sprite na roślinę (bazowe Initialize losuje stan 1-4)
/obj/structure/flora/ash/earthenroot/Initialize(mapload)
	. = ..()
	icon_state = initial(icon_state)

/obj/structure/flora/ash/dirtberries/Initialize(mapload)
	. = ..()
	icon_state = initial(icon_state)

/obj/structure/flora/ash/sarezhi/Initialize(mapload)
	. = ..()
	icon_state = initial(icon_state)

/obj/structure/flora/ash/ylpha/Initialize(mapload)
	. = ..()
	icon_state = initial(icon_state)

/obj/structure/flora/ash/sugartree/Initialize(mapload)
	. = ..()
	icon_state = initial(icon_state)

/obj/structure/flora/ash/fjylozyn/Initialize(mapload)
	. = ..()
	icon_state = initial(icon_state)

/obj/structure/flora/ash/wulumunusha/Initialize(mapload)
	. = ..()
	icon_state = initial(icon_state)

// Dzikie odmiany owoców: bez potrzeb (owocują na planecie), plon z genami wersji kapsułowej

/datum/plant_feature/fruit/xenoflora/adhomai/earthenroot/wild
	plant_needs = list()
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	genetic_budget = 3
	wild_capsule_seeds = /obj/item/plant_seeds/preset/alien/xenoflora/adhomai/earthenroot

/datum/plant_feature/fruit/xenoflora/adhomai/dirtberries/wild
	plant_needs = list()
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	genetic_budget = 3
	wild_capsule_seeds = /obj/item/plant_seeds/preset/alien/xenoflora/adhomai/dirtberries

/datum/plant_feature/fruit/xenoflora/adhomai/sarezhi/wild
	plant_needs = list()
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	genetic_budget = 3
	wild_capsule_seeds = /obj/item/plant_seeds/preset/alien/xenoflora/adhomai/sarezhi

/datum/plant_feature/fruit/xenoflora/adhomai/ylpha/wild
	plant_needs = list()
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	genetic_budget = 3
	wild_capsule_seeds = /obj/item/plant_seeds/preset/alien/xenoflora/adhomai/ylpha

/datum/plant_feature/fruit/xenoflora/adhomai/sugartree/wild
	plant_needs = list()
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	genetic_budget = 3
	wild_capsule_seeds = /obj/item/plant_seeds/preset/alien/xenoflora/adhomai/sugartree

/datum/plant_feature/fruit/xenoflora/adhomai/fjylozyn/wild
	plant_needs = list()
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	genetic_budget = 3
	wild_capsule_seeds = /obj/item/plant_seeds/preset/alien/xenoflora/adhomai/fjylozyn

/datum/plant_feature/fruit/xenoflora/adhomai/wulumunusha/wild
	plant_needs = list()
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	genetic_budget = 3
	wild_capsule_seeds = /obj/item/plant_seeds/preset/alien/xenoflora/adhomai/wulumunusha

// Dzikie presety (tylko dla struktur; nie do automatu)

/obj/item/plant_seeds/preset/earthenroot_wild
	random_pool = FALSE
	icon = 'aquila/icons/obj/hydroponics/ported_kseno_adhomai_seeds.dmi'
	name = "nasiona: dziki ziemny korzeń (dowolne podłoże)"
	name_override = "dziki ziemny korzeń"
	icon_state = "seed-earthenroot"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/xenoflora/adhomai/earthenroot/wild)

/obj/item/plant_seeds/preset/dirtberries_wild
	random_pool = FALSE
	icon = 'aquila/icons/obj/hydroponics/ported_kseno_adhomai_seeds.dmi'
	name = "nasiona: dzikie brudne jagody (dowolne podłoże)"
	name_override = "dzikie brudne jagody"
	icon_state = "seed-dirtberries"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/xenoflora/adhomai/dirtberries/wild)

/obj/item/plant_seeds/preset/sarezhi_wild
	random_pool = FALSE
	icon = 'aquila/icons/obj/hydroponics/ported_kseno_adhomai_seeds.dmi'
	name = "nasiona: dziki krzew sareżi (dowolne podłoże)"
	name_override = "dziki krzew sareżi"
	icon_state = "seed-sarezhi"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/xenoflora/adhomai/sarezhi/wild)

/obj/item/plant_seeds/preset/ylpha_wild
	random_pool = FALSE
	icon = 'aquila/icons/obj/hydroponics/ported_kseno_adhomai_seeds.dmi'
	name = "nasiona: dziki krzew ylfy (dowolne podłoże)"
	name_override = "dziki krzew ylfy"
	icon_state = "seed-ylpha"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/xenoflora/adhomai/ylpha/wild)

/obj/item/plant_seeds/preset/sugartree_wild
	random_pool = FALSE
	icon = 'aquila/icons/obj/hydroponics/ported_kseno_adhomai_seeds.dmi'
	name = "nasiona: dzikie drzewo cukrowe (dowolne podłoże)"
	name_override = "dzikie drzewo cukrowe"
	icon_state = "seed-sugartree"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/xenoflora/adhomai/sugartree/wild)

/obj/item/plant_seeds/preset/fjylozyn_wild
	random_pool = FALSE
	icon = 'aquila/icons/obj/hydroponics/ported_kseno_adhomai_seeds.dmi'
	name = "nasiona: dziki fjylozyn (dowolne podłoże)"
	name_override = "dziki fjylozyn"
	icon_state = "seed-fjylozyn"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/xenoflora/adhomai/fjylozyn/wild)

/obj/item/plant_seeds/preset/wulumunusha_wild
	random_pool = FALSE
	icon = 'aquila/icons/obj/hydroponics/ported_kseno_adhomai_seeds.dmi'
	name = "nasiona: dzika wulumunusza (dowolne podłoże)"
	name_override = "dzika wulumunusza"
	icon_state = "seed-wulumunusha"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/xenoflora/adhomai/wulumunusha/wild)
