// aq33/AquilaStation#598 - ciecze z Monkestation, lód, zimno w próżni, pęcherz i mocz, cenzura, zatykające się ubikacje

/datum/test_chamber_kit/pr_598
	name = "PR 598: ciecze, lód, mocz, ubikacje"
	pr = "aq33/AquilaStation#598"
	description = "Wiadra mają po 70 j. wody, zlewki po 30 j., zlewka bluespace 150 j. paliwa. Manekin „test lodu” stoi w głębokiej, lodowatej wodzie, a ubikacja jest zatkana i ma zawartość. Tobie (jeśli jesteś człowiekiem) zestaw dolewa wypitej wody, więc masz mocz. \
	1) Próg: wylej jedną zlewkę (30 j.) na podłogę w combat mode → oczekiwane: zwykła mokra podłoga, bez kałuży. Wylej drugą zlewkę na ten sam kafel → kałuża (razem 60 j.). Wylej wiadro (70 j.) na czysty kafel → od razu kałuża. Examine kafla pokazuje poziom i skład. \
	2) Poślizg: na mokrej podłodze i w kałuży idź i biegnij bez sprintu → bez poślizgu; sprintem → poślizg. Lubrykant i lód ślizgają jak dotąd. \
	3) Sprzątanie: mop na kałuży wsiąka po 5 j. (coraz szybciej), pełny mop wyciśnij do wiadra prawym przyciskiem (w starym trybie na intencji rozbrajania). Pusta zlewka poza combat mode nabiera ciecz z kałuży. Nadajnik pompy (w dłoni) zrzuca pompę z kluczem: przykręć, włącz klikiem, Alt-klik przełącza wysysanie i wylewanie. Zestaw odpływu połóż na podłodze i przykręć kluczem: odpływ sam spuszcza kałużę, spawarką da się go zaspawać. \
	4) Ogień: wylej paliwo ze zlewki bluespace (combat mode) i podpal zapalniczką → kałuża płonie, przy dużym ogniu rozchodzi się po plamie, dym, kałuża się wypala. \
	5) Lód: woda pod manekinem zamarza od razu (examine: lód), a po chwili w bloku lodu jest uwięziony manekin (examine bloku pokazuje, kto jest w środku). Przejmij manekina (admin: Possess) i opieraj się (resist) ok. 20 s → wybija się. Albo rozbij blok, stop go spawarką lub ogniem → wypada manekin, a woda wraca jako kałuża. \
	6) Zimno w próżni: odessij pomieszczenie (np. otwórz śluzę na kosmos albo wyssij gaz VV) → skaner atmosu na odessanym kafelku pokazuje ok. 2,7 K, mokra podłoga i woda zamarzają. Po napełnieniu temperatura wraca. \
	7) Mocz (wymaga SHITTING_ENABLED): *piss na podłodze → plama albo kałuża moczu; z pustą zlewką w ręce → mocz do zlewki; na ubikacji → do muszli. Sikanie przy działającej kamerze → wpis „Publiczne oddawanie moczu” i status Poszukiwany w kartotece. Ustaw sobie VV defecation ponad 200 przy dużym urination → popuszczenie oddaje tylko mocz; przy małym urination → tylko kał. Alert wypróżnienia na miejscu oddaje obie części. \
	8) Ubikacja: spłucz ją prawym przyciskiem → przelewa wodę, mocz i kupę na podłogę. Przepychaczka ją odtyka, potem spłukiwanie działa normalnie. \
	9) Cenzura: w ustawieniach gry (Rozgrywka) włącz „Cenzura wypróżniania” → kupa i plamy moczu wyglądają jak czarny brud, mocz w kałuży w examine to amoniak, cudze wypróżnienia bez komunikatów i dźwięków, własne z łagodnym komunikatem."
	items = list(
		/obj/item/reagent_containers/glass/bucket = 2,
		/obj/item/reagent_containers/glass/beaker = 2,
		/obj/item/reagent_containers/glass/beaker/bluespace = 1,
		/obj/item/mop = 1,
		/obj/item/lighter = 1,
		/obj/item/plunger = 1,
		/obj/item/weldingtool = 1,
		/obj/item/wrench = 1,
		/obj/item/liquid_pump_beacon = 1,
		/obj/item/drain_kit = 1,
		/obj/structure/toilet = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_598/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	for(var/obj/item/reagent_containers/glass/bucket/bucket in spawned)
		bucket.reagents.add_reagent(/datum/reagent/water, 70)
	for(var/obj/item/reagent_containers/glass/beaker/beaker in spawned)
		if(istype(beaker, /obj/item/reagent_containers/glass/beaker/bluespace))
			beaker.reagents.add_reagent(/datum/reagent/fuel, 150)
		else
			beaker.reagents.add_reagent(/datum/reagent/water, 30)
	for(var/obj/structure/toilet/toilet in spawned)
		toilet.open = TRUE
		toilet.update_icon()
		toilet.clogged = TRUE
		toilet.receive_waste(20, 1)
	for(var/mob/living/carbon/human/dummy in spawned)
		dummy.name = "test lodu"
		dummy.real_name = dummy.name
		var/turf/open/ice_turf = turfs[length(turfs)]
		dummy.forceMove(ice_turf)
		ice_turf.add_liquid(/datum/reagent/water, LIQUID_ICE_BLOCK_VOLUME + 60, chem_temp = T0C - 30)
	var/mob/living/carbon/human/H = user
	if(istype(H))
		H.adjust_hydration(400)
	if(user && !CONFIG_GET(flag/shitting_enabled))
		to_chat(user, span_warning("SHITTING_ENABLED jest wyłączone w configu: pęcherz, mocz i popuszczanie nie działają, reszta zestawu tak."))
