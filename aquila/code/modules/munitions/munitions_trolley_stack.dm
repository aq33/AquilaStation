// Stos amunicji na wózku: każdy pocisk wyśrodkowany i 5 px nad poprzednim, w kolejności ładowania.
// NSV ustawiał tylko wysokość, więc pocisk zostawał z losowym przesunięciem w bok z upuszczenia (dropItemToGround)
// albo z rozrzutu po rzucie (item_scatter.dm). Po zdjęciu jednego pocisku NSV przeliczał wysokości od końca listy,
// co odwracało kolejność stosu.

/obj/structure/munitions_trolley/load_trolley(atom/movable/A, mob/user)
	. = ..()
	if(A.loc == src)
		aq_restack()

/obj/structure/munitions_trolley/unload_munition(atom/movable/A)
	. = ..()
	aq_restack()

/// Układa amunicję w stos od pierwszej załadowanej; późniejsza leży wyżej i rysuje się na wierzchu
/obj/structure/munitions_trolley/proc/aq_restack()
	var/index = 0
	for(var/atom/movable/munition as anything in contents)
		if(!allowed[munition.type])
			continue
		munition.pixel_x = initial(munition.pixel_x)
		munition.pixel_y = 5 + index * 5
		munition.layer = ABOVE_MOB_LAYER + index * 0.001
		index++
