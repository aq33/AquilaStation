// aq33/AquilaStation#414 - kierunkowe oświetlenie (port Bee#10474)

/datum/test_chamber_kit/pr_414
	name = "PR 414: kierunkowe światło"
	pr = "aq33/AquilaStation#414"
	description = "Najlepiej przy zgaszonym świetle w komorze. Włącz latarkę i obracaj się - światło ma iść stożkiem przed tobą, nie okręgiem. \
	To samo: seclite przykręcona śrubokrętem do disablera, mini e-gun, kask, hełm hardsuita i PDA (latarka w menu). \
	Rzuć włączoną latarkę - leżąca świeci tam, gdzie wskazuje jej sprite. Lampa biurkowa, flara, latarnia i glowstick zostają okrągłe. \
	Eteryk i luminescent świecą wokół siebie, zastrzyk Glowy daje poświatę, Anti-Glow ją przyciemnia. Flashbang daje krótki biały błysk (a nie dziwny zasięg)."
	items = list(
		/obj/item/flashlight = 2,
		/obj/item/flashlight/seclite = 1,
		/obj/item/gun/energy/disabler = 1,
		/obj/item/screwdriver = 1,
		/obj/item/gun/energy/e_gun/mini = 1,
		/obj/item/clothing/head/hardhat = 1,
		/obj/item/clothing/suit/space/hardsuit/engine = 1,
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
