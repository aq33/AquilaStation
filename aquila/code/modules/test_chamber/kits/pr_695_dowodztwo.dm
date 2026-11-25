// aq33/AquilaStation#695 - resprite dowództwa

/datum/test_chamber_kit/pr_695
	name = "Resprite dowództwa"
	pr = "aq33/AquilaStation#695"
	description = "1) Załóż kolejno mundury Kapitana, Starszego Oficera i Oficera Pokładowego, obróć się we wszystkie strony i podwiń je Alt+klikiem. \
	2) Załóż fikuśną i galową kurtkę kapitana, kurtkę XO, napierśnik, hardsuit kapitana z hełmem, czapki (też oficerską), berety, peleryny i torbę: nowe sprite'y w ekwipunku i na postaci, beret Oficera Pokładowego nie zgniata głowy. \
	3) Karty ID na smyczy i PDA kapitana i XO: sprite w ręce i na postaci, PDA się włącza. \
	4) Szafki Kapitana, Starszego Oficera i mostka: zamknięta, otwarta, animacja drzwi, lampka zamka, zespawanie; pudełka kompresyjne bez spódniczki, korony i brązowych butów, buty wojskowe i kurtka XO obok pudełek; pudełko Komendanta ma oba berety Komendanta i jeden zwykły mundur, peleryna Komendanta nazywa się peleryną. \
	5) Poza komorą: Kapitan, Starszy Oficer i Oficer Pokładowy po wejściu do rundy mają nowe stroje (Kapitan w czapce i napierśniku)."
	items = list(
		/obj/item/clothing/under/rank/captain = 1,
		/obj/item/clothing/under/rank/captain/suit = 1,
		/obj/item/clothing/under/rank/civilian/head_of_personnel = 1,
		/obj/item/clothing/under/ship/officer = 1,
		/obj/item/clothing/suit/ship/officer/xo = 1,
		/obj/item/clothing/suit/captunic = 1,
		/obj/item/clothing/suit/armor/vest/capcarapace = 1,
		/obj/item/clothing/suit/armor/vest/capcarapace/alt = 1,
		/obj/item/clothing/suit/space/hardsuit/swat/captain = 1,
		/obj/item/clothing/head/caphat = 1,
		/obj/item/clothing/head/caphat/parade = 1,
		/obj/item/clothing/head/caphat/officer = 1,
		/obj/item/clothing/head/beret/ship/captain = 1,
		/obj/item/clothing/head/beret/ship/xo = 1,
		/obj/item/clothing/head/hopcap = 1,
		/obj/item/clothing/head/beret/durathread/bridge = 1,
		/obj/item/clothing/gloves/color/captain = 1,
		/obj/item/clothing/neck/cloak/cap = 1,
		/obj/item/clothing/neck/cloak/hop = 1,
		/obj/item/clothing/neck/cloak/cmo = 1,
		/obj/item/storage/backpack/satchel/cap = 1,
		/obj/item/card/id/job/captain = 1,
		/obj/item/card/id/job/head_of_personnel = 1,
		/obj/item/card/id/job/bridge_staff = 1,
		/obj/item/card/id/captains_spare = 1,
		/obj/item/modular_computer/tablet/pda/heads/captain = 1,
		/obj/item/modular_computer/tablet/pda/heads/head_of_personnel = 1,
		/obj/structure/closet/secure_closet/captains = 1,
		/obj/structure/closet/secure_closet/hop = 1,
		/obj/structure/closet/secure_closet/bridge = 1,
		/obj/item/storage/box/suitbox/hos = 1,
		/obj/item/clothing/neck/cloak/hos = 1,
	)
