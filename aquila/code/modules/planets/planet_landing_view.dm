// AQUILA - port widoku lądowania z voidcrew/Voidcrew#588 (Jackriip): to, co widać z ziemi, gdy prom z wnętrzem schodzi
// na planetę albo z niej startuje (cień kadłuba na lądowisku, spadający obraz promu, kurz od dysz, odlot w stronę dziobu),
// prawdziwy teren za oknami promu tuż przed przyziemieniem i dźwięki lądowania (aquila/sound/planets/landing, CC BY-SA 3.0).
// Pokaz z pokładu (planeta, niebo, chmury) i przebieg zejścia są w planet_descent.dm.
//
// Różnice względem oryginału: obraz promu nie niesie własnego światła (u nas oświetlenie pól jest obiektem na płaszczyźnie
// światła, nie podkładem pola) i nie zasłania kadłuba po przyziemieniu, bo nasze oświetlenie przebudowuje się od razu.
// Teren za oknami to prawdziwe pola planety w vis_contents (bez zdjęć z rust-g i płaszczyzny maski z nowego tg).

/// Cień kadłuba pojawia się na lądowisku tyle przed przyziemieniem, a spadający prom tyle
#define PLANET_LANDING_SHADOW_LEAD (6 SECONDS)
#define PLANET_LANDING_PROXY_LEAD (3 SECONDS)
/// Wysokość (piksele), z której spada obraz promu (poza ekranem stojących przy lądowisku), tuż przed przyziemieniem i w zawisie
#define PLANET_LANDING_PROXY_START_HEIGHT 1100
#define PLANET_LANDING_PROXY_FINAL_HEIGHT 64
#define PLANET_LANDING_PROXY_HOVER 10
/// Cień: szerokość względem kadłuba, gdy prom jest wysoko i tuż przed przyziemieniem; krycie wysoko i nisko
#define PLANET_LANDING_SHADOW_WIDE 1.35
#define PLANET_LANDING_SHADOW_NEAR 1.15
#define PLANET_LANDING_SHADOW_FAINT 56
#define PLANET_LANDING_SHADOW_DARK 100
/// Kurz od dysz przed przyziemieniem: najwięcej obłoczków na falę (trzy fale), szansa na pole krawędzi, jak daleko leci
#define PLANET_LANDING_WASH_PUFFS 7
#define PLANET_LANDING_WASH_CHANCE 35
#define PLANET_LANDING_WASH_PUSH 1.5
/// Start: prom unosi się, rusza do przodu i odlatuje w stronę dziobu
#define PLANET_LAUNCH_LIFT_TIME (1 SECONDS)
#define PLANET_LAUNCH_TILT_TIME (1 SECONDS)
#define PLANET_LAUNCH_GO_TIME (1.5 SECONDS)
#define PLANET_LAUNCH_TILT_HEIGHT 44
#define PLANET_LAUNCH_GO_HEIGHT 140
#define PLANET_LAUNCH_TILT_CREEP 24
/// Ile pól ponad długość kadłuba odlatuje obraz, zanim zniknie (poza ekranem stojących przy lądowisku)
#define PLANET_LAUNCH_GO_TILES 30
#define PLANET_LAUNCH_SHADOW_SLIDE_TILES 10
#define PLANET_LAUNCH_WASH_PER_WAVE 9
#define PLANET_LAUNCH_WASH_PUSH 1.8
/// Jak daleko od kadłuba czuć przyziemienie i start (drżenie)
#define PLANET_LANDING_SHAKE_RANGE 12
/// Dźwięki przy lądowisku: do tylu pól od kadłuba pełna głośność, do tylu słychać w ogóle
#define PLANET_LANDING_SOUND_FULL 20
#define PLANET_LANDING_SOUND_REACH 80
/// Jak daleko od kadłuba widać z promu prawdziwy teren w ostatniej fazie zejścia
#define PLANET_GROUND_VIEW_RANGE 9

