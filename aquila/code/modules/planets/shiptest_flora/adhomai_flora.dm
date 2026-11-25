// AQUILA - dzika flora z Adhomai na planetach lodowych (partia „adhomai”, rośliny z Aurory; wersje kapsułowe, plony i soki
// w botany/aquila/ported/ksenoflora_adhomai.dm). Jak paproć jaskiniowa (ash_flora.dm): struktura staje się rośliną naszej
// botaniki z dzikiego presetu bez potrzeb, zbiera się ją ręką i odrasta. Plon niesie geny wersji kapsułowej
// (wild_capsule_seeds), więc nasiona z siewnika rosną tylko w kapsule ksenoflory.
// Sprite'y w świecie: dojrzałe rośliny z Aurory (icons/obj/hydroponics_growing.dmi z owocami z hydroponics_products.dmi,
// pokolorowane jak w grze), CC BY-SA 3.0.

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

/obj/structure/flora/ash/fjylozyn/Initialize(mapload)
	. = ..()
	icon_state = initial(icon_state)

/obj/structure/flora/ash/wulumunusha/Initialize(mapload)
	. = ..()
	icon_state = initial(icon_state)

// Dzikie odmiany owoców: bez potrzeb (owocują na planecie), plon z genami wersji kapsułowej

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
