// aq33/AquilaStation#373 - wypróżnianie: kawa, ostre jedzenie, olej rycynowy

/datum/test_chamber_kit/pr_373
	name = "PR 373: wypróżnianie - kawa, ostre, olej rycynowy"
	pr = "aq33/AquilaStation#373"
	description = "Działa tylko z SHITTING_ENABLED w configu. Zestaw zeruje ci licznik defecation (VV na sobie, zmienna defecation). \
	Wypij kubek kawy (25 u) - po ok. 2 min licznik ok. 19. Ostry sos (kapsaicyna) też podnosi licznik. Wlej do pustej zlewki olej, siarkę i wodę (po 10 u) - powstaje olej rycynowy. \
	Wypij 10 u oleju i trochę bikaridyny, poczekaj aż licznik przekroczy 100 i usiądź na sedesie: komunikat o oczyszczeniu, inne substancje spadają o 10 u."
	items = list(
		/obj/item/reagent_containers/food/drinks/coffee = 2,
		/obj/item/reagent_containers/food/condiment/hotsauce = 1,
		/obj/item/reagent_containers/glass/beaker = 1,
		/obj/item/reagent_containers/glass/bottle/pr_373_oil = 1,
		/obj/item/reagent_containers/glass/bottle/pr_373_sulfur = 1,
		/obj/item/reagent_containers/glass/bottle/pr_373_water = 1,
		/obj/item/reagent_containers/glass/bottle/pr_373_castor = 1,
		/obj/item/reagent_containers/glass/bottle/pr_373_bicaridine = 1,
		/obj/structure/toilet = 1,
	)

/datum/test_chamber_kit/pr_373/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return
	H.defecation = 0

/obj/item/reagent_containers/glass/bottle/pr_373_oil
	name = "olej spożywczy"
	list_reagents = list(/datum/reagent/consumable/nutriment/fat/oil = 30)

/obj/item/reagent_containers/glass/bottle/pr_373_sulfur
	name = "siarka"
	list_reagents = list(/datum/reagent/sulfur = 30)

/obj/item/reagent_containers/glass/bottle/pr_373_water
	name = "woda"
	list_reagents = list(/datum/reagent/water = 30)

/obj/item/reagent_containers/glass/bottle/pr_373_castor
	name = "olej rycynowy"
	list_reagents = list(/datum/reagent/consumable/castor_oil = 30)

/obj/item/reagent_containers/glass/bottle/pr_373_bicaridine
	name = "bikaridyna"
	list_reagents = list(/datum/reagent/medicine/bicaridine = 30)
