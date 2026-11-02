// aq33/AquilaStation#476 - przedmiot jako proteza ręki (tg#91573), wypadające organy (tg#98023), SDSM-35, cel mapowania stacji

/datum/test_chamber_kit/pr_476
	name = "PR 476: protezy z przedmiotów i organy"
	pr = "aq33/AquilaStation#476"
	description = "Pacjent (człowiek bez gracza) leży obok, stół operacyjny i narzędzia chirurgiczne stoją w kąciku chirurgicznym komory. \
		1) Połóż pacjenta na stole i amputuj mu rękę (nacięcie, zaciski, rozwarcie, piła) → oczekiwane: ręka odpada. Potem operacja protezy: nacięcie, zaciski, rozwarcie i przyłóż gaśnicę → oczekiwane: gaśnica staje się ręką, w opisie „Zamiast ręki ma …”, nie da się jej upuścić. \
		2) Bez szwu uderz czymś: przedmiot odpada razem z ręką przy ciosach (80% szans na cios) → oczekiwane: ręka i przedmiot spadają. Powtórz z pizzą i nićmi chirurgicznymi (albo taśmą) w kroku „secure prosthetic” → oczekiwane: po nim przedmiot już nie odpada. \
		3) Negatyw: spróbuj przymocować chainsaw jako protezę → oczekiwane: dostajesz starą zamontowaną piłę z własnym sprite'em, nie ogólną protezę. \
		4) Organy: zacznij operację na klatce piersiowej pacjenta, po piłowaniu postaw pacjenta i każ mu biec (przejmij go jako admin albo poproś drugiego gracza) → oczekiwane: pojawia się alert „Odsłonięte organy”, co jakiś czas wypada organ. Negatyw: chodzenie albo leżenie → oczekiwane: nic nie wypada. \
		5) SDSM-35: otwórz książkę, sprawdź spis treści i strony → oczekiwane: strony się przełączają, są to strony książki."
	items = list(
		/mob/living/carbon/human = 1,
		/obj/item/surgical_drapes = 1,
		/obj/item/scalpel = 1,
		/obj/item/hemostat = 1,
		/obj/item/retractor = 1,
		/obj/item/circular_saw = 1,
		/obj/item/cautery = 1,
		/obj/item/extinguisher = 1,
		/obj/item/food/pizzaslice/margherita = 1,
		/obj/item/chainsaw = 1,
		/obj/item/stack/medical/suture = 1,
		/obj/item/stack/sticky_tape = 1,
		/obj/item/tgui_book/manual/dsm = 1,
	)

/// Makes the user a traitor with a mapping objective in the chamber
/datum/test_chamber_kit/pr_476_mapping
	name = "PR 476: cel mapowania stacji"
	pr = "aq33/AquilaStation#476"
	description = "Robi zdrajcę z celem mapowania: ciebie, jeśli jesteś człowiekiem z mindem, a inaczej człowieka bez gracza obok (skaner leży przy nim, zabierz go). Pomieszczenia to arena i, jeśli stoisz poza nią, część komory, w której stoisz. \
		1) Użyj skanera w ręce, żeby go zamocować w arenie → oczekiwane: skan trwa 3 minuty, skaner co 20 s cicho piszczy. \
		2) Negatyw: odczep skaner ręką w trakcie skanu → oczekiwane: skan się przerywa i zaczyna od zera. Zamocuj go poza celem (np. poza areną, gdy tam nie stoisz) → oczekiwane: skaner przestaje się obracać. \
		3) Dokończ skan pierwszego pomieszczenia → oczekiwane: skaner sam się odczepia, przenieś go do drugiego. Po ostatnim skanie rozpada się i cel jest wykonany."

/datum/test_chamber_kit/pr_476_mapping/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H) || !H.mind)
		if(!user)
			return
		// Admin nie jest człowiekiem z mindem: cel dostaje manekin obok
		H = new /mob/living/carbon/human(turfs[1])
		H.mind_initialize()
		to_chat(user, "<span class='warning'>Nie jesteś człowiekiem z mindem, więc zdrajcą został człowiek bez gracza obok (skaner ma przy sobie albo leży pod nim).</span>")
	var/datum/antagonist/traitor/traitor = H.mind.has_antag_datum(/datum/antagonist/traitor)
	if(!traitor)
		traitor = new
		traitor.give_objectives = FALSE
		H.mind.add_antag_datum(traitor)
	var/datum/objective/plant_device/mapping/mapping = new
	mapping.owner = H.mind
	mapping.department_name = "komora testowa"
	mapping.target_areas = list(get_area(center))
	mapping.target_areas |= get_area(H)
	mapping.update_explanation_text()
	mapping.give_device()
	traitor.add_objective(mapping)
	H.mind.announce_objectives()
