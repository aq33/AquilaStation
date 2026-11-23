// aq33/AquilaStation#655 - rasa Grod (port BeeStation/BeeStation-Hornet#5442 i BeeStation/BeeStation-Hornet#7202)

/datum/test_chamber_kit/pr_655_grod
	name = "PR 655: rasa Grod"
	pr = "aq33/AquilaStation#655"
	description = "Dwa Grody, człowiek do przejęcia, taca z ziemią i ubrania do sprawdzenia. \
	1) Wejdź w Groda (admin: Aghost → posiądź): korona na głowie, ogon, wzory; załóż szary kombinezon (szara kamizelka Groda), buty, rękawice i cylinder (zasłania koronę). \
	Skafander EVA i kask nie wchodzą. Plecak, pas, słuchawki i maska wchodzą. \
	2) Postawy: Grod zaczyna w postawie ruchu (dwie ręce, szybszy od człowieka). Akcja „Zmień postawę” daje cztery ręce (w HUD-zie dwie górne), ale Grod zwalnia i nie blokuje ciosów. \
	Weź do górnych dłoni długopis i skrzynkę, obracaj się: w każdą stronę rzeczy wiszą w innym miejscu, a tyłem chowają się za ciałem. Powrót do postawy ruchu zrzuca rzeczy z górnych dłoni. \
	3) Akcja „Odłącz koronę”: wychodzisz jako pająk-korona, ciało umiera. Wyjmij mózg człowiekowi (piła) i kliknij go pająkiem: po 5 s wchodzisz w ciało, które choruje i po chwili zasypia w kokonie jako Grod. \
	Kokon rozerwiesz ręką (co trzecia próba) albo przegryziesz od środka (opór). Wsyp ziemię do tacy workiem; drugi pająk-korona kliknięty na tacę zakopuje się w niej i po 2 minutach wyrasta z kokonu w nowym ciele. \
	4) Drugiego Groda podnieś po odłączeniu korony i załóż pająka na głowę. 5) Okno postaci: rasa Grod, korona, wzory z kolorem, ogon; imię z przycisku losowania (Eta'Thra Boski). \
	6) Mów w języku Poh'lan (,c) i krzyknij. 7) Butelka toksyny korony: wstrzyknij człowiekowi, sól kuchenna leczy przemianę. \
	8) Sprite'y z Dysku twórczyni: beret, kask budowlany, kajdanki na Grodzie, krew na kamizelce (pobrudź ją), strąk rosnący w tacy w trzech etapach."
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
		/obj/item/plant_tray = 1,
		/obj/item/substrate_bag/dirt = 1,
		/obj/item/reagent_containers/glass/bottle/grod = 1,
		/obj/item/clothing/head/beret/sci = 1,
		/obj/item/clothing/head/hardhat = 1,
		/obj/item/restraints/handcuffs = 1,
	)
