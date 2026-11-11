// Taktyka boarderów KNPC (Syndykat, piraci, zombie, ERT i inni ai_boarder).
// Hooki w core: nsv13/code/modules/overmap/knpc.dm (pick_target, tactical_move, try_throw_grenade,
// backup_candidates, path_access_card) i KNPC_MAX_BACKUP_RESPONDERS w nsv13/code/__DEFINES/knpc.dm.

/// Strzelec trzyma się co najmniej tylu pól od celu
#define KNPC_RANGE_MIN 3
/// Dalej niż tyle pól strzelec podchodzi do celu
#define KNPC_RANGE_MAX 6
/// Jak długo boarder pamięta, kto do niego strzelał
#define KNPC_SHOOTER_MEMORY (15 SECONDS)
/// Przerwa między granatami jednego boardera
#define KNPC_GRENADE_COOLDOWN (20 SECONDS)
/// Zapalnik granatu rzuconego przez KNPC (gracz ma 5 s, boarder trzyma chwilę w ręku)
#define KNPC_GRENADE_FUSE (3 SECONDS)
/// Tak daleko od uzbrojonego granatu boarder nie podchodzi do leżącego i nie rzuca drugiego (odłamki sięgają 4 pól)
#define KNPC_GRENADE_DANGER_RANGE 4
/// Szansa, że boarder Syndykatu albo pirat ma dodatkowo granat odłamkowy
#define KNPC_FRAG_CHANCE 10
/// Czas hakowania panelu drzwi
#define KNPC_HACK_TIME (10 SECONDS)
/// Przerwa między uderzeniami w drzwi
#define KNPC_BASH_DELAY (1.5 SECONDS)
/// Obrażenia uderzenia w drzwi ponad próg odporności drzwi (damage_deflection)
#define KNPC_BASH_DAMAGE 10
/// Poniżej tej części zdrowia boarder z medipenem leczy się nawet w walce
#define KNPC_HEAL_IN_COMBAT_RATIO 0.35
/// Poniżej tej części zdrowia boarder bez medipena wycofuje się do kolegów
#define KNPC_FALL_BACK_RATIO 0.3
/// Od tej części zdrowia w dół medyk podchodzi do rannego kolegi
#define KNPC_HEAL_ALLY_RATIO 0.4
/// Jak daleko boarder szuka rannego kolegi albo kolegi, do którego się wycofa
#define KNPC_ALLY_RANGE 7
#define KNPC_FALL_BACK_RANGE 15

/datum/component/knpc
	/// Cel z poprzedniej akcji (weakref), żeby boarder nie przeskakiwał między celami co sekundę
	var/datum/weakref/current_target
	/// weakref strzelającego => world.time, do kiedy pamiętamy, że do nas strzelał
	var/list/recent_shooters
	/// Wynik get_aggressors() w bieżącym process() (check_score i action liczą to samo)
	var/list/aggressors_cache
	var/aggressors_cached_at = -1
	var/next_grenade = 0
	var/next_door_action = 0
	/// Trwa hakowanie drzwi
	var/hacking_door = FALSE
	/// Hakowane drzwi (weakref)
	var/datum/weakref/hack_target
	var/next_fall_back_shout = 0
	/// Karta ze wszystkimi dostępami stacji, tylko do planowania trasy boarderów wyłamujących drzwi
	var/static/obj/item/card/id/breach_card

/datum/component/knpc/Destroy(force, silent)
	current_target = null
	recent_shooters = null
	aggressors_cache = null
	return ..()

/datum/component/knpc/process()
	if(cuffing)
		return // do_mob przerywa każdy krok boardera: wybór celu, trasa i patrol czekają, aż skończy zakuwać
	. = ..()
	aggressors_cache = null // nie trzymamy referencji do mobów między tickami
	if(!istype(current_goal, /datum/ai_goal/human/engage_targets))
		cover_turf = null // po walce nie trzymamy osłony dla siebie
	expire_unreachable()

/// Zapomina nieosiągalne przedmioty i jeńców po minucie. W nsv13 robił to tylko cel acquire_weapon, którego uzbrojony boarder nie wybiera.
/datum/component/knpc/proc/expire_unreachable()
	if(unreachable_items && world.time >= unreachable_items_reset_at)
		unreachable_items = null

