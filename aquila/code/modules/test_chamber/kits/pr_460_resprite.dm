/datum/test_chamber_kit/pr_460
	name = "Struktury z Paradise"
	pr = "aq33/AquilaStation#460"
	description = "Pokój ze ścian 3/4 (narzędzia są w zestawie): śluzy z przodu i z boku (zwykła, otwarta, zaryglowana, zespawana, szklana), okna z kratami, fałszywa ściana, rozbierana ściana wzmocniona, drzwi przeciwpożarowe, grodzie, roleta, drzwi okienne, cienkie okna i dźwigar. \
		1) Obejrzyj ściany i śluzy z przodu i z boku → oczekiwane: w poziomej ścianie śluza jest widoczna z przodu, w pionowej z boku; ściany łączą się bez dziur. \
		2) Rozbierz ścianę wzmocnioną „d” w dolnym rzędzie (śrubokręt, spawarka, łom, cążki) i postaw w jej miejscu nową ścianę → oczekiwane: sąsiednie ściany przeliczają krawędzie przy rozbiórce i przy budowie, bez artefaktów. \
		3) Odkręć śrubokrętem okno z kratą → oczekiwane: okno schodzi, a ściany obok się wygładzają. \
		4) Otwórz kolejno śluzy → oczekiwane: animacja klatkami; okno nad śluzą zakrywa ją tylko wtedy, gdy śluza jest otwarta. \
		5) Negatyw: kliknij śluzę zaryglowaną i zespawaną → oczekiwane: nie otwierają się; zespawaną otworzysz dopiero po przecięciu spawu spawarką. Fałszywa ściana → oczekiwane: kliknięta ręką odsuwa się."
	items = list(
		/obj/item/screwdriver = 1,
		/obj/item/wrench = 1,
		/obj/item/weldingtool = 1,
		/obj/item/crowbar = 1,
		/obj/item/wirecutters = 1
	)

/datum/test_chamber_kit/pr_460/setup(list/spawned, list/turfs, turf/center, mob/user)
	// '#' ściana, 'R' wzmocniona, 'W' pełne okno z kratą, 'D' śluza, 'F' fałszywa ściana, 'd' rozbierana wzmocniona
	var/list/layout = list(
		"RRRWWWRRR",
		"#.......#",
		"D.......W",
		"#.......#",
		"#DdF#DD##")
	var/list/doors = list()
	var/skipped = 0
	for(var/row in 1 to length(layout))
		var/line = layout[row]
		for(var/col in 1 to length(line))
			var/turf/T = locate(center.x + col - 5, center.y + 3 - row, center.z)
			if(!T || !istype(T.loc, /area/test_chamber/arena))
				if(copytext(line, col, col + 1) != ".")
					skipped++
				continue
			switch(copytext(line, col, col + 1))
				if("#")
					T.PlaceOnTop(/turf/closed/wall)
				if("R")
					T.PlaceOnTop(/turf/closed/wall/r_wall)
				if("d")
					var/turf/closed/wall/r_wall/RW = T.PlaceOnTop(/turf/closed/wall/r_wall)
					RW.d_state = COVER
					RW.update_icon()
				if("W")
					new /obj/structure/grille(T)
					new /obj/structure/window/reinforced/fulltile(T)
				if("F")
					new /obj/structure/falsewall(T)
				if("D")
					doors += T
	var/list/door_types = list(/obj/machinery/door/airlock/ship/engineering/glass, /obj/machinery/door/airlock/ship/maintenance, /obj/machinery/door/airlock/ship/command, /obj/machinery/door/airlock/ship/public/glass)
	for(var/i in 1 to length(doors))
		var/door_type = door_types[min(i, length(door_types))]
		var/obj/machinery/door/airlock/A = new door_type(doors[i])
		switch(i)
			if(2)
				A.open()
			if(3)
				A.bolt()
			if(4)
				A.welded = TRUE
				A.update_icon()
	// Wnętrze: drzwi przeciwpożarowe, grodzie, roleta, drzwi okienne, cienkie okna, dźwigar
	var/list/inside = list(
		list(-3, 1, /obj/machinery/door/firedoor),
		list(-2, 1, /obj/machinery/door/poddoor/ship),
		list(-1, 1, /obj/machinery/door/poddoor/shutters/ship),
		list(0, 1, /obj/machinery/door/window/southleft),
		list(1, 1, /obj/structure/window/reinforced/spawner/north),
		list(2, 1, /obj/structure/girder),
		list(-3, -1, /obj/machinery/door/firedoor/border_only/directional/south),
		list(2, -1, /obj/structure/window/reinforced/fulltile/unanchored))
	for(var/list/entry in inside)
		var/turf/T = locate(center.x + entry[1], center.y + entry[2], center.z)
		if(!T || !istype(T.loc, /area/test_chamber/arena))
			skipped++
			continue
		var/spawn_type = entry[3]
		var/atom/spawned_thing = new spawn_type(T)
		if(istype(spawned_thing, /obj/machinery/door/firedoor) || istype(spawned_thing, /obj/machinery/door/poddoor))
			var/obj/machinery/door/D = spawned_thing
			D.close()
	if(skipped)
		to_chat(user, "<span class='warning'>Arena jest mniejsza niż układ pokoju: [skipped] pól pominięto, więc część ścian, śluz i okien nie powstała.</span>")

