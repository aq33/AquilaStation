// aq33/AquilaStation#655 - rasa Grod (port BeeStation/BeeStation-Hornet#7202)

/datum/test_chamber_kit/pr_655_grod
	name = "PR 655: rasa Grod"
	pr = "aq33/AquilaStation#655"
	description = "Dwa Grody, człowiek do przejęcia i ubrania do sprawdzenia. \
	1) Wejdź w Groda (admin: Aghost → posiądź): korona na głowie, ogon, wzory; załóż szary kombinezon (szara kamizelka Groda), buty, rękawice i cylinder (zasłania koronę). \
	Skafander EVA i kask nie wchodzą. Plecak, pas, słuchawki i maska wchodzą. \
	2) Cztery ręce: w HUD-zie nad zwykłymi dłońmi są dwie górne; przełącz dłoń (X albo klik w slot), weź w nie długopis i skrzynkę i użyj ich. Chód: z boku ruszają się ręce i ciało, z przodu i z tyłu tylko ręce. \
	3) Akcja „Odłącz koronę”: wychodzisz jako pająk-korona, ciało umiera. Wyjmij mózg człowiekowi (piła) i kliknij go pająkiem: po 5 s przejmujesz ciało, które staje się Grodem. \
	4) Drugiego Groda podnieś po odłączeniu korony i załóż pająka na głowę. 5) Okno postaci: rasa Grod, korona, wzory z kolorem, ogon; imię z przycisku losowania (Eta'Thra Boski). \
	6) Mów w języku Poh'lan (,c) i krzyknij."
	items = list(
		/mob/living/carbon/human/species/grod = 2,
		/mob/living/carbon/human = 1,
		/obj/item/clothing/under/color/grey = 2,
		/obj/item/clothing/shoes/sneakers/black = 1,
		/obj/item/clothing/gloves/color/black = 1,
		/obj/item/clothing/head/grodhat = 1,
		/obj/item/clothing/suit/space/eva = 1,
		/obj/item/clothing/head/hardhat = 1,
		/obj/item/storage/backpack = 1,
		/obj/item/clothing/mask/gas = 1,
		/obj/item/pen = 2,
		/obj/item/storage/toolbox/mechanical = 1,
		/obj/item/circular_saw = 1,
	)
