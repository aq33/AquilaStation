// AQUILA - prawdziwy teren lądowiska widziany z pokładu promu przy zejściu i starcie (port widoku z voidcrew/Voidcrew#588,
// Jackriip). Prom przez całe zejście stoi na parkingu w locie; pod nim rośnie obraz terenu wokół lądowiska, od mapki
// całej okolicy po dokładną kopię pól, w chwili przyziemienia w skali 1:1, więc przy dokowaniu nic się za oknami nie zmienia.
//
// Trzy obrazy tego samego terenu wokół środka lądowiska, każdy dokładniejszy i bliższy:
// - z daleka: dwa obrazki PNG z rust-g (2 i 8 pikseli na pole), barwy z ikon pól i tego, co na nich stoi,
// - z bliska: kopie pól i wszystkiego, co na nich stoi, pojawiają się, gdy teren jest już blisko.
// Rysują się na własnej płaszczyźnie (nad kosmosem i paralaksą, pod otwartą przestrzenią i podłogą), przyciętej maską: każde pole kosmosu
// parkingu wokół kadłuba ma nakładkę na płaszczyźnie maski, więc teren widać tylko tam, gdzie gracz widzi kosmos za
// kadłubem, a nie w ciemności poza zasięgiem wzroku.
//
// Różnice względem oryginału: jeden wspólny obiekt na parkingu zamiast obrazów dla każdego gracza osobno (wnętrze promu
// jest przezroczyste i jego środek zawsze jest w zasięgu wzroku), maska na nakładkach pól zamiast nakładek obszarów
// (parking nie ma własnego obszaru), bez wypiekania światła i pogody, a niebo zostaje nasze (planet_sky.dm).

#define AQ_LANDING_VIEW_PLANE -6
#define AQ_LANDING_VIEW_MASK_PLANE -7
#define AQ_LANDING_VIEW_MASK_RENDER_TARGET "*AQ_LANDING_VIEW_MASK"

/// Obrazy z daleka: zasięg od środka lądowiska (pola) i piksele na pole
#define PLANET_GROUND_FAR_REACH 64
#define PLANET_GROUND_FAR_GRAIN 2
#define PLANET_GROUND_NEAR_REACH 24
#define PLANET_GROUND_NEAR_GRAIN 8
/// Obraz z bliska: ile pól poza obrys kadłuba
#define PLANET_GROUND_CLOSE_REACH 12
/// Jak długo obraz z daleka służy kolejnym zejściom na to samo miejsce
#define PLANET_GROUND_KEEP (10 MINUTES)
/// Wielkość terenu (względem prawdziwej), przy której pojawia się obraz z bliska
#define PLANET_GROUND_DETAIL_FROM 0.75
#define PLANET_GROUND_DETAIL_FULL 0.9
/// Jak daleko od kadłuba pola parkingu dostają maskę (zasięg wzroku z każdego miejsca promu)
#define PLANET_GROUND_MASK_RANGE 12

/// Maska widoku lądowania: nigdy nie rysuje się sama, tylko przycina płaszczyznę widoku do widocznych pól kosmosu
/atom/movable/screen/plane_master/aq_landing_view_mask
	name = "landing view mask plane master"
	plane = AQ_LANDING_VIEW_MASK_PLANE
	appearance_flags = PLANE_MASTER | NO_CLIENT_COLOR
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

// Nazwę dostaje tylko plane master HUD-u (backdrop), jak kopie płaszczyzn w soft_lighting.dm
/atom/movable/screen/plane_master/aq_landing_view_mask/backdrop(mob/mymob)
	. = ..()
	render_target = AQ_LANDING_VIEW_MASK_RENDER_TARGET

/// Teren lądowiska widziany z promu: nad kosmosem i paralaksą, pod podłogą kadłuba, przycięty maską
/atom/movable/screen/plane_master/aq_landing_view
	name = "landing view plane master"
	plane = AQ_LANDING_VIEW_PLANE
	appearance_flags = PLANE_MASTER | NO_CLIENT_COLOR
	blend_mode = BLEND_OVERLAY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/plane_master/aq_landing_view/backdrop(mob/mymob)
	. = ..()
	clear_filters()
	add_filter("aq_landing_view_mask", 1, alpha_mask_filter(render_source = AQ_LANDING_VIEW_MASK_RENDER_TARGET))

