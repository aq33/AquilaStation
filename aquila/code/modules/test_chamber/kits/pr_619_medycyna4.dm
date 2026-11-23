/datum/test_chamber_kit/pr_619
	name = "PR 619: czaszka, krwawienie per kończyna, ból i adrenalina, kręgosłup, nakładki"
	pr = "aq33/AquilaStation#619"
	description = "Obok leżą trzej ranni: „Czaszka” (pęknięta czaszka), „Krwawiący” (krwawi lewa noga i prawa ręka) i „Kręgosłup” (złamany kręgosłup, leży na łóżku na kółkach). \
	1) Czaszka: głowa „Czaszki” jest wygięta jak przy rozłupanej czaszce (mapa przesunięcia). Skaner: „Pęknięta czaszka” i dopisek o urazach mózgu; po chwili w skanerze widać lekki uraz mózgu. \
	2) Krwawienie: zbadaj „Krwawiącego” (examine): „Krew cieknie (lewa noga)” i „Krew cieknie (prawa ręka)”. Skaner pokazuje krwawienie per kończyna. Bandaż na prawą rękę zatrzymuje tylko rękę, na ręce widać bandaż; noga dalej krwawi. Bandaż na zdrową część ciała: komunikat, która kończyna krwawi. Opaska uciskowa na lewą nogę zatrzymuje tylko nogę. Utnij komuś rękę (piła na otwartej ręce albo VV): kikut krwawi, widać kikut, bandaż na kikut go opatruje. \
	3) Ból: weź obrażenia (np. uderz się kilka razy). Komunikaty o najbardziej bolącej kończynie, czerwona winieta rośnie z bólem, przy silnym bólu rozmycie, spowolnienie od bólu (nie od obrażeń), wolniejsza regeneracja staminy. Medipen z morfiną zdejmuje ból i spowolnienie. Przy silnym bólu nadnercza same wyrzucają adrenalinę, czyli epinefrynę („Serce wali jak młot”), po kilku razach rezerwa się kończy (skaner: Rezerwa nadnerczy). \
	4) Adrenalina: autostrzykawka z zestawu przetrwania (czerwono-żółty pasek) tłumi ból, po wygaśnięciu „Adrenalina opada” i zmęczenie. Druga i trzecia dawka pod rząd działa słabiej (skaner: tolerancja). Adrenalina to epinefryna: zwykły medipen z epinefryną tłumi ból tak samo, osobnego reagentu ani receptury nie ma. \
	5) Kręgosłup: „Kręgosłup” ma sparaliżowane nogi, nogi nie bolą. Operacja: przygotuj klatkę (serweta), natnij, rozewrzyj, zaciśnij naczynia, potem nastawiacz kości (stabilizacja kręgosłupa, widać gorset), potem żel kostny (zespolenie kręgów). Nerwy odrastają kilka minut, z mannitolem dwa razy szybciej; potem nogi działają. \
	6) Nakładki: szyna na złamanej nodze po opatrzeniu bandażem, otwarta czaszka przy operacji mózgu (piła na głowie). \
	Sprawdź klikanie bandażem i opaską w obu trybach sterowania (combat mode i intencje)."
	items = list(
		/obj/item/stack/medical/bandage = 2,
		/obj/item/tourniquet = 1,
		/obj/item/reagent_containers/hypospray/medipen/aq_adrenaline = 3,
		/obj/item/reagent_containers/hypospray/medipen/morphine = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/storage/backpack/duffelbag/med/surgery = 1,
		/obj/item/bonesetter = 1,
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/surgical_drapes = 1,
		/obj/item/reagent_containers/glass/bottle/mannitol = 1,
		/obj/item/reagent_containers/glass/bottle/epinephrine = 1,
		/obj/item/reagent_containers/food/condiment/sugar = 1,
		/obj/item/reagent_containers/food/condiment/saltshaker = 1,
		/obj/item/reagent_containers/glass/beaker/large = 1,
		/obj/item/storage/box/survival = 1,
	)

/datum/test_chamber_kit/pr_619/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/turf/drop = turfs[min(length(items) + 1, length(turfs))]

	var/mob/living/carbon/human/skull = new(drop)
	skull.real_name = "Czaszka"
	skull.name = skull.real_name
	var/datum/wound/blunt/fracture/crack = new()
	crack.apply_wound(skull.get_bodypart(BODY_ZONE_HEAD), silent = TRUE)

	var/mob/living/carbon/human/bleeder = new(drop)
	bleeder.real_name = "Krwawiący"
	bleeder.name = bleeder.real_name
	bleeder.add_bleeding(BLEED_CUT, BODY_ZONE_L_LEG)
	bleeder.add_bleeding(BLEED_SURFACE, BODY_ZONE_R_ARM)
	var/datum/wound/blunt/fracture/leg_fracture = new()
	leg_fracture.apply_wound(bleeder.get_bodypart(BODY_ZONE_R_LEG), silent = TRUE)

	var/obj/structure/bed/roller/bed = new(drop)
	var/mob/living/carbon/human/spine = new(drop)
	spine.real_name = "Kręgosłup"
	spine.name = spine.real_name
	spine.aq_break_spine()
	bed.buckle_mob(spine, force = TRUE)
