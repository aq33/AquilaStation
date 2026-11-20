// AQUILA - zejście promu z wnętrzem na planetę i start z niej, widziane z pokładu. Zamiast natychmiastowego dokowania
// prom przez kilka sekund schodzi: planeta za oknami rośnie, aż wypełni niebo (warstwa planety z planet_sky.dm),
// kadłub żarzy się w atmosferze, przez niebo lecą smugi, pod promem rośnie teren lądowiska z cieniem kadłuba,
// a na końcu prom dokuje na lądowisku z bryzgami albo kurzem. Start z planety pokazuje to samo w odwrotnej kolejności.
// Widok z ziemi i dźwięki (port z voidcrew/Voidcrew#588) są w planet_landing_view.dm, prawdziwy teren lądowiska pod
// promem w planet_landing_ground.dm.

/// Fazy zejścia (czas trwania każdej)
#define PLANET_DESCENT_ZOOM (3.5 SECONDS)
#define PLANET_DESCENT_REENTRY (2.5 SECONDS)
#define PLANET_DESCENT_APPROACH (3.5 SECONDS)
/// Start z planety: chmury i niebo, potem planeta maleje do zwykłej wielkości
#define PLANET_ASCENT_SKY (2.5 SECONDS)
#define PLANET_ASCENT_ZOOM (4 SECONDS)
/// Powiększenie tarczy, przy którym planeta wypełnia niebo, i przy którym teren pod promem ma piksele wielkości pól
#define PLANET_DESCENT_SKY_SCALE 18
#define PLANET_DESCENT_GROUND_SCALE 48
/// Ile razy większy od kadłuba jest cień na początku podejścia (prom wysoko nad ziemią)
#define PLANET_DESCENT_SHADOW_SCALE 2
/// Wielkość prawdziwego terenu pod promem (względem prawdziwej), gdy wyłania się spod chmur, i jak długo przed
/// przyziemieniem osiąga pełną wielkość
#define PLANET_DESCENT_GROUND_START 0.3
#define PLANET_DESCENT_GROUND_SETTLE (0.2 SECONDS)
/// Start z planety: teren pod promem maleje do tej wielkości i blednie
#define PLANET_ASCENT_GROUND_END 0.3
#define PLANET_ASCENT_GROUND_TIME (2 SECONDS)
/// Widok z ziemi: cień na lądowisku i spadający obraz promu pojawiają się tyle przed przyziemieniem
#define PLANET_DESCENT_GROUND_SHADOW_LEAD (6 SECONDS)
#define PLANET_DESCENT_GROUND_PROXY_LEAD (3 SECONDS)
/// Kurz przy przyziemieniu: szansa na pole krawędzi i najwięcej obłoczków
#define PLANET_TOUCHDOWN_DUST_CHANCE 40
#define PLANET_TOUCHDOWN_DUST_MAX 12

/obj/structure/overmap/small_craft/transport
	/// Trwające zejście na planetę (prom wisi nad nią i nie da się nim sterować)
	var/datum/planet_descent/planet_descent

/obj/structure/overmap/small_craft/transport/Destroy()
	QDEL_NULL(planet_descent)
	return ..()

/obj/structure/overmap/small_craft/transport/can_move()
	if(planet_descent)
		return FALSE
	return ..()

/// Trwające zejścia (obrysy ich lądowisk są zajęte dla innych promów)
GLOBAL_LIST_EMPTY(planet_descents)

/// Czy pole leży w obrysie lądowiska innego promu, który właśnie schodzi
/proc/planet_descent_reserved(turf/T, obj/structure/overmap/small_craft/transport/asking)
	for(var/datum/planet_descent/descent as anything in GLOB.planet_descents)
		if(descent.craft != asking && descent.footprint[T])
			return TRUE
	return FALSE

/// Zejście jednego promu na wybrany port na powierzchni planety
/datum/planet_descent
	var/obj/structure/overmap/small_craft/transport/craft
	var/obj/structure/overmap/planet/planet
	var/obj/docking_port/stationary/port
	/// Czy właśnie dokujemy na końcu zejścia (wtedy shuttle_land przepuszcza dokowanie)
	var/finishing = FALSE
	/// Cień kadłuba nad terenem w ostatniej fazie
	var/obj/effect/abstract/planet_descent_shadow/shadow
	/// Warstwy planety ludzi, którzy oglądają zejście (zapamiętane na starcie: po dokowaniu ludzie należą już do planety)
	var/list/viewers = list()
	/// Pola, na których stanie kadłub (zajęte dla innych promów do końca zejścia)
	var/list/footprint = list()
	/// Ludzie z pomarańczową poświatą w kabinie (zdejmowana po przejściu przez atmosferę albo przy przerwaniu)
	var/list/tinted = list()
	var/list/timers = list()
	/// Pola kadłuba w locie i pola lądowiska, na których każde z nich stanie (ta sama kolejność)
	var/list/hull_order = list()
	var/list/berth = list()
	/// O ile stopni (zgodnie ze wskazówkami zegara) dokowanie obróci kadłub
	var/rotation = 0
	/// world.time przyziemienia
	var/touchdown_time
	/// Widok z ziemi: cień kadłuba na lądowisku i spadający obraz promu (planet_landing_view.dm)
	var/obj/effect/abstract/planet_descent_shadow/ground/ground_shadow
	var/obj/effect/abstract/planet_landing_proxy/ground_proxy
	/// Prawdziwy teren lądowiska pod promem w ostatniej fazie (planet_landing_ground.dm)
	var/datum/planet_ground_view/ground_view
	/// Prom zadokował: przy usuwaniu pokaz kończy się od razu, a nie blednie jak przy przerwanym zejściu
	var/landed = FALSE

