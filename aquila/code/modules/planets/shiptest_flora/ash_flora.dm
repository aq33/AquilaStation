// AQUILA - zbieralne rośliny planety wulkanicznej z Shiptesta (shiptest-ss13/Shiptest, kod AGPLv3, ikony CC BY-SA 3.0):
// code/modules/mining/lavaland/ash_flora.dm. U nas /obj/structure/flora/ash to prawdziwa roślina nowej botaniki
// (komponent plant z nasion seed_type), więc każda dostaje cechę owocu i nasiona jak nasz kaktus popielny
// (korzenie, bulwa z Lavalandu bez potrzeb, owoc bez potrzeb). Odczynników Shiptesta nie mamy, zamienniki:
// włókna popiołu -> popiół, pyre elementum -> kapsaicyna, esencja pucestalu -> antytoksyna.

// Struktury. Bazowe Initialize losuje stan "[base_icon_state][1-4]"; te rośliny mają mniej sprite'ów, więc ustawiają stan po ..()

/obj/structure/flora/ash/fern
	name = "paproć jaskiniowa"
	desc = "Gatunek paproci o bardzo włóknistych liściach."
	icon = 'aquila/icons/planets/flora/ash_flora.dmi'
	icon_state = "cavefern"
	base_icon_state = "cavefern"
	seed_type = /obj/item/plant_seeds/preset/cave_fern

/obj/structure/flora/ash/fern/Initialize(mapload)
	. = ..()
	icon_state = "cavefern"

/obj/structure/flora/ash/fireblossom
	name = "ogniokwiat"
	desc = "Dziwny kwiat, który często rośnie przy jeziorach lawy. Z rozgniecionych liści wychodzi substancja przypominająca kapsaicynę."
	icon = 'aquila/icons/planets/flora/ash_flora.dmi'
	icon_state = "fireblossom1"
	base_icon_state = "fireblossom"
	seed_type = /obj/item/plant_seeds/preset/fireblossom

/obj/structure/flora/ash/fireblossom/Initialize(mapload)
	. = ..()
	icon_state = "fireblossom[rand(1, 2)]"

/obj/structure/flora/ash/puce
	name = "narośl pucestalu"
	desc = "Skupisko brunatnofioletowych kryształów."
	icon = 'aquila/icons/planets/flora/ash_flora.dmi'
	icon_state = "pucetal"
	base_icon_state = "pucetal"
	seed_type = /obj/item/plant_seeds/preset/puce

/obj/structure/flora/ash/puce/Initialize(mapload)
	. = ..()
	icon_state = "pucetal"

// Cechy owoców. Sprite'y owoców na roślinie w tacy z naszego fruit.dmi, nasiona z Shiptesta.

/datum/plant_feature/fruit/cave_fern
	species_name = "filix cavernae"
	name = "paproć jaskiniowa"
	icon_state = "tabacco"
	seed_icon = 'aquila/icons/planets/flora/ash_flora.dmi'
	seed_icon_state = "seed_fern"
	fruit_product = /obj/item/food/grown/ash_flora/fern
	fast_reagents = list(/datum/reagent/ash = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

/datum/plant_feature/fruit/fireblossom
	species_name = "flos ignis"
	name = "ogniokwiat"
	icon_state = "flower_2"
	colour_overlay = "flower_2_colour"
	colour_override = "#ff5a00"
	seed_icon = 'aquila/icons/planets/flora/ash_flora.dmi'
	seed_icon_state = "seed_fireblossom"
	fruit_product = /obj/item/food/grown/ash_flora/fireblossom
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/consumable/capsaicin = PLANT_REAGENT_MEDIUM, /datum/reagent/carbon = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

/datum/plant_feature/fruit/puce
	species_name = "crystallus pulicis"
	name = "pucestal"
	icon_state = "orb"
	colour_override = "#cc8899"
	seed_icon = 'aquila/icons/planets/flora/ash_flora.dmi'
	seed_icon_state = "cluster_puce"
	fruit_product = /obj/item/food/grown/ash_flora/puce
	fast_reagents = list(/datum/reagent/medicine/antitoxin = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

// Nasiona

/obj/item/plant_seeds/preset/cave_fern
	name = "nasiona: paproć jaskiniowa (dowolne podłoże)"
	name_override = "paproć jaskiniowa"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/cave_fern)

/obj/item/plant_seeds/preset/fireblossom
	name = "nasiona: ogniokwiat (dowolne podłoże)"
	name_override = "ogniokwiat"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/fireblossom)

/obj/item/plant_seeds/preset/puce
	name = "nasiona: pucestal (dowolne podłoże)"
	name_override = "pucestal"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/puce)

// Plony

/obj/item/food/grown/ash_flora/fern
	name = "liść paproci"
	desc = "Liść paproci jaskiniowej."
	icon = 'aquila/icons/planets/flora/ash_flora.dmi'
	icon_state = "fern"
	seed = /obj/item/plant_seeds/preset/cave_fern
	wine_power = 10

/obj/item/food/grown/ash_flora/fireblossom
	name = "ogniokwiat"
	desc = "Kwiat ogniokwiatu."
	icon = 'aquila/icons/planets/flora/ash_flora.dmi'
	icon_state = "fireblossom"
	worn_icon = 'aquila/icons/planets/flora/fireblossom_worn.dmi'
	slot_flags = ITEM_SLOT_HEAD
	seed = /obj/item/plant_seeds/preset/fireblossom
	wine_power = 40

/obj/item/food/grown/ash_flora/puce
	name = "kryształ pucestalu"
	desc = "Kryształ z narośli pucestalu."
	icon = 'aquila/icons/planets/flora/ash_flora.dmi'
	icon_state = "puce"
	seed = /obj/item/plant_seeds/preset/puce
	wine_power = 1
	foodtypes = TOXIC | GROSS
