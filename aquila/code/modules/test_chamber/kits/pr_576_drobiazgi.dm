// Zbiorczy PR z 7.11: noc i konsola kapitana, mapy w głosowaniu, sprint, stosy, guzik notatek, alarm pożarowy, mruganie

/datum/test_chamber_kit/pr_576
	name = "PR 576: drobiazgi z 7.11"
	pr = "aq33/AquilaStation#576"
	description = "1) Zaloguj się zapasową kartą kapitana w konsoli komunikacji i kliknij „Wyłącz oświetlenie nocne” → oczekiwane: ogłoszenie, światła w pełnej jasności także w nocy (admin: Secrets → noc), drugi klik przywraca automat. Zegar stacji startuje o 7:00, noc trwa 19:30-7:00. 	2) Z combat mode (w starym trybie: na intencji harm) biegnij sprintem (Shift w trybie biegu) na drugiego człowieka i kliknij guzik „leż” (albo jego klawisz) → oczekiwane: rzut do 3 kratek w kierunku biegu; trafiony człowiek leży 3 s, ty 1 s; pudło to 1,5 s na ziemi. Bez sprintu albo bez combat mode guzik zwyczajnie kładzie postać. Kliknięcia w świecie w trakcie sprintu działają po staremu (bez rzutu), w obu trybach sterowania. 	3) Wbiegnij sprintem w człowieka 4 kratki na wschód (stoi w combat mode) → oczekiwane: przewracasz się jak na ścianie, on stoi. Po wyłączeniu mu combat mode zwykłe przepchnięcie. 	4) Weź stos żelaza do ręki i włóż do plecaka → oczekiwane: biała liczba sztuk w rogu ikony, w ręce i w otwartym plecaku (siatka i zwykły schowek, np. pudełko); na podłodze jej nie ma; po zużyciu liczba maleje. Ikony na siatce plecaka są ostre (bez skalowania, plecak ma dawny rozmiar). E/Q w trakcie przeciągania obraca tylko podgląd. 	5) Guzik notatek w prawym dolnym rogu HUD-u (obok języków) → oczekiwane: okno Notatki; ikona zmienia się ze stylem HUD-u. 	6) Kliknij alarm pożarowy → oczekiwane: pętla dźwięku z tg (głośniejsza niż w pierwszej wersji), reset (drugi klik) ją wycisza. 	7) Popatrz na ludzi → oczekiwane: mrugają co ok. 5 s; nieprzytomny (np. sen) ma zamknięte oczy. 	Poza komorą: naukowiec ma w plecaku neutralizator anomalii; w głosowaniu na mapę są Shrike, Von Neumann i Atlantis (od 20 graczy), z rozmiarem w nawiasie; w prawie kosmicznym (PDA, GenPop) jest wykroczenie „Załatwianie potrzeby w miejscu publicznym”."
	items = list(
		/obj/machinery/computer/communications = 1,
		/obj/item/card/id/captains_spare = 1,
		/obj/item/stack/sheet/iron/fifty = 1,
		/obj/item/storage/backpack = 1,
		/obj/machinery/firealarm = 1,
		/obj/item/anomaly_neutralizer = 1,
		/obj/item/gun/energy/disabler = 1,
		/mob/living/carbon/human = 2,
	)

/datum/test_chamber_kit/pr_576/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/list/humans = list()
	for(var/mob/living/carbon/human/person in spawned)
		humans += person
	if(!length(humans))
		return
	// Pierwszy stoi 4 kratki na wschód w combat mode (cel do wbiegnięcia), drugi zostaje do rzutu
	var/mob/living/carbon/human/braced = humans[1]
	var/turf/east_turf = locate(center.x + 4, center.y, center.z)
	if(east_turf && istype(east_turf.loc, /area/test_chamber/arena))
		braced.forceMove(east_turf)
	braced.set_combat_mode(TRUE)
