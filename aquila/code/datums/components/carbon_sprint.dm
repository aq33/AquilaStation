// Port BeeStation/BeeStation-Hornet#14750 (code/datums/components/carbon_sprint.dm).
// Różnice względem Bee:
// - zamiast datumów move_intent sprint to nadpisanie modyfikatora biegu (SPRINT_DELAY zamiast RUN_DELAY),
//   działa tylko przy m_intent == MOVE_INTENT_RUN, patrz /mob/living/carbon/update_move_intent_slowdown()
// - rozpęd liczy każdy krok w tym samym kierunku (w Bee kroki tuż po chmurce kurzu się nie liczyły)
// - nowe: wywrotka po wpadnięciu z rozpędu w ścianę i potknięcie na schodach
// - nowe: wbiegnięcie w kogoś z combat mode działa jak ściana, a guzik „leż” podczas sprintu z combat mode to rzut (powala trafionego)

/datum/component/carbon_sprint
	var/mob/living/carbon/carbon_parent
	///Czy gracz trzyma klawisz sprintu
	var/sprint_key_down = FALSE
	///Czy właśnie sprintujemy (modyfikator prędkości założony)
	var/sprinting = FALSE
	///Ile kratek przebiegliśmy w jednym kierunku (skos liczy się jako 1.4)
	var/sustained_moves = 0
	///Długość kroku w toku, 1.4 po skosie
	var/step_size = 1
	///Krok ze sprintu czeka na pobranie kosztu w Moved()
	var/pending_step = FALSE
	///Kiedy był ostatni krok sprintu
	var/last_sprint_step = 0
	///Kierunek ostatniego kroku sprintu (0 = świeży start)
	var/last_sprint_dir = 0
	var/last_dust = 0
	///Nasza własna chmurka kurzu
	var/obj/effect/sprint_dust/dust
	///Rzut w toku: pierwsze zderzenie go rozstrzyga
	var/diving = FALSE
	COOLDOWN_DECLARE(dive_cooldown)

/datum/component/carbon_sprint/Initialize()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE
	carbon_parent = parent
	dust = new(null)

/datum/component/carbon_sprint/Destroy(force, silent)
	QDEL_NULL(dust)
	. = ..()
	carbon_parent = null

/datum/component/carbon_sprint/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(on_pre_move))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(parent, COMSIG_MOVABLE_BUMP, PROC_REF(on_bump))
	RegisterSignal(parent, COMSIG_KB_CARBON_SPRINT_DOWN, PROC_REF(on_sprint_key_down))
	RegisterSignal(parent, COMSIG_KB_CARBON_SPRINT_UP, PROC_REF(on_sprint_key_up))
	// Zamiana ciał itp. potrafi zgubić puszczenie klawisza
	RegisterSignal(parent, COMSIG_MOB_LOGOUT, PROC_REF(on_sprint_key_up))

/datum/component/carbon_sprint/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_MOB_CLIENT_PRE_MOVE,
		COMSIG_MOVABLE_MOVED,
		COMSIG_MOVABLE_BUMP,
		COMSIG_MOVABLE_IMPACT,
		COMSIG_KB_CARBON_SPRINT_DOWN,
		COMSIG_KB_CARBON_SPRINT_UP,
		COMSIG_MOB_LOGOUT,
	))
	if(sprinting)
		stop_sprint()

/datum/component/carbon_sprint/proc/on_pre_move(datum/source, new_loc)
	SIGNAL_HANDLER
	pending_step = FALSE
	if(!can_sprint())
		if(sprinting)
			stop_sprint()
		return
	// Prędkość musi być założona przed movement_delay() w /client/Move, resztę zatwierdza on_moved()
	if(!sprinting)
		sprinting = TRUE
		carbon_parent.update_move_intent_slowdown()
	pending_step = TRUE

