// aq33/AquilaStation#574 - radial w stylu SS14, czerwone wolne pola pełnych schowków, czat głosowy w menu Esc

/datum/test_chamber_kit/pr_574
	name = "PR 574: radial jak w SS14, pełne schowki"
	pr = "aq33/AquilaStation#574"
	description = "1) RCD w ręce, użyj go (Z): radial to tarcza z sektorami, sektor pod myszą się podświetla, nad tarczą jest nazwa opcji. Kliknij w róg sektora (z dala od ikony): opcja też się wybiera. Krzyżyk w środku zamyka menu. Sprawdź też Następną stronę, jeśli opcji jest więcej niż 8. \
	2) Kabel w ręce, użyj go: mniejszy radial z podpisem zamiast dymka. Tytanowe płytki w dłoni: radial wyboru rodzaju z większą tarczą (promień 48). \
	3) Radial przy krawędzi ekranu (np. przedmiot w ręce przy dolnym pasku): tarcza jest wycinkiem, sektory nie nachodzą na siebie. \
	4) Sprawdź wybór w obu trybach sterowania (combat mode i stare intencje). \
	5) Pełny pas z narzędziami: otwórz go, wolne pola (jeśli są) są czerwone. Wyjmij narzędzie: pola wracają do zwykłego koloru. Plecak: wkładaj rzeczy, aż się nie zmieszczą (przepełnienie pokazuje czerwone pola i licznik w nagłówku). \
	6) Esc: przycisk „Czat głosowy” jest widoczny tylko przy VOICE_CHAT_ENABLED w config/voice_chat.txt i otwiera stronę z mikrofonem."
	items = list(
		/obj/item/construction/rcd/loaded = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/tile/mineral/titanium = 1,
		/obj/item/storage/belt/utility/full = 1,
		/obj/item/storage/backpack = 1,
	)
