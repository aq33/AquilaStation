// AQUILA - ruch pocisku z tgstation (code/modules/projectiles/projectile.dm, stan 59fe70a: process(), process_movement(),
// process_hitscan(), /datum/vector). Port rdzenia ruchu na nasz /obj/item/projectile bez zmiany nazwy typu.
// Różnice względem tg:
// - `speed` zostaje w decysekundach na kratkę (jak w całym naszym kodzie i w NSV13), silnik liczy z niego piksele na decysekundę;
// - set_pixel_speed() z overmapu NSV13 to mnożnik prędkości (`pixel_speed_multiplier`), a zasięg liczy się co tyle pikseli,
//   ile wynosił stary „ruch” (32 × mnożnik), żeby broń statkowa leciała tak daleko jak wcześniej;
// - zostają nasze Impact()/process_hit()/select_target() i NSV13 (frakcje, physics2d, naprowadzanie z opóźnieniem);
// - limit ruchu na tick to 10 kratek (jak stary global_max_tick_moves), a dług nadrabiania jest ograniczony;
// - po trafieniu pocisk dolatuje wizualnie do miejsca uderzenia i znika w następnym ticku (tg: deletion_queued).

/datum/vector
	var/magnitude = 1
	var/angle = 0
	/// Przesunięcie na jeden piksel ruchu (sin/cos kąta), żeby nie liczyć trygonometrii co krok
	var/pixel_x = 0
	var/pixel_y = 0

/datum/vector/New(new_magnitude, new_angle)
	. = ..()
	if(!isnull(new_magnitude))
		magnitude = new_magnitude
	set_angle(new_angle)

/// Kąty BYOND: 0 to północ, 90 wschód
/datum/vector/proc/set_angle(new_angle)
	if(isnull(new_angle))
		return
	angle = new_angle
	pixel_x = sin(angle)
	pixel_y = cos(angle)

/datum/controller/subsystem/processing/projectiles
	/// Ile pikseli na decysekundę przelatuje pocisk o prędkości 1 kratki na decysekundę (do debugowania: zmiana spowalnia lub przyspiesza wszystkie pociski)
	var/pixels_per_decisecond = AQ_PROJECTILE_PIXELS_PER_DS
	/// Maks. pikseli na tick dla zwykłego pocisku (10 kratek, jak global_max_tick_moves starego silnika)
	var/max_pixels_per_tick = AQ_PROJECTILE_PIXELS_PER_DS * 10

/obj/item/projectile
	/// Kierunek lotu (tg)
	var/datum/vector/movement_vector
	/// Piksele, których nie zdążyliśmy przelecieć w poprzednim ticku (nadrabianie laga)
	var/overrun = 0
	/// Piksele przelecone od ostatniego zmniejszenia zasięgu
	var/pixels_moved_last_tile = 0
	/// Gdzie w kratce (piksele względem środka) pocisk wszedł na ostatni kafel albo w niego uderzył
	var/entry_x = 0
	var/entry_y = 0
	/// AQ_PROJECTILE_IMPACT_DELETE, gdy pocisk już trafił i tylko dogrywa animację
	var/deletion_queued = NONE
	/// Za ile ticków usunąć pocisk po trafieniu
	var/ticks_to_deletion = 1
	/// Mnożnik prędkości z set_pixel_speed() (stary silnik: global_pixel_speed 2 = mnożnik 1)
	var/pixel_speed_multiplier = 1

/obj/item/projectile/Destroy()
	. = ..()
	QDEL_NULL(movement_vector)

/// Piksele na decysekundę dla tego pocisku
/obj/item/projectile/proc/get_pixels_per_decisecond()
	if(speed <= 0) // stary silnik: prędkość 0 = maksymalna liczba ruchów na tick
		return SSprojectiles.max_pixels_per_tick / max(world.tick_lag, 0.1)
	return SSprojectiles.pixels_per_decisecond / speed * pixel_speed_multiplier

/// Ile pikseli wynosi jedna kratka zasięgu (stary silnik zmniejszał zasięg co ruch, a ruch przy set_pixel_speed() był dłuższy)
/obj/item/projectile/proc/get_range_step_pixels()
	return world.icon_size * max(pixel_speed_multiplier, 0.01)

/obj/item/projectile/set_pixel_speed(new_speed)
	pixel_speed_multiplier = new_speed / AQ_PROJECTILE_LEGACY_PIXEL_SPEED
	return TRUE

