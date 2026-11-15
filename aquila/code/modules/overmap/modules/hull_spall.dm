/// AQUILA - odłamki i wybuch kierunkowy po przebiciu poszycia (Swiss Cheese, swiss_cheese.dm). Wzory: odłamki z Aurory
/// (stożek chmur za przebitą ścianą, _ship_ammunition.dm) i Erisa (fragment_explosion_angled), wybuch kierunkowy z Baya
/// (siła wzdłuż lotu, explosion_recursive.dm) - tu jako dodatek obok zwykłego wybuchu pocisku, bez zmian w silniku wybuchów.
/// Pocisk przekazany na pokład niesie hull_spall = list(kierunek x, kierunek y, głębokość); gdzie zginie (uderzył, wybuchł,
/// skończył zasięg), stamtąd w głąb okrętu lecą odłamki, a przy głębokim wyłomie idzie seria małych wybuchów.

/// Najwięcej odłamków z jednego trafienia (wydajność: każdy odłamek to pocisk)
#define HULL_SPALL_MAX 15
/// Kąty chmur odłamków względem kierunku lotu, jak pięć chmur w Aurorze (prosto, skosy, boki stożka)
#define HULL_SPALL_ANGLES list(0, -22, 22, -45, 45)

GLOBAL_VAR_INIT(hull_spall_enabled, TRUE)

/obj/item/projectile/bullet/shrapnel/hull_spall
	name = "odprysk poszycia"
	damage = 7
	range = 6
	armour_penetration = 10
	dismemberment = 0
	ricochets_max = 1
	ricochet_chance = 30

/obj/item/projectile
	/// AQUILA - pocisk przekazany na pokład przez Swiss Cheese: list(kierunek x, kierunek y, głębokość wyłomu)
	var/list/hull_spall

/obj/item/projectile
	/// AQUILA - pierwsze trafione poszycie: od niego liczy się przebijanie w głąb
	var/turf/hull_pierce_from

/// Przebijanie w głąb: pocisk przekazany na pokład przelatuje przez ściany i gęste obiekty, dopóki nie oddali się od
/// pierwszego trafionego poszycia o głębokość wyłomu minus jedno pole; wybucha (z tą samą siłą co wcześniej) dopiero
/// w głębi. Ludzi trafia normalnie. Głębokość 1 = wybuch na poszyciu jak dawniej.
/obj/item/projectile/prehit_pierce(atom/A)
	if(hull_spall && hull_pierce_should_phase(A))
		do_sparks(2, FALSE, get_turf(A))
		return PROJECTILE_PIERCE_PHASE
	return ..()

/obj/item/projectile/proc/hull_pierce_should_phase(atom/A)
	if(!A || ismob(A))
		return FALSE
	if(!isclosedturf(A) && !(isobj(A) && A.density))
		return FALSE
	var/turf/here = get_turf(A)
	if(!here)
		return FALSE
	if(!hull_pierce_from)
		hull_pierce_from = here
	return get_dist(hull_pierce_from, here) < round(hull_spall[3]) - 1

/obj/item/projectile/Destroy()
	if(hull_spall && GLOB.hull_spall_enabled)
		var/turf/origin = get_turf(src)
		if(origin && !isspaceturf(origin))
			hull_spall_effects(origin, hull_spall[1], hull_spall[2], hull_spall[3])
	hull_spall = null
	hull_pierce_from = null
	return ..()

/// Odłamki i wybuch kierunkowy z miejsca uderzenia; zwraca liczbę wystrzelonych odłamków
/proc/hull_spall_effects(turf/origin, dir_x, dir_y, depth)
	. = hull_spall(origin, dir_x, dir_y, depth)
	if(depth >= 3)
		directional_explosion(origin, dir_x, dir_y, round(depth))

/// Pierwsze wolne pole w głąb od origin (pocisk mógł zginąć w ścianie), najwyżej 3 pola
/proc/hull_spall_open_turf(turf/origin, dir_x, dir_y)
	for(var/i in 0 to 3)
		var/turf/T = locate(round(origin.x + dir_x * i), round(origin.y + dir_y * i), origin.z)
		if(!T)
			return null
		if(!isclosedturf(T) && !isspaceturf(T) && !is_blocked_turf(T, TRUE))
			return T
	return null

/// Stożek odłamków w kierunku (dir_x, dir_y) w układzie mapy (x wschód, y północ); ile i jak daleko - z głębokości
/proc/hull_spall(turf/origin, dir_x, dir_y, depth)
	if(!origin || (!dir_x && !dir_y))
		return 0
	var/turf/start = hull_spall_open_turf(origin, dir_x, dir_y)
	if(!start)
		return 0
	var/count = clamp(round(4 + depth * 2), 4, HULL_SPALL_MAX)
	var/reach = clamp(round(3 + depth), 3, 9)
	// kąt projectile.fire(): od północy zgodnie z zegarem
	var/base = 90 - arctan(dir_x, dir_y)
	var/list/angles = HULL_SPALL_ANGLES
	for(var/i in 1 to count)
		var/obj/item/projectile/bullet/shrapnel/hull_spall/shard = new(start)
		shard.starting = start
		shard.firer = null
		shard.range = reach
		LAZYINITLIST(shard.impacted)
		hull_spall_fire(shard, base + angles[(i - 1) % length(angles) + 1] + rand(-6, 6))
	playsound(start, 'sound/effects/bang.ogg', 50, TRUE)
	return count

/proc/hull_spall_fire(obj/item/projectile/shard, fire_angle)
	set waitfor = FALSE
	shard.fire(fire_angle)

/// Wybuch kierunkowy obok zwykłych wybuchów: słabe epicentrum i seria małych wybuchów wzdłuż kierunku (dir_x, dir_y),
/// co 2 pola na długości power; w Bayu siła w przód ×3, w bok ×0,45, w tył ×0,1, tu: lej w głąb zamiast koła
/proc/directional_explosion(turf/epicenter, dir_x, dir_y, power)
	var/list/blasts = directional_explosion_plan(epicenter, dir_x, dir_y, power)
	for(var/list/blast as anything in blasts)
		explosion(blast[1], 0, blast[2], 1, 0, adminlog = FALSE, silent = TRUE)
	return length(blasts)

/// Pola i siła wybuchów kierunkowych: list(list(pole, ciężki zasięg)); epicentrum najsłabsze, w głąb co 2 pola
/proc/directional_explosion_plan(turf/epicenter, dir_x, dir_y, power)
	. = list()
	if(!epicenter || (!dir_x && !dir_y) || power <= 0)
		return
	var/norm = sqrt(dir_x * dir_x + dir_y * dir_y)
	dir_x /= norm
	dir_y /= norm
	. += list(list(epicenter, 0))
	for(var/step in 2 to power step 2)
		var/turf/T = locate(round(epicenter.x + dir_x * step), round(epicenter.y + dir_y * step), epicenter.z)
		if(!T || isspaceturf(T))
			break
		// bliżej epicentrum mocniej, dalej tylko lekkie uszkodzenia
		. += list(list(T, (step <= power / 2 && power >= 5) ? 1 : 0))

#undef HULL_SPALL_MAX
#undef HULL_SPALL_ANGLES