/// Dźwięk i drżenie dla ludzi przy lądowisku (na poziomie pól [site_turfs]): dźwięk płynie z najbliższej części obrysu,
/// drżenie czują tylko ci do PLANET_LANDING_SHAKE_RANGE pól od niego
/proc/planet_landing_jolt(list/site_turfs, sound_file, volume, shake_strength = 0, shake_time = 3)
	if(!length(site_turfs))
		return
	var/min_x = INFINITY
	var/max_x = -INFINITY
	var/min_y = INFINITY
	var/max_y = -INFINITY
	for(var/turf/T as anything in site_turfs)
		min_x = min(min_x, T.x)
		max_x = max(max_x, T.x)
		min_y = min(min_y, T.y)
		max_y = max(max_y, T.y)
	var/turf/first = site_turfs[1]
	// Duchy też (jak przy wybuchach)
	for(var/mob/listener as anything in GLOB.player_list)
		var/turf/where = get_turf(listener)
		if(!where || where.z != first.z)
			continue
		var/distance = max(min_x - where.x, where.x - max_x, min_y - where.y, where.y - max_y, 0)
		if(shake_strength && distance <= PLANET_LANDING_SHAKE_RANGE)
			shake_camera(listener, shake_time, shake_strength)
		if(sound_file && distance <= PLANET_LANDING_SOUND_REACH)
			var/turf/source = locate(clamp(where.x, min_x, max_x), clamp(where.y, min_y, max_y), first.z)
			listener.playsound_local(source, sound_file, volume, TRUE, pressure_affected = FALSE, max_distance = PLANET_LANDING_SOUND_REACH, falloff_distance = PLANET_LANDING_SOUND_FULL)

/// Kolor kurzu na planecie: kolor chmur, gdy typ go ustawia (domyślny jest biały), inaczej piaskowy
/proc/planet_dust_color(obj/structure/overmap/planet/planet)
	var/cloud_color = planet?.planet_type?.sky_cloud_color
	return (cloud_color && cloud_color != "#ffffff") ? cloud_color : "#c8b890"

/// Kurz zdmuchiwany spod krawędzi kadłuba przez dysze. Z [bow_dir] (start) głównie od strony rufy i nigdy przed dziób
/proc/planet_landing_wash(list/hull_turfs, max_puffs, chance, push, bow_dir = 0)
	var/list/hull_set = list()
	for(var/turf/T as anything in hull_turfs)
		hull_set[T] = TRUE
	var/bow_x = (bow_dir & EAST) ? 1 : ((bow_dir & WEST) ? -1 : 0)
	var/bow_y = (bow_dir & NORTH) ? 1 : ((bow_dir & SOUTH) ? -1 : 0)
	var/min_along = INFINITY
	var/max_along = -INFINITY
	for(var/turf/T as anything in hull_turfs)
		var/along = T.x * bow_x + T.y * bow_y
		min_along = min(min_along, along)
		max_along = max(max_along, along)
	var/span = max(1, max_along - min_along)
	var/puffs = 0
	for(var/turf/hull_turf as anything in shuffle(hull_turfs.Copy()))
		if(puffs >= max_puffs)
			break
		var/wash_chance = chance
		if(bow_dir)
			// 0 przy dziobie, 1 przy rufie
			var/engine_end = (max_along - (hull_turf.x * bow_x + hull_turf.y * bow_y)) / span
			wash_chance = chance * engine_end * engine_end
		if(!prob(wash_chance))
			continue
		for(var/edge_dir in shuffle(GLOB.cardinals.Copy()))
			if(edge_dir == bow_dir)
				continue
			var/turf/outside = get_step(hull_turf, edge_dir)
			if(!outside || hull_set[outside] || isclosedturf(outside))
				continue
			new /obj/effect/temp_visual/planet_landing_dust(outside, edge_dir, push)
			puffs++
			break

