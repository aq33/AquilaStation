// AQUILA - zejście promu z wnętrzem na planetę i start z niej, widziane z pokładu. Zamiast natychmiastowego dokowania
// prom przez kilkanaście sekund schodzi: planeta za oknami rośnie, aż wypełni niebo (warstwa planety z planet_sky.dm),
// kadłub żarzy się w atmosferze, przez niebo lecą smugi i chmury, pod promem rośnie powiększony teren z cieniem kadłuba,
// a na końcu prom dokuje na lądowisku z bryzgami albo kurzem. Start z planety pokazuje to samo w odwrotnej kolejności.

/// Fazy zejścia (czas trwania każdej)
#define PLANET_DESCENT_ZOOM (3.5 SECONDS)
#define PLANET_DESCENT_REENTRY (2.5 SECONDS)
#define PLANET_DESCENT_CLOUDS (1.5 SECONDS)
#define PLANET_DESCENT_APPROACH (3.5 SECONDS)
/// Start z planety: chmury i niebo, potem planeta maleje do zwykłej wielkości
#define PLANET_ASCENT_SKY (2.5 SECONDS)
#define PLANET_ASCENT_ZOOM (4 SECONDS)
/// Powiększenie tarczy, przy którym planeta wypełnia niebo, i przy którym teren pod promem ma piksele wielkości pól
#define PLANET_DESCENT_SKY_SCALE 18
#define PLANET_DESCENT_GROUND_SCALE 48
/// Ile razy większy od kadłuba jest cień na początku podejścia (prom wysoko nad ziemią)
#define PLANET_DESCENT_SHADOW_SCALE 2

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
	/// Ludzie z pomarańczową poświatą w kabinie (zdejmowana po przejściu przez atmosferę albo przy przerwaniu)
	var/list/tinted = list()
	var/list/timers = list()

/datum/planet_descent/New(obj/structure/overmap/small_craft/transport/new_craft, obj/structure/overmap/planet/new_planet, obj/docking_port/stationary/new_port)
	craft = new_craft
	planet = new_planet
	port = new_port

/datum/planet_descent/Destroy()
	for(var/timer in timers)
		deltimer(timer)
	timers.Cut()
	stop_viewers()
	clear_cabin_glow()
	QDEL_NULL(shadow)
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

/datum/planet_descent/proc/stop_viewers()
	for(var/atom/movable/screen/parallax_layer/planet_sky/sky as anything in viewers)
		if(!QDELETED(sky))
			sky.end_descent()
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
	craft.relay('sound/effects/space_wind.ogg', span_notice("[craft] schodzi z orbity nad [planet]. Trzymajcie się czegoś."))
	shake_crew(2, 1)
	// Bez atmosfery (księżyc) nie ma żaru ani chmur: od razu teren pod promem, jak w pokazie na warstwie planety
	var/reentry_at = PLANET_DESCENT_ZOOM
	var/approach_at = reentry_at
	if(planet_type.sky_atmosphere_color)
		approach_at += PLANET_DESCENT_REENTRY + PLANET_DESCENT_CLOUDS
		timers += addtimer(CALLBACK(src, PROC_REF(reentry)), reentry_at, TIMER_STOPPABLE)
		timers += addtimer(CALLBACK(src, PROC_REF(clouds)), reentry_at + PLANET_DESCENT_REENTRY, TIMER_STOPPABLE)
	timers += addtimer(CALLBACK(src, PROC_REF(approach)), approach_at, TIMER_STOPPABLE)
	timers += addtimer(CALLBACK(src, PROC_REF(finish)), approach_at + PLANET_DESCENT_APPROACH, TIMER_STOPPABLE)

/datum/planet_descent/proc/shake_crew(duration, strength)
	for(var/mob/M as anything in craft?.mobs_in_ship)
		if(M.client)
			shake_camera(M, duration, strength)

/// Wejście w atmosferę: żar na kosmosie przy kadłubie, wiatr, trzęsienie
/datum/planet_descent/proc/reentry()
	craft.relay('sound/effects/space_wind_big.ogg', span_warning("Kadłub [craft] rozgrzewa się w atmosferze [planet], prom trzęsie się."))
	shake_crew(PLANET_DESCENT_REENTRY / 2, 2)
	for(var/list/edge as anything in hull_edges(craft.shuttle_port))
		new /obj/effect/temp_visual/planet_reentry(edge[1], edge[2], PLANET_DESCENT_REENTRY + PLANET_DESCENT_CLOUDS / 2)
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

/datum/planet_descent/proc/clouds()
	clear_cabin_glow()
	craft.relay(null, span_notice("[craft] przebija chmury i podchodzi do lądowiska."))
	shake_crew(PLANET_DESCENT_CLOUDS, 1)