/// Jeden obraz terenu (z daleka albo z bliska), skalowany wokół środka kadłuba
/obj/effect/abstract/planet_ground_picture
	name = ""
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = AQ_LANDING_VIEW_PLANE
	appearance_flags = PIXEL_SCALE
	alpha = 0

/**
 * Teren wokół lądowiska dla ludzi w promie na parkingu. Budowany przy starcie zejścia (obrazy z daleka powstają w tle),
 * pokazywany w ostatniej fazie, usuwany przy dokowaniu albo blednący przy przerwanym zejściu.
 */
/datum/planet_ground_view
	/// Pola kadłuba na parkingu i pola lądowiska, na których każde z nich stoi albo stanie (ta sama kolejność)
	var/list/hull_turfs
	var/list/berth_turfs
	/// O ile stopni (zgodnie ze wskazówkami zegara) kadłub obraca się z parkingu na lądowisko
	var/rotation = 0
	/// Rezerwacja powierzchni planety: teren spoza niej nie wchodzi do obrazów
	var/datum/turf_reservation/surface
	/// Środek lądowiska i środek kadłuba na parkingu (w polach, może wypaść w połowie pola)
	var/ground_x
	var/ground_y
	var/hull_x
	var/hull_y
	var/obj/effect/abstract/planet_ground_picture/far_picture
	var/obj/effect/abstract/planet_ground_picture/near_picture
	var/obj/effect/abstract/planet_ground_picture/close_picture
	/// Pola parkingu z nakładką maski
	var/list/masked_turfs = list()
	/// Obrazy z daleka są gotowe (albo nie da się ich zrobić)
	var/aerial_done = FALSE
	/// Pokaz już trwa: obrazy z daleka gotowe później od razu dołączają do ruchu
	var/list/playing

/datum/planet_ground_view/New(list/new_hull_turfs, list/new_berth_turfs, new_rotation, datum/turf_reservation/new_surface)
	. = ..()
	hull_turfs = new_hull_turfs.Copy()
	berth_turfs = new_berth_turfs.Copy()
	rotation = new_rotation
	surface = new_surface
	var/list/box = planet_ground_box(berth_turfs)
	ground_x = (box[1] + box[3]) / 2
	ground_y = (box[2] + box[4]) / 2
	box = planet_ground_box(hull_turfs)
	hull_x = (box[1] + box[3]) / 2
	hull_y = (box[2] + box[4]) / 2
	var/turf/hull_first = hull_turfs[1]
	var/turf/anchor = locate(round(hull_x), round(hull_y), hull_first.z)
	for(var/rank in 1 to 3)
		var/obj/effect/abstract/planet_ground_picture/picture = new(anchor)
		picture.pixel_x = (hull_x - round(hull_x)) * world.icon_size
		picture.pixel_y = (hull_y - round(hull_y)) * world.icon_size
		picture.layer = rank
		switch(rank)
			if(1)
				far_picture = picture
			if(2)
				near_picture = picture
			if(3)
				close_picture = picture

/datum/planet_ground_view/Destroy(force)
	unmask()
	QDEL_NULL(far_picture)
	QDEL_NULL(near_picture)
	QDEL_NULL(close_picture)
	hull_turfs = null
	berth_turfs = null
	surface = null
	return ..()

/// Obrys pól: list(min x, min y, max x, max y)
/proc/planet_ground_box(list/turfs)
	. = list(INFINITY, INFINITY, -INFINITY, -INFINITY)
	for(var/turf/T as anything in turfs)
		.[1] = min(.[1], T.x)
		.[2] = min(.[2], T.y)
		.[3] = max(.[3], T.x)
		.[4] = max(.[4], T.y)

