/datum/buildmode_mode/mapgen
	key = "mapgen"

	use_corner_selection = TRUE
	var/generator_path

/datum/buildmode_mode/mapgen/show_help(client/c)
	to_chat(c, "<span class='notice'>***********************************************************</span>")
	to_chat(c, "<span class='notice'>LPM na turfie/obiekcie/mobie      = Wybierz róg</span>")
	to_chat(c, "<span class='notice'>PPM na przycisku trybu budowania = Wybierz generator</span>")
	to_chat(c, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/mapgen/change_settings(client/c)
	var/list/gen_paths = subtypesof(/datum/mapGenerator)
	var/list/options = list()
	for(var/path in gen_paths)
		var/datum/mapGenerator/MP = path
		options[initial(MP.buildmode_name)] = path
	var/type = input(c,"Wybierz typ generatora","Typ") as null|anything in options
	if(!type)
		return

	generator_path = options[type]
	deselect_region()

/datum/buildmode_mode/mapgen/handle_click(client/c, params, obj/object)
	if(isnull(generator_path))
		to_chat(c, "<span class='warning'>Najpierw wybierz typ generatora.</span>")
		deselect_region()
		return
	..()

/datum/buildmode_mode/mapgen/handle_selected_area(client/c, params)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	if(left_click)
		var/datum/mapGenerator/G = new generator_path
		if(istype(G, /datum/mapGenerator/repair/reload_station_map))
			if(GLOB.reloading_map)
				to_chat(c, "<span class='boldwarning'>Już przeładowujesz obszar! Zaczekaj, aż skończy się ładować, zanim załadujesz kolejny!</span>")
				deselect_region()
				return
		G.defineRegion(cornerA, cornerB, 1)
		highlight_region(G.map)
		var/confirm = alert("Na pewno chcesz uruchomić generator mapy?", "Uruchom generator", "Tak", "Nie")
		if(confirm == "Tak")
			G.generate()
		log_admin("Build Mode: [key_name(c)] ran the map generator '[G.buildmode_name]' in the region from [AREACOORD(cornerA)] to [AREACOORD(cornerB)]")
