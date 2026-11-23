// AQUILA - zejście promu z wnętrzem na planetę i start z niej, widziane z pokładu. Zamiast natychmiastowego dokowania
// prom przez kilkanaście sekund schodzi z przejściami jak w voidcrew/Voidcrew#588: planeta za oknami rośnie (warstwa
// planety z planet_sky.dm), żar i smugi wejścia w atmosferę, niebo w kolorze atmosfery, biała chmura z mgłą, spod niej
// prawdziwy teren lądowiska, mały i zamglony, rośnie do pełnej wielkości, a na końcu prom dokuje z bryzgami albo
// kurzem. Start z planety: teren odpada i odsuwa się za rufę, chmura, niebo blednie, planeta maleje.
// Widok z ziemi i dźwięki (port z voidcrew/Voidcrew#588) są w planet_landing_view.dm, prawdziwy teren lądowiska pod
// promem w planet_landing_ground.dm.

/// Zejście trwa tyle (od startu do przyziemienia T). Chwile przejść liczone od przyziemienia, jak w voidcrew/Voidcrew#588
#define PLANET_DESCENT_TOTAL (11 SECONDS)
#define PLANET_DESCENT_AT(before_touchdown) (PLANET_DESCENT_TOTAL - (before_touchdown))
/// Start z planety trwa tyle: teren odpada, chmura, niebo blednie, planeta maleje do zwykłej wielkości
#define PLANET_ASCENT_TOTAL (9 SECONDS)
/// Po tylu sekundach startu teren znika pod chmurą (bez atmosfery: pod samą planetą)
#define PLANET_ASCENT_GROUND_CUT (3.8 SECONDS)
/// Powiększenie tarczy, przy którym planeta wypełnia niebo
#define PLANET_DESCENT_SKY_SCALE 18
/// Wielkość terenu (względem prawdziwej), gdy wyłania się spod chmury
#define PLANET_DESCENT_GROUND_START 0.3
/// Kolor żaru wejścia w atmosferę (błyski i smugi)
#define PLANET_DESCENT_HEAT_COLOR "#ffa64d"
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
		// Niebo, chmura i mgiełka rysują się na płaszczyźnie widoku: maska od początku zejścia
		ground_view.mask()
	craft.relay(null, span_notice("[craft] schodzi z orbity nad [planet]. Trzymajcie się czegoś."))
	crew_sound('aquila/sound/planets/landing/spool.ogg', 50)
	shake_crew(2, 1)
	// Bez atmosfery (księżyc) nie ma żaru, nieba ani chmury: planeta rośnie, potem od razu teren
	if(planet_type.sky_atmosphere_color)
		timers += addtimer(CALLBACK(src, PROC_REF(reentry)), PLANET_DESCENT_AT(9.2 SECONDS), TIMER_STOPPABLE)
		timers += addtimer(CALLBACK(src, PROC_REF(clouds)), PLANET_DESCENT_AT(6.6 SECONDS), TIMER_STOPPABLE)
		timers += addtimer(CALLBACK(src, PROC_REF(clear_cabin_glow)), PLANET_DESCENT_AT(5.6 SECONDS), TIMER_STOPPABLE)
	timers += addtimer(CALLBACK(src, PROC_REF(approach)), PLANET_DESCENT_AT(5.2 SECONDS), TIMER_STOPPABLE)
	timers += addtimer(CALLBACK(src, PROC_REF(crew_sound), 'aquila/sound/planets/landing/thrusters.ogg', 50), PLANET_DESCENT_AT(4.6 SECONDS), TIMER_STOPPABLE)
	var/total = PLANET_DESCENT_TOTAL
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

/// Wejście w atmosferę (T-9,2 s): żar na kosmosie przy kadłubie do T-5,6 s, trzęsienie
/datum/planet_descent/proc/reentry()
	craft.relay(null, span_warning("Kadłub [craft] rozgrzewa się w atmosferze [planet], prom trzęsie się."))
	crew_sound('aquila/sound/planets/landing/entry.ogg', 65)
	shake_crew(4.5 SECONDS, 2)
	for(var/list/edge as anything in hull_edges(craft.shuttle_port))
		new /obj/effect/temp_visual/planet_reentry(edge[1], edge[2], 3.6 SECONDS)
	cabin_effects()