/// Ostatnia faza: pod promem teren, a cień kadłuba kurczy się z dużej, miękkiej plamy do obrysu promu (widać go z każdej
/// strony kadłuba, także zza ścian, które zasłaniają część nieba)
/datum/planet_descent/proc/approach()
	var/list/hull = craft.shuttle_port?.return_turfs()
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
	finishing = TRUE
	var/landed = landing.shuttle_land(target, port)
	finishing = FALSE
	port = null // port przejął prom albo shuttle_land go usunął
	qdel(src)
	if(!landed)
		if(!QDELETED(landing) && !QDELETED(target))
			landing.planet_landing_cancelled(target)
		return
	planet_touchdown_effects(landing.shuttle_port, target)
	for(var/mob/M as anything in landing.mobs_in_ship)
		if(M.client)
			shake_camera(M, 3, 3)

/// Kosmos przy kadłubie: lista (pole, kierunek do kadłuba)
/proc/hull_edges(obj/docking_port/mobile/shuttle)
	. = list()
	if(!shuttle)
		return
	var/list/hull = list()
	for(var/turf/T as anything in shuttle.return_turfs())
		hull[T] = TRUE
	for(var/turf/T as anything in hull)
		for(var/dir in GLOB.cardinals)
			var/turf/outside = get_step(T, dir)
			if(outside && !hull[outside])
				. += list(list(outside, turn(dir, 180)))

/// Bryzgi na wodzie, kurz na lądzie, wokół kadłuba stojącego na planecie (przy lądowaniu i przy starcie)
/proc/planet_touchdown_effects(obj/docking_port/mobile/shuttle, obj/structure/overmap/planet/planet, list/turfs)
	var/list/where = turfs
	if(!where)
		where = list()
		for(var/list/edge as anything in hull_edges(shuttle))
			where |= edge[1]
	var/splashed = FALSE
	var/index = 0
	for(var/turf/T as anything in where)
		if(index++ % 2) // co drugie pole wystarczy, a efektów nie ma setek
			continue
		if(istype(T, /turf/open/water) || istype(T, /turf/open/lava))
			new /obj/effect/temp_visual/liquid_splash(T)
			splashed = TRUE
		else if(!T.density)
			var/obj/effect/temp_visual/small_smoke/halfsecond/dust = new(T)
			dust.color = planet?.planet_type?.sky_cloud_color || "#c8b890"
	var/turf/center = get_turf(shuttle) || (length(where) ? where[1] : null)
	if(center)
		playsound(center, splashed ? 'sound/effects/splash.ogg' : 'sound/effects/meteorimpact.ogg', 60, TRUE)

/// Pomarańczowa poświata w kabinie przy wejściu w atmosferę (alfa pulsuje z /datum/planet_descent/proc/cabin_effects)
/atom/movable/screen/fullscreen/color_vision/planet_reentry
	color = "#ff7a20"

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
	filters += filter(type = "blur", size = 3)

// ---------------------------------------------------------------------------
// Warstwa planety: zejście i start

/atom/movable/screen/parallax_layer/planet_sky
	/// Trwa pokaz zejścia albo startu: update_status nie przestawia wtedy planety
	var/descent_active = FALSE
	/// Niebo w kolorze atmosfery, smugi pędu i chmury przelatujące przez ekran
	var/obj/effect/overlay/planet_sky_part/sky_fill
	var/list/streak_parts
	var/list/rush_parts

/atom/movable/screen/parallax_layer/planet_sky/Destroy()
	QDEL_NULL(sky_fill)
	QDEL_LIST(streak_parts)
	QDEL_LIST(rush_parts)
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
	rush_parts = list()
	for(var/copy in 0 to 1)
		var/obj/effect/overlay/planet_sky_part/streak = new
		streak.icon = 'aquila/icons/effects/planet_sky_streaks.dmi'
		streak.icon_state = "streaks"
		streak.appearance_flags = PIXEL_SCALE | RESET_TRANSFORM
		streak.layer = layer + 0.06
		streak_parts += streak
		var/obj/effect/overlay/planet_sky_part/rush = new
		rush.icon = 'aquila/icons/effects/planet_sky_surface.dmi'
		rush.appearance_flags = PIXEL_SCALE | RESET_TRANSFORM
		rush.layer = layer + 0.07
		rush_parts += rush

/// Ustawia niebo, smugi i chmury na początek pokazu (niewidoczne)
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
		var/obj/effect/overlay/planet_sky_part/rush = rush_parts[i]
		animate(rush)
		rush.icon_state = planet_type.sky_clouds || "clouds_thick"
		rush.color = planet_type.sky_cloud_color
		rush.transform = matrix(6, 0, 0, 0, 6, 0)
		rush.pixel_x = center - 256
		rush.pixel_y = center - 128 - (i - 1) * 1536
		rush.alpha = 0
	vis_contents |= sky_fill
	vis_contents |= streak_parts
	vis_contents |= rush_parts