/// Czy pole należy do powierzchni tej planety
/datum/planet_ground_view/proc/on_surface(turf/T)
	return T && (!surface || SSmapping.used_turfs[T] == surface)

/// Obrazy z daleka (rust-g) w tle; z kopii z poprzedniego zejścia na to miejsce od razu. only_kept: tylko z kopii
/datum/planet_ground_view/proc/bake_aerial(only_kept = FALSE)
	set waitfor = FALSE
	var/turf/berth_first = berth_turfs[1]
	var/list/skip = list()
	for(var/turf/T as anything in berth_turfs)
		skip[T] = TRUE
	var/list/grains = list(list(PLANET_GROUND_FAR_REACH, PLANET_GROUND_FAR_GRAIN, far_picture), list(PLANET_GROUND_NEAR_REACH, PLANET_GROUND_NEAR_GRAIN, near_picture))
	for(var/list/grain as anything in grains)
		var/icon/aerial = planet_ground_aerial(round(ground_x), round(ground_y), berth_first.z, grain[1], grain[2], skip, surface, only_kept, src)
		if(QDELETED(src))
			return
		var/obj/effect/abstract/planet_ground_picture/picture = grain[3]
		if(!aerial || QDELETED(picture))
			continue
		var/size = aerial.Width()
		var/mutable_appearance/country = mutable_appearance(aerial)
		country.plane = FLOAT_PLANE
		// Bez tego klient wygładza obrazek powiększony kilkanaście razy w rozmytą plamę
		country.appearance_flags = PIXEL_SCALE
		// Środek obrazka to róg między czterema polami; środek obrazu terenu to środek lądowiska
		country.pixel_x = -(size - world.icon_size) / 2 + (round(ground_x) - 0.5 - ground_x) * world.icon_size
		country.pixel_y = -(size - world.icon_size) / 2 + (round(ground_y) - 0.5 - ground_y) * world.icon_size
		country.transform = matrix(world.icon_size / grain[2], 0, 0, 0, world.icon_size / grain[2], 0)
		picture.overlays = list(country)
	aerial_done = TRUE
	if(playing)
		play(arglist(playing))

/// Obraz z bliska: kopie pól wokół lądowiska i wszystkiego, co na nich stoi (bez tego, co stoi na samym lądowisku:
/// kadłub to zgniecie). Dla startu z planety bez pominięć
/datum/planet_ground_view/proc/build_close(skip_berth = TRUE)
	var/turf/first = berth_turfs[1]
	var/list/box = planet_ground_box(berth_turfs)
	var/list/berth_set = list()
	if(skip_berth)
		for(var/turf/T as anything in berth_turfs)
			berth_set[T] = TRUE
	var/list/parts = list()
	var/low_x = max(1, box[1] - PLANET_GROUND_CLOSE_REACH)
	var/low_y = max(1, box[2] - PLANET_GROUND_CLOSE_REACH)
	var/high_x = min(world.maxx, box[3] + PLANET_GROUND_CLOSE_REACH)
	var/high_y = min(world.maxy, box[4] + PLANET_GROUND_CLOSE_REACH)
	for(var/turf/ground as anything in block(locate(low_x, low_y, first.z), locate(high_x, high_y, first.z)))
		if(!on_surface(ground))
			continue
		var/offset_x = (ground.x - ground_x) * world.icon_size
		var/offset_y = (ground.y - ground_y) * world.icon_size
		parts += planet_ground_part(ground, offset_x, offset_y, ground.plane == GAME_PLANE ? 2 : 1)
		if(berth_set[ground])
			continue
		for(var/atom/movable/thing as anything in ground)
			if(thing.invisibility > SEE_INVISIBLE_LIVING || !thing.icon || thing.alpha < 20)
				continue
			if(istype(thing, /obj/effect/abstract) || istype(thing, /obj/effect/temp_visual) || istype(thing, /obj/docking_port) || istype(thing, /obj/effect/planet_landing_blocker))
				continue
			if(thing.plane != FLOOR_PLANE && thing.plane != GAME_PLANE)
				continue
			parts += planet_ground_part(thing, offset_x, offset_y, thing.plane == GAME_PLANE ? 2 : 1)
	close_picture.overlays = parts