/datum/component/knpc/register_bullet(datum/source, obj/item/projectile/Proj)
	. = ..()
	if(!Proj.nodamage && isliving(Proj.firer))
		LAZYSET(recent_shooters, WEAKREF(Proj.firer), world.time + KNPC_SHOOTER_MEMORY)

/// Czy target strzelał do nas w ostatnich sekundach
/datum/component/knpc/proc/shot_us_recently(atom/target)
	if(!recent_shooters)
		return FALSE
	var/datum/weakref/ref = WEAKREF(target)
	return recent_shooters[ref] && recent_shooters[ref] > world.time

/// Wybiera cel: najbliższy, ale woli tego, kto do nas strzela, rannego i dotychczasowy cel; omija leżących i niewidocznych.
/datum/component/knpc/proc/pick_target(list/enemies)
	var/mob/living/carbon/human/H = parent
	var/atom/movable/old_target = current_target?.resolve()
	var/atom/movable/best = null
	var/best_score = INFINITY
	for(var/atom/movable/enemy as anything in enemies)
		if(QDELETED(enemy))
			continue
		var/score = get_dist(H, enemy)
		if(enemy == old_target)
			score -= 2
		if(shot_us_recently(enemy))
			score -= 3
		if(isliving(enemy))
			var/mob/living/L = enemy
			if(L.incapacitated())
				score += 3 // leżący nie strzela, najpierw ci, którzy mogą
			else if(L.health < L.maxHealth * 0.5)
				score -= 2
		if(!can_see(H, enemy, view_range))
			score += 4
		if(score < best_score)
			best_score = score
			best = enemy
	current_target = best ? WEAKREF(best) : null
	// Czyścimy przeterminowane wpisy, żeby lista nie rosła przez rundę
	for(var/datum/weakref/ref as anything in recent_shooters)
		if(recent_shooters[ref] <= world.time)
			LAZYREMOVE(recent_shooters, ref)
	return best

/// Ruch w walce: z bronią palną trzyma dystans KNPC_RANGE_MIN–KNPC_RANGE_MAX, bez niej (albo bez linii strzału) podchodzi.
/// Do obezwładnionego wroga podchodzi zawsze: kradzież ID, zakucie i dobijanie w engage_targets wymagają stania obok.
/datum/component/knpc/proc/tactical_move(atom/movable/target)
	var/mob/living/carbon/human/ai_boarder/H = parent
	var/obj/item/gun/G = H.get_active_held_item()
	var/mob/living/living_target = isliving(target) ? target : null
	if(!istype(G) || !G.can_shoot() || living_target?.incapacitated())
		cover_turf = null
		if(living_target?.incapacitated() && (get_dist(H, target) <= 1 || live_grenade_near(get_turf(target))))
			// Już stoimy przy leżącym. Trasa na jego pole kończyła się wejściem na nie, a potem nieudanym
			// szukaniem drogi do własnego pola, karą czasową i losowym błądzeniem.
			// Przy leżącym tyka granat kolegi: z bliska ogłusza mimo ochrony oczu i uszu, więc czekamy na wybuch.
			path = list()
			dest = null
			return
		return pathfind_to(target)
	if(try_take_cover(target)) // aquila/code/modules/knpc/knpc_cover_loot.dm
		return
	var/dist = get_dist(H, target)
	if(dist > KNPC_RANGE_MAX || !can_see(H, target, view_range))
		return pathfind_to(target)
	// Dobra pozycja do strzału: nie pchamy się dalej
	path = list()
	dest = null
	if(world.time < next_move || H.incapacitated() || !isturf(H.loc))
		return
	if(dist < KNPC_RANGE_MIN)
		if(tactical_step(get_step_away(H, target), target))
			return
	if(CHECK_BITFIELD(H.knpc_traits, KNPC_IS_DODGER) && prob(40))
		tactical_step(get_step(H, turn(get_dir(H, target), pick(90, -90))), target)

