/obj/item/banner/munitions
	name = "sztandar Ludowej Republiki Munistocka"
	desc = "Sztandar Ludowej Republiki Munistocka, mistrzów broni i amunicji. Chwała Munistockowi!"
	icon = 'nsv13/icons/obj/banners.dmi'
	icon_state = "banner_munitions"
	item_state = "banner_munitions"
	lefthand_file = 'nsv13/icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/equipment/banners_righthand.dmi'
	job_loyalties = list(JOB_NAME_MASTERATARMS, JOB_NAME_MUNITIONSTECHNICIAN, JOB_NAME_PILOT, JOB_NAME_AIRTRAFFICCONTROLLER)
	warcry = "USZY DZWONIĄ, DZIAŁA ŚPIEWAJĄ!"

/obj/item/banner/munitions/mundane
    inspiration_available = FALSE

/obj/item/banner/munitions/check_inspiration(mob/living/carbon/human/H)
	return HAS_TRAIT(H, TRAIT_DEAF)

/obj/item/banner/munitions/special_inspiration(mob/living/carbon/human/H)
	H.restoreEars()

/datum/crafting_recipe/munitions
    name = "sztandar Ludowej Republiki Munistocka"
    result = /obj/item/banner/munitions/mundane
    time = 40
    reqs = list(/obj/item/stack/rods = 2,
				/obj/item/clothing/under/rank/munitions_tech = 1)
    category = CAT_MISC

/obj/item/banner/solgov
	name = "sztandar Rządu Sol"
	desc = "Sztandar Słonecznego Rządu Konfederacyjnego, najpotężniejszego członka Federacji Galaktycznej."
	icon = 'nsv13/icons/obj/banners.dmi'
	icon_state = "banner_solgov"
	item_state = "banner_solgov"
	lefthand_file = 'nsv13/icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/equipment/banners_righthand.dmi'
	job_loyalties = null
	warcry = "Za serce! Za dom! Za Lunę! Za Sol!"

/obj/item/banner/solgov/mundane
	inspiration_available = FALSE

/datum/crafting_recipe/solgov
	name = "sztandar Rządu Sol"
	result = /obj/item/banner/solgov/mundane
	time = 40
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/clothing/under/ship/solgov = 1)
	category = CAT_MISC

/obj/item/banner/draconic
	name = "sztandar Imperium Drakońskiego"
	desc = "Sztandar Imperium Drakońskiego, głównej siły rządzącej ojczystą planetą jaszczuroludzi i jej księżycami."
	icon = 'nsv13/icons/obj/banners.dmi'
	icon_state = "banner_draconic"
	item_state = "banner_draconic"
	lefthand_file = 'nsv13/icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/equipment/banners_righthand.dmi'
	job_loyalties = null
	warcry = "HISSSSSSSS"

/obj/item/banner/draconic/inspiration(mob/living/carbon/human/H)
	playsound(H, 'sound/voice/lizard/lizard_scream_1.ogg', 25, FALSE)

/obj/item/banner/draconic/mundane
	inspiration_available = FALSE

/datum/crafting_recipe/draconic
	name = "sztandar Imperium Drakońskiego"
	result = /obj/item/banner/draconic/mundane
	time = 40
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/stack/sheet/durathread = 10,
				/obj/item/food/grown/moonflower = 1)
	category = CAT_MISC

/obj/item/banner/dominion
	name = "sztandar Dominium Światła"
	desc = "Sztandar Dominium Światła, pokojowo nastawionej wspólnoty, do której należy większość eteryków i ciem."
	icon = 'nsv13/icons/obj/banners.dmi'
	icon_state = "banner_dominion"
	item_state = "banner_dominion"
	lefthand_file = 'nsv13/icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/equipment/banners_righthand.dmi'
	job_loyalties = null
	warcry = "Niech prowadzi nas światło pochodni!"

/obj/item/banner/dominion/mundane
	inspiration_available = FALSE

/datum/crafting_recipe/dominion
	name = "sztandar Dominium Światła"
	result = /obj/item/banner/dominion/mundane
	time = 40
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/candle = 1,
				/obj/item/stack/sheet/durathread = 10)
	category = CAT_MISC

/obj/item/banner/dominion/check_inspiration(mob/living/carbon/human/H)
    return HAS_TRAIT(H, TRAIT_BLIND)

/obj/item/banner/dominion/special_inspiration(mob/living/carbon/human/H)
	H.reagents.add_reagent(/datum/reagent/medicine/oculine, 5)

/obj/item/banner/syndicate
	name = "sztandar Syndykatu"
	desc = "Sztandar Przestępczego Syndykatu, zorganizowanych przestępców odpowiedzialnych za wysadzenie Luny."
	icon = 'nsv13/icons/obj/banners.dmi'
	icon_state = "banner_syndicate"
	item_state = "banner_syndicate"
	lefthand_file = 'nsv13/icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/equipment/banners_righthand.dmi'
	job_loyalties = list("Traitor", "Nuclear Operative", "Syndicate Drop Trooper")
	warcry = "Śmierć Nanotrasen! Śmierć Solgovowi!"

/datum/uplink_item/badass/banner //Traitor Uplink Item
	name = "sztandar Syndykatu"
	desc = "Sztandar oznaczający twoje oddanie i lojalność wobec Syndykatu. Syndykat zwycięży!"
	item = /obj/item/banner/syndicate
	cost = 10
