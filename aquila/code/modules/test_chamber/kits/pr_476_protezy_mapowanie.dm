// aq33/AquilaStation#476 - przedmiot jako proteza ręki (tg#91573), wypadające organy (tg#98023), SDSM-35 (tg#94761), cel mapowania stacji

/datum/test_chamber_kit/pr_476
	name = "PR 476: protezy z przedmiotów i organy"
	pr = "aq33/AquilaStation#476"
	description = "Weź też \"Króliki doświadczalne\". Pacjentowi utnij rękę (amputacja), potem operacja protezy: nacięcie, zaciski, rozwarcie i przyłóż gaśnicę albo pizzę. \
	Bez szwu przedmiot odpada przy pierwszym ciosie; po kroku z nićmi/taśmą trzyma się. Piła łańcuchowa nadal daje starą zamontowaną piłę. \
	Organy: zacznij manipulację organami na klatce, po piłowaniu postaw pacjenta i każ mu biegać - pojawi się alert i co jakiś czas wypadnie organ. Chodzenie i leżenie są bezpieczne. \
	SDSM-35: otwórz książkę, sprawdź spis treści i strony."
	items = list(
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
	description = "Robi z ciebie zdrajcę z celem mapowania (trzeba być człowiekiem w komorze). Pomieszczenia to arena i, jeśli stoisz poza nią, część komory, w której stoisz. \
	Użyj skanera w ręce, żeby go zamocować; skan trwa 3 minuty, skaner co 20 s cicho piszczy. Odczepienie ręką przerywa skan. \
	Po skanie pierwszego pomieszczenia skaner sam się odczepia - przenieś go do drugiego. Po ostatnim się rozpada i cel jest wykonany."

/datum/test_chamber_kit/pr_476_mapping/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H) || !H.mind)
		to_chat(user, "<span class='warning'>Musisz być człowiekiem w komorze, żeby zostać zdrajcą.</span>")
		return
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