/datum/test_chamber_kit/pr_460_podlogi
	name = "Podłogi i naklejki z Bee"
	pr = "aq33/AquilaStation#460"
	description = "Zielone naklejki płytek z Bee: pełna, połówka, antynarożnik, narożnik, rampy i przeciwległe rogi, a dalej płaty dywanu, trawy i szklanej podłogi po 2x2 kafle. \
		1) Obejrzyj naklejki → oczekiwane: są półprzezroczyste, a rampy dają ukośne przejście. \
		2) Obejrzyj płaty dywanu, trawy i szkła → oczekiwane: sąsiednie kafle łączą się bitmaską w jedną powierzchnię, a krawędzie płatu mają osobne rogi. \
		3) Negatyw: rozbierz łomem jeden kafel dywanu ze środka płatu → oczekiwane: pozostałe kafle przeliczają krawędzie, bez dziur ani artefaktów."
	/// Naklejki rozkładają się na podłogę i same znikają, więc nie idą przez items (test liczy obiekty)
	var/list/decals = list(
		/obj/effect/turf_decal/tile/green/fourcorners,
		/obj/effect/turf_decal/tile/green/half,
		/obj/effect/turf_decal/tile/green/anticorner,
		/obj/effect/turf_decal/tile/green,
		/obj/effect/turf_decal/tile/green/corner_ramp,
		/obj/effect/turf_decal/tile/green/anticorner_ramp,
		/obj/effect/turf_decal/tile/green/opposingcorners
	)
	/// Płaty podłóg z Bee, które łączą się bitmaską
	var/list/patches = list(
		/turf/open/floor/carpet,
		/turf/open/floor/grass,
		/turf/open/floor/glass
	)

/datum/test_chamber_kit/pr_460_podlogi/setup(list/spawned, list/turfs, turf/center, mob/user)
	for(var/i in 1 to min(length(decals), length(turfs)))
		var/decal_type = decals[i]
		new decal_type(turfs[i])
	// Każdy płat to 2x2 kafle: pole z listy i jego sąsiedzi na wschód, północ i północny wschód
	var/index = length(decals) + 1
	for(var/patch_type in patches)
		if(index > length(turfs))
			break
		var/turf/base = turfs[index]
		index += 4
		for(var/turf/T in list(base, get_step(base, EAST), get_step(base, NORTH), get_step(base, NORTHEAST)))
			if(isfloorturf(T) && istype(T.loc, /area/test_chamber/arena))
				T.PlaceOnTop(patch_type)
