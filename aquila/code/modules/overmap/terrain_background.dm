/// AQUILA - warstwa środkowa tła według terenu układu (kafel mapy hex albo typ układu NSV, hazard_terrain() w
/// hazards/hazard_spawn.dm). Dalekie tło to parallax_property układu (ftl_parallax z nsv13), ta warstwa leży nad nim:
/// pył, szczątki, mgła, błyski, zorza, poświata gwiazdy, karpie w oddali. Bez nowych sprite'ów: cząsteczki BYOND i
/// ikony gry (light_352, parallax.dmi, skały overmapy, karpie). Teren ustawia się na poziomach okrętu przy skoku FTL
/// (jump_end, force_parallax_update); warstwa sama sprawdza go przy każdej aktualizacji paralaksy.
/// Wzór dokładania warstwy: szczeliny kultu krwi (bloodcult_eclipse_parallax). Na niskich ustawieniach paralaksy jej nie ma.

/// Środek widoku względem warstwy (warstwa stoi na CENTER-7,CENTER-7); widok to mniej więcej -112..560 x -16..464 pikseli
/// od warstwy, a warstwa przesuwa się o pół obrazu (240 px), więc cząsteczki rozsiewamy na widoku z takim zapasem
#define TERRAIN_VIEW_CENTER 240

/datum/space_level
	/// AQUILA - teren układu, w którym jest okręt tego poziomu (warstwa środkowa tła); null = bez warstwy
	var/mid_terrain

/atom/movable/screen/parallax_layer/terrain_mid
	icon = null
	icon_state = null
	speed = 0.8
	layer = HUD_LAYER + 0.1 // nad tłem układu (ftl_parallax na HUD_LAYER), pod obiektami
	tesselate = FALSE
	/// Teren, którego wygląd jest teraz nałożony
	var/terrain

/atom/movable/screen/parallax_layer/terrain_mid/update_status(mob/M)
	. = ..()
	var/datum/space_level/SL = M?.z ? SSmapping.z_list[M.z] : null
	var/new_terrain = (SL && SL.parallax_property != "transit") ? SL.mid_terrain : null
	if(new_terrain != terrain)
		apply_terrain(new_terrain)

/atom/movable/screen/parallax_layer/terrain_mid/update_o(view)
	. = ..()
	apply_terrain(terrain) // update_o czyści nakładki

/// Nakłada wygląd terenu: nakładki z ikon gry, cząsteczki i filtry
/atom/movable/screen/parallax_layer/terrain_mid/proc/apply_terrain(new_terrain)
	terrain = new_terrain
	cut_overlays()
	particles = null
	filters = null
	animate(src)
	alpha = 255
	transform = null
	blend_mode = BLEND_ADD
	switch(terrain)
		if("meteor")
			particles = new /particles/terrain_dust
		if("junk")
			particles = new /particles/terrain_debris
		if("nebula")
			add_sheet("nebula", "#e0a0ff", 200)
		if("estorm")
			add_sheet("gas", "#8090c8", 170)
			particles = new /particles/terrain_lightning
		if("storm")
			add_sheet("nebula", "#60ffd0", 150)
			filters += filter(type = "wave", x = 48, y = 0, size = 6, offset = 0)
			animate(filters[length(filters)], offset = 1, time = 40 SECONDS, loop = -1)
		if("rad")
			add_sheet("gas", "#90ff70", 100)
			particles = new /particles/terrain_grain
		if("flare")
			add_glow("#ffd27a", 120, 3, 280, 200)
			animate(src, alpha = 170, time = 4 SECONDS, loop = -1, easing = SINE_EASING)
			animate(alpha = 255, time = 4 SECONDS, easing = SINE_EASING)
		if("anom")
			add_sheet("nebula", "#b070ff", 140)
			filters += filter(type = "ripple", radius = 0, size = 12, repeat = 6, falloff = 1)
			animate(filters[length(filters)], radius = 600, time = 30 SECONDS, loop = -1)
		if("grav")
			add_glow("#e8e8ff", 30, 1.6, 0, 0)
			add_glow("#e8e8ff", 18, 2.6, 0, 0)
			filters += filter(type = "ripple", radius = 600, size = 10, repeat = 8, falloff = 1)
			animate(filters[length(filters)], radius = 0, time = 20 SECONDS, loop = -1) // fale ściągane do środka
		if("carp")
			blend_mode = BLEND_OVERLAY
			particles = new /particles/terrain_carp
		if("wh")
			add_sheet("nebula", "#6090ff", 150)
			filters += filter(type = "ripple", radius = 0, size = 16, repeat = 4, falloff = 0.6)
			animate(filters[length(filters)], radius = 500, time = 15 SECONDS, loop = -1)
		if("comet")
			add_glow("#cfe6ff", 80, 4, 40, 80, 0.3, -25)
			add_glow("#ffffff", 230, 0.12, 290, 200)
		if("mines")
			blend_mode = BLEND_OVERLAY
			particles = new /particles/terrain_mine_blink

/// Obraz z parallax.dmi zabarwiony i powielony 3 x 3 (warstwa przesuwa się o pół obrazu w każdą stronę)
/atom/movable/screen/parallax_layer/terrain_mid/proc/add_sheet(state, tint, sheet_alpha)
	var/list/new_overlays = list()
	for(var/x in -1 to 1)
		for(var/y in -1 to 1)
			var/mutable_appearance/sheet = mutable_appearance('icons/effects/parallax.dmi', state, alpha = sheet_alpha, color = tint)
			sheet.transform = matrix(1, 0, x * 480, 0, 1, y * 480)
			new_overlays += sheet
	add_overlay(new_overlays)

