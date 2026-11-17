/// AQUILA - „Swiss Cheese”: trafienie w okręt z wnętrzem (okręt gracza, wczytane wnętrze wroga) ląduje tam, gdzie pocisk
/// trafił kadłub na overmapie, a nie z losowej strony w środek mapy.
/// Punkt na obrysie kadłuba (overmap_visual_scale.dm) -> to samo miejsce na losowym pokładzie (mapy okrętów mają dziób na
/// wschodzie, lewą burtę na północy) -> pełna ćwiartka pancerza: wgniecenie i iskry; zbita: wyłom w poszyciu w tym miejscu
/// i uszkodzenie najbliższej maszyny w zasięgu głębokości. Dziury się kumulują: kolejne trafienie blisko dziury sięga głębiej.

/// Poniżej tej części pancerza ćwiartki trafienie robi wyłom
#define SWISS_CHEESE_BREACH 0.5

GLOBAL_LIST_EMPTY(ship_deck_bounds)

/obj/structure/overmap
	/// AQUILA - ostatnie trafienie w kadłub: list(u, v, kierunek x, kierunek y, bez pancerza) w układzie okrętu (u: rufa
	/// -1..dziób 1, v: lewa burta -1..prawa 1), zapisane w bullet_act przed relay_damage(). Rakieta i torpeda: losowy punkt
	/// i kierunek, pancerz ćwiartki pominięty.
	var/list/last_hull_hit
	/// AQUILA - dziury w poszyciu pokładów: "z" = list(list(x, y, głębokość))
	var/list/deck_holes

/// Obrys okrętu na pokładzie (pola, które nie są kosmosem): list(x0, y0, x1, y1); liczony raz na poziom
/proc/ship_deck_bounds(z)
	var/key = "[z]"
	if(GLOB.ship_deck_bounds[key])
		return GLOB.ship_deck_bounds[key]
	var/x0 = world.maxx
	var/y0 = world.maxy
	var/x1 = 0
	var/y1 = 0
	for(var/turf/T as anything in block(locate(1, 1, z), locate(world.maxx, world.maxy, z)))
		if(isspaceturf(T) || istype(T.loc, /area/space))
			continue
		x0 = min(x0, T.x)
		y0 = min(y0, T.y)
		x1 = max(x1, T.x)
		y1 = max(y1, T.y)
	if(x1 < x0 || y1 < y0)
		return null
	GLOB.ship_deck_bounds[key] = list(x0, y0, x1, y1)
	return GLOB.ship_deck_bounds[key]

/// Część pancerza w ćwiartce trafienia (u, v w układzie okrętu); bez ćwiartek: stan kadłuba
/obj/structure/overmap/proc/hull_armour_fraction(u, v)
	if(!use_armour_quadrants)
		return max_integrity ? obj_integrity / max_integrity : 1
	var/list/armour = armour_quadrants["[u >= 0 ? "forward" : "aft"]_[v < 0 ? "port" : "starboard"]"]
	if(!length(armour) || !armour["max_armour"])
		return 1
	return armour["current_armour"] / armour["max_armour"]

/// Część pancerza, która decyduje o wejściu ostatniego trafienia (rakieta i torpeda: żadna)
/obj/structure/overmap/proc/hull_hit_armour(list/hit)
	if(length(hit) >= 5 && hit[5])
		return 0
	return hull_armour_fraction(hit[1], hit[2])

/// Zapisuje trafienie w kadłub (punkt na obrysie i kierunek lotu w układzie okrętu)
/obj/structure/overmap/proc/remember_hull_hit(obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/guided_munition)) // rakieta ignoruje burty: wybucha w losowym punkcie okrętu
		var/heading = rand(0, 359)
		last_hull_hit = list(rand(-80, 80) / 100, rand(-80, 80) / 100, sin(heading), cos(heading), TRUE)
		return
	var/list/local = overmap_hull_local((P.x - x) * 32 + P.pixel_x + 16, (P.y - y) * 32 + P.pixel_y + 16)
	if(!local)
		last_hull_hit = null
		return
	var/c = cos(angle)
	var/s = sin(angle)
	var/wx = sin(P.Angle)
	var/wy = cos(P.Angle)
	last_hull_hit = list(clamp(local[2] / local[4], -1, 1), clamp(local[1] / local[3], -1, 1), wx * c - wy * s, wx * s + wy * c)

/obj/structure/overmap/bullet_act(obj/item/projectile/P)
	if(P && !QDELETED(P))
		remember_hull_hit(P)
	. = ..()
	last_hull_hit = null

