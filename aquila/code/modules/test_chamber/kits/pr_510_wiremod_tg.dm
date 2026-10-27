/datum/test_chamber_kit/pr_510
	name = "Circuity z tg (nowy wiremod)"
	pr = "aq33/AquilaStation#510"
	description = "Włóż komponenty do układu (klik komponentem w układ) i otwórz okno układu: przeciąganie komponentów, łączenie portów (jedno wejście przyjmuje kilka wyjść), zmienne układu w menu Zmienne, lista komponentów z wyszukiwarką. \
		Hello world: zegar -> mowa w pilocie albo bocie, mowa ma powiedzieć tekst. Multitool do układów: klik na obiekt zaznacza go, przycisk przy porcie obiektu wczytuje zaznaczenie. \
		Uderz układem w drukarkę komponentów: w oknie układu ma się dać drukować komponenty z menu, a odłączony komponent ląduje z powrotem w drukarce. Drukarka ma pokazywać kategorie Rdzeń, Obudowy, Matematyka itd. \
		Obudowy: pilot, kontroler, skaner, klawiatura, pistolet, bot, bankomat, drzwi, zespół, panel ścienny, panel pod płytkę (połóż płytkę nad nim - ma zniknąć i działać), implant (wszczep implanterem), skaner bramkowy, dystrybutor. \
		BCI: włóż układ do BCI, włóż BCI do komory BCI, wejdź do komory i zamknij ją - BCI ma się wszczepić, akcja ładunku pokazuje procent, nakładki HUD widzi tylko nosiciel. \
		Kabel USB: emiter, termomaszyna i pompa temperatury (strzał i włączanie z układu). Wirenet: dwa układy w botach przykręconych na tej samej sieci kabli - nadajnik i odbiornik. \
		Komponenty tylko nasze: Bitwise, Bitflag, Round, Advanced Trigonometry."
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
		/obj/item/stack/tile/plasteel = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/screwdriver = 1,
		/obj/item/wrench = 1,
	)
