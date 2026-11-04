/**
 * Prototyp ruchu po pikselach.
 *
 * Logika gry zostaje na kafelkach (loc, Adjacent, Bump, ciągnięcie działają jak zawsze).
 * Komponent trzyma przesunięcie postaci wewnątrz kafelka (offset_x/offset_y, -16..16 px)
 * i przesuwa je co tick, dopóki gracz trzyma klawisz ruchu. Przy przekroczeniu krawędzi
 * kafelka robi zwykły Move() na sąsiedni kafelek i odejmuje 32 px od przesunięcia.
 * Wygląd: pixel_w/pixel_z moba, kamera: pixel_x/pixel_y klienta, oba animowane przez jeden tick.
 */
/// Jak daleko (px) ciało może wejść w stronę zablokowanego kafelka
#define PIXEL_MOVE_WALL_MARGIN 6
#define PIXEL_MOVE_HALF_TILE 16

/datum/component/pixel_movement
	var/offset_x = 0
	var/offset_y = 0
	/// Czas ostatniego kroku, żeby nie liczyć dwa razy w jednym ticku
	var/last_step = 0
	/// Bump w ścianę/drzwi najwyżej raz na zwykły krok, nie co tick
	var/next_bump_try = 0

/datum/component/pixel_movement/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/pixel_movement/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(on_pre_move))
	RegisterSignal(parent, COMSIG_MOB_LOGIN, PROC_REF(sync_camera))

/datum/component/pixel_movement/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_CLIENT_PRE_MOVE, COMSIG_MOB_LOGIN))
	var/mob/living/owner = parent
	offset_x = 0
	offset_y = 0
	owner.pixel_w = 0
	owner.pixel_z = 0
	sync_camera()

/datum/component/pixel_movement/proc/sync_camera()
	SIGNAL_HANDLER
	var/mob/living/owner = parent
	if(owner.client)
		owner.client.pixel_x = round(offset_x)
		owner.client.pixel_y = round(offset_y)

/// /client/Move woła to co tick, gdy klawisz jest wciśnięty i mob może się ruszyć. Blokujemy zwykły krok.
/datum/component/pixel_movement/proc/on_pre_move(datum/source, turf/new_loc)
	SIGNAL_HANDLER
	var/mob/living/owner = parent
	if(last_step == world.time)
		return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE
	last_step = world.time
	var/direct = get_dir(owner, new_loc)
	if(!direct)
		return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE
	// Ta sama prędkość co zwykły chód: 32 px na movement_delay()
	var/dist = world.icon_size / max(owner.movement_delay(), world.tick_lag) * world.tick_lag
	if(NSCOMPONENT(direct) && EWCOMPONENT(direct))
		dist /= sqrt(2)
	owner.setDir(direct)
	var/old_x = offset_x
	var/old_y = offset_y
	if(direct & EAST)
		offset_x = axis_step(offset_x, dist, EAST)
	else if(direct & WEST)
		offset_x = -axis_step(-offset_x, dist, WEST)
	if(direct & NORTH)
		offset_y = axis_step(offset_y, dist, NORTH)
	else if(direct & SOUTH)
		offset_y = -axis_step(-offset_y, dist, SOUTH)
	if(QDELETED(owner))
		return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE
	// Przeskok kafelka jest kompensowany w offsecie, więc wygląd i kamera jadą liniowo
	animate(owner, pixel_w = round(offset_x), pixel_z = round(offset_y), time = world.tick_lag, flags = ANIMATION_PARALLEL)
	if(owner.client && (old_x != offset_x || old_y != offset_y))
		animate(owner.client, pixel_x = round(offset_x), pixel_y = round(offset_y), time = world.tick_lag)
	return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE

/// Krok wzdłuż jednej osi w stronę dodatnią (wartość już odwrócona dla W/S). Zwraca nowy offset.
/datum/component/pixel_movement/proc/axis_step(offset, dist, dir)
	var/mob/living/owner = parent
	var/target = offset + dist
	var/turf/next = get_step(owner, dir)
	if(target > PIXEL_MOVE_WALL_MARGIN && (!next || is_blocked_turf(next, exclude_mobs = TRUE)))
		// Ściana albo zamknięte drzwi: Move() zrobi Bump (otwiera drzwi), ciało staje przy krawędzi
		if(next && world.time >= next_bump_try)
			next_bump_try = world.time + owner.movement_delay()
			if(try_tile_move(next, dir))
				return target - world.icon_size
		return min(target, max(offset, PIXEL_MOVE_WALL_MARGIN))
	if(target < PIXEL_MOVE_HALF_TILE)
		return target
	if(try_tile_move(next, dir))
		return target - world.icon_size
	return min(target, PIXEL_MOVE_HALF_TILE - 1)

/datum/component/pixel_movement/proc/try_tile_move(turf/next, dir)
	var/mob/living/owner = parent
	var/turf/old_turf = owner.loc
	// Zwykły glide na czas Move (z niego liczy się animacja chodu), potem cały kafelek w jeden tick
	owner.set_glide_size(DELAY_TO_GLIDE_SIZE(owner.movement_delay()))
	owner.Move(next, dir)
	owner.set_glide_size(world.icon_size)
	return owner.loc != old_turf && owner.loc == next

/client/proc/toggle_pixel_movement()
	set name = "Przełącz ruch po pikselach"
	set category = "Debug"
	if(!check_rights(R_DEBUG))
		return
	var/mob/living/target = mob
	if(!istype(target))
		to_chat(src, span_warning("Ruch po pikselach działa tylko dla żywego moba."))
		return
	var/datum/component/pixel_movement/existing = target.GetComponent(/datum/component/pixel_movement)
	if(existing)
		qdel(existing)
		to_chat(src, span_notice("Ruch po pikselach wyłączony."))
		return
	target.AddComponent(/datum/component/pixel_movement)
	to_chat(src, span_notice("Ruch po pikselach włączony (prototyp)."))

#undef PIXEL_MOVE_WALL_MARGIN
#undef PIXEL_MOVE_HALF_TILE