/datum/planet_descent/New(obj/structure/overmap/small_craft/transport/new_craft, obj/structure/overmap/planet/new_planet, obj/docking_port/stationary/new_port)
	craft = new_craft
	planet = new_planet
	port = new_port
	// To samo przesunięcie co w planet_landing_footprint, z parą pole kadłuba - pole lądowiska dla obrazu promu i okien
	if(!length(craft.hull_offsets))
		craft.shuttle_cache_offsets()
	var/obj/docking_port/mobile/shuttle = craft.shuttle_port
	var/list/turned = craft.shuttle_rotate_offsets(craft.hull_offsets, port.dir)
	for(var/i in 1 to length(turned))
		var/list/offset = craft.hull_offsets[i]
		var/list/turned_offset = turned[i]
		var/turf/berth_turf = locate(port.x + turned_offset[1], port.y + turned_offset[2], port.z)
		if(!berth_turf)
			continue
		footprint[berth_turf] = TRUE
		var/turf/hull_turf = locate(shuttle.x + offset[1], shuttle.y + offset[2], shuttle.z)
		if(hull_turf)
			hull_order += hull_turf
			berth += berth_turf
	rotation = (dir2angle(port.dir) - dir2angle(shuttle.dir) + 360) % 360
	GLOB.planet_descents += src

/datum/planet_descent/Destroy()
	GLOB.planet_descents -= src
	footprint.Cut()
	for(var/timer in timers)
		deltimer(timer)
	timers.Cut()
	// Przerwane zejście: planeta, niebo i to, co widać z ziemi, bledną zamiast zniknąć
	stop_viewers(fade = !landed)
	clear_ground(fade = !landed)
	clear_cabin_glow()
	QDEL_NULL(shadow)
	hull_order = null
	berth = null
	// Zejście przerwane, zanim prom zadokował (prom zniszczony): port na powierzchni nikomu się już nie przyda
	if(istype(port, /obj/docking_port/stationary/shuttle_craft_spot) && !port.docked && !QDELETED(port))
		qdel(port, TRUE)
	if(craft?.planet_descent == src)
		craft.planet_descent = null
	craft = null
	planet = null
	port = null
	return ..()

/// Ludzie w promie z warstwą planety (bez paralaksy widzą tylko żar, cień i trzęsienie)
/datum/planet_descent/proc/viewer_layers()
	. = list()
	for(var/mob/M as anything in craft?.mobs_in_ship)
		var/atom/movable/screen/parallax_layer/planet_sky/sky = M.client ? locate() in M.client.parallax_layers_cached : null
		if(sky)
			. += sky

/datum/planet_descent/proc/stop_viewers(fade = FALSE)
	for(var/atom/movable/screen/parallax_layer/planet_sky/sky as anything in viewers)
		if(!QDELETED(sky))
			sky.end_descent(fade)
	viewers.Cut()