/// Chmura (T-6,6 s): prom wchodzi w chmurę planety
/datum/planet_descent/proc/clouds()
	craft.relay(null, span_notice("[craft] przebija chmury i podchodzi do lądowiska."))
	crew_sound('aquila/sound/planets/landing/clouds.ogg', 45)
	shake_crew(1.4 SECONDS, 1)

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

/// Spod chmury (T-5,2 s): prawdziwy teren lądowiska, mały, rośnie do pełnej wielkości w T-0,3 s; cień kadłuba leży na nim
/// z boku (słońce nie stoi w zenicie), podchodzi pod kadłub i zwęża się do jego obrysu
/datum/planet_descent/proc/approach()
	clear_cabin_glow()
	ground_view?.play(PLANET_DESCENT_GROUND_START, 1, 4.9 SECONDS, 0, 255, 0, 0.2 SECONDS)
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
	var/matrix/wide = matrix(1.35, 0, 0, 0, 1.35, 0)
	shadow.transform = wide
	shadow.pixel_x = -9 * world.icon_size
	shadow.pixel_y = 9 * world.icon_size
	// T-5,2 s -> T-0,4 s: z boku pod kadłub
	animate(shadow, pixel_x = 0, pixel_y = 0, time = 4.8 SECONDS, easing = SINE_EASING | EASE_OUT)
	// Szeroki do T-3 s, węższy w T-1 s, obrys kadłuba w chwili przyziemienia
	animate(shadow, transform = wide, time = 2.2 SECONDS, flags = ANIMATION_PARALLEL)
	animate(transform = matrix(1.15, 0, 0, 0, 1.15, 0), time = 2 SECONDS, easing = SINE_EASING)
	animate(transform = matrix(), time = 1 SECONDS, easing = SINE_EASING | EASE_OUT)
	// Widać go, gdy chmura już się rozeszła; pod kadłubem znika, zanim prom stanie
	animate(shadow, alpha = 0, time = 1 SECONDS, flags = ANIMATION_PARALLEL)
	animate(alpha = 100, time = 0.6 SECONDS)
	animate(alpha = 110, time = 0.6 SECONDS)
	animate(alpha = 140, time = 1.8 SECONDS, easing = SINE_EASING)
	animate(alpha = 110, time = 0.7 SECONDS)
	animate(alpha = 0, time = 0.4 SECONDS, easing = SINE_EASING | EASE_IN)

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
	// Kadłub na ziemi oświetlony od razu, bez klatki w ciemności
	planet_settle_lighting()
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
	/// Przejścia jak w voidcrew/Voidcrew#588, na płaszczyźnie widoku lądowania nad terenem (maska ogranicza je do tego, co
	/// widać za kadłubem): niebo w kolorze atmosfery, mgiełka nad terenem, białe wnętrze chmury, mgła, żar i smugi
	var/obj/effect/overlay/planet_sky_part/view/sky_fill
	var/obj/effect/overlay/planet_sky_part/view/haze_fill
	var/obj/effect/overlay/planet_sky_part/view/cloud_fill
	var/obj/effect/overlay/planet_sky_part/view/mist
	var/obj/effect/overlay/planet_sky_part/view/heat_fill
	var/list/streak_parts

/// Część przejść zejścia: na płaszczyźnie widoku lądowania, nie paralaksy, więc rysuje się nad terenem pod promem
/obj/effect/overlay/planet_sky_part/view
	plane = AQ_LANDING_VIEW_PLANE
	vis_flags = NONE
	appearance_flags = PIXEL_SCALE | RESET_TRANSFORM | RESET_COLOR | RESET_ALPHA
	alpha = 0

/atom/movable/screen/parallax_layer/planet_sky/Destroy()
	QDEL_NULL(sky_fill)
	QDEL_NULL(haze_fill)
	QDEL_NULL(cloud_fill)
	QDEL_NULL(mist)
	QDEL_NULL(heat_fill)
	QDEL_LIST(streak_parts)
	cancel_end_timer()
	return ..()

/// Wszystkie części przejść
/atom/movable/screen/parallax_layer/planet_sky/proc/descent_parts()
	. = list(sky_fill, haze_fill, cloud_fill, mist, heat_fill) + streak_parts

/// Nowa część przejść o środku na środku ekranu
/atom/movable/screen/parallax_layer/planet_sky/proc/new_descent_part(part_layer, icon_file, state, size)
	var/center = 7.5 * world.icon_size
	var/obj/effect/overlay/planet_sky_part/view/part = new
	part.icon = icon_file
	part.icon_state = state
	part.layer = part_layer
	part.pixel_x = center - size / 2
	part.pixel_y = center - size / 2
	return part

