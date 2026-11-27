// aq33/AquilaStation#720 - eventy z kafli mapy FTL (aquila/code/modules/events/hexmap/, pule w aquila/code/modules/overmap/hexmap/hex_terrain.dm)
// Osiem zestawów, po jednym na etap: każdy kładzie narzędzia do obsługi eventów i po potwierdzeniu odpala wszystkie eventy etapu
// tak, jak robi to wejście okrętu na kafel (bez minuty startu, z minimum graczy). Eventy działają na całym okręcie, nie tylko w komorze.

/datum/test_chamber_kit/pr_720_eventy
	pr = "aq33/AquilaStation#720"
	/// Kontrolki eventów etapu odpalane po zrzuceniu zestawu
	var/list/events = list()

/datum/test_chamber_kit/pr_720_eventy/setup(list/spawned, list/turfs, turf/center, mob/user)
	// Eventy działają na całym okręcie (część zmienia graczy w antagonistów), więc zestaw pyta przed odpaleniem
	if(user && tgui_alert(user, "Odpalić teraz wszystkie eventy etapu na całym okręcie? Część z nich daje role antagonistów albo stwory, a wpływa na wszystkich graczy w rundzie.", "Komora testowa", list("Tak", "Nie")) != "Tak")
		to_chat(user, "<span class='notice'>Eventów nie odpalono, zostały tylko narzędzia.</span>")
		return
	var/list/fired = list()
	var/list/skipped = list()
	for(var/path in events)
		var/datum/round_event_control/control = hex_event_control(path)
		if(!control)
			skipped += "[path]"
			continue
		control.hex_triggered = TRUE
		var/datum/round_event/started = control.runEvent()
		control.hex_triggered = FALSE
		control.occurrences = max(0, control.occurrences - 1) // test w komorze nie zużywa limitu wystąpień eventu w rundzie
		if(started)
			fired += control.name
		else
			skipped += control.name
	if(user)
		to_chat(user, "<span class='notice'>Odpalone eventy: [length(fired) ? jointext(fired, ", ") : "brak"].</span>")
		if(length(skipped))
			to_chat(user, "<span class='warning'>Nie wystartowały: [jointext(skipped, ", ")].</span>")

/datum/test_chamber_kit/pr_720_eventy/e1
	name = "Eventy mapy FTL: E1 wiadomości i komunikaty"
	description = "Odpala 11 eventów: wiadomości w kanale „Wiadomości z Galaktyki”, spam na PDA i faksach, prezent od Nanotrasen w magazynie zaopatrzenia, ankietę Centrali na faksie mostka (wypełnij, podpisz %sign, odeślij do Centrali), premię na budżet, aktualizację komputerów (konsole reaktora i broni nie są blokowane), nowe prawo kosmiczne i burzę Ianów."
	items = list(/obj/item/pen = 1, /obj/item/modular_computer/tablet/pda = 1)
	events = list(
		/datum/round_event_control/aquila_hex_trivial_news,
		/datum/round_event_control/aquila_hex_mundane_news,
		/datum/round_event_control/aquila_hex_news_report,
		/datum/round_event_control/aquila_hex_pda_spam,
		/datum/round_event_control/aquila_hex_fax_spam,
		/datum/round_event_control/aquila_hex_cargo_gifts,
		/datum/round_event_control/aquila_hex_centcom_questionnaire,
		/datum/round_event_control/aquila_hex_money_bonus,
		/datum/round_event_control/aquila_hex_computer_update,
		/datum/round_event_control/aquila_hex_new_space_law,
		/datum/round_event_control/aquila_hex_ian_storm,
	)

/datum/test_chamber_kit/pr_720_eventy/e2
	name = "Eventy mapy FTL: E2 awarie okrętu"
	description = "Odpala 10 awarii: rozregulowane APC, pożar instalacji, blokadę śluz na 90 s (bez prądu, bez zgniatania, otwarte wracają otwarte), wyciek promieniowania (zatkaj narzędziem z opisu), wyciek gazu, pęknięty kanister, zatkany zsyp, skażone pomieszczenie, pylenie roślin i splątanie szafek (szafki z dostępem i bluespace nie są splątane)."
	items = list(/obj/item/clothing/gloves/color/yellow = 1, /obj/item/multitool = 1, /obj/item/weldingtool = 1, /obj/item/wrench = 1, /obj/item/crowbar = 1, /obj/item/clothing/suit/radiation = 1, /obj/item/clothing/mask/gas = 1)
	events = list(
		/datum/round_event_control/aquila_hex_apc_scramble,
		/datum/round_event_control/aquila_hex_electrical_fire,
		/datum/round_event_control/aquila_hex_door_runtime,
		/datum/round_event_control/aquila_hex_radiation_leak,
		/datum/round_event_control/aquila_hex_atmos_leak,
		/datum/round_event_control/aquila_hex_canister_leak,
		/datum/round_event_control/aquila_hex_disposals_clog,
		/datum/round_event_control/aquila_hex_disease_outbreak_floor,
		/datum/round_event_control/aquila_hex_station_incident_hay_fever,
		/datum/round_event_control/aquila_hex_locker_entanglement,
	)

