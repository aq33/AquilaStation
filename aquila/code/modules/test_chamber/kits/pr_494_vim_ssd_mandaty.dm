/datum/test_chamber_kit/pr_494
	name = "PR 494: VIM, wskaźnik SSD, Citationinator"
	pr = "aq33/AquilaStation#494"
	description = "VIM: przejmij corgi albo kota (Nawiedź/ghost) i przeciągnij się na gotowego Vima. Sprawdź jazdę, Dzyń!/Bzzz., reflektory i wyjście. \
	Złóż drugiego z części: połóż hełm EVA na ziemi, dodaj obie nogi, latarkę, śrubokręt, moduł głosowy, śrubokręt, butlę. Uszkodź go i napraw spawarką (bez combat mode). Po zniszczeniu nie ma wybuchu, butla wypada. \
	SSD: człowiek z zestawu ma ustawiony znacznik; prawdziwy test to rozłączenie się postacią (znacznik ma zniknąć po powrocie, wyjściu duchem i śmierci, a examine pokazuje minuty). \
	Citationinator (Deputy i policjant mają go w plecaku): użyj go w ręce z kartą ochrony, wybierz kogoś z manifestu, mandat ma trafić do akt (HUD ochrony, konsola nakazów) i wypluć różowy kwit. Bez dostępu odmawia, emag zdejmuje blokadę."
	items = list(
		/obj/vehicle/sealed/car/vim/with_tank = 1,
		/mob/living/simple_animal/pet/dog/corgi = 1,
		/mob/living/simple_animal/pet/cat = 1,
		/obj/item/clothing/head/helmet/space/eva = 1,
		/obj/item/bodypart/l_leg/robot = 1,
		/obj/item/bodypart/r_leg/robot = 1,
		/obj/item/flashlight = 1,
		/obj/item/assembly/voice = 1,
		/obj/item/tank/internals/oxygen = 1,
		/obj/item/screwdriver = 1,
		/obj/item/weldingtool/largetank = 1,
		/obj/item/citationinator = 2,
		/obj/item/card/emag = 1,
		/obj/item/clothing/glasses/hud/security = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_494/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	for(var/mob/living/carbon/human/dummy in spawned)
		dummy.lastclienttime = world.time - 3 MINUTES
		dummy.set_ssd_indicator(TRUE)
