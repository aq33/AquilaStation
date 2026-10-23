// aq33/AquilaStation#497 - głód i pragnienie nie zadają obrażeń, tylko spowalniają regenerację krwi

/datum/test_chamber_kit/pr_497
	name = "PR 497: głód bez obrażeń"
	pr = "aq33/AquilaStation#497"
	description = "Człowiek jest wygłodzony, odwodniony i ma mało krwi. Przez minutę nie mogą mu rosnąć obrażenia brute ani burn (wcześniej głód zadawał 1-3 co kilka sekund). \
		Obrażenia oxy od małej ilości krwi są normalne. \
		Analizatorem sprawdź krew: przy odwodnieniu nie przybywa. Napój go wodą ze zlewki - krew wraca powoli, po kanapkach szybciej."
	items = list(
		/mob/living/carbon/human = 1,
		/obj/item/reagent_containers/glass/beaker/large = 1,
		/obj/item/food/sandwich = 3,
		/obj/item/healthanalyzer = 1,
	)

/datum/test_chamber_kit/pr_497/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	for(var/mob/living/carbon/human/H in spawned)
		H.set_nutrition(NUTRITION_LEVEL_STARVING - 50)
		H.set_hydration(HYDRATION_LEVEL_PARCHED - 50)
		H.blood_volume = BLOOD_VOLUME_OKAY
	for(var/obj/item/reagent_containers/glass/beaker/large/B in spawned)
		B.reagents.add_reagent(/datum/reagent/water, 100)
