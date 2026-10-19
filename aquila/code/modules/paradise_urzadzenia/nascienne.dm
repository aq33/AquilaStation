// Urządzenia naścienne z Paradise (ParadiseSS13/Paradise, grafiki CC BY-SA 3.0): APC, czujnik powietrza, alarm pożarowy.
// Ich sprite'y mają 32x48 i 4 kierunki, narysowane pod ściany 3/4, więc siedzą 32 px od środka kafla (jak w Paradise),
// a nie 23-24 px jak stare 32x32. Przesunięcie liczymy z kierunku ściany po inicjalizacji, więc działa dla map,
// budowania z ramki i egzemplarzy z ręcznym przesunięciem na mapie.

#define PARADISE_WALLMOUNT_OFFSET 32

/// Strona ściany wywnioskowana z przesunięcia (dla egzemplarzy z ręcznym pixel_x/y na mapie), null gdy przesunięcia brak.
/proc/paradise_wall_dir_from_pixels(atom/movable/A)
	if(!A.pixel_x && !A.pixel_y)
		return null
	if(abs(A.pixel_y) >= abs(A.pixel_x))
		return A.pixel_y > 0 ? NORTH : SOUTH
	return A.pixel_x > 0 ? EAST : WEST

/proc/paradise_wallmount_offset(atom/movable/A, wall_dir)
	A.pixel_x = 0
	A.pixel_y = 0
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

/obj/machinery/power/apc/Initialize(mapload)
	. = ..()
	var/wall_dir = paradise_wall_dir_from_pixels(src) || dir
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

/obj/machinery/firealarm/Initialize(mapload, dir, building)
	. = ..()
	var/wall_dir = paradise_wall_dir_from_pixels(src) || turn(src.dir, 180)
	setDir(turn(wall_dir, 180))
	paradise_wallmount_offset(src, wall_dir)

#undef PARADISE_WALLMOUNT_OFFSET