/// Kopia wyglądu do obrazu terenu: tylko to, co rysuje się na płaszczyznach świata. Podłogi pod wszystkim, co stoi
/proc/planet_ground_part(atom/thing, offset_x, offset_y, rank)
	var/mutable_appearance/part = new(thing)
	part.plane = FLOAT_PLANE
	part.layer = rank + thing.layer / 100
	part.pixel_x += offset_x
	part.pixel_y += offset_y
	part.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	// Nakładka na innej płaszczyźnie (poświata, światło) rysowałaby się na parkingu poza obrazem i bez maski
	if(length(part.overlays))
		part.overlays = planet_ground_world_layers(part.overlays)
	if(length(part.underlays))
		part.underlays = planet_ground_world_layers(part.underlays)
	return part

/// Nakładki, które rysują się na płaszczyznach świata
/proc/planet_ground_world_layers(list/layers)
	. = list()
	for(var/mutable_appearance/over as anything in layers)
		if(over.plane == FLOAT_PLANE || over.plane == FLOOR_PLANE || over.plane == GAME_PLANE)
			. += over

/// Nakładki maski na polach kosmosu parkingu wokół kadłuba
/datum/planet_ground_view/proc/mask()
	if(length(masked_turfs))
		return
	var/mutable_appearance/mask_tile = planet_ground_mask_tile()
	var/list/hull_set = list()
	for(var/turf/T as anything in hull_turfs)
		hull_set[T] = TRUE
	var/list/box = planet_ground_box(hull_turfs)
	var/turf/first = hull_turfs[1]
	var/list/area_turfs = block(locate(max(1, box[1] - PLANET_GROUND_MASK_RANGE), max(1, box[2] - PLANET_GROUND_MASK_RANGE), first.z), locate(min(world.maxx, box[3] + PLANET_GROUND_MASK_RANGE), min(world.maxy, box[4] + PLANET_GROUND_MASK_RANGE), first.z))
	for(var/turf/T as anything in area_turfs)
		if(hull_set[T] || !isspaceturf(T))
			continue
		T.add_overlay(mask_tile)
		masked_turfs += T

/datum/planet_ground_view/proc/unmask()
	var/mutable_appearance/mask_tile = planet_ground_mask_tile()
	for(var/turf/T as anything in masked_turfs)
		T.cut_overlay(mask_tile)
	masked_turfs.Cut()

/// Nakładka maski na polu kosmosu (biały kafelek na płaszczyźnie maski)
/proc/planet_ground_mask_tile()
	var/static/mutable_appearance/mask_tile
	if(!mask_tile)
		mask_tile = mutable_appearance('aquila/icons/effects/planet_descent.dmi', "fill", plane = AQ_LANDING_VIEW_MASK_PLANE)
		mask_tile.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	return mask_tile

/// Macierz obrazu terenu w danej skali: obrócona odwrotnie do obrotu kadłuba przy dokowaniu
/datum/planet_ground_view/proc/ground_matrix(scale)
	var/matrix/M = matrix(scale, 0, 0, 0, scale, 0)
	if(rotation)
		M.Turn(-rotation)
	return M

/**
 * Ruch terenu: skala from_scale -> to_scale przez time, krycie obrazów z daleka from_alpha -> to_alpha (zaczyna się po
 * alpha_delay). Obraz z bliska widać tylko przy skali od PLANET_GROUND_DETAIL_FROM do PLANET_GROUND_DETAIL_FULL i więcej.
 */