/datum/planet_descent/proc/start()
	var/datum/planet_type/planet_type = planet.planet_type
	// Prom zawisa nad planetą: z rozpędem odleciałby znad niej w trakcie zejścia i dokowanie na końcu by się nie udało
	craft.velocity._set(0, 0)
	craft.angular_velocity = 0
	craft.user_thrust_dir = 0
	craft.brakes = TRUE
	viewers = viewer_layers()
	for(var/atom/movable/screen/parallax_layer/planet_sky/sky as anything in viewers)
		sky.play_descent(planet_type)
	// Obrazy terenu pieką się w tle w czasie zbliżania i wejścia w atmosferę; obrazy z daleka tylko wtedy, gdy ktoś patrzy
	if(length(hull_order))
		ground_view = new(hull_order, berth, rotation, planet.surface?.reservation)
		ground_view.build_close()
		var/watching = FALSE
		for(var/mob/M as anything in craft.mobs_in_ship)
			if(M.client)
				watching = TRUE
				break
		if(watching)
			ground_view.bake_aerial()
		else
			ground_view.aerial_done = TRUE
	craft.relay(null, span_notice("[craft] schodzi z orbity nad [planet]. Trzymajcie się czegoś."))
	crew_sound('aquila/sound/planets/landing/spool.ogg', 50)
	shake_crew(2, 1)
	// Bez atmosfery (księżyc) nie ma żaru: od razu teren pod promem, jak w pokazie na warstwie planety
	var/reentry_at = PLANET_DESCENT_ZOOM
	var/approach_at = reentry_at
	if(planet_type.sky_atmosphere_color)
		approach_at += PLANET_DESCENT_REENTRY
		timers += addtimer(CALLBACK(src, PROC_REF(reentry)), reentry_at, TIMER_STOPPABLE)
	timers += addtimer(CALLBACK(src, PROC_REF(approach)), approach_at, TIMER_STOPPABLE)
	var/total = approach_at + PLANET_DESCENT_APPROACH
	touchdown_time = world.time + total
	timers += addtimer(CALLBACK(src, PROC_REF(finish)), total, TIMER_STOPPABLE)
	// Z ziemi: cień na lądowisku, spadający prom i kurz od dysz w ostatnich chwilach
	timers += addtimer(CALLBACK(src, PROC_REF(show_ground_shadow)), max(0, total - PLANET_DESCENT_GROUND_SHADOW_LEAD), TIMER_STOPPABLE)
	timers += addtimer(CALLBACK(src, PROC_REF(show_ground_proxy)), max(0, total - PLANET_DESCENT_GROUND_PROXY_LEAD), TIMER_STOPPABLE)
	for(var/lead in list(1.4 SECONDS, 0.9 SECONDS, 0.4 SECONDS))
		timers += addtimer(CALLBACK(src, PROC_REF(thruster_wash)), max(0, total - lead), TIMER_STOPPABLE)

/datum/planet_descent/proc/shake_crew(duration, strength)
	for(var/mob/M as anything in craft?.mobs_in_ship)
		if(M.client)
			shake_camera(M, duration, strength)

/// Wejście w atmosferę: żar na kosmosie przy kadłubie, wiatr, trzęsienie
/datum/planet_descent/proc/reentry()
	craft.relay(null, span_warning("Kadłub [craft] rozgrzewa się w atmosferze [planet], prom trzęsie się."))
	crew_sound('aquila/sound/planets/landing/entry.ogg', 65)
	shake_crew(PLANET_DESCENT_REENTRY / 2, 2)
	for(var/list/edge as anything in hull_edges(craft.shuttle_port))
		new /obj/effect/temp_visual/planet_reentry(edge[1], edge[2], PLANET_DESCENT_REENTRY)
	cabin_effects()

/// W kabinie bez okien też czuć wejście w atmosferę: pomarańczowa, pulsująca poświata i iskry z paneli. Bez migania
/// lamp (flicker() usypia i wysypuje się na lampie, której prom zniknął w trakcie)
/datum/planet_descent/proc/cabin_effects()
	for(var/mob/M as anything in craft.mobs_in_ship)
		if(!M.client)
			continue
		var/atom/movable/screen/fullscreen/glow = M.overlay_fullscreen("planet_reentry", /atom/movable/screen/fullscreen/color_vision/planet_reentry)
		glow.alpha = 0
		animate(glow, alpha = 70, time = 4, loop = -1)
		animate(alpha = 25, time = 4)
		tinted += M
	var/list/interior = list()
	for(var/area/A as anything in craft.shuttle_port?.shuttle_areas)
		for(var/turf/open/T in A)
			interior += T
	for(var/i in 1 to min(3, length(interior)))
		do_sparks(3, TRUE, pick(interior))

/datum/planet_descent/proc/clear_cabin_glow()
	for(var/mob/M as anything in tinted)
		if(!QDELETED(M))
			M.clear_fullscreen("planet_reentry", 10)
	tinted.Cut()

/// Ostatnia faza: pod promem teren, a cień kadłuba kurczy się z dużej, miękkiej plamy do obrysu promu (widać go z każdej
/// strony kadłuba, także zza ścian, które zasłaniają część nieba)
/datum/planet_descent/proc/approach()
	clear_cabin_glow()
	if(planet.planet_type.sky_atmosphere_color)
		craft.relay(null, span_notice("[craft] schodzi nad lądowisko."))
	crew_sound('aquila/sound/planets/landing/thrusters.ogg', 50)
	// Z nieba wyłania się prawdziwy teren lądowiska, mały, i rośnie do pełnej wielkości w chwili przyziemienia
	ground_view?.play(PLANET_DESCENT_GROUND_START, 1, PLANET_DESCENT_APPROACH - PLANET_DESCENT_GROUND_SETTLE, 0, 255, 0, 0.4 SECONDS)
	var/list/hull = shuttle_hull_turfs(craft.shuttle_port)
	if(!length(hull))
		return
	var/sum_x = 0
	var/sum_y = 0
	for(var/turf/T as anything in hull)
		sum_x += T.x
		sum_y += T.y
	var/turf/center = locate(round(sum_x / length(hull)), round(sum_y / length(hull)), craft.shuttle_port.z)
	shadow = new(center, hull)
	shadow.transform = matrix(PLANET_DESCENT_SHADOW_SCALE, 0, 0, 0, PLANET_DESCENT_SHADOW_SCALE, 0)
	animate(shadow, transform = matrix(), alpha = 170, time = PLANET_DESCENT_APPROACH, easing = SINE_EASING | EASE_OUT)