/datum/test_chamber_kit/pr_720_eventy/e3
	name = "Eventy mapy FTL: E3 anomalie"
	description = "Odpala 10 anomalii i portal kultu: bioprzetasowanie, radioaktywna, burzowa, mrozu, gazowa, Dawczyni życia, zakłócacz psychiki, krwi, wymiarowa (tylko złoto, srebro, szkło, drewno, tytan; kadłub zostaje), artefakt i portal kultu z konstruktami (wymaga duchów). Neutralizacja analizatorem albo sygnalizatorem, bez rdzeni."
	items = list(/obj/item/analyzer = 1, /obj/item/assembly/signaler = 2, /obj/item/clothing/suit/bio_suit = 1, /obj/item/clothing/head/bio_hood = 1, /obj/item/clothing/glasses/sunglasses = 1)
	events = list(
		/datum/round_event_control/aquila_hex_anomaly_bioscrambler,
		/datum/round_event_control/aquila_hex_anomaly_radiation,
		/datum/round_event_control/aquila_hex_anomaly_storm,
		/datum/round_event_control/aquila_hex_anomaly_frost,
		/datum/round_event_control/aquila_hex_anomaly_gas,
		/datum/round_event_control/aquila_hex_anomaly_lifebringer,
		/datum/round_event_control/aquila_hex_anomaly_insanity_pulse,
		/datum/round_event_control/aquila_hex_anomaly_blood,
		/datum/round_event_control/aquila_hex_anomaly_dimensional,
		/datum/round_event_control/aquila_hex_artifact,
		/datum/round_event_control/aquila_hex_cult_portal,
	)

/datum/test_chamber_kit/pr_720_eventy/e4
	name = "Eventy mapy FTL: E4 stwory, które mamy"
	description = "Odpala 12 eventów: inwazję mimików, podejrzaną skrzynię złomiarzy, hordę szlamów (nie dzielą się), zbłąkanego facehuggera (ostrzeżenie po 1–3 min), gniazdo obcych, inwazję hivebotów, zbuntowane drony techniczne, kocichirurga, napromieniowaną mysz oraz role duchów: żywy smar, porzucony cyborg Syndykatu (bez emagu i granatnika), meteor zmiennokształtnego (nie niszczy kadłuba)."
	items = list(/obj/item/melee/baton/loaded = 1, /obj/item/gun/energy/laser = 1, /obj/item/clothing/glasses/sunglasses = 1)
	events = list(
		/datum/round_event_control/aquila_hex_mimics_invasion,
		/datum/round_event_control/aquila_hex_station_incident_mimic,
		/datum/round_event_control/aquila_hex_slimes_spawn_horde,
		/datum/round_event_control/aquila_hex_stray_facehugger,
		/datum/round_event_control/aquila_hex_xenohive,
		/datum/round_event_control/aquila_hex_hivebots,
		/datum/round_event_control/aquila_hex_rogue_maint_drones,
		/datum/round_event_control/aquila_hex_cat_surgeon,
		/datum/round_event_control/aquila_hex_irradiated_mouse,
		/datum/round_event_control/aquila_hex_living_lube,
		/datum/round_event_control/aquila_hex_derelict_syndicate_cyborg,
		/datum/round_event_control/aquila_hex_changeling_meteor,
	)

/datum/test_chamber_kit/pr_720_eventy/e5
	name = "Eventy mapy FTL: E5 kosmiczna fauna"
	description = "Odpala 8 eventów: przeloty koi, muszek, meduz, płaszczek, rekinów i wielorybów obok kadłuba (tylko w kosmosie, nie wchodzą do okrętu; groźne tylko na EVA), pas komet (barwa gwiazd wraca na końcu) i rój dziwnych meteorów (wgniecenia zamiast dziur, zostają przedmioty). Obejrzyj przez okna albo w skafandrze."
	items = list(/obj/item/clothing/suit/space/hardsuit/engine = 1, /obj/item/tank/internals/oxygen = 1, /obj/item/clothing/mask/breath = 1)
	events = list(
		/datum/round_event_control/aquila_hex_carp_migration_koi,
		/datum/round_event_control/aquila_hex_gnat_migration,
		/datum/round_event_control/aquila_hex_jellyfish_migration,
		/datum/round_event_control/aquila_hex_ray_migration,
		/datum/round_event_control/aquila_hex_shark_migration,
		/datum/round_event_control/aquila_hex_whale_migration,
		/datum/round_event_control/aquila_hex_comet_belt,
		/datum/round_event_control/aquila_hex_fun_swarm,
	)