/// Krok na bezpieczne pole (nie w kosmos, przepaść ani ścianę), z twarzą do celu
/datum/component/knpc/proc/tactical_step(turf/T, atom/target)
	var/mob/living/carbon/human/ai_boarder/H = parent
	if(!T || T.density || isgroundlessturf(T))
		return FALSE
	next_move = world.time + H.move_delay
	if(!H.Move(T, get_dir(H, T)))
		return FALSE
	H.face_atom(target)
	return TRUE

/// Rzut granatem, gdy cel jest 3–7 pól dalej i go widać. Odłamkowy/wybuchowy najchętniej w grupę, tylko spoza jego zasięgu i nigdy, gdy w zasięgu są swoi;
/// hukowy tylko wtedy, gdy każdy swój w jego zasięgu (z rzucającym) ma ochronę oczu i uszu.
/datum/component/knpc/proc/try_throw_grenade(atom/movable/target, list/enemies)
	if(world.time < next_grenade)
		return FALSE
	var/mob/living/carbon/human/H = parent
	var/dist = get_dist(H, target)
	if(dist < 3 || dist > 7 || H.incapacitated() || !isturf(H.loc) || !can_see(H, target, view_range))
		return FALSE
	var/mob/living/living_target = isliving(target) ? target : null
	if(living_target?.incapacitated())
		return FALSE // leżący już nie walczy: szkoda granatu
	var/turf/target_turf = get_turf(target)
	if(!throw_path_clear(target_turf))
		return FALSE // granat zatrzymałby się po drodze, bliżej nas i kolegów
	if(live_grenade_near(target_turf))
		return FALSE // kolega już tam rzucił: drugi granat to strata, a po pierwszym wszyscy biegną do ogłuszonych
	var/enemies_near = 0
	for(var/atom/movable/enemy as anything in enemies)
		if(get_dist(enemy, target_turf) <= 2)
			enemies_near++
	var/obj/item/grenade/nade = null
	var/obj/item/grenade/frag = find_grenade(lethal = TRUE)
	if(frag)
		// Odłamki i ogień sięgają dalej niż sam wybuch: strefa to największy z promieni granatu
		var/blast_radius = max(frag.ex_light, frag.ex_flame, frag.shrapnel_radius, 1)
		if(dist > blast_radius && (enemies_near >= 2 || prob(30)) && !friendlies_near(target_turf, blast_radius))
			nade = frag
	if(!nade)
		var/obj/item/grenade/flashbang/flash = find_grenade(lethal = FALSE)
		if(flash && (enemies_near >= 2 || prob(50)) && flashbang_safe(flash, target_turf))
			nade = flash
	if(!nade)
		return FALSE
	next_grenade = world.time + KNPC_GRENADE_COOLDOWN
	if(isitem(nade.loc) && nade.loc != H)
		SEND_SIGNAL(nade.loc, COMSIG_TRY_STORAGE_TAKE, nade, H.drop_location(), TRUE)
	else if(!H.temporarilyRemoveItemFromInventory(nade))
		return FALSE
	nade.forceMove(H.drop_location())
	nade.preprime(H, KNPC_GRENADE_FUSE, FALSE)
	H.visible_message("<span class='danger'>[H] rzuca [nade]!</span>")
	if(istype(nade, /obj/item/grenade/flashbang))
		H.say(pick("Granat!", "Hukowy!", "Zamknąć oczy!"), forced = "knpc AI")
	else
		H.say(pick("Granat!", "Uwaga, granat!", "Odłamkowy!"), forced = "knpc AI")
	nade.throw_at(target_turf, 7, 1, H)
	return TRUE

/// Uzbrojony granat (nasz albo cudzy) w promieniu KNPC_GRENADE_DANGER_RANGE od T
/datum/component/knpc/proc/live_grenade_near(turf/T)
	if(!T)
		return FALSE
	for(var/obj/item/grenade/nade in range(KNPC_GRENADE_DANGER_RANGE, T))
		if(nade.active)
			return TRUE
	return FALSE

/// Czy rzucony przedmiot doleci do T: między nami a T nie ma ściany ani gęstego obiektu (przez stoły się przerzuca)
/datum/component/knpc/proc/throw_path_clear(turf/T)
	var/mob/living/H = parent
	var/list/line = getline(get_turf(H), T)
	for(var/i in 2 to length(line) - 1)
		var/turf/step = line[i]
		if(step.density)
			return FALSE
		for(var/atom/movable/AM in step)
			if(AM.density && !(AM.pass_flags_self & LETPASSTHROW))
				return FALSE
	return TRUE

