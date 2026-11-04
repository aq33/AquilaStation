/**
 * Prototyp ruchu po pikselach.
 *
 * Logika gry zostaje na kafelkach (loc, Adjacent, Bump, ciągnięcie działają jak zawsze).
 * Postać ma w kafelku przesunięcie step_x/step_y (-16..15 px) i bounding box 1x1 w środku
 * kafelka, więc zawsze stoi w dokładnie jednym kafelku. Gdy gracz trzyma klawisz ruchu,
 * przesunięcie rośnie co tick; przy przekroczeniu krawędzi kafelka idzie zwykły Move().
 *
 * Płynność: klient BYOND wygładza zmianę step_x tylko wtedy, gdy step_size i glide_size
 * są równe przesunięciu w tym ticku. Przy domyślnym step_size (32) ruch idzie schodkami
 * co tick, a animowanie pixel_w/client.pixel_x szarpało całym obrazem (pomiar zrzutami
 * ekranu w mini-świecie, 2026-11-04).
 */
/// Jak daleko (px) ciało może wejść w stronę zablokowanego kafelka
#define PIXEL_MOVE_WALL_MARGIN 6
#define PIXEL_MOVE_HALF_TILE 16

/datum/component/pixel_movement
	/// Ułamek piksela, który nie zmieścił się w całkowitym step_x/step_y
	var/frac_x = 0
	var/frac_y = 0
	/// Czas ostatniego kroku, żeby nie liczyć dwa razy w jednym ticku
	var/last_step = 0
	/// Bump w ścianę/drzwi najwyżej raz na zwykły krok, nie co tick
	var/next_bump_try = 0

/datum/component/pixel_movement/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/pixel_movement/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(on_pre_move))
	var/mob/living/owner = parent
	owner.bound_x = PIXEL_MOVE_HALF_TILE
	owner.bound_y = PIXEL_MOVE_HALF_TILE
	owner.bound_width = 1
	owner.bound_height = 1

/datum/component/pixel_movement/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_CLIENT_PRE_MOVE)
	var/mob/living/owner = parent
	owner.step_x = 0
	owner.step_y = 0
	owner.bound_x = initial(owner.bound_x)
	owner.bound_y = initial(owner.bound_y)
	owner.bound_width = initial(owner.bound_width)
	owner.bound_height = initial(owner.bound_height)
	restore_step_size()

/// Wbudowane step() (rozbijanie ruchu po skosie, taśmociągi) przesuwa o step_size, więc po zatrzymaniu wraca cały kafelek
/datum/component/pixel_movement/proc/restore_step_size()
	var/mob/living/owner = parent
	owner.step_size = world.icon_size

/// /client/Move woła to co tick, gdy klawisz jest wciśnięty i mob może się ruszyć. Blokujemy zwykły krok.
/datum/component/pixel_movement/proc/on_pre_move(datum/source, turf/new_loc)
	SIGNAL_HANDLER
	var/mob/living/owner = parent
	if(last_step == world.time || !isturf(owner.loc))
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

	var/old_z = owner.z
	var/old_abs_x = owner.x * world.icon_size + owner.step_x
	var/old_abs_y = owner.y * world.icon_size + owner.step_y
	var/new_x = owner.step_x + frac_x
	var/new_y = owner.step_y + frac_y
	if(direct & EAST)
		new_x = axis_step(new_x, dist, EAST)
	else if(direct & WEST)
		new_x = -axis_step(-new_x, dist, WEST)
	if(QDELETED(owner) || !isturf(owner.loc))
		return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE
	if(direct & NORTH)
		new_y = axis_step(new_y, dist, NORTH)
	else if(direct & SOUTH)
		new_y = -axis_step(-new_y, dist, SOUTH)
	if(QDELETED(owner) || !isturf(owner.loc))
		return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE

	var/int_x = clamp(round(new_x), -PIXEL_MOVE_HALF_TILE, PIXEL_MOVE_HALF_TILE - 1)
	var/int_y = clamp(round(new_y), -PIXEL_MOVE_HALF_TILE, PIXEL_MOVE_HALF_TILE - 1)
	frac_x = clamp(new_x - int_x, 0, 0.999)
	frac_y = clamp(new_y - int_y, 0, 0.999)
	owner.step_x = int_x
	owner.step_y = int_y

	// Wygładzanie: step_size i glide_size muszą równać się przesunięciu w tym ticku
	if(owner.z == old_z)
		var/delta = max(abs(owner.x * world.icon_size + int_x - old_abs_x), abs(owner.y * world.icon_size + int_y - old_abs_y))
		if(delta > 0 && delta <= world.icon_size)
			owner.step_size = delta
			owner.set_glide_size(delta)
	addtimer(CALLBACK(src, PROC_REF(restore_step_size)), world.tick_lag * 3, TIMER_UNIQUE | TIMER_OVERRIDE)
	return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE

/// Krok wzdłuż jednej osi w stronę dodatnią (wartość już odwrócona dla W/S). Zwraca nowe przesunięcie.
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
	// Zwykły glide na czas Move (z niego liczy się animacja chodu); docelowy ustawia on_pre_move
	owner.set_glide_size(DELAY_TO_GLIDE_SIZE(owner.movement_delay()))
	owner.Move(next, dir)
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