/obj/structure/overmap/relay_damage(proj_type, original_proj_angle)
	var/list/hit = last_hull_hit
	if(!hit || !length(occupying_levels))
		return ..()
	var/datum/space_level/SL = pick(occupying_levels)
	var/list/bounds = ship_deck_bounds(SL.z_value)
	if(!bounds)
		return ..()
	var/u = hit[1]
	var/v = hit[2]
	var/list/deck = swiss_cheese_deck_point(bounds, u, v, hit[3], hit[4])
	if(!deck)
		return ..()
	var/dir_x = deck[3]
	var/dir_y = deck[4]
	var/turf/target = locate(deck[1], deck[2], SL.z_value)
	var/turf/start = swiss_cheese_start(target, dir_x, dir_y, bounds)
	if(!target || !start)
		return ..()
	var/armour = hull_hit_armour(hit)
	var/depth = deck_hole_depth(target, armour)
	var/turf/hull = swiss_cheese_first_hull(start, dir_x, dir_y)
	if(depth <= 0) // pełny pancerz: wgniecenie i iskry na poszyciu
		if(hull)
			do_sparks(3, TRUE, hull)
			playsound(hull, 'sound/effects/bang.ogg', 40, TRUE)
		return
	add_deck_hole(target, depth)
	var/obj/item/projectile/proj = new proj_type(start)
	proj.starting = start
	proj.firer = null
	proj.def_zone = "chest"
	proj.original = target
	proj.hull_spall = list(dir_x, dir_y, depth) // odłamki i wybuch kierunkowy tam, gdzie pocisk zginie (hull_spall.dm)
	proj.hull_pierce_from = hull // przebijanie liczone od poszycia, nie od pierwszej ściany za starą dziurą
	LAZYINITLIST(proj.impacted)
	swiss_cheese_fire(proj, get_angle(start, target) + ((rand() - 0.5) * 6))
	addtimer(CALLBACK(src, PROC_REF(swiss_cheese_machine_damage), target, depth), 2 SECONDS)

/// Punkt trafienia na mapie pokładu i kierunek lotu: list(x, y, kierunek x, kierunek y). Mapy okrętów mają dziób na
/// wschodzie (+x) i lewą burtę na północy (+y); u: rufa -1..dziób 1, v: lewa burta -1..prawa 1; (sx, sy): lot w układzie okrętu
/proc/swiss_cheese_deck_point(list/bounds, u, v, sx, sy)
	var/norm = sqrt(sx * sx + sy * sy)
	if(!norm || !bounds)
		return null
	return list(
		round(bounds[1] + (u + 1) / 2 * (bounds[3] - bounds[1])),
		round(bounds[4] - (v + 1) / 2 * (bounds[4] - bounds[2])),
		sy / norm,
		-sx / norm,
	)

/// Wystrzał pocisku na pokładzie jak w relay_damage() z core (powolny, żeby było widać, skąd leci)
/obj/structure/overmap/proc/swiss_cheese_fire(obj/item/projectile/proj, fire_angle)
	set waitfor = FALSE
	proj.fire(fire_angle)
	proj.set_pixel_speed(4)

/// Pole startu pocisku: od celu wstecz wzdłuż kierunku lotu, aż za obrys okrętu (z zapasem 3 pól)
/obj/structure/overmap/proc/swiss_cheese_start(turf/target, dir_x, dir_y, list/bounds)
	if(!target)
		return null
	var/x = target.x
	var/y = target.y
	for(var/i in 1 to 300)
		x -= dir_x
		y -= dir_y
		if(x < bounds[1] - 3 || x > bounds[3] + 3 || y < bounds[2] - 3 || y > bounds[4] + 3)
			break
	x = clamp(round(x), TRANSITIONEDGE + 1, world.maxx - TRANSITIONEDGE - 1)
	y = clamp(round(y), TRANSITIONEDGE + 1, world.maxy - TRANSITIONEDGE - 1)
	return locate(x, y, target.z)

/// Pierwsze pole kadłuba na drodze od startu
/obj/structure/overmap/proc/swiss_cheese_first_hull(turf/start, dir_x, dir_y)
	var/x = start.x
	var/y = start.y
	for(var/i in 1 to 300)
		var/turf/T = locate(round(x), round(y), start.z)
		if(!T)
			return null
		if(!isspaceturf(T) && !istype(T.loc, /area/space))
			return T
		x += dir_x
		y += dir_y
	return null

/// Głębokość wejścia (pola): pełny pancerz 0, zbity do 6, stara dziura blisko celu dokłada połowę swojej głębokości
/obj/structure/overmap/proc/deck_hole_depth(turf/target, armour)
	var/depth = 0
	if(armour < SWISS_CHEESE_BREACH)
		depth = 1 + 5 * (1 - armour / SWISS_CHEESE_BREACH)
	for(var/list/hole as anything in LAZYACCESS(deck_holes, "[target.z]"))
		if(abs(hole[1] - target.x) <= 3 && abs(hole[2] - target.y) <= 3)
			depth += hole[3] * 0.5
			break
	return depth

/obj/structure/overmap/proc/add_deck_hole(turf/target, depth)
	LAZYINITLIST(deck_holes)
	var/key = "[target.z]"
	var/list/holes = deck_holes[key]
	if(!holes)
		holes = list()
		deck_holes[key] = holes
	for(var/list/hole as anything in holes)
		if(abs(hole[1] - target.x) <= 1 && abs(hole[2] - target.y) <= 1)
			hole[3] = max(hole[3], depth)
			return
	holes += list(list(target.x, target.y, depth))
	if(length(holes) > 40)
		holes.Cut(1, 2)

/// Uszkodzenie najbliższej maszyny w zasięgu głębokości od wyłomu (podsystem za poszyciem)
/obj/structure/overmap/proc/swiss_cheese_machine_damage(turf/target, depth)
	if(QDELETED(src) || !target)
		return
	var/obj/machinery/closest
	var/best = INFINITY
	for(var/obj/machinery/machine in range(round(depth), target))
		if(machine.resistance_flags & INDESTRUCTIBLE)
			continue
		var/dist = get_dist(machine, target)
		if(dist < best)
			best = dist
			closest = machine
	if(!closest)
		return
	do_sparks(4, TRUE, closest)
	closest.take_damage(20 + depth * 10, BRUTE, "bomb")

#undef SWISS_CHEESE_BREACH
