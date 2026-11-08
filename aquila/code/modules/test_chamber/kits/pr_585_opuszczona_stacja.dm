/datum/test_chamber_kit/pr_585
	name = "Misja Opuszczona stacja i wybór kolejnej misji"
	pr = "aq33/AquilaStation#585"
	description = "Zestaw: konsola łączności i zapasowa karta kapitana. Na serwerze (nie w CI) zestaw pyta, czy dodać misję Opuszczona stacja z wybranym celem, a potem czy otworzyć wybór kolejnej misji. \
	1) Opuszczona stacja: po dodaniu misji w logach admina „wnętrze stacji gotowe na poziomie Z …”, w odprawie (konsola łączności, Status misji) tekst celu, system i nagroda. Na overmapie w tym systemie szara opuszczona stacja. Prom desantowy albo myśliwiec z napędem FTL i komputerem dokowania w trybie dokowania wlatuje w stację → oczekiwane: pojawia się w kosmosie obok ruiny z pokojami i korytarzami w jednym z motywów (opuszczona, blob, ksenomorfy, netherworld, Ratvar). Zwykły myśliwiec bez FTL się nie dokuje (negatyw, tak samo jak przy abordażu stacji). \
	2) Cele (wybór przy dodawaniu): czarna skrzynka (GPS „CZARNA SKRZYNKA”) użyta w dłoni na mostku statku → balon, ogłoszenie z kwotą i misja WYKONANE; artefakt dowieziony na statek → wykonane; likwidacja jądrowa → raport Centrali z kodem, bomba spada kapsułą na stacji, dysk leży gdzie indziej, po uzbrojeniu i wybuchu wszyscy na poziomie stacji giną, misja wykonana, a uzbrojona bomba zabrana z poziomu stacji się rozbraja (negatyw); VIP dowieziony żywy i przytomny na statek → wykonane, martwy VIP bez gracza → NIEUDANE; zabójstwo → wykonane po śmierci celu. VIP i cel zabójstwa to role dla duchów (Nawiedź / spawner). \
	3) Kolejna misja: po wykonaniu wszystkich celów głosowanie „dodatkowe cele” (albo zgoda w zestawie) → ogłoszenie o wyborze, w konsoli kartą kapitana lista misji z losowania (także Opuszczona stacja; bez Armady, podboju galaktyki i szturmu na Dolos) i „Atak na Rubikon”, jeśli są tam wrogowie. Wybór misji → nowa odprawa z jej celami, po jej wykonaniu znów głosowanie. Wybór Rubikonu → cel oczyszczenia Rubikonu, po nim powrót do domu. Bez karty kapitana nie da się wybrać (negatyw). Bez wyboru po 5 minutach dowództwo przydziela cele po staremu."
	items = list(
		/obj/machinery/computer/communications = 1,
		/obj/item/card/id/captains_spare = 1,
	)

/datum/test_chamber_kit/pr_585/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
#ifndef UNIT_TESTS
	var/datum/controller/subsystem/overmap_mode/omode = SSovermap_mode
	if(!user || !omode.mode || omode.mission_choice_pending || omode.extension_choice_pending)
		return
	if(tgui_alert(user, "Dodać misję Opuszczona stacja do obecnych celów statku? Stacja pojawi się w systemie sektora 2.", "Komora testowa", list("Tak", "Nie")) == "Tak")
		var/static/list/objective_names = list(
			"Czarna skrzynka" = /datum/orbital_objective/recover_blackbox,
			"Artefakt obcych" = /datum/orbital_objective/artifact,
			"Likwidacja jądrowa" = /datum/orbital_objective/nuclear_bomb,
			"Ewakuacja VIP-a" = /datum/orbital_objective/vip_recovery,
			"Zabójstwo" = /datum/orbital_objective/assassination,
		)
		var/picked = tgui_input_list(user, "Cel na stacji", "Komora testowa", objective_names)
		if(picked)
			var/datum/overmap_objective/derelict_ruin/mission = new(null, objective_names[picked])
			omode.mode.objectives += mission
			mission.objective_number = length(omode.mode.objectives)
			mission.instance()
			to_chat(user, span_notice("Dodano misję Opuszczona stacja ([picked]) w systemie [mission.target_system]. Generator buduje wnętrze w tle."))
	if(tgui_alert(user, "Otworzyć wybór kolejnej misji (jak po wykonaniu misji i głosowaniu za dodatkowymi celami)? Obecne cele przestaną się liczyć.", "Komora testowa", list("Tak", "Nie")) == "Tak")
		omode.round_extended = TRUE
		omode.request_additional_objectives()
		omode.objectives_completed = FALSE
		if(omode.extension_choice_pending)
			to_chat(user, span_notice("Wybór kolejnej misji otwarty: konsola łączności, Status misji, karta kapitana."))
#endif
