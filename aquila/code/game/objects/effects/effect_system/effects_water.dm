/// Gaśnica gasi ogień pod gęstymi maszynami (wzór: tgstation, /obj/effect/particle_effect/water/Bump).
/// Kropla nie wchodzi na kafelek z gęstą maszyną, tylko się o nią odbija, więc woda trafiała w samą maszynę,
/// a pożar podłogi (turf_fire) i płomień (hotspot) na jej kafelku zostawały nietknięte.
/obj/effect/particle_effect/water/Bump(atom/A)
	. = ..()
	if(!reagents || isturf(A) || QDELETED(A))
		return
	var/turf/open/T = get_turf(A)
	if(!istype(T))
		return
	reagents.reaction(T)
	if(T.turf_fire)
		reagents.reaction(T.turf_fire)