/// Przyziemienie: właściwe dokowanie na porcie; nie wyszło (okręt skoczył, prom zszedł z planety) = lądowanie przerwane
/datum/planet_descent/proc/finish()
	var/obj/structure/overmap/small_craft/transport/landing = craft
	var/obj/structure/overmap/planet/target = planet
	// Lądowisko mogło się zapełnić w trakcie zejścia (ktoś na nim stanął, coś postawiono): dokowanie zabiłoby ludzi
	// i usunęło przedmioty na polach kadłuba, więc lądowanie się przerywa
	if(!landing.planet_landing_spot_free(target, port))
		landing.relay(null, span_warning("Lądowisko pod [landing] jest zajęte. Komputer dokowania przerywa lądowanie."))
		if(istype(port, /obj/docking_port/stationary/shuttle_craft_spot) && !port.docked)
			qdel(port, TRUE)
		port = null
		qdel(src)
		if(!QDELETED(landing) && !QDELETED(target))
			landing.planet_landing_cancelled(target)
		return
	// Dokowanie usypia (CHECK_TICK w initiate_docking) przed przeniesieniem kadłuba: na ten czas obrys zamykają
	// niewidzialne blokady, żeby nikt nie wszedł na pole, które zaraz zajmie kadłub. toShuttleMove() je pomija
	// (AQ EDIT w on_move.dm), więc trzymają do przeniesienia kadłuba, a potem usuwa je ta procka
	var/list/blockers = list()
	for(var/turf/T as anything in footprint)
		blockers += new /obj/effect/planet_landing_blocker(T)
	// Obraz promu siada na ziemi tuż przed tym, jak stanie na niej prawdziwy kadłub
	if(ground_proxy)
		animate(ground_proxy, pixel_y = 0, time = 0.2 SECONDS, easing = QUAD_EASING | EASE_IN)
	var/list/site = berth.Copy()
	finishing = TRUE
	var/docked = landing.shuttle_land(target, port)
	finishing = FALSE
	QDEL_LIST(blockers)
	port = null // port przejął prom albo shuttle_land go usunął
	landed = docked
	qdel(src)
	if(!docked)
		if(!QDELETED(landing) && !QDELETED(target))
			landing.planet_landing_cancelled(target)
		return
	planet_touchdown_effects(landing.shuttle_port, target)
	// Po dokowaniu załoga też jest na planecie: przyziemienie słyszą i czują wszyscy przy lądowisku
	planet_landing_jolt(site, 'aquila/sound/planets/landing/touchdown.ogg', 70, shake_strength = 1)
	for(var/mob/M as anything in landing.mobs_in_ship)
		if(M.client)
			shake_camera(M, 3, 3)

/// Kosmos przy kadłubie: lista (pole, kierunek do kadłuba)
/proc/hull_edges(obj/docking_port/mobile/shuttle)
	. = list()
	if(!shuttle)
		return
	var/list/hull = list()
	for(var/turf/T as anything in shuttle_hull_turfs(shuttle))
		hull[T] = TRUE
	for(var/turf/T as anything in hull)
		for(var/dir in GLOB.cardinals)
			var/turf/outside = get_step(T, dir)
			if(outside && !hull[outside])
				. += list(list(outside, turn(dir, 180)))

/// Bryzgi na wodzie, kurz na lądzie wokół kadłuba stojącego na planecie. turfs: zamiast krawędzi kadłuba te pola, z kurzem
/// w losowych kierunkach i na każdym z nich
/proc/planet_touchdown_effects(obj/docking_port/mobile/shuttle, obj/structure/overmap/planet/planet, list/turfs)
	// lista (pole, kierunek, w którym kurz odlatuje od kadłuba)
	var/list/edges = list()
	if(turfs)
		for(var/turf/T as anything in turfs)
			edges += list(list(T, pick(GLOB.cardinals)))
	else
		for(var/list/edge as anything in shuffle(hull_edges(shuttle)))
			edges += list(list(edge[1], turn(edge[2], 180)))
	var/dust_color = planet_dust_color(planet)
	var/splashed = FALSE
	var/puffs = 0
	for(var/list/edge as anything in edges)
		var/turf/T = edge[1]
		if(istype(T, /turf/open/water) || istype(T, /turf/open/lava))
			if(turfs || prob(50))
				new /obj/effect/temp_visual/liquid_splash(T)
				splashed = TRUE
			continue
		if(T.density || (!turfs && (puffs >= PLANET_TOUCHDOWN_DUST_MAX || !prob(PLANET_TOUCHDOWN_DUST_CHANCE))))
			continue
		new /obj/effect/temp_visual/planet_landing_dust(T, edge[2], 1, dust_color)
		puffs++
	if(splashed)
		var/list/first_edge = length(edges) ? edges[1] : null
		var/turf/center = get_turf(shuttle) || first_edge?[1]
		if(center)
			playsound(center, 'sound/effects/splash.ogg', 60, TRUE)

