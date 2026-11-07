// AQUILA - dźwięk przestrzenny jak w SS14: wygłuszanie przez ściany i pozycja dźwięku śledzona przez klienta.
// Hooki w code/game/sound.dm (playsound(), playsound_local()).
//
// Co działa w BYOND 516 (FMOD Ex, mikser programowy), zmierzone nagraniem wyjścia audio:
// - echo[1] (Direct) ścisza tylko ścieżkę suchą, pogłos pomieszczenia zostaje. Za ścianą zostaje więc głównie pogłos.
// - echo[3] (Room) zmienia ilość pogłosu dla jednego dźwięku.
// - echo DirectHF/Obstruction/Occlusion/Exclusion nic nie zmieniają, filtra dolnoprzepustowego po stronie klienta nie ma.
//   Stłumienie barwy dają gotowe pliki (muffled_sounds.dm, aquila/tools/muffle_sounds.py).
// - sound.atom + sound.transform: klient sam przesuwa dźwięk, gdy gracz albo źródło się rusza.
//   Pozycja jest w pikselach względem środka widoku. Atom poza widokiem klienta milknie (~-44 dB), stąd SOUND_TRACK_RANGE.

/// Wygłuszenie od tej wartości podmienia dźwięk na stłumioną kopię (ściana, zamknięte drzwi, okno wzmacniane w pełnym kafelku)
#define SOUND_OCCLUSION_MUFFLE_THRESHOLD 0.3
/// Ile głośności zabiera pełne wygłuszenie (1)
#define SOUND_OCCLUSION_VOLUME 0.5
/// Ile ścieżki suchej (echo Direct, mB) zabiera pełne wygłuszenie; pogłos zostaje
#define SOUND_OCCLUSION_DIRECT -2000
/// Wygłuszenie dźwięku z innego pokładu (podłoga między)
#define SOUND_OCCLUSION_OTHER_Z 0.5
/// Panorama: wysokość dźwięku na kratkę odległości w bok. 0 = dźwięk z boku gra w jednym uchu, 0.7 = ok. -15 dB w drugim
#define SOUND_PAN_SOFTNESS 0.7
/// Do tylu kratek od gracza klient śledzi źródło (atom musi być w widoku, inaczej milknie)
#define SOUND_TRACK_RANGE 6
/// Od tylu kratek dźwięk gra ze stłumionej kopii: powietrze zjada wysokie tony
#define SOUND_DISTANT_MUFFLE_RANGE 11
/// Szczelny hełm: ile głośności zostaje
#define SOUND_HELMET_VOLUME 0.85
/// Szczelny hełm: ile ścieżki suchej (mB) zabiera
#define SOUND_HELMET_DIRECT -400
/// Droga przez otwarte drzwi: najwyżej tyle kafelków przeszukujemy na jeden dźwięk
#define SOUND_PATH_MAX_NODES 400
/// Droga przez otwarte drzwi: wynik dla jednego kafelka źródła żyje tyle (seria z broni)
#define SOUND_PATH_CACHE_TIME (0.5 SECONDS)
/// Droga przez otwarte drzwi liczy się tylko dla dźwięków co najmniej tak głośnych (strzały, wybuchy, krzyki)
#define SOUND_PATH_MIN_VOLUME 40

/**
 * Wygłuszenie (0-1) na prostej między źródłem a słuchaczem: suma sound_dampening ścian, okien i zamkniętych drzwi.
 * Bresenham bez budowania listy kafelków, przerywa po osiągnięciu 1. Kafelek źródła się nie liczy.
 */
/proc/get_sound_occlusion(turf/source_turf, turf/listener_turf)
	if(!source_turf || !listener_turf)
		return 0
	if(source_turf.z != listener_turf.z)
		return SOUND_OCCLUSION_OTHER_Z
	var/dx = listener_turf.x - source_turf.x
	var/dy = listener_turf.y - source_turf.y
	var/abs_dx = abs(dx)
	var/abs_dy = abs(dy)
	var/steps = max(abs_dx, abs_dy)
	if(!steps)
		return 0
	var/sign_x = SIGN(dx)
	var/sign_y = SIGN(dy)
	var/x = source_turf.x
	var/y = source_turf.y
	var/z = source_turf.z
	var/error_x = abs_dx >> 1
	var/error_y = abs_dy >> 1
	. = 0
	for(var/i in 1 to steps)
		if(abs_dx >= abs_dy)
			error_y += abs_dy
			if(error_y >= abs_dx)
				error_y -= abs_dx
				y += sign_y
			x += sign_x
		else
			error_x += abs_dx
			if(error_x >= abs_dy)
				error_x -= abs_dy
				x += sign_x
			y += sign_y
		var/turf/line_turf = locate(x, y, z)
		if(!line_turf)
			continue
		. += line_turf.get_sound_dampening()
		for(var/obj/O in line_turf)
			if(O.sound_dampening)
				. += O.get_sound_dampening()
		if(. >= 1)
			return 1

/// Czy dźwięk przechodzi przez kafelek bez strat (bez ściany, zamkniętych drzwi i szyby)
/proc/sound_passes_turf(turf/T)
	if(T.get_sound_dampening())
		return FALSE
	for(var/obj/O in T)
		if(O.sound_dampening && O.get_sound_dampening())
			return FALSE
	return TRUE

