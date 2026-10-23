/datum/test_chamber_kit/pr_492
	name = "PR 492: serwery AI"
	pr = "aq33/AquilaStation#492"
	description = "Wejdź jako SI (Wejdź w ciało SI / admin: Make AI) albo wgraj MMI z mózgiem do konsoli sterowania SI (zaloguj się kartą RD/CE). \
	SI ma wskoczyć do głównego rdzenia danych. Panel przetwarzania (przycisk w HUD): przydziel CPU do projektu, uruchom ukończony projekt. \
	Konsola dystrybucji: przydziel CPU/RAM. Składarka racków: włóż procesor, dodaj RAM (materiały w skrzynce), zbuduj rack i włóż go do szafy. \
	Stanowisko podkręcania: podkręć procesor. Zniszcz rdzeń główny: SI przechodzi do zapasowego. Konsola sterowania: pobierz SI na intellicard i wgraj z powrotem. \
	Ekran rdzenia SI pokazuje twarz SI. Rdzenie i szafy grzeją się: bez chłodzenia przestają działać po przekroczeniu 15°C. Chłodziarka serwerowni (klik ustawia temperaturę) ma schłodzić powietrze do 5°C."
	items = list(
		/obj/machinery/ai/data_core/primary = 1,
		/obj/machinery/ai/server_cabinet/prefilled = 1,
		/obj/machinery/rack_creator = 1,
		/obj/machinery/computer/ai_control_console = 1,
		/obj/machinery/computer/ai_resource_distribution = 1,
		/obj/machinery/computer/ai_server_console = 1,
		/obj/machinery/computer/ai_overclocking = 1,
		/obj/machinery/ai_core_display = 1,
		/obj/machinery/server_chiller = 1,
		/obj/item/ai_cpu = 2,
		/obj/item/aicard = 1,
		/obj/item/mmi = 1,
	)

/datum/test_chamber_kit/pr_492/setup(list/spawned, list/turfs, turf/center, mob/user)
	// Podtypy osobno, bo test komory liczy przez istype tylko to, co jest w items
	spawned += new /obj/machinery/ai/data_core(turfs[min(length(spawned) + 1, length(turfs))])
	new /obj/machinery/ai/server_cabinet(turfs[min(length(spawned) + 2, length(turfs))])
	var/obj/structure/closet/crate/mats = new(center)
	new /obj/item/ai_cpu/advanced(mats)
	mats.name = "materiały na RAM"
	new /obj/item/stack/sheet/iron/fifty(mats)
	new /obj/item/stack/sheet/glass/fifty(mats)
	new /obj/item/stack/sheet/mineral/silver{amount = 20}(mats)
	new /obj/item/stack/sheet/mineral/gold{amount = 20}(mats)
	new /obj/item/paper/ai_control_code(mats)
	new /obj/item/card/id/captains_spare(mats)
	// Rdzenie z baterią, żeby działały też bez zasilania w komorze
	for(var/obj/machinery/ai/data_core/core in spawned)
		if(!core.integrated_battery)
			core.integrated_battery = new /obj/item/stock_parts/cell/high(core)
