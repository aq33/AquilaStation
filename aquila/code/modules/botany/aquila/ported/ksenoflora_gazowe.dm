/*
	AQUILA - ksenoflora od gazów: rośliny, które rosną tylko w kapsule ksenoflory (ksenoflora.dm, ksenoflora_pod.dm).
	- Oddychacz i roślina żywiczna z Baystation12 (/datum/seed/breather, /datum/seed/resin). W oryginale oddychacz wydziela azot,
	  u nas kapsuła nie przyjmuje gazów od roślin, więc zostało samo wymaganie tlenu. Żywica Baya (płyty żywicy Voxów) to u nas plastik.
	- Kapusta plazmowa z /vg/station13 (/datum/seed/plasmacabbage): jak w oryginale pochłania plazmę.
	- Pomarańcza piorunowa i jądrowa z CHOMPStation2 (modular_chomp/code/modules/hydro/plants.dm). W oryginale mutacje zwykłej pomarańczy
	  z płynnym życiem albo deathblood; u nas ksenoflora z kapsuły: piorunowa ma cechę ogniwa, jądrowa uran i promieniuje.
	Grafiki plonów: Baystation12 (hydroponics_products.dmi, CC-BY-SA 3.0), /vg/station13 (cabbageplasma.dmi, CC-BY-SA 3.0),
	pomarańcze przekolorowane z naszej pomarańczy; torebki to słoik ksenoflory z miniaturą plonu.
	Tu są też wymagania wapniaka gazowego (obce.dm), rośliny plazmowej i kryształu (obce_artefakty.dm), przeniesionych do kapsuły.
*/

/*
	Wymagania (ilości na sekundę, temperatury w K)
*/
/datum/plant_need/xenoflora/vaporsac
	required_gases = list(GAS_CO2 = 0.1)
	min_temperature = T0C + 10
	max_temperature = T0C + 40

/datum/plant_need/xenoflora/plasma_spore
	required_gases = list(GAS_PLASMA = 0.2)
	min_temperature = T0C
	max_temperature = T0C + 60

/datum/plant_need/xenoflora/crystal
	required_gases = list(GAS_PLASMA = 0.3)
	min_temperature = T0C - 90
	max_temperature = T0C - 20

/datum/plant_need/xenoflora/breather
	required_gases = list(GAS_O2 = 0.2)
	min_temperature = T0C + 10
	max_temperature = T0C + 35

/datum/plant_need/xenoflora/resin
	required_gases = list(GAS_N2 = 0.1)
	required_reagents = list(/datum/reagent/carbon = 0.05)
	min_temperature = T0C + 15
	max_temperature = T0C + 45

/datum/plant_need/xenoflora/plasma_cabbage
	required_gases = list(GAS_PLASMA = 0.1)
	min_temperature = T0C + 5
	max_temperature = T0C + 30

/datum/plant_need/xenoflora/livewire_orange
	required_gases = list(GAS_CO2 = 0.1)
	required_reagents = list(/datum/reagent/lithium = 0.05)
	min_temperature = T0C + 10
	max_temperature = T0C + 40

/datum/plant_need/xenoflora/nuclear_orange
	required_gases = list(GAS_CO2 = 0.15)
	required_reagents = list(/datum/reagent/uranium = 0.05)
	min_temperature = T0C + 40
	max_temperature = T0C + 90

/*
	Owoce
*/
/datum/plant_feature/fruit/xenoflora/breather
	species_name = "pulmo alienus"
	name = "oddychacz"
	icon_state = "orb"
	colour_override = "#5f8a45"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_kseno_gazowe_seeds.dmi'
	seed_icon_state = "xenoseeds-breather"
	fruit_product = /obj/item/food/grown/xenoflora/breather
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/breather)
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/ammonia = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/datum/plant_feature/fruit/xenoflora/resin
	species_name = "resina aliena"
	name = "roślina żywiczna"
	icon_state = "pod"
	colour_override = "#d79a3a"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_kseno_gazowe_seeds.dmi'
	seed_icon_state = "xenoseeds-resin"
	fruit_product = /obj/item/food/grown/xenoflora/resin
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/resin)
	fast_reagents = list(/datum/reagent/plastic_polymers = PLANT_REAGENT_LARGE)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_SLOW

/datum/plant_feature/fruit/xenoflora/plasma_cabbage
	species_name = "brassica plasmatica"
	name = "kapusta plazmowa"
	icon_state = "cabbage"
	icon_uneven = TRUE
	colour_override = "#c060c8"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_kseno_gazowe_seeds.dmi'
	seed_icon_state = "xenoseeds-plasmacabbage"
	fruit_product = /obj/item/food/grown/xenoflora/plasma_cabbage
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/plasma_cabbage)
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)
	fast_reagents = list(/datum/reagent/toxin/plasma = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_MEDIUM
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	fruit_size = PLANT_FRUIT_SIZE_MEDIUM

/datum/plant_feature/fruit/xenoflora/livewire_orange
	species_name = "citrum fulminis"
	name = "pomarańcza piorunowa"
	icon_state = "orange"
	icon_uneven = TRUE
	colour_override = "#fff04a"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_kseno_gazowe_seeds.dmi'
	seed_icon_state = "xenoseeds-livewire_orange"
	fruit_product = /obj/item/food/grown/xenoflora/livewire_orange
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/livewire_orange)
	genetic_budget = 3
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin, /datum/plant_trait/fruit/cell)
	fast_reagents = list(/datum/reagent/consumable/liquidelectricity = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM

/datum/plant_feature/fruit/xenoflora/nuclear_orange
	species_name = "citrum atomicum"
	name = "pomarańcza jądrowa"
	icon_state = "orange"
	icon_uneven = TRUE
	colour_override = "#8cff4a"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_kseno_gazowe_seeds.dmi'
	seed_icon_state = "xenoseeds-nuclear_orange"
	fruit_product = /obj/item/food/grown/xenoflora/nuclear_orange
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/nuclear_orange)
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment, /datum/plant_trait/reagent/fruit/vitamin)
	fast_reagents = list(/datum/reagent/uranium = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_SLOW

/*
	Nasiona (bez automatu, jak reszta ksenoflory)
*/
/obj/item/plant_seeds/preset/alien/xenoflora/breather
	name = "nasiona: oddychacz (kapsuła ksenoflory)"
	name_override = "oddychacz"
	icon = 'aquila/icons/obj/hydroponics/ported_kseno_gazowe_seeds.dmi'
	icon_state = "xenoseeds-breather"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/bush_vine, /datum/plant_feature/fruit/xenoflora/breather)