/obj/item/projectile/process()
	last_process = world.time
	if(!loc || !fired || !movement_vector)
		fired = FALSE
		return PROCESS_KILL

	if(deletion_queued == AQ_PROJECTILE_IMPACT_DELETE)
		ticks_to_deletion--
		if(ticks_to_deletion <= 0)
			qdel(src)
		return

	if(paused || !isturf(loc))
		// Nadrabia pauzę, żeby po odpauzowaniu pocisk nie przeleciał całej zaległej drogi naraz
		last_projectile_move = last_process
		return

	if(hitscan)
		process_hitscan()
		return

	var/elapsed_time = world.time - last_projectile_move
	var/pixels_to_move = elapsed_time * get_pixels_per_decisecond() + overrun
	overrun = 0
	if(pixels_to_move > SSprojectiles.max_pixels_per_tick)
		// Dług nadrabiamy w następnym ticku, ale nie więcej niż jeden pełny tick (zawieszony serwer nie zrobi z pocisku hitscanu)
		overrun = min(pixels_to_move - SSprojectiles.max_pixels_per_tick, SSprojectiles.max_pixels_per_tick)
		pixels_to_move = SSprojectiles.max_pixels_per_tick
	overrun += MODULUS(pixels_to_move, 1)
	pixels_to_move = FLOOR(pixels_to_move, 1)
	if(pixels_to_move > 0)
		process_movement(pixels_to_move)

/**
 * Główna pętla ruchu (tg). Pocisk leci prosto przez kafle; przy każdym przejściu przez krawędź kafla robi step_towards(),
 * więc Bump()/Moved() działają jak dotąd. Wizualnie przesuwa się animacją między tickami.
 *
 * pixels_to_move - ile pikseli przelecieć
 * hitscan - bez animacji, pozycja zapisywana od razu
 * tile_limit - zatrzymaj się po pierwszej zmianie kafla
 * Zwraca liczbę wykonanych odcinków.
 */
