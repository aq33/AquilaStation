// aq33/AquilaStation#725 - rozwój antagonistów z odpowiedników w innych kodach

/datum/test_chamber_kit/pr_725_ewakuacja_forma
	name = "Antagoniści: ewakuacja i prawdziwa forma"
	pr = "aq33/AquilaStation#725"
	description = "1) Daj sobie zdrajcę albo zmiennokształtnego (panel zdrajców). Raca ewakuacyjna admina otwiera portal po 5 s. W VV ustaw jej extractable_areas na bieżący obszar, odpal z ręki: kanał ochrony dostaje komunikat, po 5 s portal, wejście = ucieczka (cel „ucieczka” zaliczony w raporcie). Drugą postacią zgaś racę kliknięciem albo ją rozbij. Obcy w portalu zostaje wyrzucony z paraliżem. \
	2) Zmiennokształtny: moc „Masa ewakuacyjna” (raz na rundę, po 60 min albo z SSticker.round_start_time cofniętym w VV). \
	3) Zmiennokształtny: kup w Emporium „Prawdziwa forma”, miej 30+ chemikaliów, coś w rękach i kieszeni, załóż kajdanki. Po 3 s plugastwo (kajdanki pękają). Lewy klik bije, prawy (na intencji rozbrajania) powala, wytrąca albo odcina kończynę. Pożarcie ciągniętego człowieka, wrzask, powrót do ludzkiej postaci z ekwipunkiem na miejscu. Poniżej 30 chemikaliów powrót kończy się omdleniem. Sprawdź oba tryby sterowania."
	items = list(
		/obj/item/aquila_exfiltration_flare/admin = 1,
		/obj/item/aquila_exfiltration_flare = 1,
		/obj/item/restraints/handcuffs = 1,
		/mob/living/simple_animal/hostile/changeling_true_form = 1,
	)

/datum/test_chamber_kit/pr_725_si_porywacz_obcy
	name = "Antagoniści: moduły SI, porywacz, żywica, horror"
	pr = "aq33/AquilaStation#725"
	description = "1) Zostań SI, daj sobie zbuntowaną SI, dodaj moc obliczeniową (VV malf_picker.processing_time) i kup trzy nowe moduły. Zdjęcie zabezpieczeń: klik przez kamery w szafkę albo automat (konsola IFF i prom ewakuacyjny odmawiają). Zakłócenie interkomów: człowiek przy włączonym interkomie drży, w nausznikach nie. Zmiana głosu: wpisz „Kapitan” i mów przez radio. \
	2) Porywacz: gruczoły (dostęp, krew, kwantowy, przemiana) wszczep i aktywuj w VV (activate()). Promień zmniejszający (tylko dla porywaczy): cel maleje na 9 s, da się po nim przejść. Omninarzędzie: menu narzędzi w ręce, prawym przyciskiem (na intencji rozbrajania) zmiana zestawu. \
	3) Drzwi z żywicy: obcy przechodzi, człowiek nie. Dron obcych ma je w „Wydziel żywicę”. \
	4) Horror: wejdź w nosiciela, wstrzyknij mu np. spaceacylinę, użyj „Nauka z krwi”, potem „Wydziel chemikalia”."
	items = list(
		/obj/item/radio/intercom = 1,
		/obj/item/clothing/ears/earmuffs = 1,
		/obj/structure/closet/secure_closet = 1,
		/obj/machinery/vending/cola = 1,
		/obj/item/organ/heart/gland/access = 1,
		/obj/item/organ/heart/gland/blood = 1,
		/obj/item/organ/heart/gland/quantum = 1,
		/obj/item/organ/heart/gland/pop = 1,
		/obj/item/gun/energy/shrink_ray = 1,
		/obj/item/abductor/alien_omnitool = 1,
		/obj/structure/alien/resin/door = 1,
		/mob/living/simple_animal/horror = 1,
	)

/datum/test_chamber_kit/pr_725_rojowce_szpieg_rewolucja
	name = "Antagoniści: rojowce, szpieg, rewolucja, piraci"
	pr = "aq33/AquilaStation#725"
	description = "1) Wejdź w skorupę rojowca jako duch: rola „Rojowiec” z celem. Spróbuj rozebrać konsolę sterów, silnik, torpedę i worek prochu: odmawia. W VV ustaw zespołowi rojowców collected = 250, sobie resources = 100, na wolnym polu 3x3 kliknij przycisk przekaźnika: po 15 s przekaźnik, ogłoszenie i GPS. Zniszcz go albo wywołaj broadcast(). Poza komorą: event „Spawn Swarmer Shell” stawia skorupę w technicznych albo w ładowni. \
	2) Szpieg: aparatem zrób zdjęcie osoby ze zlecenia „Zdjęcie: …” i przyłóż je do uplinku (albo kliknij zdjęcie uplinkiem prawym przyciskiem, na intencji rozbrajania). \
	3) Rewolucja: skuj szefa i zostaw w brygu albo przy przytomnym rewolucjoniście, zakończ rundę: cel buntu zaliczony. \
	4) Poza komorą: event „Space Pirates”, odrzuć okup. Na DRADIS pojawia się piracki rajder: zniszcz go, ucieknij skokiem albo daj mu podlecieć (wtedy przybija prom z piratami)."
	items = list(
		/obj/effect/mob_spawn/swarmer = 1,
		/obj/machinery/computer/ship/helm = 1,
		/obj/item/ship_weapon/ammunition/torpedo = 1,
		/obj/item/powder_bag = 1,
		/obj/item/stack/sheet/iron/fifty = 1,
		/obj/item/camera = 1,
		/obj/item/restraints/handcuffs = 1,
	)
