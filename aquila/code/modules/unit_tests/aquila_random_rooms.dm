// Bez return: test zgłasza wszystkie błędne szablony naraz, nie tylko pierwszy
#define CHECK(assertion, reason) if (!(assertion)) { Fail(reason) }

/// AQUILA - losowe pokoje (/obj/effect/spawner/room) dobierają szablon wyłącznie po rozmiarze, więc pomyłka nie daje błędu:
/// spawner po cichu nic nie stawia albo wybiera cudzy szablon. Test pilnuje, żeby:
/// - dwa typy spawnerów nie miały tego samego rozmiaru (zabierałyby sobie szablony, np. silnik Atlasa trafiłby na inny statek),
/// - każdy spawner miał co najmniej jeden szablon swojego rozmiaru, a każdy szablon pasował do jakiegoś spawnera,
/// - plik mapy miał rozmiar zadeklarowany w template_width/template_height,
/// - room_id był unikalny (SSmapping.random_room_templates jest po nim indeksowane, duplikat nadpisuje szablon).
/datum/unit_test/aquila_random_rooms

/datum/unit_test/aquila_random_rooms/Run()
	var/list/spawner_by_size = list()
	for(var/obj/effect/spawner/room/spawner_type as anything in subtypesof(/obj/effect/spawner/room))
		var/width = initial(spawner_type.room_width)
		var/height = initial(spawner_type.room_height)
		if(!width || !height)
			continue
		var/size = "[width]x[height]"
		CHECK(!spawner_by_size[size], "[spawner_type] i [spawner_by_size[size]] mają ten sam rozmiar [size], więc losują z tej samej puli szablonów")
		spawner_by_size[size] = spawner_type

	var/list/template_sizes = list()
	var/list/room_ids = list()
	for(var/datum/map_template/random_room/template_type as anything in subtypesof(/datum/map_template/random_room))
		if(!initial(template_type.mappath))
			continue
		var/id = initial(template_type.room_id)
		CHECK(id, "[template_type] nie ma room_id")
		CHECK(!room_ids[id], "[template_type] i [room_ids[id]] mają ten sam room_id \"[id]\", jeden nadpisze drugi")
		room_ids[id] = template_type
		var/datum/map_template/random_room/template = SSmapping.random_room_templates[id]
		if(!template)
			Fail("[template_type] nie trafił do SSmapping.random_room_templates")
			continue
		var/size = "[template.template_width]x[template.template_height]"
		CHECK(spawner_by_size[size], "[template_type] ([size]) nie pasuje do żadnego spawnera, więc nigdy się nie pojawi")
		CHECK(template.width == template.template_width && template.height == template.template_height, "[template_type]: plik [template.mappath] ma [template.width]x[template.height], a szablon deklaruje [size]")
		template_sizes[size]++

	for(var/size in spawner_by_size)
		CHECK(template_sizes[size], "[spawner_by_size[size]] ([size]) nie ma żadnego szablonu, więc nic nie postawi")

#undef CHECK
