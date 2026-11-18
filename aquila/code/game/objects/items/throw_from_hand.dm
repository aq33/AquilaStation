// AQUILA - rzut z ręki widać od rzucającego.
// Rzut rusza w tym samym ticku, w którym przedmiot spada z ręki (quickstart w throw_at), a jeden tick
// potrafi przesunąć go o 1-2 pola. Klient nigdy nie widział przedmiotu przy rzucającym, więc ten
// pojawiał się od razu dalej, jakby się teleportował. Przesunięcie pikseli cofa obraz do pola startu
// i zdejmuje je w tempie rzutu; dalszy lot to zwykły glide. pixel_w/pixel_z, bo pixel_x/pixel_y
// i transform ustawiają upuszczanie, rozrzut po rzucie (item_scatter.dm) i obrót w locie.

/obj/item
	/// world.time, w którym gracz wyrzucił przedmiot z ręki (WAS_THROWN z /mob/living/carbon/throw_item)
	var/thrown_from_hand_time = -1

/obj/item/dropped(mob/user, silent = FALSE)
	. = ..()
	if(item_flags & WAS_THROWN)
		thrown_from_hand_time = world.time

/obj/item/throw_at(atom/target, range, speed, mob/thrower, spin = 1, diagonals_first = 0, datum/callback/callback, force, quickstart = TRUE)
	var/turf/start = get_turf(src)
	var/from_hand = quickstart && thrown_from_hand_time == world.time
	. = ..()
	// Tylko na mapie: przedmiot złapany albo wrzucony do pojemnika w tym samym ticku przesuwałby ikonę w ręce
	if(from_hand && !QDELETED(src) && isturf(loc))
		smooth_throw_start(start, speed)

/// Cofa obraz przedmiotu na pole startu rzutu i płynnie zdejmuje przesunięcie
/obj/item/proc/smooth_throw_start(turf/start, speed)
	var/list/offset = throw_start_offset(start, get_turf(src), speed)
	if(!offset)
		return
	pixel_w += offset[1]
	pixel_z += offset[2]
	// równolegle, żeby nie przerwać obrotu w locie (SpinAnimation)
	animate(src, pixel_w = pixel_w - offset[1], pixel_z = pixel_z - offset[2], time = offset[3], flags = ANIMATION_PARALLEL)

/**
 * Przesunięcie obrazu z pola `now` z powrotem na pole `start`: list(piksele x, piksele y, czas w ds)
 * albo null, gdy nie ma czego wygładzać. Czas to droga przez prędkość rzutu (pola na ds).
 */
/proc/throw_start_offset(turf/start, turf/now, speed)
	if(!start || !now || start == now || start.z != now.z || speed <= 0)
		return null
	var/dx = start.x - now.x
	var/dy = start.y - now.y
	var/tiles = max(abs(dx), abs(dy))
	return list(dx * world.icon_size, dy * world.icon_size, tiles / speed)
