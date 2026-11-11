/obj/machinery/vending/wardrobe/curator_wardrobe
	contraband = list(/obj/item/book/granter/spell/sexonbutton = 1)

/obj/machinery/vending/wardrobe/cargo_wardrobe
	name = "\improper Mundurownia InPost"
	desc = "Automat z odzieżą roboczą InPostu dla zaopatrzenia."
	icon_state = "cargodrobe"
	product_ads = "Ulepszony styl asystenta! Wybierz swój dziś!;Te szorty są wygodne i łatwe w noszeniu, załatw sobie takie!"
	vend_reply = "Dziękujemy, paczka już w drodze!"
	light_color = LIGHT_COLOR_YELLOW
	products = list(/obj/item/clothing/suit/hooded/wintercoat/cargo = 3,
					/obj/item/clothing/under/rank/cargo/tech = 3,
					/obj/item/clothing/under/rank/cargo/bitrunner = 3, // bitrunning
					/obj/item/clothing/under/plasmaman/bitrunner = 2,
					/obj/item/clothing/head/helmet/space/plasmaman/bitrunner = 2,
					/obj/item/clothing/under/plasmaman/cargo = 3,
					/obj/item/clothing/head/helmet/space/plasmaman/cargo = 3,
					/obj/item/clothing/shoes/sneakers/black = 3,
					/obj/item/clothing/gloves/fingerless = 3,
					/obj/item/clothing/head/soft/cargo = 3,
					/obj/item/clothing/head/beret/supply = 3,
					/obj/item/storage/backpack/inpost = 3,
					/obj/item/storage/backpack/satchel/inpost = 3,
					/obj/item/storage/backpack/duffelbag/inpost = 3,
					/obj/item/radio/headset/headset_cargo = 3,
					/obj/item/clothing/head/mailman = 2,
					/obj/item/clothing/under/misc/mailman = 2,
					/obj/item/storage/bag/mail = 2,
					/obj/item/clothing/under/plasmaman/mailman = 2,
					/obj/item/clothing/head/helmet/space/plasmaman/mailman = 2)
	premium = list (/obj/item/clothing/under/rank/cargo/miner = 3)