/// Mapa dróg dźwięku od jednego kafelka (BFS przez przejścia), wspólna dla wszystkich słuchaczy jednego dźwięku
/datum/sound_path_map
	var/turf/source
	var/created
	/// kafelek -> liczba kroków od źródła
	var/list/steps = list()
	/// kafelek -> poprzedni kafelek w stronę źródła
	var/list/previous = list()

/datum/sound_path_map/New(turf/source_turf, radius)
	source = source_turf
	created = world.time
	steps[source_turf] = 0
	var/list/queue = list(source_turf)
	var/index = 1
	while(index <= length(queue) && length(queue) < SOUND_PATH_MAX_NODES)
		var/turf/T = queue[index++]
		var/next_steps = steps[T] + 1
		if(next_steps > radius)
			continue
		for(var/dir in GLOB.cardinals)
			var/turf/next = get_step(T, dir)
			if(!next || !isnull(steps[next]) || !sound_passes_turf(next))
				continue
			steps[next] = next_steps
			previous[next] = T
			queue += next

GLOBAL_DATUM(sound_path_cache, /datum/sound_path_map)

/**
 * Skąd słuchacz słyszy dźwięk: list(wygłuszenie, atom do pozycji). Duchy słyszą wprost.
 * Głośny dźwięk za ścianą, do którego prowadzi droga przez otwarte drzwi, dochodzi od strony przejścia i mniej stłumiony.
 */
/proc/sound_heard_through(turf/source_turf, mob/listener, volume, max_distance, atom/source)
	var/turf/listener_turf = get_turf(listener)
	var/occlusion = get_sound_occlusion(source_turf, listener_turf)
	if(occlusion < SOUND_OCCLUSION_MUFFLE_THRESHOLD || volume < SOUND_PATH_MIN_VOLUME || !listener_turf || listener_turf.z != source_turf.z)
		return list(occlusion, source)
	var/datum/sound_path_map/paths = GLOB.sound_path_cache
	if(!paths || paths.source != source_turf || paths.created + SOUND_PATH_CACHE_TIME < world.time)
		paths = new /datum/sound_path_map(source_turf, min(max_distance, SOUND_RANGE))
		GLOB.sound_path_cache = paths
	var/path_steps = paths.steps[listener_turf]
	if(isnull(path_steps))
		return list(occlusion, source)
	// Okrężna droga gubi trochę dźwięku: kilka kroków ponad prostą to jeszcze prawie czysto
	var/detour = max(path_steps - get_dist(source_turf, listener_turf), 0)
	var/path_occlusion = min(0.1 + detour * 0.04, SOUND_OCCLUSION_MUFFLE_THRESHOLD - 0.01)
	if(path_occlusion >= occlusion)
		return list(occlusion, source)
	// Dźwięk wychodzi z najdalszego kafelka drogi, który słuchacz ma jeszcze na prostej (zwykle otwarte drzwi)
	var/turf/opening = listener_turf
	var/turf/current = paths.previous[listener_turf]
	while(current && current != source_turf)
		if(get_sound_occlusion(current, listener_turf) > 0)
			break
		opening = current
		current = paths.previous[current]
	return list(path_occlusion, opening == listener_turf ? source : opening)

/// Szczelny hełm (skafander, MOD): wszystko słychać przytłumione
/mob/proc/has_sealed_helmet()
	return FALSE

/mob/living/carbon/human/has_sealed_helmet()
	var/obj/item/clothing/helmet = head
	return istype(helmet) && (helmet.clothing_flags & STOPSPRESSUREDAMAGE)

/**
 * Stosuje wygłuszenie do dźwięku wysyłanego jednemu słuchaczowi: ciszej, mniej ścieżki suchej, a od progu,
 * z daleka albo w szczelnym hełmie stłumiona kopia. Zwraca oryginalny plik, jeśli go podmieniła
 * (playsound_local przywraca go po wysłaniu, bo /sound idzie do wielu słuchaczy).
 */
/proc/apply_sound_occlusion(sound/S, occlusion, distance = 0, mob/listener)
	var/helmet = listener?.has_sealed_helmet()
	var/direct = 0
	if(occlusion > 0)
		occlusion = min(occlusion, 1)
		S.volume *= 1 - occlusion * SOUND_OCCLUSION_VOLUME
		direct += round(occlusion * SOUND_OCCLUSION_DIRECT)
	if(helmet)
		S.volume *= SOUND_HELMET_VOLUME
		direct += SOUND_HELMET_DIRECT
	if(direct)
		// Kopia, żeby nie zmienić listy wspólnej z innymi dźwiękami
		var/list/echo = S.echo
		S.echo = length(echo) == 18 ? echo.Copy() : list(0, 0, -10000, -10000, 0, 0, 0, 0.25, 1.5, 1.0, 0, 1.0, 0, 0, 0, 0, 1.0, 0)
		S.echo[1] = direct
	else if(length(S.echo) && S.echo[1])
		S.echo[1] = 0 // własna kopia z poprzedniego słuchacza
	if(occlusion < SOUND_OCCLUSION_MUFFLE_THRESHOLD && distance < SOUND_DISTANT_MUFFLE_RANGE && !helmet)
		return null
	var/muffled = GLOB.muffled_sounds["[S.file]"] || GLOB.muffled_speech_sounds[S.file]
	if(!muffled)
		return null
	. = S.file
	S.file = muffled