/// Części przejść (tworzone przy pierwszym zejściu). Warstwy jak u Voidcrew: teren (1-3) pod niebem, mgiełka, chmura, żar
/atom/movable/screen/parallax_layer/planet_sky/proc/build_descent_parts()
	sky_fill = new_descent_part(24, 'aquila/icons/effects/planet_descent.dmi', "fill", world.icon_size)
	haze_fill = new_descent_part(30, 'aquila/icons/effects/planet_descent.dmi', "fill", world.icon_size)
	cloud_fill = new_descent_part(33, 'aquila/icons/effects/planet_descent.dmi', "fill", world.icon_size)
	mist = new_descent_part(33.5, 'aquila/icons/effects/planet_descent_view.dmi', "wisps", 480)
	heat_fill = new_descent_part(40, 'aquila/icons/effects/planet_descent.dmi', "fill", world.icon_size)
	streak_parts = list()
	for(var/copy in 1 to 2)
		streak_parts += new_descent_part(41, 'aquila/icons/effects/planet_descent_view.dmi', "streaks", 480)

/// Ustawia przejścia na początek pokazu (niewidoczne)
/atom/movable/screen/parallax_layer/planet_sky/proc/reset_descent_parts(datum/planet_type/planet_type)
	if(!sky_fill)
		build_descent_parts()
	var/sky_color = planet_type.sky_atmosphere_color || "#000000"
	var/fill_size = 30 // wypełnienie 32 px powiększone tak, żeby przykryło szeroki widok
	for(var/obj/effect/overlay/planet_sky_part/view/part as anything in descent_parts())
		animate(part)
		part.alpha = 0
		part.transform = matrix(fill_size, 0, 0, 0, fill_size, 0)
	sky_fill.color = sky_color
	haze_fill.color = sky_color
	cloud_fill.color = planet_type.sky_cloud_color || "#ffffff"
	heat_fill.color = PLANET_DESCENT_HEAT_COLOR
	mist.color = sky_color
	mist.transform = descent_turned(2.2, 73)
	for(var/obj/effect/overlay/planet_sky_part/view/streak as anything in streak_parts)
		streak.color = PLANET_DESCENT_HEAT_COLOR
		streak.transform = matrix(1.5, 0, 0, 0, 1.5, 0)
	vis_contents |= descent_parts()

/// Macierz: powiększenie i obrót (stopnie)
/proc/descent_turned(scale, angle)
	var/matrix/M = matrix(scale, 0, 0, 0, scale, 0)
	if(angle)
		M.Turn(angle)
	return M

/**
 * Pokaz zejścia, chwile jak w voidcrew/Voidcrew#588 (liczone od przyziemienia T, zob. /datum/planet_descent/proc/start):
 * planeta rośnie do T-6,2 s; żar (smugi od środka na zewnątrz i błyski) od T-9,2 s do T-5,6 s; niebo w kolorze atmosfery
 * gęstnieje od T-8,4 s do T-6,2 s i rzednie do T-4,4 s; chmura od T-6,2 s do T-3,8 s z mgłą; mgiełka nad terenem od
 * T-5,2 s do T-1,2 s. Teren pod niebem rysuje /datum/planet_ground_view.
 * Każdy łańcuch animate() zaczyna się od kroku, który ustawia zmienną: krok bez zmiennych zatrzymuje animacje obiektu.
 */