/datum/test_chamber_kit/pr_720_eventy/e6
	name = "Eventy mapy FTL: E6 znaleziska"
	description = "Odpala 8 eventów: dryfujące skrzynie z surowcami przy burcie (GPS znika po otwarciu), kapsuły z zasobami, tajemniczy prezent, porzucony satelitę (klucz, potem spawarka; rdzeń do analizatora), starego Vendotrona (płatny dla wszystkich, nie dla silikonów), wędrownego handlarza (15 min), przechwyconą paczkę przemytników (szyfr Cezara, skrytka w tunelach) i gniazdo kryształów bluespace (obcęgi)."
	items = list(/obj/item/wrench = 1, /obj/item/weldingtool = 1, /obj/item/wirecutters = 1, /obj/item/crowbar = 1, /obj/item/gps = 1)
	events = list(
		/datum/round_event_control/aquila_hex_resource_drift,
		/datum/round_event_control/aquila_hex_resource_pods,
		/datum/round_event_control/aquila_hex_mystery_gift,
		/datum/round_event_control/aquila_hex_derelict_satellite,
		/datum/round_event_control/aquila_hex_old_vendotron,
		/datum/round_event_control/aquila_hex_travelling_trader,
		/datum/round_event_control/aquila_hex_intercepted_contraband,
		/datum/round_event_control/aquila_hex_bluespace_crystal_infestation,
	)

/datum/test_chamber_kit/pr_720_eventy/e7
	name = "Eventy mapy FTL: E7 nowe plagi"
	description = "Odpala 9 plag: słoneczne larwy i żywy kabel (nie ssą prądu poniżej 30% ogniwa ani w zamkniętych pomieszczeniach; kabel wytnij w izolowanych rękawicach), dzikie szlamy, larwy obcych (zagnieżdżona larwa: operacja na organach klatki albo 2 j. środka na szkodniki, staza zatrzymuje), mimity (limit 12), oczny horror (okulary chronią), kosmicznego dzika, pleśń (zniszcz rdzeń) i złośliwy narząd (operacja)."
	items = list(/obj/item/clothing/gloves/color/yellow = 1, /obj/item/wirecutters = 1, /obj/item/clothing/glasses/sunglasses = 1, /obj/item/healthanalyzer = 1, /obj/item/scalpel = 1, /obj/item/hemostat = 1, /obj/item/retractor = 1, /obj/item/circular_saw = 1)
	events = list(
		/datum/round_event_control/aquila_hex_grub_infestation,
		/datum/round_event_control/aquila_hex_powercreeper,
		/datum/round_event_control/aquila_hex_metroid_infestation,
		/datum/round_event_control/aquila_hex_abominable_infestation,
		/datum/round_event_control/aquila_hex_mimite_infestation,
		/datum/round_event_control/aquila_hex_eye_horror,
		/datum/round_event_control/aquila_hex_hog,
		/datum/round_event_control/aquila_hex_mold,
		/datum/round_event_control/aquila_hex_spontaneous_malignant_organ,
	)

/datum/test_chamber_kit/pr_720_eventy/e8
	name = "Eventy mapy FTL: E8 Syndykat i rozdarcia"
	description = "Odpala 7 eventów: przebudzenie uśpionych agentów (audycja liczbowa, wymaga graczy z preferencją), saperów Syndykatu z bombą (rozbrojenie: przetnij przewód uzbrajający według legendy w planach okrętu), zamach Syndykatu, porzuconego IPC (rola ducha), rozdarcie wymiarów z ogarami, rozdarcie klaunów i inwazję demonów (zniszcz wszystkie portale). Stwory znikają z końcem eventu."
	items = list(/obj/item/wirecutters = 1, /obj/item/multitool = 1, /obj/item/gun/energy/laser = 1, /obj/item/melee/baton/loaded = 1)
	events = list(
		/datum/round_event_control/aquila_hex_sleeper_agent,
		/datum/round_event_control/aquila_hex_syndie_bombsquad,
		/datum/round_event_control/aquila_hex_syndicate_assassination,
		/datum/round_event_control/aquila_hex_abandoned_ipc,
		/datum/round_event_control/aquila_hex_tear,
		/datum/round_event_control/aquila_hex_tear_honk,
		/datum/round_event_control/aquila_hex_demon_incursion,
	)