/// Pokaz zejścia (czasy jak w /datum/planet_descent): planeta rośnie, niebo, smugi, chmury, teren pod promem
/atom/movable/screen/parallax_layer/planet_sky/proc/play_descent(datum/planet_type/planet_type)
	descent_active = TRUE
	show_planet(planet_type)
	reset_descent_parts(planet_type)
	var/sky = matrix(PLANET_DESCENT_SKY_SCALE, 0, 0, 0, PLANET_DESCENT_SKY_SCALE, 0)
	var/ground = matrix(PLANET_DESCENT_GROUND_SCALE, 0, 0, 0, PLANET_DESCENT_GROUND_SCALE, 0)
	var/has_air = !!planet_type.sky_atmosphere_color
	var/air_time = has_air ? PLANET_DESCENT_REENTRY + PLANET_DESCENT_CLOUDS : 0
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
	animate(time = PLANET_DESCENT_REENTRY + PLANET_DESCENT_CLOUDS - 10)
	animate(alpha = 0, time = 10)
	// Smugi pędu: dwie kopie jadą w górę jedna za drugą, w czasie wejścia w atmosferę
	for(var/obj/effect/overlay/planet_sky_part/streak as anything in streak_parts)
		var/start_y = streak.pixel_y
		animate(streak, alpha = 0, time = PLANET_DESCENT_ZOOM)
		animate(alpha = 255, pixel_y = start_y + 360, time = PLANET_DESCENT_REENTRY / 2)
		animate(pixel_y = start_y + 720, time = PLANET_DESCENT_REENTRY / 2)
		animate(alpha = 0, pixel_y = start_y + 1080, time = PLANET_DESCENT_CLOUDS / 2)
	// Chmury przelatują przez cały ekran z dołu do góry
	for(var/obj/effect/overlay/planet_sky_part/rush as anything in rush_parts)
		var/start_y = rush.pixel_y
		animate(rush, alpha = 0, time = PLANET_DESCENT_ZOOM + PLANET_DESCENT_REENTRY - 3)
		animate(alpha = 255, time = 3)
		animate(pixel_y = start_y + 1536, time = PLANET_DESCENT_CLOUDS)
		animate(alpha = 0, time = 2)

/// Pokaz startu z planety: chmury i niebo, potem planeta maleje do zwykłej wielkości za oknami
/atom/movable/screen/parallax_layer/planet_sky/proc/play_ascent(datum/planet_type/planet_type)
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
	addtimer(CALLBACK(src, PROC_REF(end_descent)), (has_air ? PLANET_ASCENT_SKY : 0) + PLANET_ASCENT_ZOOM + 1)
	if(!has_air)
		return
	sky_fill.alpha = 230
	animate(sky_fill, time = PLANET_ASCENT_SKY / 2)
	animate(alpha = 0, time = PLANET_ASCENT_SKY / 2)
	// Chmury lecą z góry na dół: prom wznosi się przez nie
	for(var/obj/effect/overlay/planet_sky_part/rush as anything in rush_parts)
		var/start_y = rush.pixel_y + 1536
		rush.pixel_y = start_y
		rush.alpha = 255
		animate(rush, pixel_y = start_y - 1536, time = PLANET_ASCENT_SKY)
		animate(alpha = 0, time = 2)

/// Koniec pokazu: części pokazu znikają, a planeta wraca do zwykłego wyboru (przy następnym update_status)
/atom/movable/screen/parallax_layer/planet_sky/proc/end_descent()
	if(!descent_active)
		return
	descent_active = FALSE
	if(sky_fill)
		animate(sky_fill)
		vis_contents -= sky_fill
	for(var/obj/effect/overlay/planet_sky_part/part as anything in streak_parts + rush_parts)
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
	if(planet_descent || shuttle_docked_at || !shuttle_port || !planet.craft_over_planet(src))
		// Port trwającego zejścia zostaje: drugie wywołanie (autopilot, ponowne dokowanie) nie może go zabrać
		if(istype(port, /obj/docking_port/stationary/shuttle_craft_spot) && !port.docked && port != planet_descent?.port)
			qdel(port, TRUE)
		return FALSE
	planet_descent = new(src, planet, port)
	planet_descent.start()
	return TRUE

/obj/structure/overmap/small_craft/transport/shuttle_launch(mob/user)
	var/obj/structure/overmap/planet/planet = get_overmap()
	// Pola pod kadłubem: po starcie znów są gruntem planety, a kurz zostaje tam, gdzie stał prom
	var/list/site
	if(istype(planet) && shuttle_port)
		site = shuttle_port.return_turfs()
	. = ..()
	if(!. || !istype(planet))
		return
	planet_touchdown_effects(null, planet, site)
	relay('sound/effects/space_wind_big.ogg', span_notice("[src] wznosi się przez atmosferę [planet] na orbitę."))
	for(var/mob/M as anything in mobs_in_ship)
		if(!M.client)
			continue
		shake_camera(M, 3, 2)
		var/atom/movable/screen/parallax_layer/planet_sky/sky = locate() in M.client.parallax_layers_cached
		sky?.play_ascent(planet.planet_type)

#undef PLANET_DESCENT_ZOOM
#undef PLANET_DESCENT_REENTRY
#undef PLANET_DESCENT_CLOUDS
#undef PLANET_DESCENT_APPROACH
#undef PLANET_ASCENT_SKY
#undef PLANET_ASCENT_ZOOM
#undef PLANET_DESCENT_SKY_SCALE
#undef PLANET_DESCENT_GROUND_SCALE
#undef PLANET_DESCENT_SHADOW_SCALE
