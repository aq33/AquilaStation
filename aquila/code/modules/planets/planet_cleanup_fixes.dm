// AQUILA - poprawki ogólnych mechanik, które wyszły przy prawdziwym wczytywaniu ruin planet (PR aq33/AquilaStation#639).

// Zdolność moba nie trzyma usuniętego moba. U nas akcja dana mobowi jako zdolność (target = owner = mob, a mob trzymał
// akcję w zmiennej albo w kontrolerze AI) tworzyła cykl referencji: twarde usunięcie i w testach kilkuminutowe szukanie
// referencji (np. losowy legion podmieniany na karłowatego, obserwator z oślepiającym spojrzeniem). Wystarczy zerwać
// cel; akcji nie usuwamy, bo konsole kamer i dokowania tworzą akcje raz i przy każdym użyciu ustawiają target na
// użytkownika (usunięta akcja psuła konsolę do końca rundy, a kamera overmapy nie sprzątała swojego oka).

/datum/action/owner_deleted(datum/source)
	. = ..()
	if(source == target)
		target = null

// Miny z ruin planet (zamiast min naciskowych Shiptesta) odpalały się od przedmiotów i mobów pojawiających się podczas
// wczytywania ruiny, zanim reszta ruiny przeszła Initialize (setki runtime'ów „taking damage while having <= 0
// integrity” i zniszczone ruiny przed przylotem załogi). Mina z ruiny planety uzbraja się chwilę po wczytaniu
// i reaguje tylko na żywe stworzenia, jak mina naciskowa. Inne miny działają po staremu.

/obj/effect/mine
	/// Postawiona z mapy (ruiny): tylko żywe stworzenia i dopiero po uzbrojeniu
	var/map_placed = FALSE
	/// Od kiedy mina z mapy reaguje na wejście
	var/armed_at = 0

/obj/effect/mine/Initialize(mapload)
	. = ..()
	// Tylko miny z ruin na powierzchni planety: miny z innych map (domeny bitrunnera, ruiny NSV) działają po staremu
	if(mapload && istype(SSmapping.used_turfs[get_turf(src)], /datum/turf_reservation/planet))
		map_placed = TRUE
		armed_at = world.time + 5 SECONDS

/obj/effect/mine/on_entered(datum/source, atom/movable/AM)
	if(map_placed && (!isliving(AM) || world.time < armed_at))
		return
	return ..()

// Maszyna (APC, alarm, kamera) zostawała źródłem alarmu w GLOB.alarms po usunięciu: APC w Destroy() woła
// area.poweralert(FALSE, src), czyli podnosi alarm zasilania z samym sobą jako źródłem, a wpisu nikt potem nie czyści.
// Usunięte APC z ruin (np. planet przy znikaniu powierzchni) zostawało z ogniwem w pamięci (twarde usunięcie). Tylko
// obszary ruin: na okręcie alarm zniszczonego APC ma zostać widoczny na konsolach alarmów.
/obj/machinery/Destroy()
	var/area/machine_area = get_area(src)
	. = ..()
	if(!istype(machine_area, /area/ruin))
		return
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
