// Urządzenia 32x32 na ścianach Paradise. Sprite ściany 32x40 zajmuje swój kafel (górne 8 px to tylko zakładka na ścianę
// powyżej), więc urządzenie ma leżeć na kaflu ściany, tak jak APC i alarmy z wallbumps w nascienne.dm:
// - ściana północna: widoczna część na środku kafla ściany, nie schodzi na podłogę,
// - ściana południowa: górna krawędź równo z krawędzią podłogi (jak tył APC i alarmów),
// - ściany wschodnia i zachodnia: przy wewnętrznej krawędzi ściany i PARADISE_SIDE_RAISE wyżej, bo segmenty ściany
//   pionowej (zakładki) są przesunięte w górę względem kafla.
// Mapy mają te same urządzenia na przesunięciach 22-32 px, więc wyrównujemy je w kodzie zamiast poprawiać setki wpisów:
// paradise_wall_place() zmienia tylko przesunięcie prostopadłe do ściany, przesunięcie wzdłuż ściany (dwa urządzenia
// na jednym kawałku ściany) zostaje z mapy. Wartości policzone z widocznej części sprite'ów w każdym kierunku.

/// O tyle wyżej wiszą urządzenia na ścianach wschodnich i zachodnich
#define PARADISE_SIDE_RAISE 4

/// Strona ściany z przesunięcia urządzenia. Dopuszcza przesunięcie wzdłuż ściany do 60% przesunięcia w stronę ściany;
/// null dla przesunięć po skosie i małych (urządzenie na samym kaflu ściany albo stojące na podłodze).
/proc/paradise_wallmount_side(atom/movable/A, min_offset = 16)
	var/ax = abs(A.pixel_x)
	var/ay = abs(A.pixel_y)
	if(max(ax, ay) < min_offset)
		return null
	if(ay > ax)
		if(ax * 5 > ay * 3)
			return null
		return A.pixel_y > 0 ? NORTH : SOUTH
	if(ay * 5 > ax * 3)
		return null
	return A.pixel_x > 0 ? EAST : WEST

/// Ustawia przesunięcie i kierunek urządzenia naściennego dla ścian Paradise. Wywoływane po Initialize(), po zawieszeniu
/// z ramki (after_attach) i po przewieszeniu przez trwałą strukturę statku. Domyślnie nic nie robi.
/obj/proc/paradise_wall_place()
	return

/// Przesunięcie prostopadłe do ściany z argumentów (północ, południe, wschód, zachód), wzdłuż ściany zostaje.
/// Na ścianach bocznych podnosi o side_raise, jeśli maper nie przesunął urządzenia wzdłuż ściany. Zwraca stronę ściany albo null.
/obj/proc/paradise_wall_snap(north, south, east, west, side_raise = PARADISE_SIDE_RAISE)
	var/wall_dir = paradise_wallmount_side(src)
	switch(wall_dir)
		if(NORTH)
			pixel_y = north
		if(SOUTH)
			pixel_y = south
		if(EAST, WEST)
			pixel_x = (wall_dir == EAST) ? east : west
			if(!pixel_y)
				pixel_y = side_raise
	return wall_dir

// Zawieszenie z ramki: ramka ustawia przesunięcie dopiero po Initialize()
/obj/item/wallframe/after_attach(obj/O)
	. = ..()
	O.paradise_wall_place()

// --- Urządzenia z Paradise i SS220 w 4 kierunkach

// Włącznik światła: dir = od ściany
/obj/machinery/light_switch/Initialize(mapload)
	. = ..()
	paradise_wall_place()

/obj/machinery/light_switch/paradise_wall_place()
	var/wall_dir = paradise_wall_snap(34, -21, 24, -24)
	if(wall_dir)
		setDir(turn(wall_dir, 180))

// Newscaster: dir = strona ściany (kierunki dorysowane w aquila/icons/obj/terminals.dmi)
/obj/machinery/newscaster/Initialize(mapload, ndir, building)
	. = ..()
	paradise_wall_place()