/datum/planet_ground_view/proc/play(from_scale, to_scale, time, from_alpha = 255, to_alpha = 255, alpha_delay = 0, alpha_time = 0, easing = SINE_EASING | EASE_OUT)
	mask()
	if(!aerial_done)
		// Obrazy z daleka jeszcze się pieką: dołączą do ruchu, gdy będą gotowe (z uwzględnieniem tego, co już minęło)
		playing = list(from_scale, to_scale, time, from_alpha, to_alpha, alpha_delay, alpha_time, easing, world.time)
	var/started = length(args) >= 9 ? args[9] : world.time
	var/elapsed = clamp(world.time - started, 0, time)
	var/remaining = max(1, time - elapsed)
	// Skala w chwili dołączenia (przybliżenie liniowe wystarcza: dołącza najwyżej kilka dziesiątych sekundy później)
	var/now_scale = from_scale + (to_scale - from_scale) * (elapsed / max(1, time))
	// animate() bez zmienianych zmiennych (nawet z czasem i ANIMATION_PARALLEL) zatrzymuje wszystkie animacje obiektu,
	// więc każdy łańcuch krycia zaczyna się od kroku, który coś zmienia
	for(var/obj/effect/abstract/planet_ground_picture/picture as anything in list(far_picture, near_picture, close_picture))
		if(QDELETED(picture))
			continue
		animate(picture)
		picture.transform = ground_matrix(now_scale)
		animate(picture, transform = ground_matrix(to_scale), time = remaining, easing = easing)
		if(picture == close_picture)
			// Krycie obrazu z bliska z wielkości terenu: jego krzywa w kilku krokach
			picture.alpha = detail_alpha(now_scale)
			var/steps = 6
			for(var/step in 1 to steps)
				var/step_alpha = detail_alpha(now_scale + (to_scale - now_scale) * planet_ground_ease(step / steps, easing))
				if(step == 1)
					animate(picture, alpha = step_alpha, time = remaining / steps, flags = ANIMATION_PARALLEL)
				else
					animate(alpha = step_alpha, time = remaining / steps)
			continue
		// Obrazy z daleka: from_alpha przez alpha_delay, potem przez alpha_time do to_alpha
		if(!alpha_time)
			picture.alpha = elapsed >= alpha_delay ? to_alpha : from_alpha
			if(elapsed < alpha_delay)
				animate(picture, alpha = from_alpha, time = alpha_delay - elapsed, flags = ANIMATION_PARALLEL)
				animate(alpha = to_alpha, time = 1)
			continue
		var/progress = clamp((elapsed - alpha_delay) / alpha_time, 0, 1)
		picture.alpha = from_alpha + (to_alpha - from_alpha) * progress
		if(progress >= 1)
			continue
		var/fade = max(1, alpha_delay + alpha_time - max(elapsed, alpha_delay))
		if(elapsed < alpha_delay)
			animate(picture, alpha = picture.alpha, time = alpha_delay - elapsed, flags = ANIMATION_PARALLEL)
			animate(alpha = to_alpha, time = fade)
		else
			animate(picture, alpha = to_alpha, time = fade, flags = ANIMATION_PARALLEL)

/// Krycie obrazu z bliska przy tej wielkości terenu
/datum/planet_ground_view/proc/detail_alpha(scale)
	return clamp((scale - PLANET_GROUND_DETAIL_FROM) / (PLANET_GROUND_DETAIL_FULL - PLANET_GROUND_DETAIL_FROM), 0, 1) * 255

/// Postęp ruchu 0-1 po krzywej animate() (tylko te, których używa widok terenu)
/proc/planet_ground_ease(progress, easing)
	if(easing & EASE_OUT)
		return sin(progress * 90)
	if(easing & EASE_IN)
		return 1 - cos(progress * 90)
	return progress

/// Przerwane zejście: teren blednie, potem znika
/datum/planet_ground_view/proc/fade_away()
	playing = null
	for(var/obj/effect/abstract/planet_ground_picture/picture as anything in list(far_picture, near_picture, close_picture))
		if(!QDELETED(picture))
			animate(picture, alpha = 0, time = 1 SECONDS)
	QDEL_IN(src, 1 SECONDS)

// ---------------------------------------------------------------------------
// Obrazy z daleka

