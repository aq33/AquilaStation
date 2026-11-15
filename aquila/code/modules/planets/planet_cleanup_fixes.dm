// AQUILA - poprawki ogólnych mechanik, które wyszły przy prawdziwym wczytywaniu ruin planet (PR aq33/AquilaStation#639).

// Zdolność moba znika razem z mobem, jak w tg (/datum/action/proc/clear_ref). U nas akcja przeżywała usunięcie moba,
// któremu dano ją jako zdolność (target = owner = mob, a mob trzymał akcję w zmiennej albo w kontrolerze AI): cykl
// referencji, twarde usunięcie i w testach kilkuminutowe szukanie referencji (np. losowy legion podmieniany na
// karłowatego, obserwator z oślepiającym spojrzeniem).

/datum/action/owner_deleted(datum/source)
	. = ..()
	// Zdolność moba (cel = właściciel): bez celu nie ma czego robić. Akcje przedmiotów sprząta sam przedmiot.
	if(source == target)
		target = null
		qdel(src)

// Miny z ruin planet (zamiast min naciskowych Shiptesta) odpalały się od przedmiotów i mobów pojawiających się podczas
// wczytywania ruiny, zanim reszta ruiny przeszła Initialize (setki runtime'ów „taking damage while having <= 0
// integrity” i zniszczone ruiny przed przylotem załogi). Mina postawiona z mapy uzbraja się chwilę po wczytaniu
// i reaguje tylko na żywe stworzenia, jak mina naciskowa. Mina postawiona w grze działa po staremu.

/obj/effect/mine
	/// Postawiona z mapy (ruiny): tylko żywe stworzenia i dopiero po uzbrojeniu
	var/map_placed = FALSE
	/// Od kiedy mina z mapy reaguje na wejście
	var/armed_at = 0

/obj/effect/mine/Initialize(mapload)
	. = ..()
	if(mapload)
		map_placed = TRUE
		armed_at = world.time + 5 SECONDS

/obj/effect/mine/on_entered(datum/source, atom/movable/AM)
	if(map_placed && (!isliving(AM) || world.time < armed_at))
		return
	return ..()

// Maszyna (APC, alarm, kamera) zostawała źródłem alarmu w GLOB.alarms po usunięciu: APC w Destroy() woła
// area.poweralert(FALSE, src), czyli podnosi alarm zasilania z samym sobą jako źródłem, a wpisu nikt potem nie czyści.
// Usunięte APC (np. z ruin planet przy znikaniu powierzchni) zostawało z ogniwem w pamięci (twarde usunięcie).
/obj/machinery/Destroy()
	. = ..()
	for(var/alarm_class in GLOB.alarms)
		var/list/class_alarms = GLOB.alarms[alarm_class]
		for(var/area_name in class_alarms.Copy())
			var/list/alarm = class_alarms[area_name]
			var/list/sources = alarm?[3]
			if(!(src in sources))
				continue
			sources -= src
			if(!length(sources))
				class_alarms -= area_name