/// Pomarańczowa poświata w kabinie przy wejściu w atmosferę (alfa pulsuje z /datum/planet_descent/proc/cabin_effects)
/atom/movable/screen/fullscreen/color_vision/planet_reentry
	color = "#ff7a20"

/// Blokada pola lądowiska na czas dokowania: nie da się na nie wejść (prom zaraz je zajmie). toShuttleMove() jej nie
/// usuwa (AQ EDIT w code/modules/shuttle/on_move.dm), robi to /datum/planet_descent/proc/finish po dokowaniu
/obj/effect/planet_landing_blocker
	density = TRUE
	anchored = TRUE
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/// Żar na polu przy kadłubie, od strony kadłuba
/obj/effect/temp_visual/planet_reentry
	icon = 'aquila/icons/effects/planet_descent.dmi'
	icon_state = "reentry"
	layer = ABOVE_ALL_MOB_LAYER
	blend_mode = BLEND_ADD
	randomdir = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/temp_visual/planet_reentry/Initialize(mapload, hull_dir, glow_time)
	if(glow_time)
		duration = glow_time
	. = ..()
	dir = hull_dir
	alpha = 0
	animate(src, alpha = 255, time = duration / 4)
	animate(alpha = 160, time = duration / 4)
	animate(alpha = 255, time = duration / 4)
	animate(alpha = 0, time = duration / 4)

/// Cień kadłuba: na płaszczyźnie podłóg pod warstwą pól, więc rysuje się na kosmosie wokół promu, a pod podłogą
/// kadłuba znika sam (obiekt w świecie na płaszczyźnie paralaksy w ogóle się nie rysuje, sprawdzone w kliencie)
/obj/effect/abstract/planet_descent_shadow
	icon = null
	plane = FLOOR_PLANE
	layer = SPACE_LAYER
	appearance_flags = KEEP_TOGETHER | PIXEL_SCALE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 0
	/// Rozmycie brzegu cienia (piksele)
	var/blur_size = 3

/// hull: pola kadłuba; cień leży na środku kadłuba, więc skaluje się wokół niego
/obj/effect/abstract/planet_descent_shadow/Initialize(mapload, list/hull)
	. = ..()
	var/turf/anchor = get_turf(src)
	var/list/parts = list()
	for(var/turf/T as anything in hull)
		var/mutable_appearance/part = mutable_appearance('aquila/icons/effects/planet_descent.dmi', "shadow")
		part.pixel_x = (T.x - anchor.x) * world.icon_size
		part.pixel_y = (T.y - anchor.y) * world.icon_size
		parts += part
	add_overlay(parts)
	filters += filter(type = "blur", size = blur_size)

// ---------------------------------------------------------------------------
// Warstwa planety: zejście i start

/atom/movable/screen/parallax_layer/planet_sky
	/// Trwa pokaz zejścia albo startu: update_status nie przestawia wtedy planety
	var/descent_active = FALSE
	/// Odłożony koniec pokazu (po starcie albo po wygaszeniu przerwanego zejścia): nowy pokaz go anuluje, inaczej
	/// spóźniony koniec zabrałby planetę z nowego zejścia
	var/end_timer
	/// Niebo w kolorze atmosfery i smugi pędu
	var/obj/effect/overlay/planet_sky_part/sky_fill
	var/list/streak_parts

/atom/movable/screen/parallax_layer/planet_sky/Destroy()
	QDEL_NULL(sky_fill)
	QDEL_LIST(streak_parts)
	cancel_end_timer()
	return ..()

/// Części pokazu zejścia (tworzone przy pierwszym zejściu)
/atom/movable/screen/parallax_layer/planet_sky/proc/build_descent_parts()
	var/center = 7.5 * world.icon_size
	sky_fill = new
	sky_fill.icon = 'aquila/icons/effects/planet_descent.dmi'
	sky_fill.icon_state = "fill"
	sky_fill.appearance_flags = PIXEL_SCALE | RESET_TRANSFORM
	sky_fill.layer = layer + 0.05
	sky_fill.pixel_x = center - world.icon_size / 2
	sky_fill.pixel_y = center - world.icon_size / 2
	streak_parts = list()
	for(var/copy in 0 to 1)
		var/obj/effect/overlay/planet_sky_part/streak = new
		streak.icon = 'aquila/icons/effects/planet_sky_streaks.dmi'
		streak.icon_state = "streaks"
		streak.appearance_flags = PIXEL_SCALE | RESET_TRANSFORM
		streak.layer = layer + 0.06
		streak_parts += streak