/**
 * Mały obraz terenu na reach pól w każdą stronę od mid_x, mid_y, grain pikseli na pole: każde pole i to, co na nim
 * stoi (bez ludzi i przedmiotów), w swoich barwach. Zapamiętywany na PLANET_GROUND_KEEP dla tego samego miejsca. Może
 * trwać kilka ticków. null, gdy się nie da.
 * * skip_contents - pola, z których nie bierze tego, co na nich stoi (lądowisko pod kadłubem)
 * * surface - rezerwacja powierzchni; pola spoza niej w kolorze tła
 * * only_kept - tylko zapamiętany obraz, bez robienia nowego
 * * owner - widok, dla którego powstaje obraz: gdy zniknie (zejście przerwane), robienie obrazu się przerywa
 */
/proc/planet_ground_aerial(mid_x, mid_y, z, reach, grain, list/skip_contents, datum/turf_reservation/surface, only_kept = FALSE, datum/owner)
	var/static/list/kept = list()
	var/key = "[mid_x],[mid_y],[z],[reach],[grain]"
	var/list/had = kept[key]
	if(had && had[2] > world.time)
		return had[1]
	if(only_kept)
		return null
	var/side = reach * 2 * grain
	// Każdy piksel, od górnego wiersza
	var/list/cells = new /list(side * side)
	var/low_x = mid_x - reach
	var/low_y = mid_y - reach
	var/list/occupied = list()
	for(var/tile_y = mid_y + reach - 1, tile_y >= low_y, tile_y--)
		for(var/tile_x in low_x to mid_x + reach - 1)
			var/turf/ground = locate(tile_x, tile_y, z)
			if(!ground || (surface && SSmapping.used_turfs[ground] != surface))
				continue
			planet_ground_stamp(cells, side, planet_ground_tones(ground.icon, ground.icon_state, ground.dir, grain), (tile_x - low_x) * grain + round(ground.pixel_x * grain / world.icon_size, 1), (tile_y - low_y) * grain + round(ground.pixel_y * grain / world.icon_size, 1))
			if(length(ground.contents) && !skip_contents?[ground])
				occupied += ground
		CHECK_TICK
		if(owner && QDELETED(owner))
			planet_ground_sheet(forget = TRUE)
			return null
	for(var/turf/ground as anything in occupied)
		var/list/standing = list()
		for(var/atom/movable/thing as anything in ground)
			// Nic, co się rusza, i nic za małego, żeby było widać z góry
			if(ismob(thing) || isitem(thing) || thing.invisibility > SEE_INVISIBLE_LIVING || !thing.icon || thing.alpha < 128)
				continue
			if(istype(thing, /obj/effect/abstract) || istype(thing, /obj/effect/temp_visual) || istype(thing, /obj/docking_port))
				continue
			if(thing.plane != FLOOR_PLANE && thing.plane != GAME_PLANE)
				continue
			var/place = 1
			for(var/atom/movable/other as anything in standing)
				if(other.layer > thing.layer)
					break
				place++
			standing.Insert(place, thing)
		for(var/atom/movable/thing as anything in standing)
			planet_ground_stamp(cells, side, planet_ground_tones(thing.icon, thing.icon_state, thing.dir, grain), (ground.x - low_x) * grain + round(thing.pixel_x * grain / world.icon_size, 1), (ground.y - low_y) * grain + round(thing.pixel_y * grain / world.icon_size, 1))
		CHECK_TICK
		if(owner && QDELETED(owner))
			planet_ground_sheet(forget = TRUE)
			return null
	// Poza powierzchnią: średni kolor terenu
	var/list/total = list(0, 0, 0)
	var/found = 0
	for(var/i in 1 to length(cells) step 7)
		var/tone = cells[i]
		if(!tone)
			continue
		var/list/rgb_parts = rgb2num(tone)
		total[1] += rgb_parts[1]
		total[2] += rgb_parts[2]
		total[3] += rgb_parts[3]
		found++
	if(!found)
		planet_ground_sheet(forget = TRUE)
		return null
	var/fill = rgb(total[1] / found, total[2] / found, total[3] / found)
	for(var/i in 1 to length(cells))
		if(!cells[i])
			cells[i] = fill
	var/path = "data/landing_view/[z]_[mid_x]_[mid_y]_[grain].png"
	if(!fexists("data/landing_view/made"))
		text2file("", "data/landing_view/made") // tworzy folder
	var/failed = rustg_dmi_create_png(path, "[side]", "[side]", cells.Join(""))
	planet_ground_sheet(forget = TRUE)
	if(failed)
		stack_trace("Brak obrazu terenu dla widoku lądowania: [failed]")
		return null
	var/icon/aerial = new(path)
	kept[key] = list(aerial, world.time + PLANET_GROUND_KEEP)
	return aerial