/// Czy w promieniu range od T stoi ktoś żywy z naszej frakcji (z nami włącznie)
/datum/component/knpc/proc/friendlies_near(turf/T, range)
	var/mob/living/H = parent
	for(var/mob/living/L in range(range, T))
		if(L.stat != DEAD && H.faction_check_mob(L))
			return TRUE
	return FALSE

/// Hukowy w T nie ogłuszy nikogo swojego: każdy swój bliżej niż zasięg granatu ma ochronę oczu i uszu
/datum/component/knpc/proc/flashbang_safe(obj/item/grenade/flashbang/flash, turf/T)
	var/mob/living/H = parent
	for(var/mob/living/L in range(flash.flashbang_range - 1, T))
		if(L.stat == DEAD || !H.faction_check_mob(L))
			continue
		if(L.get_eye_protection() < 1 || L.get_ear_protection() < 1)
			return FALSE
	return TRUE

/// Przedmioty przy sobie i w plecaku (kopia: dopisanie do H.contents przeniosłoby przedmiot)
/datum/component/knpc/proc/carried_items()
	var/mob/living/carbon/human/H = parent
	. = H.contents.Copy()
	var/obj/item/storage/S = H.back
	if(S)
		. += S.contents

/// Granat noszony przy sobie lub w plecaku: lethal = wybuchowy/odłamkowy, inaczej hukowy
/datum/component/knpc/proc/find_grenade(lethal = TRUE)
	for(var/obj/item/grenade/nade in carried_items())
		if(nade.active || nade.dud_flags)
			continue
		if(lethal)
			if(nade.ex_dev || nade.ex_heavy || nade.ex_light || nade.shrapnel_type)
				return nade
		else if(istype(nade, /obj/item/grenade/flashbang))
			return nade

/// Medipen z zawartością noszony przy sobie lub w plecaku
/datum/component/knpc/proc/find_medipen()
	for(var/obj/item/reagent_containers/hypospray/medipen/survival/P in carried_items())
		if(P.reagents?.total_volume)
			return P

/// Inni boarderzy z tego samego Z, od najbliższego (wezwanie wsparcia)
/datum/component/knpc/proc/backup_candidates()
	var/mob/living/H = parent
	var/list/candidates = list()
	for(var/datum/component/knpc/other as anything in GLOB.knpcs)
		if(other == src || QDELETED(other) || QDELETED(other.parent))
			continue
		var/mob/living/other_mob = other.parent
		if(other_mob.z != H.z)
			continue
		candidates[other] = get_dist(H, other_mob)
	sortTim(candidates, GLOBAL_PROC_REF(cmp_numeric_asc), associative = TRUE)
	return candidates

/// Najbliższy żywy boarder z tej samej frakcji w promieniu range (bez nas); conscious_only pomija nieprzytomnych
/datum/component/knpc/proc/nearest_ally(range, max_health_ratio = INFINITY, conscious_only = FALSE)
	var/mob/living/carbon/human/H = parent
	var/mob/living/carbon/human/best = null
	var/best_dist = INFINITY
	for(var/datum/component/knpc/other as anything in GLOB.knpcs)
		if(other == src || QDELETED(other))
			continue
		var/mob/living/carbon/human/ally = other.parent
		if(QDELETED(ally) || ally.stat == DEAD || ally.z != H.z)
			continue
		if(conscious_only && ally.stat != CONSCIOUS)
			continue
		if(ally.health > ally.maxHealth * max_health_ratio)
			continue
		var/dist = get_dist(H, ally)
		if(dist > range || dist >= best_dist)
			continue
		if(!H.faction_check_mob(ally, TRUE))
			continue
		best = ally
		best_dist = dist
	return best

