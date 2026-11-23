/*
	Syntetyczne nerki, śledziona i jelita (Goon: synthkidney, synthspleen, synthintestines).
	Te narządy wprowadza AquilaMed 5 (aq33/AquilaStation#652). Jego define ORGAN_SLOT_KIDNEYS jest w aquila/code/__DEFINES,
	więc bez AquilaMed 5 ten plik nic nie dodaje, a po scaleniu obu PR-ów rośliny włączają się same.
	Trzustki nie ma, bo nie mamy takiego narządu.
*/
#ifdef ORGAN_SLOT_KIDNEYS

/datum/plant_mutation_set/surowce_med5
	reagent_mutations = list(
		/datum/plant_feature/fruit/surowce/synthmeat = list(
			/datum/plant_feature/fruit/surowce/synth_organ/kidneys = list(/datum/reagent/medicine/potass_iodide = 10),
			/datum/plant_feature/fruit/surowce/synth_organ/spleen = list(/datum/reagent/iron = 10),
			/datum/plant_feature/fruit/surowce/synth_organ/intestines = list(/datum/reagent/cellulose = 10),
		),
	)

/datum/plant_feature/fruit/surowce/synth_organ/kidneys
	species_name = "renes synthetici"
	name = "syntetyczne nerki"
	icon_state = "synth_kidneys"
	fruit_product = /obj/item/organ/kidneys/synthgrown

/datum/plant_feature/fruit/surowce/synth_organ/spleen
	species_name = "lien syntheticus"
	name = "syntetyczna śledziona"
	icon_state = "synth_spleen"
	fruit_product = /obj/item/organ/spleen/synthgrown

/datum/plant_feature/fruit/surowce/synth_organ/intestines
	species_name = "intestina synthetica"
	name = "syntetyczne jelita"
	icon_state = "synth_intestines"
	fruit_product = /obj/item/organ/intestines/synthgrown

/obj/item/organ/kidneys/synthgrown
	name = "syntetyczne nerki"
	desc = "Nerki wyhodowane w tacy hydroponicznej. Filtrują trochę słabiej niż prawdziwe."
	maxHealth = 0.75 * STANDARD_ORGAN_THRESHOLD

/obj/item/organ/spleen/synthgrown
	name = "syntetyczna śledziona"
	desc = "Śledziona wyhodowana w tacy hydroponicznej. Krwinek robi mniej niż prawdziwa."
	maxHealth = 0.75 * STANDARD_ORGAN_THRESHOLD

/obj/item/organ/intestines/synthgrown
	name = "syntetyczne jelita"
	desc = "Jelita wyhodowane w tacy hydroponicznej. Długie, zielonkawe i lekko pachną kompostem."
	maxHealth = 0.75 * STANDARD_ORGAN_THRESHOLD

#endif
