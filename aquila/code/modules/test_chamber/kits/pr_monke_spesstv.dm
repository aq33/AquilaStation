/datum/test_chamber_kit/pr_monke_spesstv
	name = "Spess.tv i kamery reporterskie"
	pr = "aq33/AquilaStation#TBD"
	description = "Weź kamerę reporterską do ręki i użyj jej: telewizor ma się zapalić i powiedzieć „... - teraz NA ŻYWO!”, a PDA ma pisnąć z powiadomieniem Spess.tv. \
		Kliknij telewizor (albo otwórz Spess.tv w PDA) i wybierz kamerę „NA ŻYWO: ...”: obraz ma iść za tobą, a examine kamery ma pokazać liczbę widzów. \
		Powiedz coś: głośniki telewizora i PDA z otwartym Spess.tv mają to powtórzyć na kanale Rozrywka. Ctrl+klik na telewizorze wycisza głośniki, Alt+klik na kamerze wyłącza mikrofon, \
		Ctrl+Shift+klik zmienia nazwę programu. Odłożenie kamery albo schowanie do plecaka kończy transmisję i gasi telewizor. \
		Z kamery, 16 prętów i taśmociągu (spawacz + klucz) zrób w menu wytwarzania dużą kamerę; ona nadaje po kliknięciu i jedzie razem z nią obraz. \
		Bitrunning: z zestawem „Bitrunning z tg” włącz w konsoli kwantowej nadawanie i załaduj domenę - telewizory mają pokazać kamery „Awatar ...”."
	items = list(
		/obj/item/broadcast_camera = 1,
		/obj/machinery/computer/security/telescreen/entertainment = 1,
		/obj/item/modular_computer/tablet/pda = 1,
		/obj/item/radio/entertainment/microphone/physical = 1,
		/obj/item/radio/entertainment/speakers/physical = 1,
		/obj/item/stack/rods/fifty = 1,
		/obj/item/stack/conveyor = 1,
		/obj/item/weldingtool/largetank = 1,
		/obj/item/wrench = 1,
	)