/// Karta do planowania trasy: wyłamujący drzwi liczą trasę przez śluzy, do których nie mają dostępu
/datum/component/knpc/proc/path_access_card()
	var/mob/living/carbon/human/H = parent
	if(istype(H, /mob/living/carbon/human/ai_boarder))
		var/mob/living/carbon/human/ai_boarder/boarder = H
		if(boarder.knpc_traits & (KNPC_IS_DOOR_BASHER | KNPC_IS_DOOR_HACKER))
			if(!breach_card)
				breach_card = new /obj/item/card/id/knpc_breach
				breach_card.access = get_all_accesses()
			return breach_card
	return H.wear_id

/// Karta, którą planują trasę boarderzy wyłamujący drzwi (nigdy nie trafia do świata)
/obj/item/card/id/knpc_breach
	name = "karta wyłamania drzwi (KNPC)"

// Zaryglowana albo pozbawiona zasilania śluza blokowała wyszukiwanie trasy nawet z kartą wszystkich dostępów,
// więc haker i wyważacz omijali dokładnie te drzwi, które handle_blocking_door() umie otworzyć.
/obj/machinery/door/airlock/CanAStarPass(obj/item/card/id/ID, to_dir, atom/movable/caller)
	if(istype(ID, /obj/item/card/id/knpc_breach))
		return TRUE
	return ..()

/datum/component/knpc/next_path_step()
	if(handle_blocking_door())
		return FALSE
	return ..()

/// Drzwi na następnym polu trasy, których nie otworzymy normalnie: hakowanie albo wyważanie.
/// Zwraca TRUE, gdy boarder zajmuje się drzwiami i nie powinien iść dalej.
/datum/component/knpc/proc/handle_blocking_door()
	if(!length(path))
		if(hacking_door)
			cancel_door_hack() // trasa się zmieniła (walka, odwrót): nie stoimy przy drzwiach
		return FALSE
	var/mob/living/carbon/human/ai_boarder/H = parent
	if(!istype(H) || !(H.knpc_traits & (KNPC_IS_DOOR_BASHER | KNPC_IS_DOOR_HACKER)) || H.incapacitated() || !isturf(H.loc))
		return FALSE
	var/turf/next_turf = get_step_towards(H, path[1])
	if(!next_turf || next_turf == H.loc)
		if(hacking_door)
			cancel_door_hack()
		return FALSE
	var/obj/machinery/door/D = null
	for(var/obj/machinery/door/candidate in next_turf)
		if(!(istype(candidate, /obj/machinery/door/airlock) || istype(candidate, /obj/machinery/door/window)) || !candidate.density) // bez grodzi, rolet i firelocków
			continue
		D = candidate
		break
	if(hacking_door)
		if(D && hack_target?.resolve() == D)
			return TRUE // dalej hakujemy drzwi, przez które idzie trasa
		cancel_door_hack()
	if(!D)
		return FALSE
	if(!D.welded && !D.locked && D.hasPower() && D.allowed(H))
		return FALSE // otworzy się samo przy wejściu
	// 2. Przerwa między uderzeniami: czekamy przy drzwiach, zamiast oddawać ruch core (wchodził w drzwi i nabijał tries)
	if(world.time < next_door_action)
		return TRUE
	H.face_atom(D)
	if((H.knpc_traits & KNPC_IS_DOOR_HACKER) && !D.welded)
		hacking_door = TRUE
		hack_target = WEAKREF(D)
		H.visible_message("<span class='warning'>[H] zdejmuje osłonę panelu [D] i zaczyna przy nim majstrować!</span>")
		playsound(D, 'sound/items/screwdriver.ogg', 50, TRUE)
		addtimer(CALLBACK(src, PROC_REF(finish_door_hack), WEAKREF(D)), KNPC_HACK_TIME)
		return TRUE
	next_door_action = world.time + KNPC_BASH_DELAY
	var/obj/item/held = H.get_active_held_item()
	var/damage = KNPC_BASH_DAMAGE + max(0, held?.force - KNPC_BASH_DAMAGE)
	H.do_attack_animation(D)
	playsound(D, 'sound/effects/bang.ogg', 50, TRUE)
	D.take_damage(damage + D.damage_deflection, BRUTE, MELEE, TRUE, get_dir(D, H))
	if(!QDELETED(D) && D.density && D.obj_integrity <= D.max_integrity * 0.5 && D.open(2))
		H.visible_message("<span class='danger'>[H] wyważa [D]!</span>")
	return TRUE