/obj/machinery/newscaster/paradise_wall_place()
	var/wall_dir = paradise_wall_snap(34, -24, 27, -27)
	if(wall_dir)
		setDir(wall_dir)

// Request console: dir = strona ściany
/obj/machinery/requests_console/Initialize(mapload)
	. = ..()
	paradise_wall_place()

/obj/machinery/requests_console/paradise_wall_place()
	var/wall_dir = paradise_wall_snap(34, -25, 28, -28)
	if(wall_dir)
		setDir(wall_dir)

// Interkom (SS220): dir = strona ściany
/obj/item/radio/intercom/Initialize(mapload, ndir, building)
	. = ..()
	paradise_wall_place()

/obj/item/radio/intercom/paradise_wall_place()
	var/wall_dir = paradise_wall_snap(34, -21, 24, -24)
	if(wall_dir)
		setDir(wall_dir)

// Teleekran: dir = od ściany (panel z przyciskami w stronę pokoju)
/obj/machinery/computer/security/telescreen/Initialize(mapload)
	. = ..()
	paradise_wall_place()

/obj/machinery/computer/security/telescreen/paradise_wall_place()
	var/wall_dir = paradise_wall_snap(34, -23, 26, -26)
	if(wall_dir)
		setDir(turn(wall_dir, 180))

// Monitor rozrywkowy ma jednokierunkowy, szeroki ekran: na środku kafla ściany
/obj/machinery/computer/security/telescreen/entertainment/paradise_wall_place()
	paradise_wall_snap(34, -27, 32, -32)

// Tablica ogłoszeń: dir = od ściany (wieszak przy ścianie)
/obj/structure/noticeboard/Initialize(mapload)
	. = ..()
	paradise_wall_place()

/obj/structure/noticeboard/paradise_wall_place()
	var/wall_dir = paradise_wall_snap(34, -24, 27, -27)
	if(wall_dir)
		setDir(turn(wall_dir, 180))

// Szafka na topór: kierunki dorysowane (obrót na ścianach bocznych), dir = strona ściany
/obj/structure/fireaxecabinet
	icon = 'aquila/icons/obj/fireaxe_kierunki.dmi'

/obj/structure/fireaxecabinet/Initialize(mapload)
	. = ..()
	paradise_wall_place()

/obj/structure/fireaxecabinet/paradise_wall_place()
	var/wall_dir = paradise_wall_snap(34, -25, 27, -27)
	if(wall_dir)
		setDir(wall_dir)

// --- Urządzenia jednokierunkowe

/obj/structure/extinguisher_cabinet/Initialize(mapload, ndir, building)
	. = ..()
	paradise_wall_place()

/obj/structure/extinguisher_cabinet/paradise_wall_place()
	paradise_wall_snap(34, -25, 25, -25)

/obj/machinery/button/Initialize(mapload, ndir, built)
	. = ..()
	paradise_wall_place()

/obj/machinery/button/paradise_wall_place()
	paradise_wall_snap(34, -19, 23, -23)

/obj/machinery/flasher/Initialize(mapload, ndir, built)
	. = ..()
	paradise_wall_place()

/obj/machinery/flasher/paradise_wall_place()
	paradise_wall_snap(32, -22, 23, -22)

// Przenośny flasher stoi na podłodze
/obj/machinery/flasher/portable/paradise_wall_place()
	return

/obj/machinery/keycard_auth/Initialize(mapload)
	. = ..()
	paradise_wall_place()

/obj/machinery/keycard_auth/paradise_wall_place()
	paradise_wall_snap(34, -20, 25, -24)

/obj/machinery/advanced_airlock_controller/Initialize(mapload)
	. = ..()
	paradise_wall_place()

/obj/machinery/advanced_airlock_controller/paradise_wall_place()
	paradise_wall_snap(36, -18, 26, -27)

/obj/machinery/doorButtons/Initialize(mapload)
	. = ..()
	paradise_wall_place()

