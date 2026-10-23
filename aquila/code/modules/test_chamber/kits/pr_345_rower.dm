// aq33/AquilaStation#345 - rower stacjonarny generujący prąd

/datum/test_chamber_kit/pr_345
	name = "PR 345: rower stacjonarny"
	pr = "aq33/AquilaStation#345"
	description = "Przypnij do roweru małpę (przeciągnij na rower) i obejrzyj go: ma generować 15 kW. Człowiek bez gracza daje 25 kW, przypięty gracz (ty) 50 kW. \
	Po odpięciu moc spada do 0. Zemaguj rower: daje 1,5x więcej, ale co tick zadaje 5 brute i paraliżuje, a ofiarę da się zdjąć tylko łomem. \
	Prąd trafia do sieci pod rowerem (połóż kabel z cewki i sprawdź multitoolem). Klucz odkręca/przykręca rower."
	items = list(
		/obj/machinery/power/stationarybike = 1,
		/mob/living/carbon/monkey = 1,
		/mob/living/carbon/human = 1,
		/obj/item/card/emag = 1,
		/obj/item/crowbar = 1,
		/obj/item/wrench = 1,
		/obj/item/multitool = 1,
		/obj/item/stack/cable_coil = 1,
	)