/obj/item/plant_seeds/preset/alien/xenoflora/resin
	name = "nasiona: roślina żywiczna (kapsuła ksenoflory)"
	name_override = "roślina żywiczna"
	icon = 'aquila/icons/obj/hydroponics/ported_kseno_gazowe_seeds.dmi'
	icon_state = "xenoseeds-resin"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/tree/sparse, /datum/plant_feature/fruit/xenoflora/resin)

/obj/item/plant_seeds/preset/alien/xenoflora/plasma_cabbage
	name = "nasiona: kapusta plazmowa (kapsuła ksenoflory)"
	name_override = "kapusta plazmowa"
	icon = 'aquila/icons/obj/hydroponics/ported_kseno_gazowe_seeds.dmi'
	icon_state = "xenoseeds-plasmacabbage"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/tuber, /datum/plant_feature/fruit/xenoflora/plasma_cabbage)

/obj/item/plant_seeds/preset/alien/xenoflora/livewire_orange
	name = "nasiona: pomarańcza piorunowa (kapsuła ksenoflory)"
	name_override = "pomarańcza piorunowa"
	icon = 'aquila/icons/obj/hydroponics/ported_kseno_gazowe_seeds.dmi'
	icon_state = "xenoseeds-livewire_orange"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/tree/orange, /datum/plant_feature/fruit/xenoflora/livewire_orange)

/obj/item/plant_seeds/preset/alien/xenoflora/nuclear_orange
	name = "nasiona: pomarańcza jądrowa (kapsuła ksenoflory)"
	name_override = "pomarańcza jądrowa"
	icon = 'aquila/icons/obj/hydroponics/ported_kseno_gazowe_seeds.dmi'
	icon_state = "xenoseeds-nuclear_orange"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/tree/orange, /datum/plant_feature/fruit/xenoflora/nuclear_orange)

/*
	Plony
*/
/obj/item/food/grown/xenoflora/breather
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/breather
	name = "oddychacz"
	desc = "Pulsujący kłąb liści i korzeni, który wciąga powietrze jak płuco. Pachnie amoniakiem."
	icon = 'aquila/icons/obj/hydroponics/ported_kseno_gazowe_harvest.dmi'
	icon_state = "breather"
	tastes = list("amoniak" = 2, "liście" = 1)
	foodtypes = VEGETABLES | GROSS

/obj/item/food/grown/xenoflora/resin
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/resin
	name = "gałązka żywicy"
	desc = "Sztywna gałązka oblepiona twardniejącą żywicą. Pocięta nożem daje arkusz plastiku."
	icon = 'aquila/icons/obj/hydroponics/ported_kseno_gazowe_harvest.dmi'
	icon_state = "resin"
	tastes = list("żywica" = 1)
	foodtypes = GROSS
	grind_results = list(/datum/reagent/plastic_polymers = 0)

/obj/item/food/grown/xenoflora/resin/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/stack/sheet/plastic, 1, 2 SECONDS)

/obj/item/food/grown/xenoflora/resin/make_dryable()
	return //Żywica nie schnie na suszarce

/obj/item/food/grown/xenoflora/plasma_cabbage
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/plasma_cabbage
	name = "kapusta plazmowa"
	desc = "Nie mylić z czerwoną kapustą."
	icon = 'aquila/icons/obj/hydroponics/ported_kseno_gazowe_harvest.dmi'
	icon_state = "plasmacabbage"
	w_class = WEIGHT_CLASS_SMALL
	tastes = list("kapusta" = 2, "plazma" = 1)
	foodtypes = VEGETABLES | TOXIC

/obj/item/food/grown/xenoflora/livewire_orange
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/livewire_orange
	name = "pomarańcza piorunowa"
	desc = "Żółta pomarańcza, która lekko kłuje w palce. Z odcinkami kabla da się z niej zrobić baterię."
	icon = 'aquila/icons/obj/hydroponics/ported_kseno_gazowe_harvest.dmi'
	icon_state = "livewire_orange"
	tastes = list("pomarańcza" = 2, "prąd" = 1)
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/orangejuice

/obj/item/food/grown/xenoflora/nuclear_orange
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/nuclear_orange
	name = "pomarańcza jądrowa"
	desc = "Pomarańcza świecąca chorobliwą zielenią. Lepiej nie trzymać jej w kieszeni."
	icon = 'aquila/icons/obj/hydroponics/ported_kseno_gazowe_harvest.dmi'
	icon_state = "nuclear_orange"
	tastes = list("cytryna" = 2, "wnętrze reaktora" = 1)
	foodtypes = FRUIT | TOXIC
	juice_typepath = /datum/reagent/consumable/lemonjuice

/obj/item/food/grown/xenoflora/nuclear_orange/Initialize(mapload, skip_genes)
	. = ..()
	AddElement(/datum/element/radioactive, 1)