/// Ustawia niebo i smugi na początek pokazu (niewidoczne)
/atom/movable/screen/parallax_layer/planet_sky/proc/reset_descent_parts(datum/planet_type/planet_type)
	if(!sky_fill)
		build_descent_parts()
	var/sky_size = 30 // wypełnienie 32 px powiększone tak, żeby przykryło szeroki widok
	animate(sky_fill)
	sky_fill.transform = matrix(sky_size, 0, 0, 0, sky_size, 0)
	sky_fill.color = planet_type.sky_atmosphere_color || "#ffffff"
	sky_fill.alpha = 0
	var/center = 7.5 * world.icon_size
	for(var/i in 1 to 2)
		var/obj/effect/overlay/planet_sky_part/streak = streak_parts[i]
		animate(streak)
		streak.transform = matrix(1.5, 0, 0, 0, 1.5, 0)
		streak.pixel_x = center - 240
		streak.pixel_y = center - 240 - (i - 1) * 720
		streak.alpha = 0
	vis_contents |= sky_fill
	vis_contents |= streak_parts

/// Pokaz zejścia (czasy jak w /datum/planet_descent): planeta rośnie, niebo, smugi, teren pod promem
/atom/movable/screen/parallax_layer/planet_sky/proc/play_descent(datum/planet_type/planet_type)
	cancel_end_timer()
	descent_active = TRUE
	show_planet(planet_type)
	reset_descent_parts(planet_type)
	var/sky = matrix(PLANET_DESCENT_SKY_SCALE, 0, 0, 0, PLANET_DESCENT_SKY_SCALE, 0)
	var/ground = matrix(PLANET_DESCENT_GROUND_SCALE, 0, 0, 0, PLANET_DESCENT_GROUND_SCALE, 0)
	var/has_air = !!planet_type.sky_atmosphere_color
	var/air_time = has_air ? PLANET_DESCENT_REENTRY : 0
	// Tarcza rośnie, aż wypełni niebo; w atmosferze stoi pod niebem, potem rośnie dalej jako teren pod promem.
	// Środek tarczy jedzie na środek ekranu, żeby teren nie uciekał w bok
	for(var/obj/effect/overlay/planet_sky_part/part as anything in list(body, shade, atmosphere))
		var/target_alpha = part == body ? 255 : 0
		animate(part, transform = sky, pixel_y = 7.5 * world.icon_size - 96, alpha = target_alpha, time = PLANET_DESCENT_ZOOM, easing = CUBIC_EASING | EASE_IN)
		if(air_time)
			animate(time = air_time)
		animate(transform = ground, time = PLANET_DESCENT_APPROACH, easing = SINE_EASING | EASE_OUT)
	if(!has_air)
		return
	// Niebo w kolorze atmosfery: pojawia się przy wejściu w atmosferę, znika nad terenem
	animate(sky_fill, alpha = 0, time = PLANET_DESCENT_ZOOM - 5)
	animate(alpha = 230, time = 10)
	animate(time = PLANET_DESCENT_REENTRY - 10)
	animate(alpha = 0, time = 10)
	// Smugi pędu: dwie kopie jadą w górę jedna za drugą, w czasie wejścia w atmosferę
	for(var/obj/effect/overlay/planet_sky_part/streak as anything in streak_parts)
		var/start_y = streak.pixel_y
		animate(streak, alpha = 0, time = PLANET_DESCENT_ZOOM)
		animate(alpha = 255, pixel_y = start_y + 360, time = PLANET_DESCENT_REENTRY / 3)
		animate(pixel_y = start_y + 720, time = PLANET_DESCENT_REENTRY / 3)
		animate(alpha = 0, pixel_y = start_y + 1080, time = PLANET_DESCENT_REENTRY / 3)