/obj/machinery/doorButtons/paradise_wall_place()
	paradise_wall_snap(34, -19, 22, -22)

/obj/machinery/embedded_controller/Initialize(mapload)
	. = ..()
	paradise_wall_place()

/obj/machinery/embedded_controller/paradise_wall_place()
	paradise_wall_snap(34, -19, 23, -23)

/obj/machinery/airlock_sensor/Initialize(mapload)
	. = ..()
	paradise_wall_place()

/obj/machinery/airlock_sensor/paradise_wall_place()
	paradise_wall_snap(34, -19, 23, -23)

/obj/machinery/status_display/Initialize(mapload, ndir, building)
	. = ..()
	paradise_wall_place()

/obj/machinery/status_display/paradise_wall_place()
	paradise_wall_snap(33, -28, 32, -32)

/obj/machinery/door_timer/Initialize(mapload)
	. = ..()
	paradise_wall_place()

/obj/machinery/door_timer/paradise_wall_place()
	paradise_wall_snap(33, -28, 32, -32)

/obj/machinery/turretid/Initialize(mapload, ndir, built)
	. = ..()
	paradise_wall_place()

/obj/machinery/turretid/paradise_wall_place()
	paradise_wall_snap(34, -21, 26, -28)

/obj/machinery/defibrillator_mount/Initialize(mapload)
	. = ..()
	paradise_wall_place()

/obj/machinery/defibrillator_mount/paradise_wall_place()
	paradise_wall_snap(32, -24, 27, -27)

/obj/machinery/vending/wallmed/Initialize(mapload)
	. = ..()
	paradise_wall_place()

/obj/machinery/vending/wallmed/paradise_wall_place()
	paradise_wall_snap(36, -25, 25, -24)

/obj/structure/mirror/Initialize(mapload)
	. = ..()
	paradise_wall_place()

/obj/structure/mirror/paradise_wall_place()
	paradise_wall_snap(32, -27, 25, -25)

/obj/structure/reagent_dispensers/peppertank/Initialize(mapload)
	. = ..()
	paradise_wall_place()

/obj/structure/reagent_dispensers/peppertank/paradise_wall_place()
	paradise_wall_snap(34, -27, 30, -30)

/obj/item/storage/secure/safe/Initialize(mapload)
	. = ..()
	paradise_wall_place()

/obj/item/storage/secure/safe/paradise_wall_place()
	paradise_wall_snap(34, -23, 34, -24)

/obj/machinery/vitals_reader/Initialize(mapload)
	. = ..()
	paradise_wall_place()

/obj/machinery/vitals_reader/paradise_wall_place()
	paradise_wall_snap(32, -29, 32, -32)

/obj/machinery/digital_clock/Initialize(mapload)
	. = ..()
	paradise_wall_place()

/obj/machinery/digital_clock/paradise_wall_place()
	paradise_wall_snap(34, -23, 29, -30)

/obj/machinery/computer/ship/viewscreen/Initialize(mapload)
	. = ..()
	paradise_wall_place()

/obj/machinery/computer/ship/viewscreen/paradise_wall_place()
	paradise_wall_snap(32, -27, 32, -32)

// --- Tabliczki i plakaty (32x32, prawie cały kafel): na środku kafla ściany, tak jak tabliczka postawiona na samej ścianie.
// Mapy mają je na 24-34 px, część zachodzi na podłogę. Duże tabliczki (szersze lub wyższe niż kafel) i małe przesunięcia
// (składanie kilku tabliczek w jedną) zostają bez zmian.
/obj/structure/sign/Initialize(mapload)
	. = ..()
	paradise_wall_place()

/obj/structure/sign/paradise_wall_place()
	if(!paradise_wallmount_side(src, 20) || max(abs(pixel_x), abs(pixel_y)) > 40)
		return
	if(get_cached_width() != world.icon_size || get_cached_height() != world.icon_size)
		return
	paradise_wall_snap(32, -32, 32, -32, 0)

#undef PARADISE_SIDE_RAISE