/// Przerywa hakowanie: timer finish_door_hack() potem nic nie zrobi
/datum/component/knpc/proc/cancel_door_hack()
	hacking_door = FALSE
	hack_target = null

/datum/component/knpc/proc/finish_door_hack(datum/weakref/door_ref)
	if(!hacking_door || hack_target != door_ref)
		return // przerwane albo to stary timer
	cancel_door_hack()
	var/mob/living/carbon/human/H = parent
	var/obj/machinery/door/D = door_ref?.resolve()
	if(!D || QDELETED(H) || H.incapacitated() || get_dist(H, D) > 1 || !D.density || D.welded)
		return
	if(istype(D, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = D
		if(A.locked)
			A.unbolt()
	if(D.open(2))
		H.visible_message("<span class='warning'>[H] otwiera [D] zwarciem w panelu!</span>")
		do_sparks(3, TRUE, D)

// Syndykat hakuje drzwi, piraci je wyważają (zombie mają to od zawsze w nsv13).
// Oba dostają granat hukowy, a z małą szansą też odłamkowy.
/mob/living/carbon/human/ai_boarder/syndicate/Initialize(mapload)
	. = ..()
	knpc_traits |= KNPC_IS_DOOR_HACKER
	// Słuchawki bowman chronią uszy, zaawansowane okulary (zwykłe nie chronią przed błyskiem) oczy: hukowy rzucony przez kolegę nie ogłusza Syndykatu
	if(!glasses)
		equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/advanced(src), ITEM_SLOT_EYES)
	give_knpc_gear()

/mob/living/carbon/human/ai_boarder/space_pirate/Initialize(mapload)
	. = ..()
	knpc_traits |= KNPC_IS_DOOR_BASHER
	give_knpc_gear()

/// Granat hukowy, z szansą KNPC_FRAG_CHANCE odłamkowy i dwie opaski zaciskowe do plecaka (bez plecaka do kieszeni, jeśli wolna)
/mob/living/carbon/human/ai_boarder/proc/give_knpc_gear()
	var/list/grenades = list(/obj/item/grenade/flashbang, /obj/item/restraints/handcuffs/cable/zipties, /obj/item/restraints/handcuffs/cable/zipties)
	if(prob(KNPC_FRAG_CHANCE))
		grenades += /obj/item/grenade/frag
	for(var/grenade_type in grenades)
		if(back)
			new grenade_type(back)
		else
			var/obj/item/grenade/nade = new grenade_type(src)
			if(!equip_to_slot_if_possible(nade, ITEM_SLOT_LPOCKET, disable_warning = TRUE) && !equip_to_slot_if_possible(nade, ITEM_SLOT_RPOCKET, disable_warning = TRUE))
				qdel(nade)

// Przy krytycznym zdrowiu medipen idzie przed walką
/datum/ai_goal/human/heal_self/check_score(datum/component/knpc/HA)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/H = HA.parent
	if(H.health <= H.maxHealth * KNPC_HEAL_IN_COMBAT_RATIO)
		return AI_SCORE_SUPERPRIORITY + 10

// check_score i action w jednym process() liczą tych samych wrogów: drugi raz z pamięci
/datum/ai_goal/get_aggressors(datum/component/knpc/HA)
	if(istype(HA) && HA.aggressors_cache && HA.aggressors_cached_at == world.time)
		return HA.aggressors_cache.Copy()
	var/list/found = ..()
	if(istype(HA))
		HA.aggressors_cache = found?.Copy()
		HA.aggressors_cached_at = world.time
	return found

// Nie strzelamy w ścianę do kogoś, kogo tylko „pamiętamy” zza rogu
/datum/ai_goal/human/CheckFriendlyFire(mob/living/us, mob/living/them)
	. = ..()
	if(!. && !can_see(us, them, get_dist(us, them) + 1))
		return TRUE

/// Ciężko ranny boarder bez medipena wycofuje się do najbliższego kolegi zamiast walczyć sam
/datum/ai_goal/human/fall_back
	name = "Fall back"
	score = AI_SCORE_SUPERPRIORITY + 5
	required_ai_flags = null

/datum/ai_goal/human/fall_back/check_score(datum/component/knpc/HA)
	if(!..())
		return 0
	var/mob/living/carbon/human/H = HA.parent
	if(H.health > H.maxHealth * KNPC_FALL_BACK_RATIO || H.incapacitated() || HA.find_medipen())
		return 0
	if(!length(get_aggressors(HA)))
		return 0
	var/mob/living/carbon/human/ally = HA.nearest_ally(KNPC_FALL_BACK_RANGE, conscious_only = TRUE)
	if(!ally || get_dist(H, ally) <= 2)
		return 0 // nie ma do kogo albo już jesteśmy przy swoich: walczymy razem
	return score

/datum/ai_goal/human/fall_back/action(datum/component/knpc/HA)
	if(!can_action(HA))
		return
	var/mob/living/carbon/human/H = HA.parent
	var/mob/living/carbon/human/ally = HA.nearest_ally(KNPC_FALL_BACK_RANGE, conscious_only = TRUE)
	if(!ally)
		return
	if(world.time >= HA.next_fall_back_shout)
		HA.next_fall_back_shout = world.time + 20 SECONDS
		H.say(pick("Jestem ranny, wycofuję się!", "Dostałem! Osłaniajcie mnie!", "Cofam się!"), forced = "knpc AI")
	HA.pathfind_to(ally)

/// Boarder z medipenem leczy ciężko rannego kolegę obok (rannego w krytycznym stanie też)
/datum/ai_goal/human/heal_ally
	name = "Heal ally"
	score = AI_SCORE_SUPERPRIORITY + 2
	required_ai_flags = null

/datum/ai_goal/human/heal_ally/check_score(datum/component/knpc/HA)
	if(!..())
		return 0
	var/mob/living/carbon/human/H = HA.parent
	if(H.incapacitated() || !HA.find_medipen())
		return 0
	var/mob/living/carbon/human/ally = HA.nearest_ally(KNPC_ALLY_RANGE, KNPC_HEAL_ALLY_RATIO)
	if(!ally)
		return 0
	// Przytomny kolega z własnym medipenem poradzi sobie sam
	if(ally.stat == CONSCIOUS)
		var/datum/component/knpc/ally_ai = ally.GetComponent(/datum/component/knpc)
		if(ally_ai?.find_medipen())
			return 0
	// Wróg tuż obok: najpierw walka
	for(var/atom/movable/enemy as anything in get_aggressors(HA))
		if(get_dist(H, enemy) <= 2)
			return 0
	return score

/datum/ai_goal/human/heal_ally/action(datum/component/knpc/HA)
	if(!can_action(HA))
		return
	var/mob/living/carbon/human/H = HA.parent
	var/mob/living/carbon/human/ally = HA.nearest_ally(KNPC_ALLY_RANGE, KNPC_HEAL_ALLY_RATIO)
	var/obj/item/reagent_containers/hypospray/medipen/survival/P = HA.find_medipen()
	if(!ally || !P)
		return
	if(get_dist(H, ally) > 1)
		HA.pathfind_to(ally)
		return
	H.say(pick("Trzymaj się!", "Medyk! Mam cię!", "Nie umieraj mi tu!"), forced = "knpc AI")
	P.attack(ally, H)
	if(P.loc == H)
		H.dropItemToGround(P)
	else if(isitem(P.loc))
		SEND_SIGNAL(P.loc, COMSIG_TRY_STORAGE_TAKE, P, H.drop_location(), TRUE)

#undef KNPC_RANGE_MIN
#undef KNPC_RANGE_MAX
#undef KNPC_SHOOTER_MEMORY
#undef KNPC_GRENADE_COOLDOWN
#undef KNPC_GRENADE_FUSE
#undef KNPC_GRENADE_DANGER_RANGE
#undef KNPC_FRAG_CHANCE
#undef KNPC_HACK_TIME
#undef KNPC_BASH_DELAY
#undef KNPC_BASH_DAMAGE
#undef KNPC_HEAL_IN_COMBAT_RATIO
#undef KNPC_FALL_BACK_RATIO
#undef KNPC_HEAL_ALLY_RATIO
#undef KNPC_ALLY_RANGE
#undef KNPC_FALL_BACK_RANGE