/// Kierunek dziobu promu stojącego na [hull_turfs]: od środka kadłuba ku szybom kokpitu (Sabre nie ma na mapie silników,
/// po których oryginał szuka rufy). Bez szyb albo z szybami na środku: w górę ekranu
/proc/planet_landing_bow_dir(list/hull_turfs)
	if(!length(hull_turfs))
		return NORTH
	var/hull_x = 0
	var/hull_y = 0
	var/window_x = 0
	var/window_y = 0
	var/windows = 0
	for(var/turf/T as anything in hull_turfs)
		hull_x += T.x
		hull_y += T.y
		if(istype(T, /turf/closed/indestructible/dropship/sabre_window))
			window_x += T.x
			window_y += T.y
			windows++
	if(!windows)
		return NORTH
	var/toward_x = window_x / windows - hull_x / length(hull_turfs)
	var/toward_y = window_y / windows - hull_y / length(hull_turfs)
	if(abs(toward_x) < 0.5 && abs(toward_y) < 0.5)
		return NORTH
	if(abs(toward_x) > abs(toward_y))
		return toward_x > 0 ? EAST : WEST
	return toward_y > 0 ? NORTH : SOUTH

/// Pole w środku obrysu [turfs] (do zakotwiczenia cienia i obrazu)
/proc/planet_landing_center(list/turfs)
	if(!length(turfs))
		return
	var/min_x = INFINITY
	var/max_x = -INFINITY
	var/min_y = INFINITY
	var/max_y = -INFINITY
	for(var/turf/T as anything in turfs)
		min_x = min(min_x, T.x)
		max_x = max(max_x, T.x)
		min_y = min(min_y, T.y)
		max_y = max(max_y, T.y)
	var/turf/first = turfs[1]
	return locate(round((min_x + max_x) / 2), round((min_y + max_y) / 2), first.z)

/**
 * Obraz całego kadłuba rysowany gdzie indziej: wszystko, co widać na każdym polu kadłuba, skopiowane jako nakładka w miejscu
 * tego pola. Jeden obiekt, więc cały obraz porusza się razem (osobne pola rozjeżdżałyby się o piksel), i nieruchomy obraz,
 * a nie widok na żywo.
 */
/obj/effect/abstract/planet_landing_proxy
	name = ""
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	// Nad światem i jego oświetleniem: prom jest w powietrzu, nad wszystkimi
	plane = ABOVE_LIGHTING_PLANE
	appearance_flags = KEEP_TOGETHER | PIXEL_SCALE
	// Za oknami promu (pola planety w vis_contents) obrazu nie widać: załoga zobaczyłaby nieruchomą kopię swojego promu
	vis_flags = VIS_HIDE

/// Rysuje kadłub stojący na [sources] tak, jak stanie na [places] (ta sama kolejność, jeden poziom), obrócony o [rotation]
/// stopni zgodnie ze wskazówkami zegara. FALSE, gdy nie ma czego rysować
/obj/effect/abstract/planet_landing_proxy/proc/picture(list/sources, list/places, rotation = 0)
	if(!length(places) || length(sources) != length(places))
		return FALSE
	var/turf/anchor = planet_landing_center(places)
	if(!anchor)
		return FALSE
	abstract_move(anchor)
	var/matrix/turn = rotation ? matrix().Turn(rotation) : null
	// Osobno podłogi i reszta: w świecie płaszczyzna gry rysuje się cała nad płaszczyzną podłóg, niezależnie od warstw,
	// a w jednym obrazie wszystko sortowałoby się po warstwie (kable i dekale na podłodze zamalowałyby maszyny)
	var/list/floor_parts = list()
	var/list/game_parts = list()
	for(var/i in 1 to length(places))
		var/turf/source = sources[i]
		var/turf/place = places[i]
		if(!source || !place)
			continue
		var/offset_x = (place.x - anchor.x) * world.icon_size
		var/offset_y = (place.y - anchor.y) * world.icon_size
		var/mutable_appearance/floor = new(source)
		floor.plane = FLOAT_PLANE
		floor.pixel_x += offset_x
		floor.pixel_y += offset_y
		if(turn)
			floor.transform = turn
		if(source.plane == GAME_PLANE)
			game_parts += floor
		else
			floor_parts += floor
		for(var/atom/movable/thing as anything in source)
			if(thing.invisibility > SEE_INVISIBLE_LIVING || !thing.icon)
				continue
			// Tylko to, co rysuje się w samym świecie: poświaty i efekty na innych płaszczyznach malowałyby się jak obrazki
			if(thing.plane != FLOOR_PLANE && thing.plane != GAME_PLANE)
				continue
			var/mutable_appearance/part = new(thing)
			part.plane = FLOAT_PLANE
			part.pixel_x += offset_x
			part.pixel_y += offset_y
			if(turn)
				part.transform = thing.transform * turn
			if(thing.plane == GAME_PLANE)
				game_parts += part
			else
				floor_parts += part
	var/list/groups = list()
	var/rank = 0
	for(var/list/parts as anything in list(floor_parts, game_parts))
		rank++
		if(!length(parts))
			continue
		var/mutable_appearance/group = new()
		group.plane = FLOAT_PLANE
		group.layer = rank
		group.appearance_flags = KEEP_TOGETHER | PIXEL_SCALE
		group.overlays = parts
		groups += group
	overlays = groups
	return length(groups) > 0

