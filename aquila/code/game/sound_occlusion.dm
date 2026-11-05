// AQUILA - dźwięk przestrzenny jak w SS14: wygłuszanie przez ściany i pozycja dźwięku śledzona przez klienta.
// Hooki w code/game/sound.dm (playsound(), playsound_local()).
//
// Co działa w BYOND 516 (FMOD Ex, mikser programowy), zmierzone nagraniem wyjścia audio:
// - echo[1] (Direct) ścisza tylko ścieżkę suchą, pogłos pomieszczenia zostaje. Za ścianą zostaje więc głównie pogłos.
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

/**
 * Stosuje wygłuszenie do dźwięku wysyłanemu jednemu słuchaczowi: ciszej, mniej ścieżki suchej, a od progu stłumiona kopia.
 * Zwraca oryginalny plik, jeśli go podmieniła (playsound_local przywraca go po wysłaniu, bo /sound idzie do wielu słuchaczy).
 */
/proc/apply_sound_occlusion(sound/S, occlusion)
	if(occlusion <= 0)
		if(length(S.echo) && S.echo[1])
			S.echo[1] = 0 // własna kopia z poprzedniego słuchacza
		return null
	occlusion = min(occlusion, 1)
	S.volume *= 1 - occlusion * SOUND_OCCLUSION_VOLUME
	// Kopia, żeby nie zmienić listy wspólnej z innymi dźwiękami
	var/list/echo = S.echo
	S.echo = length(echo) == 18 ? echo.Copy() : list(0, 0, -10000, -10000, 0, 0, 0, 0.25, 1.5, 1.0, 0, 1.0, 0, 0, 0, 0, 1.0, 0)
	S.echo[1] = round(occlusion * SOUND_OCCLUSION_DIRECT)
	if(occlusion < SOUND_OCCLUSION_MUFFLE_THRESHOLD)
		return null
	var/muffled = GLOB.muffled_sounds["[S.file]"] || GLOB.muffled_speech_sounds[S.file]
	if(!muffled)
		return null
	. = S.file
	S.file = muffled

/**
 * Pozycja dźwięku względem słuchacza. Blisko i w widoku: klient śledzi atom źródła (ruch gracza i źródła w trakcie dźwięku).
 * Dalej albo przez kamerę: stała pozycja z kafelków. W obu wypadkach dźwięk z boku dostaje wysokość proporcjonalną
 * do odległości w bok, więc nie gra w jednym uchu (SOUND_PAN_SOFTNESS).
 */
/mob/proc/apply_sound_position(sound/S, turf/turf_source, turf/listener_turf, atom/source, distance_multiplier, z_change)
	var/dx = turf_source.x - listener_turf.x
	var/dy = turf_source.y - listener_turf.y
	if(source && !z_change && distance_multiplier == 1 && client && client.eye == src && !client.pixel_x && !client.pixel_y \
		&& abs(dx) <= SOUND_TRACK_RANGE && abs(dy) <= SOUND_TRACK_RANGE)
		// Ruchomy atom na kafelku śledzimy wprost, resztę (przedmiot w plecaku, sam kafelek) przez kafelek źródła
		// atom i transform są w /sound od BYOND 516; SpacemanDMM z CI ich nie zna, stąd dostęp przez :
		S:atom = (ismovable(source) && isturf(source.loc)) ? source : turf_source
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
