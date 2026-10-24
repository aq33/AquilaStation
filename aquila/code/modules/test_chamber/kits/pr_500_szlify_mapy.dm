/datum/test_chamber_kit/pr_500
	name = "Szlify map, przezroczyste okna"
	pr = "aq33/AquilaStation#500"
	description = "Okna: rząd wzmocnionych okien ma być półprzezroczysty jak w Paradise - pod szybą widać kratę, a pod oknem bez kraty podłogę i kabel. \
		Ciemnego wypełnienia pod szybą ma nie być, rama okna i łączenie z sąsiednimi oknami bez zmian. Rozbij jedno okno i sprawdź, czy sąsiednie przeliczają łączenia. \
		Zegar i zaawansowany monitor mają działać jak na mapach (monitor łączy się ze stołem operacyjnym). \
		Na stacji obejrzyj zegary (np. Atlas z1 126,118 i 139,110; Trawnik z2 98-100,137), monitor w chirurgii Atlasa z2 150,104 i w traumie Trawnika z2 112,158, \
		rowery w więzieniach (Atlas z1 135,145; Trawnik z2 149,151), exodrony u kwatermistrza Trawnika (z1 102-108,124-127) i kuźnię Trawnika (z2 145-152,117-123)."
	items = list(
		/obj/structure/window/reinforced/fulltile = 4,
		/obj/structure/window/fulltile = 1,
		/obj/structure/window/plasma/reinforced/fulltile = 1,
		/obj/structure/cable/yellow = 1,
		/obj/machinery/digital_clock = 1,
		/obj/structure/table/optable = 1,
		/obj/machinery/vitals_reader/advanced = 1,
		/obj/item/weldingtool/experimental = 1,
	)

/// Cztery wzmocnione okna z kratą w jednym rzędzie, żeby było widać łączenie i szybę na dłuższym odcinku.
/// Spawner okna usuwa się po zrzuceniu (test komory by go nie policzył), więc krata i szyba idą osobno.
/datum/test_chamber_kit/pr_500/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/list/windows = list()
	for(var/obj/structure/window/reinforced/fulltile/W in spawned)
		windows += W
	if(!length(windows))
		return
	var/turf/start = get_turf(windows[1])
	for(var/i in 1 to length(windows))
		var/turf/T = locate(start.x + i - 1, start.y, start.z)
		if(i > 1 && (!T || T.density || (locate(/obj/structure) in T)))
			T = start
		var/obj/structure/window/W = windows[i]
		W.forceMove(T)
		if(!(locate(/obj/structure/grille) in T))
			new /obj/structure/grille(T)
	for(var/obj/structure/window/W as anything in windows)
		queue_smooth(W)
		queue_smooth_neighbors(W)