/// Obłok kurzu wyrzucony spod krawędzi kadłuba przy lądowaniu albo starcie, odpływający od kadłuba
/obj/effect/temp_visual/planet_landing_dust
	name = ""
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke"
	color = "#c9b79c"
	// Także nad wznoszącym się promem
	plane = ABOVE_LIGHTING_PLANE
	pixel_x = -32
	pixel_y = -32
	alpha = 0
	duration = 2.4 SECONDS
	randomdir = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/// push - mnożnik odlotu (strumień z dysz odlatuje dalej niż kurz spod osiadającego kadłuba); dust_color - kolor kurzu
/obj/effect/temp_visual/planet_landing_dust/Initialize(mapload, push_dir = NORTH, push = 1, dust_color)
	. = ..()
	if(dust_color)
		color = dust_color
	else if(push > 1) // strumień z dysz: tyle powietrza co kurzu, jaśniejszy, żeby był widoczny też na piasku
		color = "#e4ded2"
	var/drift = round(rand(14, 28) * push)
	var/drift_x = (push_dir & EAST) ? drift : ((push_dir & WEST) ? -drift : rand(-6, 6))
	var/drift_y = (push_dir & NORTH) ? drift : ((push_dir & SOUTH) ? -drift : rand(-6, 6))
	transform = matrix(0.45, 0, 0, 0, 0.45, 0)
	animate(src, alpha = push > 1 ? rand(110, 150) : rand(80, 120), transform = matrix(0.7, 0, 0, 0, 0.7, 0), time = 0.3 SECONDS, easing = SINE_EASING | EASE_OUT)
	animate(alpha = 0, transform = matrix(1.1, 0, 0, 0, 1.1, 0), pixel_x = pixel_x + drift_x, pixel_y = pixel_y + drift_y, time = duration - 0.3 SECONDS, easing = SINE_EASING | EASE_OUT)

/// Cień kadłuba na ziemi lądowiska: nad podłogą, pod ścianami i wszystkim, co stoi na polu
/obj/effect/abstract/planet_descent_shadow/ground
	plane = GAME_PLANE
	layer = ABOVE_OPEN_TURF_LAYER - 0.01
	blur_size = 6

/// Okno na prawdziwy teren planety: pole kosmosu przy promie schodzącym na planetę pokazuje odpowiadające mu pole lądowiska
/// (z tym, co na nim stoi, i jego oświetleniem), tuż nad kosmosem, pod kadłubem
/obj/effect/abstract/planet_ground_window
	name = ""
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = FLOOR_PLANE
	layer = SPACE_LAYER + 0.01
	appearance_flags = PIXEL_SCALE
	alpha = 0

/**
 * Start z planety widziany z ziemi: obraz kadłuba unosi się, rusza do przodu i odlatuje w stronę dziobu, kurz leci spod
 * rufy, a cień zostaje na lądowisku, potem sunie za promem i blednie. Potem wszystko usuwa się samo.
 */
/datum/planet_launch_view
	var/obj/effect/abstract/planet_landing_proxy/proxy
	var/obj/effect/abstract/planet_descent_shadow/ground/shadow
	/// Pola, na których stał kadłub
	var/list/berth_turfs
	/// Kierunek dziobu na lądowisku
	var/bow_dir = NORTH