/// Miękka poświata (light_352) w punkcie (dx, dy) od środka widoku, skalowana; stretch i angle dla smug
/atom/movable/screen/parallax_layer/terrain_mid/proc/add_glow(tint, glow_alpha, scale, dx, dy, stretch = 1, angle = 0)
	var/mutable_appearance/glow = mutable_appearance('icons/effects/light_overlays/light_352.dmi', "light", alpha = glow_alpha, color = tint)
	var/matrix/M = matrix(scale, 0, 0, 0, scale * stretch, 0)
	if(angle)
		M.Turn(angle)
	M.Translate(TERRAIN_VIEW_CENTER - 176 + dx, TERRAIN_VIEW_CENTER - 176 + dy)
	glow.transform = M
	add_overlay(glow)

/// Dokłada warstwę środkową po zwykłych warstwach (poza najniższym ustawieniem paralaksy)
/datum/hud/create_parallax(mob/viewmob)
	. = ..()
	var/mob/screenmob = viewmob || mymob
	var/client/C = screenmob?.client
	if(!C || !length(C.parallax_layers) || C.prefs?.parallax == PARALLAX_LOW)
		return
	var/atom/movable/screen/parallax_layer/terrain_mid/mid = locate() in C.parallax_layers_cached
	if(!mid)
		mid = new(null, C.view)
		C.parallax_layers_cached += mid
	C.parallax_layers |= mid
	C.screen |= mid

/// Ustawia teren tła na poziomach okrętu i odświeża paralaksę załogi
/obj/structure/overmap/proc/update_terrain_background(datum/star_system/system)
	var/terrain = system?.hazard_terrain()
	var/list/levels = list()
	if(reserved_z)
		var/datum/space_level/reserved = SSmapping.z_list[reserved_z]
		reserved.mid_terrain = terrain
		levels += reserved_z
	for(var/datum/space_level/SL as anything in occupying_levels)
		SL.mid_terrain = terrain
		levels += SL.z_value
	// wszyscy gracze na tych poziomach, także duchy i goście spoza załogi (mobs_in_ship ich nie ma)
	for(var/mob/M as anything in GLOB.player_list)
		if((M.z in levels) && M.client && M.hud_used && length(M.client.parallax_layers))
			M.hud_used.update_parallax(force = TRUE)

/obj/structure/overmap/jump_end(datum/star_system/target_system, misjump = FALSE)
	. = ..()
	update_terrain_background(current_system || target_system)

/obj/structure/overmap/force_parallax_update(ftl_start)
	. = ..()
	update_terrain_background(ftl_start ? null : current_system)

// ---- Cząsteczki (pola rozrzutu obejmują widok z zapasem na przesuw warstwy o pół obrazu) ----

/particles/terrain_dust
	width = 2000
	height = 1600
	count = 420
	spawning = 10
	lifespan = 40 SECONDS
	fade = 5 SECONDS
	fadein = 5 SECONDS
	color = "#e6cfa8"
	position = generator("box", list(-360, -260, 0), list(800, 710, 0))
	velocity = generator("box", list(-0.25, -0.12, 0), list(0.25, 0.12, 0))
	scale = generator("num", 2, 3.2)

/particles/terrain_debris
	width = 2000
	height = 1600
	count = 110
	spawning = 3
	lifespan = 60 SECONDS
	fade = 6 SECONDS
	fadein = 6 SECONDS
	icon = 'nsv13/icons/overmap/stellarbodies/asteroidfield/icefield/asteroid_ice_32x.dmi'
	icon_state = list("particle-1" = 1, "particle-2" = 1, "particle-3" = 1, "particle-4" = 1, "particle-5" = 1)
	color = "#9aa0aa"
	position = generator("box", list(-360, -260, 0), list(800, 710, 0))
	velocity = generator("box", list(-0.2, -0.08, 0), list(0.2, 0.08, 0))
	scale = generator("num", 0.35, 0.6)
	spin = generator("num", -1, 1)

/particles/terrain_lightning
	width = 2000
	height = 1600
	count = 6
	spawning = 0.08
	lifespan = 8
	fade = 6
	icon = 'nsv13/goonstation/icons/effects/explosions/electricity.dmi'
	icon_state = "thundercloud"
	color = "#cfe0ffcc"
	position = generator("box", list(-120, -20, 0), list(560, 450, 0))
	scale = generator("num", 1, 1.6)

/particles/terrain_grain
	width = 2000
	height = 1600
	count = 420
	spawning = 40
	lifespan = 15
	fade = 10
	color = "#b6ff9a"
	scale = 2
	position = generator("box", list(-360, -260, 0), list(800, 710, 0))

/particles/terrain_carp
	width = 2000
	height = 1600
	count = 70
	spawning = 3
	lifespan = 80 SECONDS
	fade = 5 SECONDS
	fadein = 5 SECONDS
	icon = 'icons/mob/carp.dmi'
	icon_state = "carp"
	color = "#c8c8d8"
	position = generator("box", list(-360, -260, 0), list(800, 710, 0))
	velocity = generator("box", list(-0.1, -0.35, 0), list(0.1, -0.2, 0)) // karp z ikony patrzy na południe
	scale = generator("num", 0.55, 1)

/particles/terrain_mine_blink
	width = 2000
	height = 1600
	count = 22
	spawning = 0.4
	lifespan = 8 SECONDS
	fade = 3 SECONDS
	fadein = 1 SECONDS
	icon = 'nsv13/icons/overmap/effects.dmi'
	icon_state = "mine_syndicate"
	position = generator("box", list(-360, -260, 0), list(800, 710, 0))
	scale = generator("num", 0.6, 0.9)

#undef TERRAIN_VIEW_CENTER
