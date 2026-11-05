/datum/test_chamber_kit/pr_492
	name = "PR 492: serwery AI"
	pr = "aq33/AquilaStation#492"
	description = "Zestaw stawia główny rdzeń danych z SI („SI testowa” już w środku, bez gracza: przejmij ją jako admin, np. Possess na moba), drugi rdzeń (zapasowy), szafy, składarkę racków, konsole i kable ethernet pod całą areną. Rdzenie mają baterię. W skrzynce „materiały na RAM” są zaawansowany procesor, 50 żelaza i szkła, srebro, złoto, kod kontrolny i zapasowa karta kapitana (dostęp RD/CE). \
	1) Przejmij SI → oczekiwane: SI siedzi w głównym rdzeniu, na HUD jest przycisk panelu przetwarzania. Konsola dystrybucji zasobów (karta w ręce) → przydziel SI całe wolne CPU i RAM: szafa prefilled daje łącznie 1 THz i 1 TB. \
	2) Panel przetwarzania: przydziel CPU do projektu i uruchom ukończony projekt → oczekiwane: wolne CPU dają punkty badań SI, projekt zmienia stan (np. przyspieszenie kamery). \
	3) Składarka racków: włóż zwykły procesor (1 THz), dodaj RAM 1 TB (1 szkło + 1 żelazo, wsyp arkusze ze skrzynki) i zbuduj → oczekiwane: rack 1 THz / 1 TB (examine). Włóż rack do pustej szafy → total w konsoli dystrybucji rośnie o 1 THz i 1 TB. Negatyw: drugi procesor w tym samym racku → „To gniazdo nie zostało jeszcze zbadane!”. \
	4) Stanowisko podkręcania: podkręć procesor → oczekiwane: wynik próby (udana albo nie) i zmiana taktowania/poboru mocy procesora w examine. \
	5) Zniszcz główny rdzeń (np. VV/Delete albo ciężki młotek) → oczekiwane: SI przechodzi do zapasowego rdzenia, nie ginie. Negatyw: usuń też zapasowy → SI umiera, wypada intellicard z jej zapisem. \
	6) Konsola sterowania SI (karta RD/CE albo kod z papieru): włóż intellicard, pobierz SI na kartę → oczekiwane: SI znika z rdzenia i z listy przydziałów, jest na karcie; wgraj z powrotem → wraca do rdzenia. Wariant z MMI wymaga gracza w mózgu (wymaga ducha/drugiego gracza: włóż mózg do MMI i oddaj go graczowi); bez mózgu z umysłem konsola odmawia: „mózg nieaktywny!”. \
	7) Ekran rdzenia SI pokazuje twarz SI. Ciepło: podnieś temperaturę powietrza przy rdzeniu powyżej 15°C (VV gazu, 300 K) → oczekiwane: rdzeń/szafa przestają pracować i SI traci zasoby; włącz chłodziarkę serwerowni (klik ustawia temperaturę) → ok. 5°C na jej polu i sąsiednich, maszyny wracają do pracy."
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
		/obj/item/organ/brain = 1,
	)

/datum/test_chamber_kit/pr_492/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/turf/primary_turf = get_turf(spawned[1])
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
	// Maszyny SI łączą się kablem ethernet (aq33/AquilaStation#499), więc kładziemy go pod całą areną
	for(var/turf/T as anything in turfs)
		if(!locate(/obj/structure/ethernet_cable) in T)
			new /obj/structure/ethernet_cable(T)
	// Rdzenie z baterią, żeby działały też bez zasilania w komorze
	for(var/obj/machinery/ai/data_core/core in spawned)
		if(!core.integrated_battery)
			core.integrated_battery = new /obj/item/stock_parts/cell/high(core)
	// Gotowa SI bez gracza, żeby test nie wymagał "Make AI" ani drugiej osoby (jak w teście jednostkowym)
	var/mob/living/carbon/human/brain_holder = new(primary_turf)
	brain_holder.name = "ciało SI testowej"
	brain_holder.real_name = brain_holder.name
	var/mob/living/silicon/ai/test_ai = new(primary_turf, null, brain_holder)
	if(!QDELETED(test_ai))
		test_ai.name = "SI testowa"
		test_ai.real_name = test_ai.name
