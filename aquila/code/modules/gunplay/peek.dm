// AQUILA - strzał zza rogu z wychylenia (przesunięcie o piksele pod C, nsv13/code/modules/pixelshifting).
// Wychylony strzelec wypuszcza pocisk z miejsca, w które się wychylił (do 16 px, czyli krawędzi kafla), i celuje
// stamtąd w kursor. Wcześniej pocisk startował ze środka kafla, więc zza rogu zawsze trafiał w róg.
// Trafić strzelca da się dalej tylko na jego kaflu.

/// Przesunięcie sprite'a od zwykłego położenia (piksele) albo null, gdy mob nie jest wychylony
/mob/living/proc/get_peek_offset()
	if(!is_shifted)
		return null
	var/dx = clamp(pixel_x - body_pixel_x_offset - base_pixel_x, -world.icon_size / 2, world.icon_size / 2)
	var/dy = clamp(pixel_y - body_pixel_y_offset - base_pixel_y, -world.icon_size / 2, world.icon_size / 2)
	if(!dx && !dy)
		return null
	return list(dx, dy)

/obj/item/projectile/preparePixelProjectile(atom/target, atom/source, params, spread = 0)
	. = ..()
	if(QDELETED(src) || !isliving(source) || isnull(Angle))
		return
	var/mob/living/shooter = source
	if(shooter.loc != loc) // z mecha, pojazdu albo szafki strzela się jak dotąd
		return
	var/list/peek = shooter.get_peek_offset()
	if(!peek)
		return
	// Punkt celu względem środka kafla strzelca: kursor albo środek kafla celu
	var/list/aim
	var/list/modifiers = islist(params) ? params : null
	if(modifiers?["screen-loc"] && shooter.client)
		aim = aq_screen_loc_to_view_offset(shooter.client, modifiers["screen-loc"])
	if(!aim)
		var/turf/target_turf = get_turf(target)
		if(!target_turf)
			return
		aim = list((target_turf.x - loc.x) * world.icon_size, (target_turf.y - loc.y) * world.icon_size)
	var/from_center = ATAN2(aim[2], aim[1])
	var/from_peek = ATAN2(aim[2] - peek[2], aim[1] - peek[1])
	var/correction = from_peek - from_center
	if(correction > 180)
		correction -= 360
	else if(correction < -180)
		correction += 360
	pixel_x = peek[1]
	pixel_y = peek[2]
	setAngle(Angle + correction) // rozrzut już doliczony w Angle zostaje

/// Ile pikseli wychylenia na jedno wywołanie (co tick przy trzymanej strzałce); w NSV13 był 1 px, pełne 16 px trwało ok. 0,8 s
#define AQ_PIXEL_SHIFT_STEP 4

/mob/living/pixel_shift(direction)
	for(var/i in 1 to AQ_PIXEL_SHIFT_STEP)
		. = ..()
		if(. == FALSE) // canface() odmówił (martwy, skuty, przypięty)
			return

#undef AQ_PIXEL_SHIFT_STEP
