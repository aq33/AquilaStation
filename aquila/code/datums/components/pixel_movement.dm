/**
 * Prototyp ruchu po pikselach.
 *
 * Logika gry zostaje na kafelkach (loc, Adjacent, Bump, ciągnięcie działają jak zawsze).
 * Postać ma w kafelku przesunięcie step_x/step_y (-16..15 px) i bounding box 1x1 w środku
 * kafelka, więc zawsze stoi w dokładnie jednym kafelku. Gdy gracz trzyma klawisz ruchu,
 * przesunięcie rośnie co tick; gdy środek ciała przekracza krawędź kafelka, idzie zwykły Move().
 *
 * Prędkość jak w SS14 (Content.Shared/Movement/Systems/SharedMoverController.cs): tarcie, potem przyspieszenie
 * w stylu Quake, stałe 20/s. Pełna prędkość po ok. 0.2 s, po puszczeniu klawisza krótki wybieg (timer co tick).
 * Prędkość docelowa to zwykły chód: 32 px na movement_delay(), po skosie tyle samo na przekątnej.
 *
 * Kolizje: ciało to kwadrat 2 * PIXEL_MOVE_BODY_HALF px wokół środka (w SS14 koło o promieniu 0.35 kafla).
 * Krawędź do sąsiedniego kafelka jest zablokowana jak w /turf/Enter (CanPass zawartości i samego kafelka)
 * albo przez obiekt na krawędzi własnego kafelka (okno kierunkowe, wiatrołap). Przy zablokowanej krawędzi
 * ciało staje PIXEL_MOVE_WALL_MARGIN px za środkiem, a próba Move() (najwyżej raz na zwykły krok) robi Bump:
 * otwiera drzwi, pcha skrzynię, zamienia się z mobem. Ściana zabiera składową prędkości w swoją stronę, więc
 * po skosie postać sunie wzdłuż niej. Ciało wystające w bok na zablokowany narożnik zsuwa się z niego przy
 * ruchu prosto (w SS14 robi to okrągłe ciało), a wepchnięte w zablokowany kafelek jest wypychane.
 *
 * Płynność: klient BYOND wygładza zmianę step_x tylko wtedy, gdy step_size i glide_size
 * są równe przesunięciu w tym ticku. Przy domyślnym step_size (32) ruch idzie schodkami
 * co tick, a animowanie pixel_w/client.pixel_x szarpało całym obrazem (pomiar zrzutami
 * ekranu w mini-świecie, 2026-11-04). Przesunięcie o kafelek przez kogoś innego (ciągnięcie,
 * taśmociąg) dostaje z powrotem step_size 32, inaczej klient pokazałby skok zamiast poślizgu.
 *
 * Zwykły ruch po kafelkach zostaje w nieważkości (dryf i odpychanie się od ścian) i gdy ktoś na nas siedzi.
 * Wbudowane step() podaje mobowi z bounding boxem 1x1 bieżący kafelek i piksele; hook w /atom/movable/Move()
 * (TRAIT_PIXEL_MOVEMENT) zamienia to na krok o kafelek, inaczej ruch po skosie przez step() zawsze by się nie udał.
 */
#define PIXEL_MOVE_HALF_TILE 16
/// Połowa szerokości ciała w pikselach (w SS14 koło o promieniu 0.35 kafla = 11.2 px)
#define PIXEL_MOVE_BODY_HALF 11
/// Jak daleko (px) środek ciała podchodzi do krawędzi zablokowanego kafelka
#define PIXEL_MOVE_WALL_MARGIN (PIXEL_MOVE_HALF_TILE - PIXEL_MOVE_BODY_HALF)

/// Stałe z SS14 (Acceleration 20, Friction = FrictionNoInput 20 na sekundę), tu na decysekundę
#define PIXEL_MOVE_ACCELERATION 2
#define PIXEL_MOVE_FRICTION 2
/// Podkrok fizyki w decysekundach (SS14: 30 ticków na sekundę po 2 podkroki = 1/60 s)
#define PIXEL_MOVE_SUBSTEP (1 / 6)
/// Poniżej tej prędkości (px/ds) bez klawisza mob staje
#define PIXEL_MOVE_STOP_SPEED 0.05

