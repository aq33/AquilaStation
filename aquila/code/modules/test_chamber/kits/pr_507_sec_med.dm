// Skaner N-spect, Undercover I.D., tagi triage, opaska uciskowa

/datum/test_chamber_kit/pr_507_sec
	name = "PR 507: N-spect i Undercover I.D."
	pr = "aq33/AquilaStation#507"
	description = "N-spect: kliknij pudełko z kontrabandą (wykryto), czyste pudełko (czysto) i torbę przemytnika z kontrabandą w środku (czysto). \
	Łom otwiera klapkę, Ctrl+klik wyjmuje ogniwo. Wadliwy N-spect odwraca wynik. Bramka: tryb Kontrabanda, przejdź z pudełkiem z kontrabandą. \
	Undercover I.D.: sfałszuj kartę (działa bez bycia antagiem), przyłóż do niej kartę kapitana (dostępy nie mają się skopiować), multitool blokuje i odblokowuje przebranie."
	items = list(
		/obj/item/inspector = 1,
		/obj/item/inspector/faulty = 1,
		/obj/machinery/scanner_gate = 1,
		/obj/item/storage/backpack/satchel/flat/empty = 1,
		/obj/item/card/id/syndicate/undercover = 1,
		/obj/item/card/id/captains_spare = 1,
		/obj/item/multitool = 1,
		/obj/item/crowbar = 1,
	)

/datum/test_chamber_kit/pr_507_sec/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/obj/item/storage/box/contraband_box = new(center)
	contraband_box.name = "pudełko z kontrabandą"
	var/obj/item/pen/pen = new(contraband_box)
	pen.mark_contraband()
	var/obj/item/storage/box/clean_box = new(center)
	clean_box.name = "czyste pudełko"
	new /obj/item/pen(clean_box)
	for(var/obj/item/storage/backpack/satchel/flat/smuggler in spawned)
		var/obj/item/pen/hidden_pen = new(smuggler)
		hidden_pen.mark_contraband()

/datum/test_chamber_kit/pr_507_med
	name = "PR 507: triage i opaska uciskowa"
	pr = "aq33/AquilaStation#507"
	description = "Pacjent ma przerwaną tętnicę na lewej nodze. Opaska: wybierz lewą nogę i kliknij pacjenta (2,5 s, na sobie 5 s), krwawienie ma spaść o 90%, noga spowolniona, na ręce wolniejsze akcje, na szyi dusi, \
	skaner i examine pokazują opaskę, examine ma link Zdejmij. Po 3 min kończyna dostaje obrażenia i spowolnienie rośnie, po 8 min zdjęcie daje toksyny. \
	Bez zszycia rany zdjęta opaska puszcza krwawienie z powrotem. Triage: przyklej tag z bloczka (pudełko), tagger w ręce wybiera kategorię albo zdejmowanie."
	items = list(
		/obj/item/tourniquet = 2,
		/obj/item/storage/box/triage = 1,
		/obj/item/triage_tagger = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/stack/medical/suture = 1,
		/obj/item/pen = 1,
	)

/datum/test_chamber_kit/pr_507_med/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/mob/living/carbon/human/patient = new(center)
	patient.real_name = "Pacjent z tętnicą"
	patient.name = patient.real_name
	var/datum/wound/slash/artery/artery = new()
	artery.apply_wound(patient.get_bodypart(BODY_ZONE_L_LEG), silent = TRUE)
