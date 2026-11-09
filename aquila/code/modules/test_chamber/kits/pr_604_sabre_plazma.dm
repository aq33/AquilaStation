/datum/test_chamber_kit/pr_604
	name = "Sabre na plazmie"
	pr = "aq33/AquilaStation#604"
	description = "Zestaw: 2 kanistry plazmy, klucz i zapasowa karta kapitana. \
	1) Wejdź do Sabre w hangarze. W ładowni przy łóżku stoi złącze paliwa (żółta ramka), a obok w podłodze podgrzewacz paliwa Sabre. Obejrzyj podgrzewacz → pokazuje mole gazu; obejrzyj właz z zewnątrz → „Paliwo: X/2500”. \
	2) Wtocz kanister plazmy na złącze i przykręć kluczem → paliwo Sabre rośnie (okno pilota, opis włazu). Jeden pełny kanister daje prawie pełny zbiornik. \
	3) Leć na overmapie → paliwo spada; przy ciągu szybciej niż na jałowym. Z zerowym paliwem start ze steru odmawia (negatyw). \
	4) Wąż kriopaliwa ze zbiornika przy myśliwcach kliknięty we właz Sabre → komunikat, że Sabre lata na plazmie, paliwo bez zmian (negatyw). Myśliwiec tankuje się wężem jak wcześniej. \
	5) Zestaw do tankowania w locie: Sabre tankuje myśliwiec → paliwo przechodzi, Sabre traci plazmę."
	items = list(
		/obj/machinery/portable_atmospherics/canister/toxins = 2,
		/obj/item/wrench = 1,
		/obj/item/card/id/captains_spare = 1,
	)