#define PIXEL_TILE_MOVE_FAILED 0
#define PIXEL_TILE_MOVE_DONE 1
/// Move() skończył się gdzie indziej (schody, otwarta przestrzeń, teleport w Entered)
#define PIXEL_TILE_MOVE_TELEPORTED 2

#define PIXEL_MOVEMENT_TRAIT "pixel_movement_component"

/datum/component/pixel_movement
	/// Ułamek piksela, który nie zmieścił się w całkowitym step_x/step_y
	var/frac_x = 0
	var/frac_y = 0
	/// Pozycja w kafelku w trakcie liczenia kroku (piksele z ułamkiem)
	var/pos_x = 0
	var/pos_y = 0
	/// Prędkość w px na decysekundę
	var/vel_x = 0
	var/vel_y = 0
	/// Timer wybiegu po puszczeniu klawisza
	var/coast_timer
	/// move_axis ustawia, gdy przeszkoda zatrzymała ruch wzdłuż osi
	var/axis_stopped = FALSE
	/// Czas ostatniego kroku, żeby nie liczyć dwa razy w jednym ticku
	var/last_step = -1
	/// Bump w ścianę/drzwi najwyżej raz na zwykły krok, nie co tick
	var/next_bump_try = 0
	/// Przesunięcie sprzed kroku w tym ticku; cofamy do niego, gdy w tym samym ticku przesunie nas ktoś inny
	var/undo_x = 0
	var/undo_y = 0
	/// TRUE w trakcie naszego własnego Move() (wtedy on_moved nic nie robi)
	var/own_move = FALSE
	/// Kiedy ostatnio przesunął nas ktoś inny; w tym ticku już się nie ruszamy
	var/last_external_move = -1
	/// Kierunek z klawiszy w ostatnim kroku (sprint liczy po nim rozpęd)
	var/input_dir = NONE
	/// Zamroczenie: kierunek albo obrót wylosowany na czas jednego zwykłego kroku
	var/confused_dir = NONE
	var/confused_turn = 0
	var/next_confused_roll = 0

/datum/component/pixel_movement/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/pixel_movement/RegisterWithParent()
	var/mob/living/owner = parent
	ADD_TRAIT(owner, TRAIT_PIXEL_MOVEMENT, PIXEL_MOVEMENT_TRAIT)
	RegisterSignal(owner, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(on_pre_move))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	// Przypięcie do krzesła (bez forceMove, gdy już stoimy na jego kafelku) i ktoś przypięty do nas
	RegisterSignal(owner, COMSIG_LIVING_BUCKLED_TO, PROC_REF(recenter))
	RegisterSignal(owner, COMSIG_MOVABLE_BUCKLE, PROC_REF(recenter))
	owner.bound_x = PIXEL_MOVE_HALF_TILE
	owner.bound_y = PIXEL_MOVE_HALF_TILE
	owner.bound_width = 1
	owner.bound_height = 1

/datum/component/pixel_movement/UnregisterFromParent()
	var/mob/living/owner = parent
	UnregisterSignal(owner, list(COMSIG_MOB_CLIENT_PRE_MOVE, COMSIG_MOVABLE_MOVED, COMSIG_LIVING_BUCKLED_TO, COMSIG_MOVABLE_BUCKLE))
	REMOVE_TRAIT(owner, TRAIT_PIXEL_MOVEMENT, PIXEL_MOVEMENT_TRAIT)
	stop_motion()
	recenter()
	owner.bound_x = initial(owner.bound_x)
	owner.bound_y = initial(owner.bound_y)
	owner.bound_width = initial(owner.bound_width)
	owner.bound_height = initial(owner.bound_height)

/// Środek kafelka, zero prędkości i zwykły step_size: po teleporcie, przypięciu, wejściu do szafki i przy wyłączeniu.
/// Samo `loc =` w BYOND zostawia step_x/step_y (sprawdzone w mini-świecie), więc bez tego mob siedziałby obok krzesła.
/datum/component/pixel_movement/proc/recenter()
	SIGNAL_HANDLER
	var/mob/living/owner = parent
	owner.step_x = 0
	owner.step_y = 0
	owner.step_size = world.icon_size
	frac_x = 0
	frac_y = 0
	undo_x = 0
	undo_y = 0
	vel_x = 0
	vel_y = 0

