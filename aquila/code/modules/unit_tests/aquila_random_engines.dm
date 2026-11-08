// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - losowe silniki Trawnika i Padalca: każdy spawner silnika dostaje dokładnie swoje warianty,
/// rozmiar pliku zgadza się z zadeklarowanym (inaczej spawner po cichu nic nie postawi),
/// a każdy reaktor Stormdrive w szablonie ma konsolę z tym samym reactor_id.
/datum/unit_test/aquila_random_engines

/datum/unit_test/aquila_random_engines/Run()
	// spawner => liczba wariantów (Padalec: bez Tesli)
	var/list/spawners = list(
		/obj/effect/spawner/room/atlasengine = 3,
		/obj/effect/spawner/room/serendipity_engine = 3,
		/obj/effect/spawner/room/snake_engine = 2,
	)
	for(var/spawner_type in spawners)
		var/expected = spawners[spawner_type]
		var/obj/effect/spawner/room/spawner = spawner_type
		var/width = initial(spawner.room_width)
		var/height = initial(spawner.room_height)
		var/list/matching = list()
		for(var/template_type in subtypesof(/datum/map_template/random_room))
			var/datum/map_template/random_room/template = template_type
			if(initial(template.template_width) == width && initial(template.template_height) == height)
				matching += template_type
		TEST_ASSERT(length(matching) == expected, "[spawner_type] ([width]x[height]) ma [length(matching)] pasujących szablonów zamiast [expected]: [english_list(matching)]")
		for(var/template_type in matching)
			var/datum/map_template/random_room/template = new template_type()
			TEST_ASSERT(template.width == width && template.height == height, "[template_type]: plik [template.mappath] ma [template.width]x[template.height], a spawner [width]x[height]")
			var/text = file2text(template.mappath)
			if(!findtext(text, "stormdrive_reactor"))
				continue
			var/regex/ids = new(@'reactor_id = "([^"]+)"', "g")
			var/list/found = list()
			while(ids.Find(text))
				found[ids.group[1]]++
			TEST_ASSERT(length(found), "[template_type]: reaktor bez reactor_id, konsola go nie znajdzie")
			for(var/id in found)
				TEST_ASSERT(found[id] >= 2, "[template_type]: reactor_id \"[id]\" występuje [found[id]] raz, brakuje pary reaktor + konsola")

/// AQUILA - generator Tesli znika, gdy powstaje kula. Trwała struktura statku nie może go śledzić,
/// bo zapisany jako usunięty skasowałaby go w następnej rundzie z tym samym wariantem silnika.
/datum/unit_test/aquila_random_engines_tesla_persistence

/datum/unit_test/aquila_random_engines_tesla_persistence/Run()
	var/turf/T = run_loc_floor_bottom_left
	var/obj/machinery/the_singularitygen/tesla/generator = allocate(/obj/machinery/the_singularitygen/tesla, T)
	var/obj/machinery/power/emitter/emitter = allocate(/obj/machinery/power/emitter, T)
	var/datum/ship_structure/structure = new(list(T.z), list(T.x, T.y, T.x, T.y))
	var/list/tracked = structure.tracked_objs(T)
	TEST_ASSERT(emitter in tracked, "emiter powinien być częścią zapisywanej struktury (kontrola testu)")
	TEST_ASSERT(!(generator in tracked), "generator Tesli jest zapisywany w strukturze statku, więc po odpaleniu kuli zniknie w kolejnej rundzie")
	qdel(structure)

#undef TEST_ASSERT