/atom/movable/screen/parallax_layer/planet_sky/proc/play_descent(datum/planet_type/planet_type)
	cancel_end_timer()
	descent_active = TRUE
	show_planet(planet_type)
	reset_descent_parts(planet_type)
	var/has_air = !!planet_type.sky_atmosphere_color
	var/sky = matrix(PLANET_DESCENT_SKY_SCALE, 0, 0, 0, PLANET_DESCENT_SKY_SCALE, 0)
	// Planeta rośnie, aż jej brzeg zniknie z ekranu, a środek jedzie na środek ekranu; w atmosferze chowa się pod niebem,
	// bez atmosfery zostaje, aż przykryje ją teren
	var/grow_time = PLANET_DESCENT_AT(has_air ? 6.2 SECONDS : 5.2 SECONDS)
	for(var/obj/effect/overlay/planet_sky_part/part as anything in list(body, shade, atmosphere))
		var/target_alpha = part == body ? 255 : 0
		animate(part, transform = sky, pixel_y = 7.5 * world.icon_size - 96, alpha = target_alpha, time = grow_time, easing = CUBIC_EASING | EASE_IN)
		if(has_air)
			animate(alpha = 0, time = 1)
	if(!has_air)
		return
	// Żar: dwie warstwy smug lecą od środka na zewnątrz, druga 0,9 s za pierwszą
	var/angle = 0
	for(var/obj/effect/overlay/planet_sky_part/view/streak as anything in streak_parts)
		var/lead = angle ? 0.9 SECONDS : 0
		var/matrix/small = descent_turned(1.5, angle)
		streak.transform = small
		animate(streak, transform = small, time = PLANET_DESCENT_AT(9.2 SECONDS) + lead)
		animate(transform = descent_turned(3.4, angle), time = 3.6 SECONDS)
		animate(streak, alpha = 0, time = PLANET_DESCENT_AT(9.2 SECONDS) + lead, flags = ANIMATION_PARALLEL)
		animate(alpha = 255, time = 0.8 SECONDS)
		animate(alpha = 255, time = max(1, 1.8 SECONDS - lead))
		animate(alpha = 0, time = 1 SECONDS)
		angle += 137
	// Błyski żaru nad wszystkim za kadłubem
	animate(heat_fill, alpha = 0, time = PLANET_DESCENT_AT(9.2 SECONDS))
	animate(alpha = 115, time = 0.6 SECONDS, easing = SINE_EASING)
	var/flare = FALSE
	for(var/flash in 1 to 5)
		animate(alpha = flare ? 115 : 65, time = 0.4 SECONDS, easing = SINE_EASING)
		flare = !flare
	animate(alpha = 0, time = 1 SECONDS)
	// Niebo w kolorze atmosfery: planeta rozmywa się w nim, a ono rzednie nad terenem
	animate(sky_fill, alpha = 0, time = PLANET_DESCENT_AT(8.4 SECONDS))
	animate(alpha = 255, time = 2.2 SECONDS, easing = SINE_EASING)
	animate(alpha = 255, time = 1 SECONDS)
	animate(alpha = 0, time = 0.8 SECONDS)
	// Wnętrze chmury: wszystko białe (w kolorze chmur planety)
	animate(cloud_fill, alpha = 0, time = PLANET_DESCENT_AT(6.2 SECONDS))
	animate(alpha = 250, time = 1.2 SECONDS, easing = SINE_EASING | EASE_IN)
	animate(alpha = 250, time = 0.4 SECONDS)
	animate(alpha = 0, time = 0.8 SECONDS, easing = SINE_EASING | EASE_OUT)
	// Mgła przelatuje w chmurze, żeby biel nie stała w miejscu
	var/matrix/mist_small = descent_turned(2.2, 73)
	animate(mist, transform = mist_small, time = PLANET_DESCENT_AT(6 SECONDS))
	animate(transform = descent_turned(6.5, 73), time = 2 SECONDS)
	animate(mist, alpha = 0, time = PLANET_DESCENT_AT(6 SECONDS), flags = ANIMATION_PARALLEL)
	animate(alpha = 120, time = 1 SECONDS)
	animate(alpha = 120, time = 0.5 SECONDS)
	animate(alpha = 0, time = 0.5 SECONDS)
	// Mgiełka między promem a terenem, rzednie w miarę schodzenia
	animate(haze_fill, alpha = 0, time = PLANET_DESCENT_AT(5.2 SECONDS))
	animate(alpha = 170, time = 0.2 SECONDS)
	animate(alpha = 0, time = 3.8 SECONDS)

/**
 * Pokaz startu z planety, chwile jak w voidcrew/Voidcrew#588 (od chwili startu): teren pod promem odpada (rysuje go
 * /datum/planet_ground_view/proc/play_climb) pod gęstniejącą mgiełką, od 3,3 s chmura, od 4,1 s wyjście nad nią w niebo,
 * które blednie do 6,4 s, a od 4,6 s planeta maleje do zwykłej wielkości za oknami.
 */