/// Wielkość pogłosu źródła: dźwięk zza ściany z hali niesie więcej pogłosu niż z szafy (echo Room, mB)
/proc/source_reverb_boost(environment)
	switch(environment)
		if(SOUND_ENVIRONMENT_HANGAR, SOUND_ENVIRONMENT_QUARRY, SOUND_ENVIRONMENT_ARENA, SOUND_ENVIRONMENT_AUDITORIUM, SOUND_ENVIRONMENT_CONCERT_HALL, SOUND_ENVIRONMENT_CAVE)
			return 800
		if(SOUND_ENVIRONMENT_HALLWAY, SOUND_ENVIRONMENT_STONE_CORRIDOR, SOUND_ENVIRONMENT_STONEROOM, SOUND_ENVIRONMENT_PARKING_LOT, SOUND_ENVIRONMENT_SEWER_PIPE)
			return 400
	return 0

/// Za ścianą słychać pogłos pomieszczenia źródła: więcej pogłosu, gdy źródło stoi w dużej, twardej sali
/proc/apply_source_reverb(sound/S, turf/source_turf, occlusion)
	// S.echo[1] < 0: apply_sound_occlusion zrobiła już własną kopię listy, którą wolno zmienić
	if(occlusion <= 0 || S.environment == SOUND_ENVIRONMENT_NONE || length(S.echo) != 18 || S.echo[1] >= 0)
		return
	var/area/source_area = get_area(source_turf)
	if(!source_area)
		return
	var/boost = source_reverb_boost(source_area.get_sound_environment())
	if(boost)
		S.echo[3] = round(boost * min(occlusion, 1))

/**
 * Pozycja dźwięku względem słuchacza. Blisko i w widoku: klient śledzi atom źródła (ruch gracza i źródła w trakcie dźwięku).
 * Dalej albo przez kamerę: stała pozycja z kafelków. W obu wypadkach dźwięk z boku dostaje wysokość proporcjonalną
 * do odległości w bok, więc nie gra w jednym uchu (SOUND_PAN_SOFTNESS). Źródło będące kafelkiem (np. otwarte drzwi,
 * przez które dochodzi dźwięk zza ściany) wyznacza pozycję zamiast turf_source.
 */
/mob/proc/apply_sound_position(sound/S, turf/turf_source, turf/listener_turf, atom/source, distance_multiplier, z_change)
	var/turf/position_turf = isturf(source) ? source : turf_source
	var/dx = position_turf.x - listener_turf.x
	var/dy = position_turf.y - listener_turf.y
	if(source && !z_change && distance_multiplier == 1 && client && client.eye == src && !client.pixel_x && !client.pixel_y \
		&& abs(dx) <= SOUND_TRACK_RANGE && abs(dy) <= SOUND_TRACK_RANGE)
		// atom i transform są w /sound od BYOND 516; SpacemanDMM z CI ich nie zna, stąd dostęp przez :
		// Ruchomy atom na kafelku śledzimy wprost, resztę (przedmiot w plecaku) przez kafelek pozycji
		S:atom = (ismovable(source) && isturf(source.loc)) ? source : position_turf
		// Piksele względem środka widoku -> kratki; x w bok podnosi dźwięk (łagodniejsza panorama), y mapy -> przód/tył
		S:transform = list(1 / world.icon_size, SOUND_PAN_SOFTNESS / world.icon_size, 0, 0, 0, 1 / world.icon_size, 0, 0, 0)
		S.x = 0
		S.y = 0
		S.z = 0
		return
	S:atom = null
	S:transform = null
	S.x = dx * distance_multiplier
	S.z = dy * distance_multiplier
	// y to wysokość nad głową; w 2D niesie tylko różnicę pokładów i łagodzi panoramę
	S.y = z_change + max(abs(S.x) * SOUND_PAN_SOFTNESS, 0.5)

/// Suma sound_dampening na linii między dwoma kafelkami, najwyżej 1 (dalekie strzały)
/proc/distant_sound_dampening(turf/source_turf, turf/listener_turf)
	return get_sound_occlusion(source_turf, listener_turf)

#undef SOUND_OCCLUSION_MUFFLE_THRESHOLD
#undef SOUND_OCCLUSION_VOLUME
#undef SOUND_OCCLUSION_DIRECT
#undef SOUND_OCCLUSION_OTHER_Z
#undef SOUND_PAN_SOFTNESS
#undef SOUND_TRACK_RANGE
#undef SOUND_DISTANT_MUFFLE_RANGE
#undef SOUND_HELMET_VOLUME
#undef SOUND_HELMET_DIRECT
#undef SOUND_PATH_MAX_NODES
#undef SOUND_PATH_CACHE_TIME
#undef SOUND_PATH_MIN_VOLUME
