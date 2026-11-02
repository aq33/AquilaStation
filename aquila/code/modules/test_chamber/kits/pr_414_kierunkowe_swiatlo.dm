// aq33/AquilaStation#414 - kierunkowe oświetlenie (port Bee#10474)

/datum/test_chamber_kit/pr_414
	name = "PR 414: kierunkowe światło"
	pr = "aq33/AquilaStation#414"
	description = "Zestaw gasi lampy w komorze na 5 minut, żeby stożek światła był dobrze widoczny. \
	1) Włącz latarkę i obracaj się → oczekiwane: światło idzie stożkiem przed tobą, nie okręgiem. \
	2) To samo: seclite przykręcona śrubokrętem do disablera, mini e-gun, kask, hełm hardsuita, hełm plazmamena i PDA (latarka w menu) → oczekiwane: każde świeci stożkiem w stronę, w którą patrzysz. \
	3) Rzuć włączoną latarkę → oczekiwane: leżąca świeci tam, gdzie wskazuje jej sprite. \
	4) Negatyw: lampa biurkowa, flara, latarnia i glowstick → oczekiwane: zostają okrągłe, bez stożka. \
	5) Eteryk i luminescent świecą wokół siebie, zastrzyk Glowy daje poświatę, Anti-Glow ją przyciemnia → oczekiwane: poświata okrągła, nie stożek. \
	6) Rzuć flashbanga → oczekiwane: krótki biały błysk (a nie dziwny zasięg). \
	Borgi z latarką (z opisu PR) wymagają drugiego gracza lub borga zrobionego przez admina - w tym zestawie ich nie ma."
	items = list(
		/obj/item/flashlight = 2,
		/obj/item/flashlight/seclite = 1,
		/obj/item/gun/energy/disabler = 1,
		/obj/item/screwdriver = 1,
		/obj/item/gun/energy/e_gun/mini = 1,
		/obj/item/clothing/head/hardhat = 1,
		/obj/item/clothing/suit/space/hardsuit/engine = 1,
		/obj/item/clothing/head/helmet/space/plasmaman = 1,
		/obj/item/modular_computer/tablet/pda = 1,
		/obj/item/flashlight/lamp = 1,
		/obj/item/flashlight/flare = 1,
		/obj/item/flashlight/lantern = 1,
		/obj/item/flashlight/glowstick = 1,
		/mob/living/carbon/human/species/ethereal = 1,
		/mob/living/carbon/human/species/jelly/luminescent = 1,
		/obj/item/dnainjector/glow = 1,
		/obj/item/dnainjector/antiglow = 1,
		/obj/item/grenade/flashbang = 1,
	)

/datum/test_chamber_kit/pr_414/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	// Ciemność w komorze, inaczej stożek ginie w świetle lamp (lampy wracają po 5 minutach)
	for(var/obj/machinery/light/lamp in range(20, center))
		if(GLOB.test_chamber?.contains(lamp))
			lamp.extinguish_light()