/datum/component/pixel_movement/proc/on_moved(datum/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	if(own_move)
		return
	var/mob/living/owner = parent
	last_external_move = world.time
	// forceMove: teleport, szafka, mech, ventcrawl, schody. Przesunięcie z poprzedniego miejsca nie ma tu sensu.
	if(forced || !isturf(owner.loc) || !isturf(old_loc))
		recenter()
		return
	// Ktoś inny przesunął nas o kafelek (ciągnięcie, taśmociąg, zamiana miejscami). Klient pokaże poślizg tylko
	// przy step_size >= przesunięcia, a nasz krok w tym samym ticku dołożyłby kilka pikseli ponad kafelek.
	if(last_step == world.time)
		owner.step_x = undo_x
		owner.step_y = undo_y
		frac_x = 0
		frac_y = 0
	owner.step_size = world.icon_size

/// /client/Move woła to co tick, gdy klawisz jest wciśnięty i mob może się ruszyć. Blokujemy zwykły krok.
/datum/component/pixel_movement/proc/on_pre_move(datum/source, turf/new_loc)
	SIGNAL_HANDLER
	var/mob/living/owner = parent
	own_move = FALSE // samonaprawa, gdyby Move() w poprzednim ticku przerwał błąd
	if(!isturf(owner.loc))
		return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE
	// Nieważkość (dryf, odpychanie się) i noszenie kogoś zostają przy zwykłym ruchu po kafelkach
	if(owner.has_buckled_mobs() || !owner.has_gravity())
		stop_motion()
		return NONE
	if(last_step == world.time || last_external_move == world.time)
		return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE
	var/direct = get_dir(owner, new_loc)
	if(!direct)
		return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE
	last_step = world.time
	input_dir = direct
	var/delay = max(owner.movement_delay(), world.tick_lag)
	direct = apply_confusion(direct, delay)
	owner.setDir(direct)
	advance(direct, delay)
	if(QDELETED(src))
		return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE
	// Pchając gęsty obiekt mob patrzy na niego, jak w /client/Move
	var/atom/movable/pulled = owner.pulling
	if(pulled && !ismob(pulled) && pulled.density)
		owner.setDir(turn(owner.dir, 180))
	if(!coast_timer && (vel_x || vel_y))
		coast_timer = addtimer(CALLBACK(src, PROC_REF(coast)), world.tick_lag, TIMER_LOOP | TIMER_STOPPABLE)
	return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE

/// Wybieg po puszczeniu klawisza. Timer co tick; SSinput ma wyższy priorytet niż SStimer,
/// więc przy trzymanym klawiszu krok z on_pre_move jest już zrobiony i tu nic się nie dzieje.
/datum/component/pixel_movement/proc/coast()
	var/mob/living/owner = parent
	if(last_step == world.time || last_external_move == world.time)
		return
	if(!vel_x && !vel_y)
		stop_motion()
		return
	if(!isturf(owner.loc) || owner.buckled || owner.pulledby || owner.stat != CONSCIOUS || !(owner.mobility_flags & MOBILITY_MOVE) || !owner.has_gravity())
		stop_motion()
		return
	last_step = world.time
	advance(NONE, max(owner.movement_delay(), world.tick_lag))

/// Zatrzymuje wybieg i zeruje prędkość; przesunięcie w kafelku zostaje
/datum/component/pixel_movement/proc/stop_motion()
	var/mob/living/owner = parent
	vel_x = 0
	vel_y = 0
	if(coast_timer)
		deltimer(coast_timer)
		coast_timer = null
	owner.step_size = world.icon_size

/**
 * Jeden tick ruchu: prędkość jak w SS14 (najpierw tarcie, potem przyspieszenie, w podkrokach 1/60 s),
 * potem przesunięcie z kolizjami i wygładzanie. direct = NONE to wybieg bez klawisza.
 */
/datum/component/pixel_movement/proc/advance(direct, delay)
	var/mob/living/owner = parent
	var/wish_speed = world.icon_size / delay
	var/wish_x = 0
	var/wish_y = 0
	if(direct & EAST)
		wish_x = 1
	else if(direct & WEST)
		wish_x = -1
	if(direct & NORTH)
		wish_y = 1
	else if(direct & SOUTH)
		wish_y = -1
	var/diagonal = wish_x && wish_y
	if(diagonal)
		wish_x /= sqrt(2)
		wish_y /= sqrt(2)
	var/substeps = max(1, round(world.tick_lag / PIXEL_MOVE_SUBSTEP, 1))
	var/dt = world.tick_lag / substeps
	var/keep = max(0, 1 - dt * PIXEL_MOVE_FRICTION)
	var/disp_x = 0
	var/disp_y = 0
	for(var/i in 1 to substeps)
		vel_x *= keep
		vel_y *= keep
		if(wish_x || wish_y)
			// Quake: dokładamy tylko brakującą prędkość w kierunku klawiszy, więc skręt wytraca starą składową tarciem
			var/missing = wish_speed - (vel_x * wish_x + vel_y * wish_y)
			if(missing > 0)
				var/gain = min(PIXEL_MOVE_ACCELERATION * dt * wish_speed, missing)
				vel_x += wish_x * gain
				vel_y += wish_y * gain
		disp_x += vel_x * dt
		disp_y += vel_y * dt
	if(!wish_x && !wish_y && abs(vel_x) + abs(vel_y) < PIXEL_MOVE_STOP_SPEED)
		vel_x = 0
		vel_y = 0

	var/turf/start_turf = owner.loc
	var/old_abs_x = start_turf.x * world.icon_size + owner.step_x
	var/old_abs_y = start_turf.y * world.icon_size + owner.step_y
	undo_x = owner.step_x
	undo_y = owner.step_y
	pos_x = owner.step_x + frac_x
	pos_y = owner.step_y + frac_y

	if(disp_x)
		axis_stopped = FALSE
		if(!move_axis(TRUE, disp_x > 0 ? 1 : -1, abs(disp_x), delay, diagonal))
			return
		if(axis_stopped) // przeszkoda zabiera składową prędkości w swoją stronę, jak solver w SS14
			vel_x = 0
	if(disp_y)
		axis_stopped = FALSE
		if(!move_axis(FALSE, disp_y > 0 ? 1 : -1, abs(disp_y), delay, diagonal))
			return
		if(axis_stopped)
			vel_y = 0
	depenetrate(max(abs(disp_x), abs(disp_y), 1))

	var/int_x = clamp(round(pos_x), -PIXEL_MOVE_HALF_TILE, PIXEL_MOVE_HALF_TILE - 1)
	var/int_y = clamp(round(pos_y), -PIXEL_MOVE_HALF_TILE, PIXEL_MOVE_HALF_TILE - 1)
	frac_x = clamp(pos_x - int_x, 0, 0.999)
	frac_y = clamp(pos_y - int_y, 0, 0.999)
	owner.step_x = int_x
	owner.step_y = int_y

	// Wygładzanie: step_size i glide_size muszą równać się przesunięciu w tym ticku
	var/turf/end_turf = owner.loc
	if(end_turf.z == start_turf.z)
		var/delta = max(abs(end_turf.x * world.icon_size + int_x - old_abs_x), abs(end_turf.y * world.icon_size + int_y - old_abs_y))
		if(delta > 0 && delta <= world.icon_size)
			owner.step_size = delta
			owner.set_glide_size(delta)

/// Jak zamroczenie w /client/Move, ale losowane raz na zwykły krok, nie co tick
/datum/component/pixel_movement/proc/apply_confusion(direct, delay)
	var/mob/living/owner = parent
	if(!owner.confused || owner.m_intent != MOVE_INTENT_RUN || HAS_TRAIT(owner, TRAIT_CONFUSEIMMUNE))
		confused_dir = NONE
		confused_turn = 0
		return direct
	if(world.time >= next_confused_roll)
		next_confused_roll = world.time + delay
		confused_dir = NONE
		confused_turn = 0
		if(owner.confused > 40)
			confused_dir = pick(GLOB.alldirs)
		else if(prob(owner.confused * 1.5))
			confused_turn = pick(90, -90)
		else if(prob(owner.confused * 3))
			confused_turn = pick(45, -45)
	if(confused_dir)
		return confused_dir
	if(confused_turn)
		return angle2dir(dir2angle(direct) + confused_turn)
	return direct

/**
 * Krok wzdłuż jednej osi. sign: 1 na wschód/północ, -1 na zachód/południe.
 * Zwraca FALSE, gdy Move() przeniósł moba gdzie indziej i krok trzeba przerwać.
 */
/datum/component/pixel_movement/proc/move_axis(horizontal, sign, dist, delay, diagonal)
	var/mob/living/owner = parent
	var/turf/here = owner.loc
	var/dir_along = horizontal ? (sign > 0 ? EAST : WEST) : (sign > 0 ? NORTH : SOUTH)
	var/side_pos = horizontal ? NORTH : EAST
	var/side_neg = horizontal ? SOUTH : WEST
	// Wartości w układzie osi: along rośnie w stronę ruchu
	var/along = (horizontal ? pos_x : pos_y) * sign
	var/lateral = horizontal ? pos_y : pos_x
	var/target = along + dist
	var/turf/next = get_step(here, dir_along)

	if(target > PIXEL_MOVE_WALL_MARGIN)
		// Przód ciała wchodzi w następny kafelek
		if(edge_blocked(here, next))
			if(next && world.time >= next_bump_try)
				next_bump_try = world.time + delay
				switch(try_tile_move(next, dir_along))
					if(PIXEL_TILE_MOVE_TELEPORTED)
						return FALSE
					if(PIXEL_TILE_MOVE_DONE)
						// Bump od razu zwolnił przejście (zamiana z mobem): jesteśmy już w następnym kafelku
						set_axis(horizontal, sign, max(target - world.icon_size, -PIXEL_MOVE_HALF_TILE), lateral)
						return TRUE
			target = min(target, max(along, PIXEL_MOVE_WALL_MARGIN))
			axis_stopped = TRUE
		else
			// Bok ciała zahacza o zablokowany narożnik
			var/corner = NONE
			if(lateral > PIXEL_MOVE_WALL_MARGIN && corner_blocked(get_step(next, side_pos)))
				corner = side_pos
			else if(lateral < -PIXEL_MOVE_WALL_MARGIN && corner_blocked(get_step(next, side_neg)))
				corner = side_neg
			if(corner)
				target = min(target, max(along, PIXEL_MOVE_WALL_MARGIN))
				if(diagonal)
					// Po skosie z rogu zsuwa druga oś
					axis_stopped = TRUE
				else
					// Ruch prosto zsuwa ciało z rogu (w SS14 okrągłe ciało ślizga się po krawędzi), prędkość zostaje
					var/overlap = abs(lateral) - PIXEL_MOVE_WALL_MARGIN
					lateral -= min(dist, overlap) * (corner == side_pos ? 1 : -1)

	if(target >= PIXEL_MOVE_HALF_TILE)
		switch(try_tile_move(get_step(here, dir_along), dir_along))
			if(PIXEL_TILE_MOVE_TELEPORTED)
				return FALSE
			if(PIXEL_TILE_MOVE_DONE)
				target -= world.icon_size
			else
				target = PIXEL_MOVE_HALF_TILE - 1
				axis_stopped = TRUE
	set_axis(horizontal, sign, target, lateral)
	return TRUE

/datum/component/pixel_movement/proc/set_axis(horizontal, sign, along, lateral)
	if(horizontal)
		pos_x = along * sign
		pos_y = lateral
	else
		pos_y = along * sign
		pos_x = lateral

/// Ciało wepchnięte w zablokowany kafelek (zamknęły się drzwi obok, ktoś podszedł) jest wypychane z powrotem
/datum/component/pixel_movement/proc/depenetrate(push)
	var/mob/living/owner = parent
	var/turf/here = owner.loc
	if(pos_x > PIXEL_MOVE_WALL_MARGIN && edge_blocked(here, get_step(here, EAST)))
		pos_x = max(PIXEL_MOVE_WALL_MARGIN, pos_x - push)
	else if(pos_x < -PIXEL_MOVE_WALL_MARGIN && edge_blocked(here, get_step(here, WEST)))
		pos_x = min(-PIXEL_MOVE_WALL_MARGIN, pos_x + push)
	if(pos_y > PIXEL_MOVE_WALL_MARGIN && edge_blocked(here, get_step(here, NORTH)))
		pos_y = max(PIXEL_MOVE_WALL_MARGIN, pos_y - push)
	else if(pos_y < -PIXEL_MOVE_WALL_MARGIN && edge_blocked(here, get_step(here, SOUTH)))
		pos_y = min(-PIXEL_MOVE_WALL_MARGIN, pos_y + push)

/**
 * Czy krawędź między sąsiednimi kafelkami zatrzyma moba. Bez skutków ubocznych (CanPass jest SHOULD_BE_PURE),
 * w przeciwieństwie do /turf/Enter i COMSIG_ATOM_EXIT, które robią Bump.
 */
/datum/component/pixel_movement/proc/edge_blocked(turf/from, turf/dest)
	var/mob/living/owner = parent
	if(!dest)
		return TRUE
	if(!dest.CanPass(owner, from))
		return TRUE
	for(var/atom/movable/thing as anything in dest)
		if(thing != owner && !thing.CanPass(owner, from))
			return TRUE
	// Obiekty na krawędzi własnego kafelka (okno kierunkowe, wiatrołap) blokują wyjście w swoją stronę
	for(var/atom/movable/thing as anything in from)
		if(thing != owner && (thing.flags_1 & ON_BORDER_1) && !thing.CanPass(owner, dest))
			return TRUE
	return FALSE

/// Narożnik, o który bok ciała może zahaczyć: ściana albo pełny gęsty obiekt. Moby i obiekty na krawędzi kafelka się nie liczą.
/datum/component/pixel_movement/proc/corner_blocked(turf/corner)
	var/mob/living/owner = parent
	if(!corner)
		return TRUE
	if(!corner.CanPass(owner, owner.loc))
		return TRUE
	for(var/atom/movable/thing as anything in corner)
		if(thing.density && !ismob(thing) && !(thing.flags_1 & ON_BORDER_1) && !thing.CanPass(owner, owner.loc))
			return TRUE
	return FALSE

/datum/component/pixel_movement/proc/try_tile_move(turf/next, dir)
	var/mob/living/owner = parent
	if(!next)
		return PIXEL_TILE_MOVE_FAILED
	var/turf/old_turf = owner.loc
	// Zwykły glide na czas Move (z niego liczy się animacja chodu i poślizg ciągniętego obiektu); docelowy ustawia advance()
	owner.set_glide_size(DELAY_TO_GLIDE_SIZE(owner.movement_delay()))
	own_move = TRUE
	owner.Move(next, dir)
	own_move = FALSE
	if(QDELETED(owner) || QDELETED(src))
		return PIXEL_TILE_MOVE_TELEPORTED
	if(owner.loc == next)
		if(owner.throwing) // jak w /client/Move: własny krok kończy lot
			owner.throwing.finalize(FALSE)
		return PIXEL_TILE_MOVE_DONE
	if(owner.loc == old_turf)
		return PIXEL_TILE_MOVE_FAILED
	recenter()
	return PIXEL_TILE_MOVE_TELEPORTED

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

#undef PIXEL_MOVE_HALF_TILE
#undef PIXEL_MOVE_BODY_HALF
#undef PIXEL_MOVE_WALL_MARGIN
#undef PIXEL_MOVE_ACCELERATION
#undef PIXEL_MOVE_FRICTION
#undef PIXEL_MOVE_SUBSTEP
#undef PIXEL_MOVE_STOP_SPEED
#undef PIXEL_TILE_MOVE_FAILED
#undef PIXEL_TILE_MOVE_DONE
#undef PIXEL_TILE_MOVE_TELEPORTED
#undef PIXEL_MOVEMENT_TRAIT