/// sources - pola kadłuba po starcie (w locie), places - pola lądowiska w tej samej kolejności, rotation - obrót kadłuba
/// z lotu na lądowisko (stopnie zgodnie ze wskazówkami zegara)
/datum/planet_launch_view/New(list/sources, list/places, rotation = 0)
	. = ..()
	berth_turfs = places
	if(!length(places))
		return
	bow_dir = turn(planet_landing_bow_dir(sources), -rotation)
	proxy = new(places[1])
	if(!proxy.picture(sources, places, rotation))
		QDEL_NULL(proxy)

/datum/planet_launch_view/Destroy(force)
	QDEL_NULL(proxy)
	QDEL_NULL(shadow)
	berth_turfs = null
	return ..()

/datum/planet_launch_view/proc/lift_off()
	planet_landing_jolt(berth_turfs, 'aquila/sound/planets/landing/liftoff_outside.ogg', 80, shake_strength = 1)
	planet_landing_wash(berth_turfs, PLANET_LAUNCH_WASH_PER_WAVE, 100, PLANET_LAUNCH_WASH_PUSH, bow_dir)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(planet_landing_wash), berth_turfs.Copy(), PLANET_LAUNCH_WASH_PER_WAVE, 100, PLANET_LAUNCH_WASH_PUSH, bow_dir), 0.35 SECONDS)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(planet_landing_wash), berth_turfs.Copy(), PLANET_LAUNCH_WASH_PER_WAVE, 100, PLANET_LAUNCH_WASH_PUSH, bow_dir), 0.7 SECONDS)
	if(!proxy)
		qdel(src)
		return
	var/bow_x = (bow_dir & EAST) ? 1 : ((bow_dir & WEST) ? -1 : 0)
	var/bow_y = (bow_dir & NORTH) ? 1 : ((bow_dir & SOUTH) ? -1 : 0)
	var/min_along = INFINITY
	var/max_along = -INFINITY
	for(var/turf/T as anything in berth_turfs)
		var/along = T.x * bow_x + T.y * bow_y
		min_along = min(min_along, along)
		max_along = max(max_along, along)
	var/fly = (max_along - min_along + 1 + PLANET_LAUNCH_GO_TILES) * world.icon_size
	// Cały czas poziomo: do przodu i w górę naraz, coraz szybciej. Bez obracania i zmniejszania
	animate(proxy, pixel_x = bow_x * PLANET_LAUNCH_TILT_CREEP, pixel_y = PLANET_LAUNCH_TILT_HEIGHT + bow_y * PLANET_LAUNCH_TILT_CREEP, time = PLANET_LAUNCH_LIFT_TIME + PLANET_LAUNCH_TILT_TIME, easing = SINE_EASING | EASE_IN)
	animate(pixel_x = bow_x * fly, pixel_y = PLANET_LAUNCH_GO_HEIGHT + bow_y * fly, time = PLANET_LAUNCH_GO_TIME, easing = QUAD_EASING | EASE_IN)
	shadow = new(planet_landing_center(berth_turfs), berth_turfs)
	var/slide = PLANET_LAUNCH_SHADOW_SLIDE_TILES * world.icon_size
	shadow.alpha = PLANET_LANDING_SHADOW_DARK
	animate(shadow, pixel_x = bow_x * PLANET_LAUNCH_TILT_CREEP, pixel_y = bow_y * PLANET_LAUNCH_TILT_CREEP, time = PLANET_LAUNCH_LIFT_TIME + PLANET_LAUNCH_TILT_TIME, easing = SINE_EASING | EASE_IN)
	animate(pixel_x = bow_x * slide, pixel_y = bow_y * slide, time = PLANET_LAUNCH_GO_TIME, easing = QUAD_EASING | EASE_IN)
	// Blednie od chwili, gdy rusza, więc znika przed promem
	animate(shadow, time = PLANET_LAUNCH_LIFT_TIME, flags = ANIMATION_PARALLEL)
	animate(alpha = 0, time = PLANET_LAUNCH_TILT_TIME + PLANET_LAUNCH_GO_TIME * 0.6, easing = SINE_EASING)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), PLANET_LAUNCH_LIFT_TIME + PLANET_LAUNCH_TILT_TIME + PLANET_LAUNCH_GO_TIME + 0.2 SECONDS)