///Rozpęd, kurz i koszt zatwierdzamy dopiero po udanym kroku, z faktycznym kierunkiem (confusion potrafi go zmienić)
/datum/component/carbon_sprint/proc/on_moved(datum/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	var/turf/old_turf = get_turf(old_loc)
	var/turf/new_turf = get_turf(carbon_parent)
	if(pending_step && sprinting && !forced && old_turf && new_turf && old_turf.z == new_turf.z && get_dist(old_turf, new_turf) == 1)
		pending_step = FALSE
		commit_step(get_dir(old_turf, new_turf), old_turf)
	check_stairs(old_turf, new_turf)

/datum/component/carbon_sprint/proc/commit_step(direct, turf/old_turf)
	step_size = (direct & (direct - 1)) ? SPRINT_DIAGONAL_MODIFIER : 1
	// Ruszamy od nowa: pierwszy krok albo po dłuższym postoju z wciśniętym klawiszem
	if(!last_sprint_dir || world.time > last_sprint_step + SPRINT_SUSTAINED_RUN_GRACE)
		dust.appear("sprint_cloud", direct, old_turf, 0.6 SECONDS)
		last_dust = world.time
		sustained_moves = step_size
	else if(direct & last_sprint_dir)
		if((sustained_moves < SPRINT_SUSTAINED_THRESHOLD) && ((sustained_moves + step_size) >= SPRINT_SUSTAINED_THRESHOLD) && world.time > last_dust + SPRINT_SUSTAINED_RUN_GRACE)
			dust.appear("sprint_cloud_small", direct, old_turf, 0.4 SECONDS)
			last_dust = world.time
		sustained_moves += step_size
	else
		if(sustained_moves >= SPRINT_SUSTAINED_THRESHOLD)
			dust.appear("sprint_cloud_small", direct, old_turf, 0.4 SECONDS)
			last_dust = world.time
		if(direct & turn(last_sprint_dir, 180))
			dust.appear("sprint_cloud_tiny", direct, old_turf, 0.3 SECONDS)
			last_dust = world.time
		sustained_moves = 0
	last_sprint_dir = direct
	last_sprint_step = world.time

	var/cost = SPRINT_COST * step_size
	if(carbon_parent.has_movespeed_modifier(MOVESPEED_ID_BULKY_DRAGGING) || carbon_parent.has_movespeed_modifier(MOVESPEED_ID_HUMAN_CARRYING))
		cost *= SPRINT_HAUL_MODIFIER
	carbon_parent.stamina?.adjust(-cost)
	carbon_parent.stamina?.block_regen(SPRINT_REGEN_DELAY)

/datum/component/carbon_sprint/proc/on_sprint_key_down(datum/source)
	SIGNAL_HANDLER
	sprint_key_down = TRUE

/datum/component/carbon_sprint/proc/on_sprint_key_up(datum/source)
	SIGNAL_HANDLER
	sprint_key_down = FALSE
	if(sprinting)
		stop_sprint()

/datum/component/carbon_sprint/proc/stop_sprint()
	sprinting = FALSE
	pending_step = FALSE
	sustained_moves = 0
	last_sprint_dir = 0
	carbon_parent.update_move_intent_slowdown()

/datum/component/carbon_sprint/proc/can_sprint()
	if(!sprint_key_down)
		return FALSE
	if(carbon_parent.m_intent != MOVE_INTENT_RUN)
		return FALSE
	if(carbon_parent.stat != CONSCIOUS || carbon_parent.InCritical())
		return FALSE
	if(carbon_parent.movement_type & (FLOATING|FLYING|VENTCRAWLING))
		return FALSE
	if(!(carbon_parent.mobility_flags & MOBILITY_STAND) || carbon_parent.legcuffed)
		return FALSE
	if(HAS_TRAIT(carbon_parent, TRAIT_EXHAUSTED))
		return FALSE
	if(!carbon_parent.stamina || carbon_parent.stamina.current <= 0)
		return FALSE
	return TRUE

///Czy krok sprintu był przed chwilą (do wywrotki i schodów)
/datum/component/carbon_sprint/proc/sprinted_recently(window = SPRINT_SUSTAINED_RUN_GRACE)
	return sprinting && world.time <= last_sprint_step + window

// ---------------------------------------------------------------------------
// Wywrotka na ścianie (nowe, nie ma w Bee)

/datum/component/carbon_sprint/proc/on_bump(datum/source, atom/bumped)
	SIGNAL_HANDLER
	if(!sprinted_recently() || carbon_parent.throwing)
		return
	// Mob ustępuje albo się przepycha, chyba że stoi w combat mode: wtedy to jak ściana
	if(ismob(bumped) && !is_braced_mob(bumped))
		return
	var/moves = sustained_moves
	sustained_moves = 0
	pending_step = FALSE
	if(moves < SPRINT_WALLSLAM_MIN_MOVES || !bumped.density)
		return
	// Drugi krok skosu po udanym pierwszym to ślizg po ścianie, nie uderzenie z rozpędu (Move() dzieli skos zawsze najpierw na N/S)
	if(carbon_parent.moving_diagonally == SECOND_DIAG_STEP)
		return
	// Drzwi otwierają się na bump najwyżej raz na sekundę (door.dm Bumped): druga śluza zaraz za pierwszą tylko chwilowo się nie otwiera
	if(istype(bumped, /obj/machinery/door) && world.time - carbon_parent.last_bumped <= 10)
		return
	// Ocena tick później: drzwi, które się przed nami otwierają, nie przewracają
	addtimer(CALLBACK(src, PROC_REF(resolve_bump), bumped, moves, get_turf(carbon_parent)), 1)

/datum/component/carbon_sprint/proc/resolve_bump(atom/bumped, moves, turf/bump_turf)
	if(QDELETED(carbon_parent) || QDELETED(bumped) || !is_hard_obstacle(bumped))
		return
	// Przez tick mob mógł się już przemieścić: wywrotka tylko na miejscu zderzenia
	if(get_turf(carbon_parent) != bump_turf || get_dist(carbon_parent, bumped) > 1)
		return
	if(!(carbon_parent.mobility_flags & MOBILITY_STAND) || carbon_parent.stat != CONSCIOUS)
		return
	var/extra = moves - SPRINT_WALLSLAM_MIN_MOVES
	if(!prob(min(SPRINT_WALLSLAM_BASE_CHANCE + extra * SPRINT_WALLSLAM_CHANCE_PER_TILE, SPRINT_WALLSLAM_MAX_CHANCE)))
		return
	var/damage = min(SPRINT_WALLSLAM_BASE_DAMAGE + extra * SPRINT_WALLSLAM_DAMAGE_PER_TILE, SPRINT_WALLSLAM_MAX_DAMAGE)
	carbon_parent.visible_message("<span class='danger'>[carbon_parent] wpada z rozpędu na [bumped] i się przewraca!</span>", \
		"<span class='userdanger'>Wpadasz z rozpędu na [bumped] i się przewracasz!</span>")
	playsound(get_turf(carbon_parent), 'sound/effects/bang.ogg', 50, TRUE, -1)
	carbon_parent.apply_damage(damage, BRUTE, BODY_ZONE_HEAD)
	carbon_parent.Knockdown(SPRINT_WALLSLAM_KNOCKDOWN)
	if(sprinting)
		stop_sprint()

///Ściana, okno, zamknięte drzwi, przykręcona gęsta struktura albo ktoś stojący w combat mode
/datum/component/carbon_sprint/proc/is_hard_obstacle(atom/bumped)
	if(ismob(bumped))
		return is_braced_mob(bumped)
	if(!bumped.density)
		return FALSE
	if(isturf(bumped))
		return TRUE
	if(!isobj(bumped))
		return FALSE
	var/obj/O = bumped
	if(!O.anchored)
		return FALSE
	if(istype(O, /obj/machinery/door))
		var/obj/machinery/door/door = O
		return !door.operating
	// Drewniane i żelazne drzwi (mineral_door) otwierają się ze sleep(10), więc tick po zderzeniu są jeszcze gęste
	if(istype(O, /obj/structure/mineral_door))
		var/obj/structure/mineral_door/mineral_door = O
		return !mineral_door.isSwitchingStates
	return TRUE

///Przytomny, stojący mob w combat mode (w starym trybie: na intencji harm) zatrzymuje biegnącego jak ściana
/datum/component/carbon_sprint/proc/is_braced_mob(atom/bumped)
	if(!isliving(bumped) || bumped == carbon_parent)
		return FALSE
	var/mob/living/target = bumped
	// Tylko ludzie, małpy i moby z graczem: NPC z domyślnym combat mode (blobbernaut, morph) niczego świadomie nie zapierają
	if(!iscarbon(target) && !target.client)
		return FALSE
	return target.combat_mode && target.density && target.stat == CONSCIOUS && (target.mobility_flags & MOBILITY_STAND)

// ---------------------------------------------------------------------------
// Rzut na sprincie (nowe): guzik „leż” (albo jego klawisz) przy wciśniętym klawiszu sprintu i combat mode rzuca postać przed siebie
// zamiast ją położyć. Po puszczeniu klawisza sprintu guzik zwyczajnie kładzie. Nad kosmosem i przepaścią też zwyczajnie kładzie

/mob/living/carbon/lay_down()
	if(!resting)
		var/datum/component/carbon_sprint/sprint = GetComponent(/datum/component/carbon_sprint)
		if(sprint?.try_rest_dive())
			return
	return ..()

/// Wołane z lay_down(). TRUE, jeśli zamiast położenia się zaczął się rzut
/datum/component/carbon_sprint/proc/try_rest_dive()
	if(!can_dive())
		return FALSE
	var/dive_dir = last_sprint_dir || carbon_parent.dir
	var/turf/target_turf = get_ranged_target_turf(carbon_parent, dive_dir, SPRINT_DIVE_RANGE)
	if(!target_turf || target_turf == get_turf(carbon_parent) || !safe_dive_path(dive_dir))
		return FALSE
	INVOKE_ASYNC(src, PROC_REF(start_dive), target_turf)
	return TRUE

/// Żadna kratka na drodze rzutu nie jest bez podłoża (kosmos, przepaść, otwarta przestrzeń): rzut by tam wyniósł postać
/datum/component/carbon_sprint/proc/safe_dive_path(dive_dir)
	var/turf/T = get_turf(carbon_parent)
	for(var/i in 1 to SPRINT_DIVE_RANGE)
		T = get_step(T, dive_dir)
		if(!T)
			return TRUE
		if(isgroundlessturf(T) || isspaceturf(T))
			return FALSE
		if(T.density)
			return TRUE
	return TRUE

/datum/component/carbon_sprint/proc/can_dive()
	if(diving || !COOLDOWN_FINISHED(src, dive_cooldown))
		return FALSE
	if(carbon_parent.incapacitated(ignore_restraints = TRUE) || carbon_parent.resting)
		return FALSE
	// W starym trybie sterowania combat mode to intencja harm
	if(!carbon_parent.combat_mode || !sprint_key_down || !sprinted_recently(SPRINT_RECENT_STEP_WINDOW))
		return FALSE
	if(carbon_parent.restrained() || carbon_parent.buckled || !isturf(carbon_parent.loc))
		return FALSE
	if(!carbon_parent.stamina || carbon_parent.stamina.current < SPRINT_DIVE_COST)
		return FALSE
	return TRUE

/datum/component/carbon_sprint/proc/start_dive(turf/target_turf)
	if(!target_turf)
		return
	diving = TRUE
	if(sprinting)
		stop_sprint()
	RegisterSignal(carbon_parent, COMSIG_MOVABLE_IMPACT, PROC_REF(on_dive_impact))
	// Odstęp i komunikat przed throw_at: pierwszy krok rzutu idzie od razu, więc zderzenie z kimś tuż obok
	// rozstrzyga się jeszcze w throw_at() i jego komunikat musi wyjść po „rzuca się przed siebie”
	COOLDOWN_START(src, dive_cooldown, SPRINT_DIVE_COOLDOWN)
	carbon_parent.visible_message("<span class='warning'>[carbon_parent] rzuca się przed siebie!</span>", 		"<span class='notice'>Rzucasz się przed siebie!</span>")
	playsound(get_turf(carbon_parent), 'sound/weapons/thudswoosh.ogg', 40, TRUE, -1)
	// Siła WEAK: carbonowe throw_impact nie dokłada swoich obrażeń, rozstrzyga on_dive_impact()
	if(!carbon_parent.throw_at(target_turf, SPRINT_DIVE_RANGE, 1, carbon_parent, FALSE, callback = CALLBACK(src, PROC_REF(end_dive)), force = MOVE_FORCE_WEAK))
		// Rzut anulowany (np. COMPONENT_CANCEL_THROW): bez kosztu i bez odstępu
		COOLDOWN_RESET(src, dive_cooldown)
		end_dive()
		return
	carbon_parent.stamina?.adjust(-SPRINT_DIVE_COST)
	carbon_parent.stamina?.block_regen(SPRINT_REGEN_DELAY)

///Pierwsze zderzenie rzutu: ktoś (powalony), przeszkoda (wywrotka) albo podłoga (lądowanie)
/datum/component/carbon_sprint/proc/on_dive_impact(datum/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	UnregisterSignal(carbon_parent, COMSIG_MOVABLE_IMPACT)
	if(!diving)
		return
	if(isliving(hit_atom) && hit_atom != carbon_parent)
		dive_hit(hit_atom)
	else if(hit_atom.density && (isturf(hit_atom) || is_hard_obstacle(hit_atom)))
		carbon_parent.visible_message("<span class='danger'>[carbon_parent] rzuca się prosto na [hit_atom]!</span>", 			"<span class='userdanger'>Rzucasz się prosto na [hit_atom]!</span>")
		playsound(get_turf(carbon_parent), 'sound/effects/bang.ogg', 50, TRUE, -1)
		carbon_parent.apply_damage(SPRINT_WALLSLAM_BASE_DAMAGE, BRUTE, BODY_ZONE_HEAD)
		carbon_parent.Knockdown(SPRINT_WALLSLAM_KNOCKDOWN)
	else
		carbon_parent.Knockdown(SPRINT_DIVE_MISS_KNOCKDOWN)
	diving = FALSE

/datum/component/carbon_sprint/proc/dive_hit(mob/living/target)
	carbon_parent.visible_message("<span class='danger'>[carbon_parent] rzuca się na [target] i powala na ziemię!</span>", 		"<span class='userdanger'>Rzucasz się na [target] i powalasz na ziemię!</span>", ignored_mobs = target)
	to_chat(target, "<span class='userdanger'>[carbon_parent] rzuca się na ciebie i powala cię na ziemię!</span>")
	playsound(get_turf(target), 'sound/weapons/punch1.ogg', 50, TRUE, -1)
	log_combat(carbon_parent, target, "tackled (sprint dive)")
	target.Knockdown(SPRINT_DIVE_TARGET_KNOCKDOWN)
	carbon_parent.Knockdown(SPRINT_DIVE_SELF_KNOCKDOWN)

/datum/component/carbon_sprint/proc/end_dive()
	if(QDELETED(carbon_parent))
		return
	UnregisterSignal(carbon_parent, COMSIG_MOVABLE_IMPACT)
	diving = FALSE

// ---------------------------------------------------------------------------
// Potknięcie na schodach (nowe, nie ma w Bee)

/datum/component/carbon_sprint/proc/check_stairs(turf/old_turf, turf/new_turf)
	if(!old_turf || !new_turf || old_turf.z == new_turf.z)
		return
	if(!sprinted_recently(SPRINT_RECENT_STEP_WINDOW))
		return
	var/chance
	// W dół: spadamy przez otwartą przestrzeń na ostatni stopień
	var/obj/structure/stairs/stairs = locate() in new_turf
	if(stairs?.isTerminator())
		chance = SPRINT_STAIRS_TRIP_CHANCE_DOWN
	else
		// W górę: schodzimy z ostatniego stopnia piętro wyżej
		stairs = locate() in old_turf
		if(!stairs?.isTerminator())
			return
		chance = SPRINT_STAIRS_TRIP_CHANCE_UP
	if(HAS_TRAIT(carbon_parent, TRAIT_EXHAUSTED))
		chance += SPRINT_STAIRS_TRIP_EXHAUSTED_BONUS
	if(!prob(chance))
		return
	// Tick później, żeby spadanie przez otwartą przestrzeń zdążyło się skończyć
	addtimer(CALLBACK(src, PROC_REF(stairs_trip), stairs, new_turf), 1)

/datum/component/carbon_sprint/proc/stairs_trip(obj/structure/stairs/stairs, turf/arrived_at)
	if(QDELETED(carbon_parent) || QDELETED(stairs) || carbon_parent.stat == DEAD)
		return
	// Przez tick mob mógł się już przemieścić (teleport, popchnięcie): wtedy nie ma potknięcia
	if(get_turf(carbon_parent) != arrived_at)
		return
	var/turf/top = get_turf(stairs)
	// Najpierw koniec sprintu, żeby forceMove nie odpalił check_stairs drugi raz
	if(sprinting)
		stop_sprint()
	if(get_turf(carbon_parent) != top)
		carbon_parent.forceMove(top)
	carbon_parent.visible_message("<span class='danger'>[carbon_parent] potyka się na schodach i zjeżdża na dół!</span>", \
		"<span class='userdanger'>Potykasz się na schodach i zjeżdżasz na dół!</span>")
	playsound(top, "bodyfall", 50, TRUE, -1)
	carbon_parent.apply_damage(SPRINT_STAIRS_TRIP_DAMAGE, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
	carbon_parent.Knockdown(SPRINT_STAIRS_TRIP_KNOCKDOWN)
	slide_step(turn(stairs.dir, 180), stairs.dir, SPRINT_STAIRS_MAX_SLIDE)

///Zjazd po kolejnych stopniach aż do pierwszej kratki za schodami
/datum/component/carbon_sprint/proc/slide_step(slide_dir, stairs_dir, steps_left)
	if(QDELETED(carbon_parent) || steps_left <= 0)
		return
	var/turf/next = get_step(carbon_parent, slide_dir)
	if(!next || is_blocked_turf(next, TRUE))
		return
	var/obj/structure/stairs/next_stairs = locate() in next
	if(!carbon_parent.Move(next, slide_dir))
		return
	if(next_stairs?.dir == stairs_dir)
		addtimer(CALLBACK(src, PROC_REF(slide_step), slide_dir, stairs_dir, steps_left - 1), 1)
	else
		playsound(next, "bodyfall", 50, TRUE, -1)
