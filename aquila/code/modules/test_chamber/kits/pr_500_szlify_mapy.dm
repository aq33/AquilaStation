/datum/test_chamber_kit/pr_500
	name = "Szlify map, przezroczyste okna"
	pr = "aq33/AquilaStation#500"
	description = "Okna: rząd wzmocnionych okien ma być półprzezroczysty jak w Paradise - pod szybą widać kratę, a pod oknem bez kraty podłogę i kabel. \
		Ciemnego wypełnienia pod szybą ma nie być, rama okna i łączenie z sąsiednimi oknami bez zmian. Rozbij jedno okno i sprawdź, czy sąsiednie przeliczają łączenia. \
		Zegar i zaawansowany monitor mają działać jak na mapach (monitor łączy się ze stołem operacyjnym). \
		Na stacji obejrzyj zegary (np. Atlas z1 126,118 i 139,110; Trawnik z2 98-100,137), monitor w chirurgii Atlasa z2 150,104 i w traumie Trawnika z2 112,158, \
		rowery w więzieniach (Atlas z1 135,145; Trawnik z2 149,151), exodrony u kwatermistrza Trawnika (z1 102-108,124-127) i kuźnię Trawnika (z2 145-152,117-123)."
	items = list(
		/obj/effect/spawner/structure/window/reinforced = 1,
		/obj/structure/window/fulltile = 1,
		/obj/structure/window/plasma/reinforced/fulltile = 1,
		/obj/structure/cable/yellow = 1,
		/obj/machinery/digital_clock = 1,
		/obj/structure/table/optable = 1,
		/obj/machinery/vitals_reader/advanced = 1,
		/obj/item/weldingtool/experimental = 1,
	)

/// Rząd czterech okien z kratą obok pierwszego, żeby było widać łączenie i szybę na dłuższym odcinku
/datum/test_chamber_kit/pr_500/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/turf/start = turfs[1]
	for(var/i in 1 to 3)
		var/turf/T = locate(start.x + i, start.y, start.z)
		if(T && !T.density && !(locate(/obj/structure) in T))
			new /obj/effect/spawner/structure/window/reinforced(T)