/// Pokaz startu z planety: niebo, potem planeta maleje do zwykłej wielkości za oknami
/atom/movable/screen/parallax_layer/planet_sky/proc/play_ascent(datum/planet_type/planet_type)
	cancel_end_timer()
	descent_active = TRUE
	show_planet(planet_type)
	reset_descent_parts(planet_type)
	var/normal = matrix(planet_type.sky_scale, 0, 0, 0, planet_type.sky_scale, 0)
	var/sky = matrix(PLANET_DESCENT_SKY_SCALE, 0, 0, 0, PLANET_DESCENT_SKY_SCALE, 0)
	var/has_air = !!planet_type.sky_atmosphere_color
	for(var/obj/effect/overlay/planet_sky_part/part as anything in list(body, shade, atmosphere))
		var/normal_y = part.pixel_y
		part.transform = sky
		part.pixel_y = 7.5 * world.icon_size - 96
		part.alpha = part == body ? 255 : 0
		if(has_air)
			animate(part, time = PLANET_ASCENT_SKY)
			animate(transform = normal, pixel_y = normal_y, alpha = 255, time = PLANET_ASCENT_ZOOM, easing = CUBIC_EASING | EASE_OUT)
		else
			animate(part, transform = normal, pixel_y = normal_y, alpha = 255, time = PLANET_ASCENT_ZOOM, easing = CUBIC_EASING | EASE_OUT)
	end_timer = addtimer(CALLBACK(src, PROC_REF(end_descent)), (has_air ? PLANET_ASCENT_SKY : 0) + PLANET_ASCENT_ZOOM + 1, TIMER_STOPPABLE)
	if(!has_air)
		return
	sky_fill.alpha = 230
	animate(sky_fill, time = PLANET_ASCENT_SKY / 2)
	animate(alpha = 0, time = PLANET_ASCENT_SKY / 2)

/atom/movable/screen/parallax_layer/planet_sky/proc/cancel_end_timer()
	if(end_timer)
		deltimer(end_timer)
		end_timer = null

/// Koniec pokazu: części pokazu znikają, a planeta wraca do zwykłego wyboru (przy następnym update_status).
/// fade: przerwane zejście, planeta i niebo bledną w kosmos, a po chwili wraca zwykły widok
/atom/movable/screen/parallax_layer/planet_sky/proc/end_descent(fade = FALSE)
	if(!descent_active)
		return
	if(fade)
		var/list/parts = list(body, shade, atmosphere, sky_fill) + streak_parts
		for(var/obj/effect/overlay/planet_sky_part/part as anything in parts)
			if(part)
				animate(part, alpha = 0, time = 1.2 SECONDS, easing = SINE_EASING)
		cancel_end_timer()
		end_timer = addtimer(CALLBACK(src, PROC_REF(end_descent)), 1.3 SECONDS, TIMER_STOPPABLE)
		return
	end_timer = null
	descent_active = FALSE
	if(sky_fill)
		animate(sky_fill)
		vis_contents -= sky_fill
	for(var/obj/effect/overlay/planet_sky_part/part as anything in streak_parts)
		animate(part)
		vis_contents -= part
	var/datum/planet_type/planet_type = shown_type
	show_planet(null)
	for(var/obj/effect/overlay/planet_sky_part/part as anything in list(body, shade, atmosphere))
		animate(part)
		part.alpha = 255
	next_check = 0
	if(planet_type && current_mob)
		update_status(current_mob)

/atom/movable/screen/parallax_layer/planet_sky/update_status(mob/M)
	if(descent_active)
		current_mob = M
		return
	return ..()

// ---------------------------------------------------------------------------
// Prom: zejście zamiast natychmiastowego dokowania na planecie, pokaz przy starcie z planety

/// Na planecie dokowanie zaczyna zejście; prawdziwe dokowanie przychodzi z /datum/planet_descent/proc/finish
/obj/structure/overmap/small_craft/transport/shuttle_land(obj/structure/overmap/OM, obj/docking_port/stationary/port)
	if(!istype(OM, /obj/structure/overmap/planet) || planet_descent?.finishing)
		return ..()
	var/obj/structure/overmap/planet/planet = OM
	var/spot_taken = !planet_descent && !shuttle_docked_at && shuttle_port && !planet_landing_spot_free(planet, port)
	if(spot_taken && pilot)
		to_chat(pilot, span_warning("Na wybranym lądowisku ktoś albo coś stoi. Komputer dokowania nie zaczyna zejścia."))
	if(planet_descent || shuttle_docked_at || !shuttle_port || !planet.craft_over_planet(src) || spot_taken)
		// Port trwającego zejścia zostaje: drugie wywołanie (autopilot, ponowne dokowanie) nie może go zabrać
		if(istype(port, /obj/docking_port/stationary/shuttle_craft_spot) && !port.docked && port != planet_descent?.port)
			qdel(port, TRUE)
		return FALSE
	planet_descent = new(src, planet, port)
	planet_descent.start()
	return TRUE

/// Pola, na których stanie kadłub na porcie (z obrotem portu)
/obj/structure/overmap/small_craft/transport/proc/planet_landing_footprint(obj/docking_port/stationary/port)
	. = list()
	if(!port || !shuttle_port)
		return
	if(!length(hull_offsets))
		shuttle_cache_offsets()
	for(var/list/offset as anything in shuttle_rotate_offsets(hull_offsets, port.dir))
		var/turf/T = locate(port.x + offset[1], port.y + offset[2], port.z)
		if(T)
			. += T

