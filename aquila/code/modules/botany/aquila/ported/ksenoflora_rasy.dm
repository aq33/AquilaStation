/*
	AQUILA - łzy Merlina z Baystation12 (code/modules/spells/aoe_turf/conjure/grove.dm), przeniesione jako ksenoflora:
	rosną tylko w kapsule ksenoflory, na plazmie i wodzie święconej. Pozostałe rośliny ras z Baya usunięte (bez przepisów
	i własnych odczynników, raport/bloat_09_rosliny_po_kuchni.md).
	Sprite'y plonu i torebki złożone z Baya (icons/obj/flora/hydroponics_products.dmi i seeds.dmi, pokolorowane jak w grze), licencja CC-BY-SA 3.0.
	Odczynniki Baya, których nie mamy, zamienione na nasze najbliższe (lista w nagłówku rośliny).
*/

/*
	Wymagania kapsuły
*/

/datum/plant_need/xenoflora/merlin_tears
	required_gases = list(GAS_PLASMA = 0.1)
	required_reagents = list(/datum/reagent/water/holywater = 0.1)
	min_temperature = T0C + 15
	max_temperature = T0C + 25

/*
	Owoce
*/
/datum/plant_feature/fruit/xenoflora/rasy
	abstract_type = /datum/plant_feature/fruit/xenoflora/rasy
	seed_icon = 'aquila/icons/obj/hydroponics/ported_kseno_rasy_seeds.dmi'

/*
	Łzy Merlina (Bay: merlin tears, roślina z zaklęcia czarodzieja „Sanctuary”).
	Zamiany: dermalina na kelotan, dylowen na antytoksynę, alkizyna na mannitol, imidazolina na okulinę, peridaksyna na korazon.
*/
/datum/plant_feature/fruit/xenoflora/rasy/merlin_tears
	species_name = "lacrimae merlini"
	name = "łzy Merlina"
	icon_state = "berry"
	colour_override = "#4d4dff"
	seed_icon_state = "seed-merlin_tears"
	fruit_product = /obj/item/food/grown/xenoflora/rasy/merlin_tears
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/xenoflora/merlin_tears)
	fast_reagents = list(
		/datum/reagent/medicine/bicaridine = PLANT_REAGENT_SMALL,
		/datum/reagent/medicine/kelotane = PLANT_REAGENT_SMALL,
		/datum/reagent/medicine/antitoxin = PLANT_REAGENT_SMALL,
		/datum/reagent/medicine/tricordrazine = PLANT_REAGENT_SMALL,
		/datum/reagent/medicine/mannitol = PLANT_REAGENT_MICRO,
		/datum/reagent/medicine/oculine = PLANT_REAGENT_MICRO,
		/datum/reagent/medicine/corazone = PLANT_REAGENT_MICRO,
	)
	total_volume = PLANT_FRUIT_VOLUME_MEDIUM
	growth_time = PLANT_FRUIT_GROWTH_SLOW

/*
	Nasiona (tylko ksenoflora: pula artefaktu „Seeding” i ruin planet)
*/
/obj/item/plant_seeds/preset/alien/xenoflora/rasy
	icon = 'aquila/icons/obj/hydroponics/ported_kseno_rasy_seeds.dmi'
	abstract_type = /obj/item/plant_seeds/preset/alien/xenoflora/rasy

/obj/item/plant_seeds/preset/alien/xenoflora/rasy/merlin_tears
	name = "nasiona: łzy Merlina (kapsuła ksenoflory)"
	name_override = "łzy Merlina"
	icon_state = "seed-merlin_tears"
	plant_features = list(/datum/plant_feature/roots/xenoflora, /datum/plant_feature/body/tree/mini, /datum/plant_feature/fruit/xenoflora/rasy/merlin_tears)

/*
	Plony
*/
/obj/item/food/grown/xenoflora/rasy
	abstract_type = /obj/item/food/grown/xenoflora/rasy
	icon = 'aquila/icons/obj/hydroponics/ported_kseno_rasy_harvest.dmi'

/obj/item/food/grown/xenoflora/rasy/merlin_tears
	seed = /obj/item/plant_seeds/preset/alien/xenoflora/rasy/merlin_tears
	name = "łzy Merlina"
	desc = "Kiść niebieskich jagód, które podobno wyrosły z łez czarodzieja. Leczą rany, oparzenia i zatrucia."
	icon_state = "merlin_tears"
	tastes = list("jagody" = 2, "magia" = 1)
	foodtypes = FRUIT
