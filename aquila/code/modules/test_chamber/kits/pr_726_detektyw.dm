// aq33/AquilaStation#726 - Detektyw, część 3 planu Żandarmerii (aquila/code/modules/detectivework/)

/datum/test_chamber_kit/pr_726_detektyw
	name = "PR 726: narzędzia detektywa"
	pr = "aq33/AquilaStation#726"
	description = "1) Dotknij długopisu i zeskanuj go skanerem: przy odcisku jest wiek śladu. 2) Prawym przyciskiem mydłem na długopisie (12 s): odciski znikają, skaner pokazuje ślady mydła. 3) Rozlej krew (strzykawka z krwią), zmyj ją środkiem czyszczącym i włącz lampę UV obok: ślad świeci, gdy lampa jest blisko. 4) Załóż fedorę jako detektyw (ustaw rolę w panelu admina) i włącz tryb noir: świat szary, krew i łuski na czerwono. 5) BloodTrakiem dotknij świeżej plamy krwi: wskazuje właściciela, po zaschnięciu krwi już nie. 6) Załóż okulary śledcze i poproś kogoś o oględziny przedmiotu. 7) Etui-pluskwę włóż do kieszeni, ustaw częstotliwość, nastaw radio na tę samą i mów obok pluskwy. 8) Alkomat na kimś po piwie."
	items = list(
		/obj/item/detective_scanner = 1,
		/obj/item/pen = 2,
		/obj/item/soap = 1,
		/obj/item/reagent_containers/glass/rag = 1,
		/obj/item/reagent_containers/spray/cleaner = 1,
		/obj/item/aq_uv_light = 1,
		/obj/item/clothing/head/fedora/det_hat = 1,
		/obj/item/pinpointer/aq_bloodtrak = 1,
		/obj/item/clothing/glasses/hud/security/sunglasses/aq_investigation = 1,
		/obj/item/storage/box/rxglasses/spyglasskit = 1,
		/obj/item/radio = 1,
		/obj/item/radio/aq_bug_mic/cigarettes = 1,
		/obj/item/aq_breathalyzer = 1,
		/obj/item/reagent_containers/food/drinks/beer = 2,
		/obj/item/ammo_casing/c38 = 2,
	)