/// Czy kadłub zmieści się na porcie (każde pole wolne, także od lądowisk innych schodzących promów)
/obj/structure/overmap/small_craft/transport/proc/planet_landing_spot_free(obj/structure/overmap/planet/planet, obj/docking_port/stationary/port)
	var/list/footprint = planet_landing_footprint(port)
	// Pole poza mapą nie trafia do obrysu: wtedy obrys jest krótszy niż kadłub
	if(!length(footprint) || length(footprint) != length(hull_offsets))
		return FALSE
	for(var/turf/T as anything in footprint)
		if(!shuttle_landing_turf_free(planet, T))
			return FALSE
	return TRUE

/obj/structure/overmap/small_craft/transport/shuttle_launch(mob/user)
	var/obj/structure/overmap/planet/planet = get_overmap()
	// Port na planecie (po starcie go nie ma): z niego widok z ziemi wie, gdzie i jak obrócony stał kadłub
	var/site_x
	var/site_y
	var/site_z
	var/site_dir
	if(istype(planet) && shuttle_port && shuttle_docked_at)
		site_x = shuttle_docked_at.x
		site_y = shuttle_docked_at.y
		site_z = shuttle_docked_at.z
		site_dir = shuttle_docked_at.dir
	. = ..()
	if(!. || !istype(planet))
		return
	if(site_z)
		// Kadłub już w locie: obraz z jego pól odlatuje z lądowiska (hull_offsets są po starcie liczone od nowa)
		var/list/sources = list()
		var/list/places = list()
		var/list/turned = shuttle_rotate_offsets(hull_offsets, site_dir)
		for(var/i in 1 to length(turned))
			var/list/offset = hull_offsets[i]
			var/list/turned_offset = turned[i]
			var/turf/source = locate(shuttle_port.x + offset[1], shuttle_port.y + offset[2], shuttle_port.z)
			var/turf/place = locate(site_x + turned_offset[1], site_y + turned_offset[2], site_z)
			if(source && place)
				sources += source
				places += place
		var/launch_rotation = (dir2angle(site_dir) - dir2angle(shuttle_port.dir) + 360) % 360
		var/datum/planet_launch_view/launch_view = new(sources, places, launch_rotation)
		launch_view.lift_off()
		// Z pokładu: lądowisko pod promem maleje i blednie (obrazy z daleka z poprzedniego zejścia na to miejsce, jeśli są)
		var/watching = FALSE
		for(var/mob/M as anything in mobs_in_ship)
			if(M.client)
				watching = TRUE
				break
		if(length(sources) && watching)
			var/datum/planet_ground_view/ground_view = new(sources, places, launch_rotation, planet.surface?.reservation)
			ground_view.build_close(skip_berth = FALSE)
			ground_view.bake_aerial(only_kept = TRUE)
			ground_view.play(1, PLANET_ASCENT_GROUND_END, PLANET_ASCENT_GROUND_TIME, 255, 0, PLANET_ASCENT_GROUND_TIME * 0.6, PLANET_ASCENT_GROUND_TIME * 0.4, SINE_EASING | EASE_IN)
			QDEL_IN(ground_view, PLANET_ASCENT_GROUND_TIME + 0.2 SECONDS)
	relay(null, span_notice("[src] wznosi się przez atmosferę [planet] na orbitę."))
	for(var/mob/M as anything in mobs_in_ship)
		if(M.client && M.can_hear())
			SEND_SOUND(M, sound('aquila/sound/planets/landing/launch.ogg', volume = 60))
	for(var/mob/M as anything in mobs_in_ship)
		if(!M.client)
			continue
		shake_camera(M, 3, 2)
		var/atom/movable/screen/parallax_layer/planet_sky/sky = locate() in M.client.parallax_layers_cached
		sky?.play_ascent(planet.planet_type)

#undef PLANET_DESCENT_ZOOM
#undef PLANET_DESCENT_REENTRY
#undef PLANET_DESCENT_APPROACH
#undef PLANET_ASCENT_SKY
#undef PLANET_ASCENT_ZOOM
#undef PLANET_DESCENT_SKY_SCALE
#undef PLANET_DESCENT_GROUND_SCALE
#undef PLANET_DESCENT_SHADOW_SCALE
#undef PLANET_DESCENT_GROUND_START
#undef PLANET_DESCENT_GROUND_SETTLE
#undef PLANET_ASCENT_GROUND_END
#undef PLANET_ASCENT_GROUND_TIME
#undef PLANET_DESCENT_GROUND_SHADOW_LEAD
#undef PLANET_DESCENT_GROUND_PROXY_LEAD
#undef PLANET_TOUCHDOWN_DUST_CHANCE
#undef PLANET_TOUCHDOWN_DUST_MAX