/obj/item/projectile/proc/process_movement(pixels_to_move, hitscan = FALSE, tile_limit = FALSE)
	if(!isturf(loc) || !movement_vector)
		return 0
	var/tile_size = world.icon_size
	var/total_move_distance = max(pixels_to_move, 1)
	var/movements_done = 0
	last_projectile_move = world.time
	while(pixels_to_move > 0 && isturf(loc) && !QDELETED(src) && !deletion_queued)
		// pixel_x/y to przesunięcie od środka kafla, więc +16 daje pozycję od lewej/dolnej krawędzi
		var/pixel_x_actual = pixel_x + tile_size / 2
		if(pixel_x_actual > tile_size)
			pixel_x_actual = pixel_x_actual % tile_size
		var/pixel_y_actual = pixel_y + tile_size / 2
		if(pixel_y_actual > tile_size)
			pixel_y_actual = pixel_y_actual % tile_size

		var/distance_to_border = INFINITY
		var/x_to_border = INFINITY
		var/y_to_border = INFINITY
		if(movement_vector.pixel_x)
			var/x_border_dist = -pixel_x_actual
			if(movement_vector.pixel_x > 0)
				x_border_dist = tile_size - pixel_x_actual
			x_to_border = x_border_dist / movement_vector.pixel_x
			distance_to_border = x_to_border
		if(movement_vector.pixel_y)
			var/y_border_dist = -pixel_y_actual
			if(movement_vector.pixel_y > 0)
				y_border_dist = tile_size - pixel_y_actual
			y_to_border = y_border_dist / movement_vector.pixel_y
			distance_to_border = min(distance_to_border, y_to_border)

		if(distance_to_border == INFINITY)
			stack_trace("Pocisk [type] miał pusty wektor ruchu")
			qdel(src)
			return movements_done

		var/distance_to_move = min(distance_to_border, pixels_to_move)
		// Naprowadzany pocisk co najwyżej kafel na odcinek, żeby skręcał płynnie
		if(homing && distance_to_move > tile_size)
			distance_to_move = tile_size

		var/x_shift = distance_to_move >= x_to_border ? SIGN(movement_vector.pixel_x) : 0
		var/y_shift = distance_to_move >= y_to_border ? SIGN(movement_vector.pixel_y) : 0
		var/moving_turfs = x_shift || y_shift
		entry_x = pixel_x + movement_vector.pixel_x * distance_to_move - x_shift * tile_size
		entry_y = pixel_y + movement_vector.pixel_y * distance_to_move - y_shift * tile_size

		if(moving_turfs)
			var/turf/new_turf = locate(x + x_shift, y + y_shift, z)
			if(!istype(new_turf))
				qdel(src)
				return movements_done
			if(hitscan)
				// Hitscan: najpierw dojdź do krawędzi, żeby wiązka kończyła się na ścianie, a nie kafel przed nią
				pixel_x = entry_x + x_shift * tile_size
				pixel_y = entry_y + y_shift * tile_size
			var/angle_before_step = Angle
			step_towards(src, new_turf)
			if(QDELETED(src))
				return movements_done
			if(loc != new_turf && !deletion_queued)
				if(Angle == angle_before_step)
					// Zatrzymało nas coś, czego nie wolno trafić (strzelec, jego mech, okręt tej samej frakcji) - lecimy przez to
					trajectory_ignore_forcemove = TRUE
					forceMove(new_turf)
					trajectory_ignore_forcemove = FALSE
					if(QDELETED(src))
						return movements_done
				else
					// Rykoszet zmienił kierunek: zostajemy na krawędzi kafla i lecimy dalej nowym wektorem
					entry_x += x_shift * tile_size
					entry_y += y_shift * tile_size
					x_shift = 0
					y_shift = 0
			if(loc != new_turf)
				moving_turfs = FALSE

		movements_done++
		pixels_moved_last_tile += distance_to_move
		var/range_step = get_range_step_pixels()
		if(!deletion_queued && pixels_moved_last_tile >= range_step)
			pixels_moved_last_tile -= range_step
			Range()
			if(QDELETED(src))
				return movements_done

		if(physics2d) // NSV13 - kolizje z okrętami na overmapie
			physics2d.update(x * tile_size + pixel_x, y * tile_size + pixel_y, Angle)

		if(deletion_queued)
			if(hitscan)
				qdel(src)
				return movements_done
			// Dolecieliśmy do celu: dograj animację do krawędzi trafienia i zniknij
			if(moving_turfs)
				pixel_x -= x_shift * tile_size
				pixel_y -= y_shift * tile_size
			var/delete_x = pixel_x + movement_vector.pixel_x * distance_to_move
			var/delete_y = pixel_y + movement_vector.pixel_y * distance_to_move
			var/animate_time = world.tick_lag * distance_to_move / total_move_distance
			if(distance_to_move > pixels_to_move)
				ticks_to_deletion++
			if(!move_animate(delete_x, delete_y, animate_time, deleting = TRUE))
				animate(src, pixel_x = delete_x, pixel_y = delete_y, time = animate_time, flags = ANIMATION_PARALLEL | ANIMATION_CONTINUE)
				animate(alpha = 0, time = 0, flags = ANIMATION_CONTINUE)
			return movements_done

		pixels_to_move -= distance_to_move
		if(hitscan)
			pixel_x = entry_x
			pixel_y = entry_y
		else
			// animate() od razu ustawia pixel_x/y na serwerze, a klient interpoluje; najpierw cofamy przesunięcie z kroku na nowy kafel
			pixel_x -= x_shift * tile_size
			pixel_y -= y_shift * tile_size
			if(!move_animate(entry_x, entry_y, world.tick_lag * distance_to_move / total_move_distance))
				animate(src, pixel_x = entry_x, pixel_y = entry_y, time = world.tick_lag * distance_to_move / total_move_distance, flags = ANIMATION_PARALLEL | ANIMATION_CONTINUE)

		if(homing && world.time >= next_homing_process)
			process_homing()

		if(paused)
			return movements_done

		// Szybki pocisk na długim dystansie nie zje całego ticka serwera
		if(TICK_CHECK)
			overrun += pixels_to_move
			return movements_done

		if(tile_limit && moving_turfs)
			return movements_done

	return movements_done

/// Wołane przy każdej animacji ruchu; zwrot TRUE oznacza własną animację zamiast zwykłej
/obj/item/projectile/proc/move_animate(animate_x, animate_y, animate_time = world.tick_lag, deleting = FALSE)
	return FALSE

/// Zgodność ze starym silnikiem: jeden „ruch” = tyle pikseli, ile przelatywał stary pixel_move() (kafel × mnożnik)
/obj/item/projectile/pixel_move(trajectory_multiplier, hitscanning = FALSE)
	if(!loc || !movement_vector)
		return
	process_movement(SSprojectiles.pixels_per_decisecond * trajectory_multiplier * pixel_speed_multiplier, hitscanning)

