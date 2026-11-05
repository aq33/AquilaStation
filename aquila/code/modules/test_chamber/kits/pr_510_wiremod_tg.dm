/datum/test_chamber_kit/pr_510
	name = "Circuity z tg (nowy wiremod)"
	pr = "aq33/AquilaStation#510"
	description = "Zestaw: 6 układów, multitool układowy, obudowy (pilot, kontroler, skaner, klawiatura, pistolet, boty, bankomat, śluza, dron, serwer, dystrybutor, skaner bramkowy, BCI, zespół, panel ścienny, panel pod płytkę, implant, aparat, PDA, moduł MOD), komora BCI, drukarka komponentów, emiter, termomaszyna, pompa temperatury, duplikator modułów, alarm powietrza i komponenty (zegar, mowa, słuch, arytmetyka, foreach, lista, wirenet, bitwise, round, trygonometria, kamera zdalna ×2 i inne). \
	1) Hello world: włóż komponent zegara i mowy do układu (klik komponentem w układ), otwórz okno układu, połącz wyjście zegara z wejściem Trigger mowy i wpisz tekst w Message; włóż układ w pilota albo bota → oczekiwane: obudowa co tik zegara mówi wpisany tekst. Jedno wejście przyjmuje kilka wyjść naraz. \
	2) Zmienne układu: w menu Zmienne dodaj zmienną i zobacz ją na liście; wyszukiwarka w menu komponentów filtruje po nazwie → oczekiwane: wyniki zawężają się do wpisanej frazy. \
	3) Multitool układowy: klik na obiekt zaznacza go, przycisk przy porcie typu obiekt wczytuje zaznaczenie → oczekiwane: port pokazuje nazwę zaznaczonego obiektu. \
	4) Drukarka: uderz układem w drukarkę komponentów → oczekiwane: w oknie układu można drukować komponenty z menu (kategorie Rdzeń, Obudowy, Matematyka itd.); odłączony komponent wraca do drukarki. \
	5) USB: kabel USB do bota z układem i do emitera → oczekiwane: w układzie pojawia się komponent emitera, jego strzał z układu odpala emiter; to samo z termomaszyną (włączenie i temperatura docelowa) i z pompą temperatury; alarm powietrza daje odczyty. \
	6) Wirenet: dwa boty przykręcone kluczem na tej samej sieci kabli (połóż kabel pod obydwoma), w jednym wirenet_send, w drugim wirenet_receive z tym samym kluczem → oczekiwane: odbiorca dostaje dane z nadajnika. \
	7) BCI: włóż układ do BCI, BCI do komory BCI, wejdź człowiekiem do komory i zamknij ją → oczekiwane: BCI się wszczepia, akcja ładunku pokazuje procent, nakładki HUD widzi tylko nosiciel. Panel pod płytkę: połóż płytkę nad nim → oczekiwane: znika pod płytką i dalej działa. Implant: wszczep implanterem. \
	8) Nasze komponenty: bitwise (opcja And: 6 i 3 → 2), round (opcja Round: 2,6 → 3, Floor: 2, Ceil: 3), bitflag, trygonometria zaawansowana (np. sinh 0 → 0) → oczekiwane: poprawne wyniki na wyjściach. \
	9) Aparat/PDA/moduł MOD jako obudowy: włóż układ i wyzwól komponent aparatu → oczekiwane: aparat robi zdjęcie, PDA i moduł MOD przyjmują układ jako obudowę (okno układu się otwiera). Kamera zdalna → oczekiwane: pozwala patrzeć przez kamerę obudowy. \
	10) Negatywy: (a) połącz wyjście tekstowe (np. wiadomość z komponentu słuchu) z wejściem liczbowym arytmetyki → połączenie zostaje odrzucone, kabel się nie tworzy; (b) włóż drugi komponent kamery zdalnej do tego samego układu → „Nie możesz włożyć kilku takich komponentów do jednego układu!”."
	items = list(
		/obj/item/integrated_circuit/loaded = 6,
		/obj/item/multitool/circuit = 1,
		/obj/item/usb_cable = 2,
		/obj/item/compact_remote = 1,
		/obj/item/controller = 1,
		/obj/item/wiremod_scanner = 1,
		/obj/item/keyboard_shell = 1,
		/obj/item/gun/energy/wiremod_gun = 1,
		/obj/item/shell/bot = 2,
		/obj/item/shell/money_bot = 1,
		/obj/item/shell/airlock = 1,
		/obj/item/shell/drone = 1,
		/obj/item/shell/server = 1,
		/obj/item/shell/dispenser = 1,
		/obj/item/shell/scanner_gate = 1,
		/obj/item/shell/bci = 1,
		/obj/item/assembly/wiremod = 1,
		/obj/item/wallframe/circuit = 1,
		/obj/item/undertile_circuit = 1,
		/obj/item/implantcase/circuit = 1,
		/obj/item/implanter = 1,
		/obj/machinery/bci_implanter = 1,
		/obj/machinery/modular_fabricator/component_printer = 1,
		/obj/machinery/power/emitter = 1,
		/obj/item/circuit_component/clock = 1,
		/obj/item/circuit_component/speech = 1,
		/obj/item/circuit_component/hear = 1,
		/obj/item/circuit_component/arithmetic = 1,
		/obj/item/circuit_component/foreach = 1,
		/obj/item/circuit_component/list_literal = 1,
		/obj/item/circuit_component/wirenet_send = 1,
		/obj/item/circuit_component/wirenet_receive = 1,
		/obj/item/circuit_component/bitwise = 1,
		/obj/item/circuit_component/compare/bitflag = 1,
		/obj/item/circuit_component/round = 1,
		/obj/item/circuit_component/advanced_trigonometry = 1,
		/obj/item/circuit_component/object_overlay = 1,
		/obj/item/circuit_component/equipment_action = 1,
		/obj/item/camera = 1,
		/obj/item/modular_computer/tablet/pda = 1,
		/obj/item/mod/module/circuit = 1,
		/obj/item/circuit_component/wire_bundle = 1,
		/obj/item/circuit_component/remotecam = 2,
		/obj/machinery/atmospherics/components/unary/thermomachine/freezer = 1,
		/obj/machinery/atmospherics/components/binary/temperature_pump = 1,
		/obj/machinery/module_duplicator = 1,
		/obj/machinery/airalarm = 1,
		/obj/item/stack/tile/plasteel = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/screwdriver = 1,
		/obj/item/wrench = 1,
	)