// ---------------------------------------------------------------------------
// Zejście widziane z ziemi i prawdziwy teren za oknami promu (wywoływane z /datum/planet_descent)

/// Cień kadłuba na lądowisku: szeroki i blady, gdy prom jest wysoko, ciemnieje i zwęża się do obrysu przed przyziemieniem.
/// Słychać nadlatujący prom
/datum/planet_descent/proc/show_ground_shadow()
	if(ground_shadow || !length(berth))
		return
	ground_shadow = new(planet_landing_center(berth), berth)
	planet_landing_jolt(berth, 'aquila/sound/planets/landing/approach.ogg', 50)
	var/time_left = max(1, touchdown_time - world.time)
	var/fade_in = min(1.5 SECONDS, time_left / 4)
	var/spread_end = max(0, time_left - PLANET_LANDING_PROXY_LEAD - fade_in)
	var/close_time = min(PLANET_LANDING_PROXY_LEAD, time_left)
	ground_shadow.transform = matrix(PLANET_LANDING_SHADOW_WIDE, 0, 0, 0, PLANET_LANDING_SHADOW_WIDE, 0)
	animate(ground_shadow, alpha = PLANET_LANDING_SHADOW_FAINT, time = fade_in)
	animate(time = max(1, spread_end))
	animate(transform = matrix(PLANET_LANDING_SHADOW_NEAR, 0, 0, 0, PLANET_LANDING_SHADOW_NEAR, 0), alpha = 80, time = close_time * 2 / 3, easing = SINE_EASING)
	animate(transform = matrix(), alpha = PLANET_LANDING_SHADOW_DARK, time = close_time / 3, easing = SINE_EASING | EASE_OUT)

/// Obraz promu spada z nieba nad lądowisko i zawisa tuż nad nim do przyziemienia
/datum/planet_descent/proc/show_ground_proxy()
	if(ground_proxy || !length(hull_order))
		return
	ground_proxy = new(berth[1])
	if(!ground_proxy.picture(hull_order, berth, rotation))
		QDEL_NULL(ground_proxy)
		return
	var/time_left = max(1, touchdown_time - world.time)
	var/high_part = time_left * 2 / 3
	ground_proxy.pixel_y = PLANET_LANDING_PROXY_START_HEIGHT
	animate(ground_proxy, pixel_y = PLANET_LANDING_PROXY_FINAL_HEIGHT, time = high_part, easing = QUAD_EASING | EASE_OUT)
	animate(pixel_y = PLANET_LANDING_PROXY_HOVER, time = time_left - high_part, easing = SINE_EASING | EASE_OUT)

/// Dysze dosięgają ziemi: kurz spod krawędzi lądowiska
/datum/planet_descent/proc/thruster_wash()
	planet_landing_wash(berth, PLANET_LANDING_WASH_PUFFS, PLANET_LANDING_WASH_CHANCE, PLANET_LANDING_WASH_PUSH)