/obj/item/projectile/fire(angle, atom/direct_target)
	LAZYINITLIST(impacted)
	if(fired_from)
		SEND_SIGNAL(fired_from, COMSIG_PROJECTILE_BEFORE_FIRE, src, original)
	if(!log_override && firer && original)
		log_combat(firer, original, "fired at", src, "from [get_area_name(src, TRUE)]")
	if(direct_target && (get_dist(direct_target, get_turf(src)) <= 1)) // strzał z przyłożenia
		process_hit(get_turf(direct_target), direct_target)
		if(QDELETED(src))
			return
	if(isnum_safe(angle))
		setAngle(angle)
	if(spread)
		setAngle(Angle + ((rand() - 0.5) * spread))
	var/turf/starting_turf = get_turf(src)
	if(isnull(Angle)) // bez kąta liczymy go z przesunięć xo/yo
		if(isnull(xo) || isnull(yo))
			stack_trace("WARNING: Projectile [type] deleted due to being unable to resolve a target after angle was null!")
			qdel(src)
			return
		var/turf/target = locate(CLAMP(starting_turf.x + xo, 1, world.maxx), CLAMP(starting_turf.y + yo, 1, world.maxy), starting_turf.z)
		setAngle(get_angle(src, target))
	original_angle = Angle
	if(!nondirectional_sprite)
		var/matrix/M = new
		M.Turn(Angle)
		transform = M
	trajectory_ignore_forcemove = TRUE
	forceMove(starting_turf)
	trajectory_ignore_forcemove = FALSE
	QDEL_NULL(movement_vector)
	movement_vector = new(1, Angle)
	overrun = 0
	pixels_moved_last_tile = 0
	last_projectile_move = world.time
	fired = TRUE
	if(hitscan)
		record_hitscan_start(RETURN_POINT_VECTOR_INCREMENT(src, Angle, MUZZLE_EFFECT_PIXEL_INCREMENT, 1))
		process_hitscan()
		if(QDELETED(src))
			return
	if(!(datum_flags & DF_ISPROCESSING))
		START_PROCESSING(SSprojectiles, src)
	// Od razu jeden kafel do przodu, żeby pocisk nie trafił strzelca (jak stary pixel_move(1) w fire())
	if(!hitscan && !deletion_queued)
		process_movement(world.icon_size * pixel_speed_multiplier, tile_limit = TRUE)

/obj/item/projectile/setAngle(new_angle)
	Angle = new_angle
	if(!nondirectional_sprite)
		var/matrix/M = new
		M.Turn(Angle)
		transform = M
	if(movement_vector)
		movement_vector.set_angle(new_angle)
	return TRUE

/// Hitscan przelatuje całą drogę od razu; przy pauzie albo braku czasu w ticku dokończy w process()
/obj/item/projectile/process_hitscan()
	if(!movement_vector)
		qdel(src)
		return
	if(!beam_index)
		record_hitscan_start(RETURN_POINT_VECTOR_INCREMENT(src, Angle, MUZZLE_EFFECT_PIXEL_INCREMENT, 1))
	var/safety = range * 3
	while(isturf(loc) && !QDELETED(src))
		if(paused)
			return
		if(safety-- <= 0)
			if(loc)
				Bump(loc)
			if(!QDELETED(src))
				qdel(src)
			return
		process_movement(world.icon_size, hitscan = TRUE)
		if(QDELETED(src))
			return
		if(TICK_CHECK)
			return

/obj/item/projectile/finalize_hitscan_and_generate_tracers(impacting = TRUE)
	if(movement_vector && beam_index)
		beam_segments[beam_index] = RETURN_PRECISE_POINT(src)
	generate_hitscan_tracers(null, null, impacting)

/// Teleport w locie (portal, przejście z-levela): pocisk leci dalej z nowego miejsca, wiązka hitscanu zaczyna się od nowa
/obj/item/projectile/forceMove(atom/target)
	var/teleported = fired && movement_vector && !trajectory_ignore_forcemove && isturf(target) && isloc(loc) && z
	if(teleported && hitscan)
		finalize_hitscan_and_generate_tracers(FALSE)
	. = ..()
	if(!teleported || QDELETED(src))
		return
	pixel_x = 0
	pixel_y = 0
	if(hitscan)
		record_hitscan_start(RETURN_PRECISE_POINT(src))

/// Zamiast qdel po trafieniu: pocisk dolatuje wizualnie do miejsca trafienia i znika w następnym ticku (tg)
/obj/item/projectile/proc/queue_impact_deletion()
	if(!fired || hitscan || !movement_vector || !isturf(loc) || !(datum_flags & DF_ISPROCESSING))
		qdel(src)
		return
	deletion_queued = AQ_PROJECTILE_IMPACT_DELETE
