/// AQUILA - szansa trafienia zależy od prędkości poprzecznej celu (plan walki na overmapie, „Brand New Combat”, bez łuków
/// ostrzału). Pocisk niekierowany wystrzelony w okręt dostaje rozrzut rosnący z prędkością celu w poprzek linii strzału:
/// okręt płynący burtą do strzelca trudniej trafić niż taki, który leci na niego albo stoi. Pociski kierowane i strzał
/// w pole (myszką) zostają bez zmian.

/// Stopnie rozrzutu na jednostkę prędkości poprzecznej (prędkość okrętu to do ok. 3,5, myśliwca do 10)
#define TRANSVERSE_SPREAD_PER_SPEED 2.5
#define TRANSVERSE_SPREAD_MAX 12

/// Prędkość celu w poprzek linii strzału od strzelca (względem strzelca)
/obj/structure/overmap/proc/transverse_speed(obj/structure/overmap/target)
	if(!target?.velocity || !velocity)
		return 0
	var/to_x = target.x - x
	var/to_y = target.y - y
	var/dist = sqrt(to_x * to_x + to_y * to_y)
	if(!dist)
		return 0
	to_x /= dist
	to_y /= dist
	var/rel_x = target.velocity.a - velocity.a
	var/rel_y = target.velocity.e - velocity.e
	var/along = rel_x * to_x + rel_y * to_y
	return sqrt(max(0, rel_x * rel_x + rel_y * rel_y - along * along))

/// Dodatkowy rozrzut (stopnie) dla pocisku tego typu w ten cel
/obj/structure/overmap/proc/transverse_spread(obj/structure/overmap/target, proj_type)
	if(!isovermap(target) || !ispath(proj_type, /obj/item/projectile))
		return 0
	if(!is_unguided_overmap_projectile(proj_type))
		return 0
	return min(TRANSVERSE_SPREAD_MAX, transverse_speed(target) * TRANSVERSE_SPREAD_PER_SPEED)

/// Pocisk leci prosto, tam gdzie wycelowano (nie kierowany, nie promień)
/proc/is_unguided_overmap_projectile(proj_type)
	if(!ispath(proj_type, /obj/item/projectile) || ispath(proj_type, /obj/item/projectile/guided_munition))
		return FALSE
	var/obj/item/projectile/proj = proj_type
	return !initial(proj.can_home) && !initial(proj.hitscan)

/obj/structure/overmap/fire_projectile(proj_type, atom/target, pixel_speed = null, user_override = null, firing_flags = NONE, ai_aim = FALSE, miss_chance = 5, max_miss_distance = 5, spread_override = null, projectile_speed = null)
	if(isovermap(target))
		if(isnull(spread_override))
			var/extra = transverse_spread(target, proj_type)
			if(extra > 0)
				var/obj/item/projectile/proj = proj_type
				spread_override = initial(proj.spread) + extra
		// wybrany moduł celu (module_targeting.dm): strzelec gracza celuje w ten punkt kadłuba
		if(!ai_aim && LAZYLEN(aim_modules) && is_unguided_overmap_projectile(proj_type))
			var/turf/aim = aim_turf_for(target)
			if(aim)
				target = aim
	return ..(proj_type, target, pixel_speed, user_override, firing_flags, ai_aim, miss_chance, max_miss_distance, spread_override, projectile_speed)

#undef TRANSVERSE_SPREAD_PER_SPEED
#undef TRANSVERSE_SPREAD_MAX