/// Ostatnia faza: za oknami pojawia się prawdziwy teren wokół lądowiska (pola kosmosu przy kadłubie pokazują pola planety,
/// na których stanie prom). Widać na nim cień kadłuba i kurz od dysz, tak jak zobaczą je ludzie na ziemi
/// fade_start, fade_time - po jakim czasie od początku podejścia teren zaczyna się pojawiać i jak długo
/datum/planet_descent/proc/show_ground_window(fade_start, fade_time)
	var/obj/docking_port/mobile/shuttle = craft?.shuttle_port
	if(!shuttle || !port || !length(hull_order) || length(ground_windows))
		return
	var/list/hull_set = list()
	for(var/turf/T as anything in hull_order)
		hull_set[T] = TRUE
	var/turf/first = hull_order[1]
	var/min_x = INFINITY
	var/max_x = -INFINITY
	var/min_y = INFINITY
	var/max_y = -INFINITY
	for(var/turf/T as anything in hull_order)
		min_x = min(min_x, T.x)
		max_x = max(max_x, T.x)
		min_y = min(min_y, T.y)
		max_y = max(max_y, T.y)
	var/turns = rotation / 90
	var/list/area_turfs = block(locate(max(1, min_x - PLANET_GROUND_VIEW_RANGE), max(1, min_y - PLANET_GROUND_VIEW_RANGE), first.z), locate(min(world.maxx, max_x + PLANET_GROUND_VIEW_RANGE), min(world.maxy, max_y + PLANET_GROUND_VIEW_RANGE), first.z))
	for(var/turf/T as anything in area_turfs)
		if(hull_set[T] || !isspaceturf(T))
			continue
		var/offset_x = T.x - shuttle.x
		var/offset_y = T.y - shuttle.y
		for(var/i = 0, i < turns, i++)
			var/old_x = offset_x
			offset_x = offset_y
			offset_y = -old_x
		var/turf/ground = locate(port.x + offset_x, port.y + offset_y, port.z)
		if(!ground)
			continue
		var/obj/effect/abstract/planet_ground_window/window = new(T)
		window.vis_contents += ground
		// W locie świat wokół kadłuba jest obrócony odwrotnie do obrotu kadłuba przy dokowaniu
		if(rotation)
			window.transform = matrix().Turn(-rotation)
		animate(window, alpha = 0, time = fade_start)
		animate(alpha = 255, time = fade_time, easing = SINE_EASING | EASE_IN)
		ground_windows += window

/// Usuwa widok z ziemi i teren za oknami; przy przerwanym zejściu wszystko blednie zamiast zniknąć
/datum/planet_descent/proc/clear_ground(fade = FALSE)
	var/list/leftovers = list(ground_shadow, ground_proxy) + ground_windows
	ground_shadow = null
	ground_proxy = null
	ground_windows = list()
	for(var/atom/movable/thing as anything in leftovers)
		if(QDELETED(thing))
			continue
		if(!fade)
			qdel(thing)
			continue
		animate(thing, alpha = 0, time = 1 SECONDS)
		QDEL_IN(thing, 1 SECONDS)

/// Dźwięk dla ludzi na pokładzie (na parkingu w locie nikt inny go nie słyszy)
/datum/planet_descent/proc/crew_sound(sound_file, volume)
	for(var/mob/M as anything in craft?.mobs_in_ship)
		if(M.client && M.can_hear())
			SEND_SOUND(M, sound(sound_file, volume = volume))

#undef PLANET_LANDING_SHADOW_LEAD
#undef PLANET_LANDING_PROXY_LEAD
#undef PLANET_LANDING_PROXY_START_HEIGHT
#undef PLANET_LANDING_PROXY_FINAL_HEIGHT
#undef PLANET_LANDING_PROXY_HOVER
#undef PLANET_LANDING_SHADOW_WIDE
#undef PLANET_LANDING_SHADOW_NEAR
#undef PLANET_LANDING_SHADOW_FAINT
#undef PLANET_LANDING_SHADOW_DARK
#undef PLANET_LANDING_WASH_PUFFS
#undef PLANET_LANDING_WASH_CHANCE
#undef PLANET_LANDING_WASH_PUSH
#undef PLANET_LAUNCH_LIFT_TIME
#undef PLANET_LAUNCH_TILT_TIME
#undef PLANET_LAUNCH_GO_TIME
#undef PLANET_LAUNCH_TILT_HEIGHT
#undef PLANET_LAUNCH_GO_HEIGHT
#undef PLANET_LAUNCH_TILT_CREEP
#undef PLANET_LAUNCH_GO_TILES
#undef PLANET_LAUNCH_SHADOW_SLIDE_TILES
#undef PLANET_LAUNCH_WASH_PER_WAVE
#undef PLANET_LAUNCH_WASH_PUSH
#undef PLANET_LANDING_SHAKE_RANGE
#undef PLANET_LANDING_SOUND_FULL
#undef PLANET_LANDING_SOUND_REACH
#undef PLANET_GROUND_VIEW_RANGE
