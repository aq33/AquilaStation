// aq33/AquilaStation#578 - losowy silnik na Trawniku i Padalcu (aquila/code/modules/mapping/random_engines.dm)

/datum/test_chamber_kit/pr_578_silniki
	name = "Losowe silniki Trawnika i Padalca"
	pr = "aq33/AquilaStation#578"
	description = "Silnik losuje się przy ładowaniu mapy, więc wariant jest stały dla rundy (który wypadł, napisze się w czacie po zrzuceniu zestawu, z linkiem do skoku). Każdy wariant (Trawnik: Tesla, Stormdrive, supermateria; Padalec: Stormdrive, supermateria) sprawdza się w osobnej rundzie. \
	1) Tesla (tylko Trawnik): przykręć i zespawaj cewki, generatory pola i emitery, odpal akcelerator. Kula ma zostać w polu, a monitor mocy w sterowni ma pokazać prąd. \
	2) Stormdrive: włóż pręty kontrolne ze skrzyń, puść plazmę z kanistra pompą paliwa i odpal akcelerator. Konsola reaktora ma pokazywać reaktor i prąd. \
	3) Supermateria: włóż butle z plazmą do kolektorów (dozownik na Trawniku stoi obok, na Padalcu w sterowni), przykręć kanister N2 do portu pętli (na Padalcu przynieś go ze sterowni), włącz pompy i zamrażarki, potem emitery. Odpad ma iść przez filtry do wtryskiwacza w kosmosie, a temperatura w komorze ma się ustabilizować. \
	4) Na wszystkich wariantach: brak dziur w ścianach i podłodze na granicy hali, działające drzwi, wenty i oświetlenie."
	items = list(
		/obj/item/geiger_counter = 1,
		/obj/item/clothing/glasses/meson/engine = 1,
		/obj/item/clothing/suit/radiation = 1,
		/obj/item/clothing/head/radiation = 1,
		/obj/item/tank/internals/plasma = 6,
	)

/datum/test_chamber_kit/pr_578_silniki/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/datum/map_template/random_room/rolled
	for(var/id in SSmapping.random_room_templates)
		var/datum/map_template/random_room/template = SSmapping.random_room_templates[id]
		// losowe pokoje nie zwiększają `loaded` (to licznik ruin); wybrany szablon ma `spawned`
		if(template.spawned && (findtext(id, "aq_engine_") || findtext(id, "_eng_atl_")))
			rolled = template
			break
	if(!rolled)
		to_chat(user, "<span class='warning'>Ta mapa nie ma losowego silnika (są na Atlasie, Trawniku i Padalcu).</span>")
		return
	to_chat(user, "<span class='notice'>W tej rundzie wylosowany silnik: [rolled.name].</span>")
	var/atom/engine
	if(findtext(rolled.room_id, "supermatter"))
		engine = GLOB.main_supermatter_engine
	else if(findtext(rolled.room_id, "tesla"))
		engine = (locate(/obj/machinery/the_singularitygen/tesla) in GLOB.machines) || (locate(/obj/anomaly/energy_ball) in world)
	else
		for(var/obj/machinery/atmospherics/components/binary/stormdrive_reactor/reactor in GLOB.machines)
			// pomija zepsuty drugi reaktor Padalca (stan 4 = REACTOR_STATE_MELTDOWN, define jest #undef w stormdrive.dm)
			if(is_station_level(reactor.z) && reactor.state != 4)
				engine = reactor
				break
	if(engine)
		to_chat(user, "<span class='notice'>Silnik: [ADMIN_VERBOSEJMP(engine)]</span>")