/atom/movable/screen/parallax_layer/planet_sky/proc/play_ascent(datum/planet_type/planet_type)
	cancel_end_timer()
	descent_active = TRUE
	show_planet(planet_type)
	reset_descent_parts(planet_type)
	var/has_air = !!planet_type.sky_atmosphere_color
	var/normal = matrix(planet_type.sky_scale, 0, 0, 0, planet_type.sky_scale, 0)
	var/high = matrix(PLANET_DESCENT_SKY_SCALE * 0.6, 0, 0, 0, PLANET_DESCENT_SKY_SCALE * 0.6, 0)
	var/planet_at = has_air ? 4.6 SECONDS : PLANET_ASCENT_GROUND_CUT
	for(var/obj/effect/overlay/planet_sky_part/part as anything in list(body, shade, atmosphere))
		var/normal_y = part.pixel_y
		part.transform = high
		part.pixel_y = 7.5 * world.icon_size - 96
		part.alpha = 0
		animate(part, alpha = 0, time = planet_at)
		animate(alpha = 255, time = 1)
		animate(transform = normal, pixel_y = normal_y, time = 4 SECONDS, easing = SINE_EASING)
	end_timer = addtimer(CALLBACK(src, PROC_REF(end_descent)), PLANET_ASCENT_TOTAL, TIMER_STOPPABLE)
	if(!has_air)
		return
	// Mgiełka gęstnieje nad odpadającym terenem
	animate(haze_fill, alpha = 0, time = 0.8 SECONDS)
	animate(alpha = 110, time = 1.6 SECONDS)
	animate(alpha = 235, time = 1 SECONDS)
	animate(alpha = 235, time = 0.4 SECONDS)
	animate(alpha = 0, time = 1)
	// Niebo nad chmurą, blednie w kosmos
	animate(sky_fill, alpha = 0, time = 2.8 SECONDS)
	animate(alpha = 255, time = 0.8 SECONDS, easing = SINE_EASING)
	animate(alpha = 255, time = 1.1 SECONDS)
	animate(alpha = 0, time = 1.7 SECONDS, easing = SINE_EASING)
	// Przez chmurę
	animate(cloud_fill, alpha = 0, time = 3.3 SECONDS)
	animate(alpha = 250, time = 0.5 SECONDS, easing = SINE_EASING | EASE_IN)
	animate(alpha = 250, time = 0.3 SECONDS)
	animate(alpha = 0, time = 0.7 SECONDS, easing = SINE_EASING | EASE_OUT)
	var/matrix/mist_big = descent_turned(6.5, 73)
	mist.transform = mist_big
	animate(mist, transform = mist_big, time = 3.2 SECONDS)
	animate(transform = descent_turned(2.2, 73), time = 1.6 SECONDS)
	animate(mist, alpha = 0, time = 3.2 SECONDS, flags = ANIMATION_PARALLEL)
	animate(alpha = 120, time = 0.5 SECONDS)
	animate(alpha = 120, time = 0.5 SECONDS)
	animate(alpha = 0, time = 0.6 SECONDS)

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
		var/list/parts = list(body, shade, atmosphere) + (sky_fill ? descent_parts() : list())
		for(var/obj/effect/overlay/planet_sky_part/part as anything in parts)
			if(part)
				animate(part, alpha = 0, time = 1.2 SECONDS, easing = SINE_EASING)
		cancel_end_timer()
		end_timer = addtimer(CALLBACK(src, PROC_REF(end_descent)), 1.3 SECONDS, TIMER_STOPPABLE)
		return
	end_timer = null
	descent_active = FALSE
	if(sky_fill)
		for(var/obj/effect/overlay/planet_sky_part/part as anything in descent_parts())
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
	var/from_planet = istype(planet) && shuttle_port && shuttle_docked_at
	// Widok startu rusza w środku przenoszenia kadłuba (takeoff), zanim dokowanie uśpi: inaczej przez chwilę widać kadłub
	// bez światła i zwykłą planetę za oknami
	if(from_planet)
		shuttle_port.aq_takeoff_hook = CALLBACK(src, PROC_REF(planet_lift_off), planet)
	. = ..()
	if(shuttle_port?.aq_takeoff_hook)
		shuttle_port.aq_takeoff_hook = null
	if(!. || !from_planet)
		return
	relay(null, span_notice("[src] wznosi się przez atmosferę [planet] na orbitę."))

/**
 * Kadłub właśnie opuścił lądowisko (wołane z takeoff()). Z ziemi obraz promu odlatuje, a z pokładu lądowisko odpada
 * i odsuwa się za rufę pod chmurą, potem niebo i planeta maleje (jak w voidcrew/Voidcrew#588).
 * old_turfs, new_turfs - pola przed przeniesieniem i po nim, w tej samej kolejności; rotation - obrót przy przeniesieniu
 */
