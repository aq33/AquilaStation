/datum/test_chamber_kit/pr_444
	name = "Rewolucja, zegary, marskość"
	pr = "aq33/AquilaStation#444"
	description = "Zestaw robi z ciebie przywódcę rewolucji, jeśli jesteś żywym człowiekiem (inaczej nadaj sobie rolę w Panelu antagów). Na jednym z pól areny stoi goła ściana pod ramę zegara. \
		1) Sprawdź pasek akcji i ekwipunek → oczekiwane: jest zdolność „Nawrócenie rewolucyjne”, flesza nie ma. \
		2) Użyj zdolności na człowieku bez gracza (z zestawu) → oczekiwane: komunikat, że ten umysł jest pusty, brak konwersji (cel musi mieć klienta). \
		3) Wymaga drugiego gracza: użyj zdolności na nim z odległości do 3 kratek → oczekiwane: 3 zdania co ok. 3 s, cel ogłuszony i milczy, na końcu jest rewolucjonistą. \
		4) Powtórz i w trakcie odejdź dalej niż 3 kratki albo ruszaj się → oczekiwane: „Konwersja się nie udała”. Uderz drugiego gracza i od razu użyj zdolności → oczekiwane: cel zaatakowany przed chwilą nie da się przekonać. \
		5) Weź kartę kapitana i użyj konsoli komunikacyjnej do wezwania promu, gdy rewolucja trwa → oczekiwane: prom się wzywa, w losowym momencie od 2:30 przychodzi ogłoszenie, ETA 10 min i blokada odwołania. \
		6) W tej konsoli ustaw na wyświetlaczu krótki i długi komunikat z polskimi literami → oczekiwane: długi przewija się płynnie, Ń, Ś i Ż są pokazane jako N, S i Z. \
		7) Zegar: kliknij ramą z zestawu w ścianę areny → oczekiwane: powstaje zegar z czasem pokładowym; potem odkręć kluczem istniejący zegar → oczekiwane: wraca do ramy. Emag losuje cyfry, multitool resetuje, spawarka naprawia. \
		8) Marskość: użyj autosurgeona z wątrobą (70%) i zbadaj się analizatorem zdrowia → oczekiwane: wynik pokazuje marskość. Wypij whisky i absynt → oczekiwane: szkody wątroby rosną szybciej, od 60% mdłości, świąd i wymioty. \
		9) Menu kołowe: weź skrzynkę z narzędziami do jednej ręki (druga pusta) i kliknij dowolny przedmiot → oczekiwane: ikony menu są nad trzymanymi przedmiotami, HUD-em i paskami postępu."
	items = list(
		/obj/machinery/digital_clock = 1,
		/obj/item/wallframe/digital_clock = 1,
		/obj/item/multitool = 1,
		/obj/item/card/emag = 1,
		/obj/item/card/id/captains_spare = 1,
		/obj/machinery/status_display/evac = 1,
		/obj/machinery/computer/communications = 1,
		/obj/item/reagent_containers/food/drinks/bottle/whiskey = 2,
		/obj/item/reagent_containers/food/drinks/bottle/absinthe = 1,
		/obj/item/reagent_containers/food/drinks/beer = 4,
		/obj/item/healthanalyzer = 1,
		/obj/item/autosurgeon/cirrhosis_test = 1,
		/obj/item/storage/toolbox/mechanical = 1,
		/mob/living/carbon/human = 2
	)

/datum/test_chamber_kit/pr_444/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	// Ściana pod ramę zegara, na wolnym polu za przedmiotami z zestawu
	var/turf/wall_turf = turfs[min(length(items) + 1, length(turfs))]
	wall_turf.PlaceOnTop(/turf/closed/wall)
	// Admin-człowiek zostaje przywódcą rewolucji, żeby od razu mieć zdolność nawracania
	var/mob/living/carbon/human/admin_body = user
	if(!istype(admin_body) || !admin_body.mind)
		to_chat(user, "<span class='warning'>Nie jesteś żywym człowiekiem, więc nie dostałeś roli przywódcy rewolucji. Nadaj ją sobie lub komuś w Panelu antagów.</span>")
		return
	if(!admin_body.mind.has_antag_datum(/datum/antagonist/rev/head))
		admin_body.mind.make_Rev()

/obj/item/organ/liver/cirrhosis_test
	cirrhosis = 70

/obj/item/autosurgeon/cirrhosis_test
	uses = 1
	starting_organ = list(/obj/item/organ/liver/cirrhosis_test)
