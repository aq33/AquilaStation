// Urządzenia naścienne z Paradise (ParadiseSS13/Paradise, grafiki CC BY-SA 3.0): APC, czujnik powietrza, alarm pożarowy,
// a na końcu pliku 32x32: włącznik światła, newscaster, request console i szafka gaśnicy.
// Pierwsze trzy mają sprite'y 32x48 i 4 kierunki, narysowane pod ściany 3/4, więc siedzą 32 px od środka kafla (jak w Paradise),
// a nie 23-24 px jak stare 32x32. Przesunięcie liczymy z kierunku ściany po inicjalizacji, więc działa dla map,
// budowania z ramki i egzemplarzy z ręcznym przesunięciem na mapie.

#define PARADISE_WALLMOUNT_OFFSET 32

/// Strona ściany wywnioskowana z przesunięcia (dla egzemplarzy z ręcznym pixel_x/y na mapie), null gdy przesunięcia brak.
/proc/paradise_wall_dir_from_pixels(atom/movable/A)
	if(!A.pixel_x && !A.pixel_y)
		return null
	// Przesunięcie po skosie (np. x=32, y=24): maper przesunął urządzenie wzdłuż ściany, ścianę wyznacza wtedy kierunek
	if(abs(A.pixel_x) >= 8 && abs(A.pixel_y) >= 8)
		return null
	if(abs(A.pixel_y) >= abs(A.pixel_x))
		return A.pixel_y > 0 ? NORTH : SOUTH
	return A.pixel_x > 0 ? EAST : WEST

/proc/paradise_wallmount_offset(atom/movable/A, wall_dir)
	// Przesunięcie wzdłuż ściany z mapy zostaje, zerujemy tylko oś prostopadłą do ściany
	if(wall_dir & (NORTH|SOUTH))
		A.pixel_y = 0
	else
		A.pixel_x = 0
	switch(wall_dir)
		if(NORTH)
			A.pixel_y = PARADISE_WALLMOUNT_OFFSET
		if(SOUTH)
			A.pixel_y = -PARADISE_WALLMOUNT_OFFSET
		if(EAST)
			A.pixel_x = PARADISE_WALLMOUNT_OFFSET
		if(WEST)
			A.pixel_x = -PARADISE_WALLMOUNT_OFFSET

// APC: dir = strona ściany, tak samo jak w Paradise
/obj/machinery/power/apc
	icon = 'aquila/icons/paradise/obj/wallbumps/apc.dmi'

// Po New(), bo ten na końcu ustawia dir = SOUTH i stare przesunięcie, także przy budowie z ramki
/obj/machinery/power/apc/New(turf/loc, ndir, building = 0)
	var/map_wall_dir = paradise_wall_dir_from_pixels(src) // ręczne przesunięcie z mapy, zanim New() je nadpisze
	. = ..()
	var/wall_dir = map_wall_dir || tdir || SOUTH
	setDir(wall_dir)
	paradise_wallmount_offset(src, wall_dir)

// Alarmy: u nas dir = strona, w którą patrzą (od ściany); w plikach są już odwrócone kierunki klatek
/obj/machinery/airalarm
	icon = 'aquila/icons/paradise/obj/wallbumps/airalarm.dmi'

/obj/machinery/airalarm/Initialize(mapload, ndir, nbuild)
	. = ..()
	var/wall_dir = paradise_wall_dir_from_pixels(src) || turn(dir, 180)
	setDir(turn(wall_dir, 180))
	paradise_wallmount_offset(src, wall_dir)

/obj/machinery/firealarm
	icon = 'aquila/icons/paradise/obj/wallbumps/firealarm.dmi'

// Blok NSV13 w firealarm.dm ustawia dir = strona ściany; przywracamy dir od ściany, inaczej alarm z przesunięciem po skosie ląduje na środku pokoju
/obj/machinery/firealarm/directional/north
	dir = SOUTH

/obj/machinery/firealarm/directional/south
	dir = NORTH

/obj/machinery/firealarm/directional/west
	dir = EAST

/obj/machinery/firealarm/directional/east
	dir = WEST

/obj/machinery/firealarm/Initialize(mapload, dir, building)
	. = ..()
	var/wall_dir = paradise_wall_dir_from_pixels(src) || turn(src.dir, 180)
	setDir(turn(wall_dir, 180))
	paradise_wallmount_offset(src, wall_dir)

// Urządzenia 32x32 z Paradise w 4 kierunkach; zostają na przesunięciu z mapy, kierunek bierzemy z niego.
// Włącznik światła: dir = od ściany, jak w Paradise
/obj/machinery/light_switch/Initialize(mapload)
	. = ..()
	var/wall_dir = paradise_wall_dir_from_pixels(src)
	if(wall_dir)
		setDir(turn(wall_dir, 180))

// Newscaster i request console: dir = strona ściany
/obj/machinery/newscaster/Initialize(mapload, ndir, building)
	. = ..()
	var/wall_dir = paradise_wall_dir_from_pixels(src)
	if(wall_dir)
		setDir(wall_dir)

/obj/machinery/requests_console/Initialize(mapload)
	. = ..()
	var/wall_dir = paradise_wall_dir_from_pixels(src)
	if(wall_dir)
		setDir(wall_dir)

// Gaśnica: zamknięta szafka pokazuje za szybą, czy gaśnica jest w środku
// Core wkłada gaśnicę w Initialize(), ale nie odświeża ikony, więc bez tego szafka z mapy zostaje na "extinguisher_closed"
/obj/structure/extinguisher_cabinet/Initialize(mapload, ndir, building)
	. = ..()
	update_icon()

/obj/structure/extinguisher_cabinet/update_icon()
	. = ..()
	if(opened || !stored_extinguisher)
		return
	if(istype(stored_extinguisher, /obj/item/extinguisher/mini))
		icon_state = "extinguisher_mini_closed"
	else
		icon_state = "extinguisher_full_closed"

#undef PARADISE_WALLMOUNT_OFFSET