/obj/structure/overmap/small_craft/transport/proc/planet_lift_off(obj/structure/overmap/planet/planet, list/old_turfs, list/new_turfs, rotation)
	var/list/sources = list()
	var/list/places = list()
	for(var/i in 1 to min(length(old_turfs), length(new_turfs)))
		var/turf/place = old_turfs[i]
		var/turf/source = new_turfs[i]
		if(place && source && shuttle_port.shuttle_areas[source.loc])
			sources += source
			places += place
	if(!length(sources))
		return
	// Obrót z lotu na lądowisko: odwrotny do obrotu przy starcie
	var/launch_rotation = (360 - (rotation % 360)) % 360
	var/datum/planet_launch_view/launch_view = new(sources, places, launch_rotation)
	launch_view.lift_off()
	var/list/crew = list()
	for(var/turf/T as anything in sources)
		for(var/mob/M in T)
			if(M.client)
				crew += M
	if(length(crew))
		// Obrazy z daleka z poprzedniego zejścia na to miejsce, jeśli są; dziób na ekranie (parking nie jest obrócony)
		var/datum/planet_ground_view/ground_view = new(sources, places, launch_rotation, planet.surface?.reservation)
		ground_view.build_close(skip_berth = FALSE)
		ground_view.bake_aerial(only_kept = TRUE)
		ground_view.play_climb(planet_landing_bow_dir(sources), PLANET_ASCENT_GROUND_CUT)
		// Maska trzyma niebo i chmurę do końca startu
		QDEL_IN(ground_view, PLANET_ASCENT_TOTAL)
	for(var/mob/M as anything in crew)
		if(M.can_hear())
			SEND_SOUND(M, sound('aquila/sound/planets/landing/launch.ogg', volume = 60))
		shake_camera(M, 3, 2)
		var/atom/movable/screen/parallax_layer/planet_sky/sky = locate() in M.client.parallax_layers_cached
		sky?.play_ascent(planet.planet_type)
	planet_settle_lighting()

/// Jednorazowe wywołanie w takeoff(), po przeniesieniu kadłuba, zanim dokowanie uśpi (start z planety)
/obj/docking_port/mobile/var/datum/callback/aq_takeoff_hook

/obj/docking_port/mobile/takeoff(obj/docking_port/stationary/new_dock, list/old_turfs, list/new_turfs, list/moved_atoms, rotation, movement_direction, list/underlying_old_area, list/all_towed_shuttles)
	. = ..()
	if(aq_takeoff_hook)
		var/datum/callback/hook = aq_takeoff_hook
		aq_takeoff_hook = null
		hook.Invoke(old_turfs, new_turfs, rotation)

/// Oświetlenie przeliczone od razu, a nie w kolejnych tickach: po przeniesieniu kadłub czeka w kolejkach SSlighting i
/// przez ułamek sekundy rysuje się czarny (jak landing_settle_lighting() w voidcrew/Voidcrew#588)
/proc/planet_settle_lighting()
	var/list/queue = SSlighting.sources_queue
	SSlighting.sources_queue = list()
	for(var/datum/light_source/source as anything in queue)
		source.update_corners()
		if(!QDELETED(source))
			source.needs_update = LIGHTING_NO_UPDATE
	queue = SSlighting.corners_queue
	SSlighting.corners_queue = list()
	for(var/datum/lighting_corner/corner as anything in queue)
		corner.needs_update = FALSE
		corner.update_objects()
	queue = SSlighting.objects_queue
	SSlighting.objects_queue = list()
	for(var/atom/movable/lighting_object/lit as anything in queue)
		if(QDELETED(lit))
			continue
		lit.update()
		lit.needs_update = FALSE

#undef PLANET_DESCENT_TOTAL
#undef PLANET_DESCENT_AT
#undef PLANET_ASCENT_TOTAL
#undef PLANET_ASCENT_GROUND_CUT
#undef PLANET_DESCENT_SKY_SCALE
#undef PLANET_DESCENT_GROUND_START
#undef PLANET_DESCENT_HEAT_COLOR
#undef PLANET_DESCENT_GROUND_SHADOW_LEAD
#undef PLANET_DESCENT_GROUND_PROXY_LEAD
#undef PLANET_TOUCHDOWN_DUST_CHANCE
#undef PLANET_TOUCHDOWN_DUST_MAX