/// Wpisuje [tones] (z planet_ground_tones()) w [cells] obrazu, lewym dolnym rogiem shift_x komórek w prawo i shift_y w górę
/proc/planet_ground_stamp(list/cells, side, list/tones, shift_x, shift_y)
	for(var/row in 1 to length(tones))
		var/at_y = shift_y + row - 1
		if(at_y < 0 || at_y >= side)
			continue
		var/list/line = tones[row]
		var/base = (side - 1 - at_y) * side + shift_x
		for(var/col in 1 to length(line))
			var/tone = line[col]
			if(!tone || shift_x + col < 1 || shift_x + col > side)
				continue
			cells[base + col] = tone

/**
 * Stan ikony zmniejszony do grain pikseli na pole: wiersze od dołu, każdy lista kolorów (null tam, gdzie jest
 * przezroczysta). Szesnaście poziomów każdej barwy, więc obrazek ma mało kolorów i mały plik. Liczony raz dla każdego wyglądu.
 */
/proc/planet_ground_tones(icon_file, state, dir, grain)
	var/static/list/known = list()
	var/static/list/real_dirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
	if(!icon_file)
		return list()
	if(!(dir in real_dirs))
		dir = SOUTH
	var/key = "[icon_file]|[state]|[dir]|[grain]"
	var/list/tones = known[key]
	if(tones)
		return tones
	tones = list()
	var/icon/sheet = planet_ground_sheet(icon_file)
	var/width = sheet.Width()
	var/height = sheet.Height()
	var/stride = world.icon_size / grain
	var/middle = 1 + round(stride / 2)
	for(var/row in 1 to CEILING(height / stride, 1))
		var/list/line = new /list(CEILING(width / stride, 1))
		for(var/col in 1 to length(line))
			var/pixel = sheet.GetPixel(min(width, (col - 1) * stride + middle), min(height, (row - 1) * stride + middle), state, dir, 1)
			if(!pixel)
				continue
			var/list/rgb_parts = rgb2num(pixel)
			if(length(rgb_parts) > 3 && rgb_parts[4] < 128)
				continue
			line[col] = rgb(round(rgb_parts[1], 17), round(rgb_parts[2], 17), round(rgb_parts[3], 17))
		tones += list(line)
	known[key] = tones
	return tones

/// Jedna ikona na cały plik, czytana stan po stanie (wycinanie każdego stanu osobno jest wolne). Trzymana tylko na
/// czas robienia obrazu
/proc/planet_ground_sheet(icon_file, forget = FALSE)
	var/static/list/sheets = list()
	if(forget)
		sheets = list()
		return null
	var/icon/sheet = sheets["[icon_file]"]
	if(!sheet)
		sheet = icon(icon_file)
		sheets["[icon_file]"] = sheet
	return sheet

#undef PLANET_GROUND_FAR_REACH
#undef PLANET_GROUND_FAR_GRAIN
#undef PLANET_GROUND_NEAR_REACH
#undef PLANET_GROUND_NEAR_GRAIN
#undef PLANET_GROUND_CLOSE_REACH
#undef PLANET_GROUND_KEEP
#undef PLANET_GROUND_DETAIL_FROM
#undef PLANET_GROUND_DETAIL_FULL
#undef PLANET_GROUND_MASK_RANGE
