// AQUILA - Symulacja walk boarderów KNPC: arena budowana w kodzie, prawdziwe AI (SSfastprocess), zapis przebiegu co 0,5 s.
// Długa (kilkanaście minut), więc nie chodzi w CI. Lokalnie: dm.exe -DCBT -DUNIT_TESTS -DKNPC_SIM nsv13.dme, potem Dream Daemon z -trusted,
// opcjonalnie z -params "knpc_sim=<grupa>" (zakucie, drzwi, walki1, walki3), żeby puścić tylko jedną grupę scenariuszy.
// Z KNPC_SIM uruchamia się tylko ten test (focus). W [GLOB.log_directory]: knpc_sim*.log (przebieg tekstem), knpc_sim*.csv (wyniki)
// i knpc_sim*.json (klatki dla odtwarzacza).
// Scenariusze z kryterium (zakucie, drzwi) failują test; walki i szyba tylko zapisują wynik do oceny.
#ifdef KNPC_SIM

/// Lewy dolny róg areny na poziomie testów (szablon testów stoi na środku poziomu)
#define KNPC_SIM_X 10
#define KNPC_SIM_Y 10
/// Rozmiar areny razem ze ścianami
#define KNPC_SIM_W 32
#define KNPC_SIM_H 17
/// Co ile zapisujemy klatkę
#define KNPC_SIM_FRAME (0.5 SECONDS)
/// Ile sekund bez ruchu, strzału i zmiany celu liczymy jako zastój
#define KNPC_SIM_STALL 8

GLOBAL_DATUM(knpc_sim, /datum/unit_test/aquila_knpc_sim)

/// Obszar areny: z grawitacją (w pokoju testowym jej nie ma, a dryf przerywał do_mob i rozrzucał boarderów) i bez prądu, więc oświetlony
/area/testroom/knpc_sim
	name = "Arena symulacji KNPC"
	has_gravity = STANDARD_GRAVITY

/mob/living/carbon/human/ai_boarder/syndicate/smg/knpc_sim
	difficulty_override = TRUE

/mob/living/carbon/human/ai_boarder/syndicate/pistol/knpc_sim
	difficulty_override = TRUE

/mob/living/carbon/human/ai_boarder/space_pirate/pistol/knpc_sim
	difficulty_override = TRUE

/mob/living/carbon/human/ai_boarder/ert/knpc_sim
	difficulty_override = TRUE

/obj/item/gun/shoot_live_shot(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
	. = ..()
	GLOB.knpc_sim?.on_shot(user)

// Ogłuszenie przez granat sprawdzamy wprost: stan każdego boardera Syndykatu tuż przed i tuż po wybuchu hukowego
/obj/item/grenade/flashbang/prime(mob/living/lanced_by)
	var/list/before = GLOB.knpc_sim?.syndicate_stun_levels()
	. = ..()
	GLOB.knpc_sim?.check_grenade_stuns(before)

/// Dane jednego uczestnika symulacji
/datum/knpc_sim_track
	var/id
	var/mob/living/carbon/human/mob
	var/label
	var/team
	var/turf/last_turf
	var/turf/prev_turf
	/// Klatki z rzędu bez ruchu, strzału i zakuwania
	var/idle = 0
	var/max_idle = 0
	var/oscillations = 0
	var/goal_switches = 0
	var/last_goal
	var/shots = 0
	var/shots_this_frame = 0
	var/hits_taken = 0
	var/friendly_hits_dealt = 0
	var/died_at
	// Zachowania z aq33/AquilaStation#609
	var/grenades = 0
	var/heals_self = 0
	var/falls_back = 0
	var/heals_ally = 0
	var/backup_calls = 0
	var/backup_responses = 0
	/// Strzały do celu, którego boarder nie widzi (miały zniknąć)
	var/blind_shots = 0
	/// Klatki walki z bronią palną przeciw stojącemu celowi: razem, w dystansie 3–6, bliżej niż 3, w osłonie
	var/armed_frames = 0
	var/band_frames = 0
	var/close_frames = 0
	var/cover_frames = 0
	var/target_switches = 0
	var/last_target

/datum/knpc_sim_track/Destroy(force)
	mob = null
	last_turf = null
	prev_turf = null
	last_target = null
	return ..()

/// Zachowania z AQ#609 do logu (tylko te, które wystąpiły)
/datum/knpc_sim_track/proc/tactics_text()
	var/list/parts = list()
	if(armed_frames)
		parts += "dystans 3–6: [round(100 * band_frames / armed_frames)]% walki z bronią, bliżej niż 3: [round(100 * close_frames / armed_frames)]%, w osłonie: [round(100 * cover_frames / armed_frames)]%"
	if(target_switches)
		parts += "zmiany wroga [target_switches]"
	if(grenades)
		parts += "granaty [grenades]"
	if(heals_self)
		parts += "medipen [heals_self]"
	if(falls_back)
		parts += "odwrót [falls_back]"
	if(heals_ally)
		parts += "leczy kolegę [heals_ally]"
	if(backup_calls)
		parts += "wzywa wsparcie [backup_calls]"
	if(backup_responses)
		parts += "odpowiada na wezwanie [backup_responses]"
	if(blind_shots)
		parts += "STRZAŁY NA ŚLEPO [blind_shots]"
	return parts.Join(", ")

/datum/unit_test/aquila_knpc_sim
	focus = TRUE
	var/sim_z
	var/area/arena_area
	var/list/arena_turfs = list()
	/// mob => /datum/knpc_sim_track
	var/list/tracks = list()
	var/scenario
	var/scenario_run
	var/scenario_start
	var/log_path
	var/csv_path
	var/json_path
	var/cuff_attempts = 0
	var/list/patrol_nodes = list()
	/// Obiekty o zmiennym stanie (drzwi, okna, worki): list(obiekt, rodzaj, x, y)
	var/list/sim_objects = list()
	/// Bieżący scenariusz do JSON
	var/list/frames
	var/list/events
	/// Wszystkie zakończone scenariusze
	var/list/all_scenarios = list()
	/// Czy któryś boarder Syndykatu dostał ogłuszenie od wybuchu hukowego (porównanie przed i po prime())
	var/ally_stunned = FALSE
	/// Kto z boarderów leży teraz (mob => TRUE): wpis w logu tylko przy przewróceniu, każdy osobno
	var/list/allies_down = list()
	/// Kiedy padł ostatni okrzyk „Granat!” (zapalnik KNPC to 3 s)
	var/last_grenade_at = 0

/datum/unit_test/aquila_knpc_sim/Run()
	GLOB.knpc_sim = src
	sim_z = run_loc_floor_bottom_left.z
	arena_area = GLOB.areas_by_type[/area/testroom/knpc_sim] || new /area/testroom/knpc_sim
	// Grupa scenariuszy z parametru serwera (-params "knpc_sim=walki1"), bez niego wszystkie. Na 516 serwer potrafi paść
	// po kilku minutach (rust_g.dll_unloaded, niezależnie od symulacji), więc grupy da się puszczać osobno.
	var/group = world.params["knpc_sim"]
	var/static/list/groups = list("zakucie", "drzwi", "taktyka", "walki1", "walki3")
	if(group && !(group in groups))
		GLOB.knpc_sim = null
		return Fail("Nieznana grupa scenariuszy knpc_sim=[group], dostępne: [groups.Join(", ")]")
	var/suffix = group ? "_[group]" : ""
	log_path = "[GLOB.log_directory]/knpc_sim[suffix].log"
	csv_path = "[GLOB.log_directory]/knpc_sim[suffix].csv"
	json_path = "[GLOB.log_directory]/knpc_sim[suffix].json"
	fdel(log_path)
	fdel(csv_path)
	text2file("scenariusz;przebieg;wynik;czas_s;szczegoly", csv_path)
	// Twarde usunięcie czegoś z rundy (np. komponentu czatu drużyny) odpala w buildzie testowym wyszukiwanie
	// referencji bez CHECK_TICK, które w długiej symulacji kończyło się zniknięciem serwera. GC wraca po symulacji.
	var/gc_could_fire = SSgarbage.can_fire
	SSgarbage.can_fire = FALSE

	if(!group || group == "zakucie")
		scenario_cuff(/mob/living/carbon/human/ai_boarder/syndicate/smg/knpc_sim, 1, FALSE, "zakucie_ogluszonego_smg")
		scenario_cuff(/mob/living/carbon/human/ai_boarder/syndicate/pistol/knpc_sim, 1, FALSE, "zakucie_ogluszonego_pistolet")
		scenario_cuff(/mob/living/carbon/human/ai_boarder/syndicate/smg/knpc_sim, 2, FALSE, "zakucie_ogluszonego_dwoch")
		scenario_cuff(/mob/living/carbon/human/ai_boarder/syndicate/smg/knpc_sim, 1, TRUE, "zakucie_nieprzytomnego")
	if(!group || group == "drzwi")
		scenario_door(/mob/living/carbon/human/ai_boarder/syndicate/smg/knpc_sim, "drzwi_hakowanie")
		scenario_door(/mob/living/carbon/human/ai_boarder/space_pirate/pistol/knpc_sim, "drzwi_wywazanie")
		scenario_window()
	if(!group || group == "taktyka")
		scenario_heal_in_combat()
		scenario_fall_back()
		scenario_medic()
		scenario_backup()
		scenario_grenade()
	if(!group || group == "walki1")
		for(var/i in 1 to 3)
			scenario_fight(1, i, "walka_1v1")
	if(!group || group == "walki3")
		for(var/i in 1 to 3)
			scenario_fight(3, i, "walka_3v3_oslony", TRUE)

	GLOB.knpc_sim = null
	restore_space()
	SSgarbage.can_fire = gc_could_fire

// ---------- Arena ----------

/datum/unit_test/aquila_knpc_sim/proc/arena_turf(rx, ry)
	return locate(KNPC_SIM_X + rx, KNPC_SIM_Y + ry, sim_z)

/// Ściany na obwodzie, w środku podłoga z własnym powietrzem
/datum/unit_test/aquila_knpc_sim/proc/build_arena()
	arena_turfs = list()
	var/list/floors = list()
	for(var/turf/T as anything in block(locate(KNPC_SIM_X, KNPC_SIM_Y, sim_z), locate(KNPC_SIM_X + KNPC_SIM_W - 1, KNPC_SIM_Y + KNPC_SIM_H - 1, sim_z)))
		var/edge = (T.x == KNPC_SIM_X || T.y == KNPC_SIM_Y || T.x == KNPC_SIM_X + KNPC_SIM_W - 1 || T.y == KNPC_SIM_Y + KNPC_SIM_H - 1)
		if(edge)
			T = T.ChangeTurf(/turf/closed/wall/r_wall, flags = CHANGETURF_IGNORE_AIR)
		else
			floors += T
		arena_turfs += T
	for(var/turf/T as anything in floors)
		T.ChangeTurf(/turf/open/floor/plasteel, flags = CHANGETURF_IGNORE_AIR)
	for(var/turf/T as anything in arena_turfs)
		var/area/old_area = T.loc
		if(old_area != arena_area)
			arena_area.contents += T
			T.change_area(old_area, arena_area)
	// Punkty patrolowe jak na statku: AI wraca do patrolu, gdy nie ma celu (to też potrafi przerwać zakuwanie)
	patrol_nodes = list()
	var/list/spots = list(list(3, 3), list(KNPC_SIM_W - 4, 3), list(KNPC_SIM_W - 4, KNPC_SIM_H - 4), list(3, KNPC_SIM_H - 4))
	for(var/list/spot as anything in spots)
		patrol_nodes += new /obj/effect/landmark/patrol_node(arena_turf(spot[1], spot[2]))
	for(var/i in 1 to length(patrol_nodes))
		var/obj/effect/landmark/patrol_node/node = patrol_nodes[i]
		node.next_nodes = list(patrol_nodes[(i % length(patrol_nodes)) + 1])

/// Ściana wewnątrz areny (zapisana w JSON jako przeszkoda)
/datum/unit_test/aquila_knpc_sim/proc/add_wall(rx, ry)
	var/turf/T = arena_turf(rx, ry)
	T.ChangeTurf(/turf/closed/wall/r_wall, flags = CHANGETURF_IGNORE_AIR)
	sim_objects += list(list(null, "wall", rx, ry))

/datum/unit_test/aquila_knpc_sim/proc/add_object(type, rx, ry, kind)
	var/obj/O = new type(arena_turf(rx, ry))
	sim_objects += list(list(O, kind, rx, ry))
	return O

/// Usuwa wszystko z areny i przywraca podłogę (ściany wewnętrzne, okna, drzwi)
/datum/unit_test/aquila_knpc_sim/proc/clear_arena()
	for(var/mob/M as anything in tracks)
		UnregisterSignal(M, list(COMSIG_ATOM_BULLET_ACT, COMSIG_MOB_STATCHANGE, COMSIG_MOB_SAY, COMSIG_CARBON_CUFF_ATTEMPTED, COMSIG_MOVABLE_MOVED))
		qdel(tracks[M])
	tracks = list()
	sim_objects = list()
	allies_down = list()
	for(var/turf/T as anything in arena_turfs)
		for(var/atom/movable/AM as anything in T.contents)
			if(ismob(AM) || isobj(AM))
				qdel(AM)
	patrol_nodes = list()
	sleep(1 SECONDS)

/// Po symulacji poziom testów wraca do kosmosu
/datum/unit_test/aquila_knpc_sim/proc/restore_space()
	for(var/turf/T as anything in arena_turfs)
		for(var/atom/movable/AM as anything in T.contents)
			if(ismob(AM) || isobj(AM))
				qdel(AM)
		T.ChangeTurf(/turf/open/space)

// ---------- Uczestnicy i zdarzenia ----------

/datum/unit_test/aquila_knpc_sim/proc/add_mob(type, rx, ry, team, label)
	var/mob/living/carbon/human/H = new type(arena_turf(rx, ry))
	var/datum/knpc_sim_track/track = new
	track.id = length(tracks) + 1
	track.mob = H
	track.label = label
	track.team = team
	track.last_turf = get_turf(H)
	tracks[H] = track
	RegisterSignal(H, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_bullet))
	RegisterSignal(H, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat))
	RegisterSignal(H, COMSIG_MOB_SAY, PROC_REF(on_say))
	RegisterSignal(H, COMSIG_CARBON_CUFF_ATTEMPTED, PROC_REF(on_cuff_attempt))
	RegisterSignal(H, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	return H

/// Etykieta uczestnika albo nazwa obcego atomu
/datum/unit_test/aquila_knpc_sim/proc/label_of(atom/A)
	var/datum/knpc_sim_track/track = tracks[A]
	return track ? track.label : "[A]"

/datum/unit_test/aquila_knpc_sim/proc/id_of(atom/A)
	var/datum/knpc_sim_track/track = tracks[A]
	return track ? track.id : 0

/datum/unit_test/aquila_knpc_sim/proc/on_shot(mob/living/user)
	var/datum/knpc_sim_track/track = tracks[user]
	if(!track)
		return
	track.shots++
	track.shots_this_frame++
	var/datum/component/knpc/ai = user.GetComponent(/datum/component/knpc)
	var/atom/target = ai?.current_target?.resolve()
	add_event("shot", null, track.id, id_of(target))
	if(target && !can_see(user, target, get_dist(user, target) + 1))
		track.blind_shots++
		sim_log("STRZAŁ NA ŚLEPO: [track.label] strzela do [label_of(target)], którego nie widzi", "stall")

/datum/unit_test/aquila_knpc_sim/proc/on_bullet(mob/living/source, obj/item/projectile/P)
	SIGNAL_HANDLER
	var/datum/knpc_sim_track/victim = tracks[source]
	victim.hits_taken++
	var/datum/knpc_sim_track/shooter = tracks[P.firer]
	var/friendly = shooter && shooter != victim && shooter.team == victim.team
	add_event(friendly ? "ff" : "hit", null, shooter?.id || 0, victim.id)
	if(friendly)
		shooter.friendly_hits_dealt++
		sim_log("BRATOBÓJCZY OGIEŃ: [shooter.label] trafia [victim.label]", "ff")

/datum/unit_test/aquila_knpc_sim/proc/on_stat(mob/living/source, new_stat)
	SIGNAL_HANDLER
	var/datum/knpc_sim_track/track = tracks[source]
	var/static/list/stat_names = list("przytomny", "nieprzytomny (miękki krytyk)", "nieprzytomny", "martwy")
	sim_log("[track.label]: stan [stat_names[new_stat + 1]] (HP [round(source.health)])", "stat")
	if(new_stat == DEAD && !track.died_at)
		track.died_at = elapsed()

/datum/unit_test/aquila_knpc_sim/proc/on_say(mob/living/source, list/speech_args)
	SIGNAL_HANDLER
	var/message = speech_args[SPEECH_MESSAGE]
	sim_log("[label_of(source)] mówi: \"[message]\"", "say")
	var/datum/knpc_sim_track/track = tracks[source]
	var/mob/living/carbon/human/ai_boarder/boarder = source
	if(!track || !istype(boarder))
		return
	// Okrzyki z knpc_tactics.dm i knpc.dm: tak liczymy zachowania bez hooków w kodzie AI
	var/static/list/grenade_lines = list("Granat!", "Hukowy!", "Zamknąć oczy!", "Uwaga, granat!", "Odłamkowy!")
	var/static/list/heal_ally_lines = list("Trzymaj się!", "Medyk! Mam cię!", "Nie umieraj mi tu!")
	if(message in grenade_lines)
		track.grenades++
		last_grenade_at = elapsed()
	else if(message in heal_ally_lines)
		track.heals_ally++
	for(var/line in boarder.response_lines)
		if(findtext(message, line))
			track.backup_responses++
			return
	for(var/line in boarder.call_lines)
		if(findtext(message, line))
			track.backup_calls++
			return

/datum/unit_test/aquila_knpc_sim/proc/on_cuff_attempt(mob/living/source, mob/attemptee)
	SIGNAL_HANDLER
	cuff_attempts++
	sim_log("[label_of(attemptee)] zaczyna zakuwać [label_of(source)]", "cuff")

/// Ruch w trakcie zakuwania przerywa do_mob. W walce bywa normalny (wróg pchnął), więc tylko zapis w logu;
/// przy szukaniu przyczyny można tu dopisać stack_trace(), żeby zobaczyć stos wywołań w runtime.log.
/datum/unit_test/aquila_knpc_sim/proc/on_moved(mob/living/source, atom/old_loc, dir)
	SIGNAL_HANDLER
	var/datum/component/knpc/ai = source.GetComponent(/datum/component/knpc)
	if(!ai?.cuffing)
		return
	sim_log("RUCH W TRAKCIE ZAKUWANIA: [label_of(source)] ([dir2text(dir)])", "stall")

// ---------- Przebieg ----------

/datum/unit_test/aquila_knpc_sim/proc/elapsed()
	return round((world.time - scenario_start) / 10, 0.1)

/datum/unit_test/aquila_knpc_sim/proc/add_event(kind, text, from_id = 0, to_id = 0)
	events += list(list("t" = elapsed(), "k" = kind, "x" = text, "a" = from_id, "b" = to_id))

/// Zdarzenie do logu tekstowego i do odtwarzacza
/datum/unit_test/aquila_knpc_sim/proc/sim_log(text, kind = "info")
	text2file("\[[elapsed()]s\] [text]", log_path)
	add_event(kind, text)

/datum/unit_test/aquila_knpc_sim/proc/begin(name, run = 1)
	scenario = name
	scenario_run = run
	cuff_attempts = 0
	frames = list()
	events = list()
	build_arena()
	scenario_start = world.time
	text2file("\n===== [name] #[run] =====", log_path)

/// Klatka: stan wszystkich uczestników i obiektów; tekstowo co sekundę. Liczy też zastoje.
/datum/unit_test/aquila_knpc_sim/proc/snapshot(write_text)
	var/list/mob_states = list()
	for(var/mob/living/carbon/human/H as anything in tracks)
		var/datum/knpc_sim_track/track = tracks[H]
		if(QDELETED(H))
			mob_states += list(list(track.id, -1, -1, 0, DEAD, "", 0, 0, 0, 0))
			continue
		var/datum/component/knpc/ai = H.GetComponent(/datum/component/knpc)
		var/turf/here = get_turf(H)
		var/moved = here != track.last_turf
		if(moved)
			if(here == track.prev_turf)
				track.oscillations++
			track.prev_turf = track.last_turf
			track.last_turf = here
		var/goal = ai?.current_goal?.name || ""
		var/atom/target = ai?.current_target?.resolve()
		mob_states += list(list(track.id, here.x - KNPC_SIM_X, here.y - KNPC_SIM_Y, round(H.health), H.stat, goal, id_of(target), track.shots_this_frame, ai?.cuffing ? 1 : 0, H.handcuffed ? 1 : 0))
		if(!ai || H.stat != CONSCIOUS)
			track.shots_this_frame = 0
			continue
		if(goal != track.last_goal)
			track.goal_switches++
			sim_log("[track.label]: cel AI [track.last_goal || "-"] -> [goal]", "goal")
			track.last_goal = goal
			if(goal == "Heal Self")
				track.heals_self++
			else if(goal == "Fall back")
				track.falls_back++
		// Dystans, osłona i przeskakiwanie między celami w walce z bronią palną przeciw stojącemu celowi
		var/mob/living/living_target = isliving(target) ? target : null
		if(goal == "Engage targets" && living_target && !living_target.incapacitated() && istype(H.get_active_held_item(), /obj/item/gun))
			track.armed_frames++
			var/dist = get_dist(H, living_target)
			if(dist >= 3 && dist <= 6)
				track.band_frames++
			else if(dist < 3)
				track.close_frames++
			if(ai.cover_turf && ai.cover_turf == here)
				track.cover_frames++
		if(goal == "Engage targets" && target && target != track.last_target)
			if(track.last_target)
				track.target_switches++
			track.last_target = target
		var/active = moved || track.shots_this_frame || ai.cuffing || ai.hacking_door
		track.idle = active ? 0 : track.idle + 1
		track.max_idle = max(track.max_idle, track.idle)
		if(track.idle * KNPC_SIM_FRAME == KNPC_SIM_STALL SECONDS)
			sim_log("ZASTÓJ: [track.label] od [KNPC_SIM_STALL] s stoi bez ruchu i strzału ([goal])", "stall")
		if(write_text)
			var/obj/item/held = H.get_active_held_item()
			text2file("  [elapsed()]s [track.label] ([here.x - KNPC_SIM_X],[here.y - KNPC_SIM_Y]) HP [round(H.health)] [goal] cel=[target ? "[label_of(target)]@[get_dist(H, target)]" : "-"] ręka=[held ? held.name : "-"] trasa=[length(ai.path)] timeout=[ai.pathfind_timeout] zakuwa=[ai.cuffing] strzały=[track.shots_this_frame]", log_path)
		track.shots_this_frame = 0
	var/list/object_states = list()
	for(var/list/entry as anything in sim_objects)
		var/obj/O = entry[1]
		if(entry[2] == "wall")
			object_states += 1
		else if(QDELETED(O))
			object_states += -1
		else
			object_states += O.density ? 1 : 0
	frames += list(list("t" = elapsed(), "m" = mob_states, "o" = object_states))

/// Czeka do spełnienia warunku albo limitu; zwraca czas w sekundach albo null przy limicie
/datum/unit_test/aquila_knpc_sim/proc/run_until(limit_seconds, datum/callback/done)
	var/frame_count = limit_seconds SECONDS / KNPC_SIM_FRAME
	for(var/frame in 1 to frame_count)
		sleep(KNPC_SIM_FRAME)
		snapshot(frame % 2 == 0)
		if(done.Invoke())
			return elapsed()
	return null

/datum/unit_test/aquila_knpc_sim/proc/finish(result, details)
	var/list/stats = list()
	var/list/mob_info = list()
	for(var/mob/living/carbon/human/H as anything in tracks)
		var/datum/knpc_sim_track/track = tracks[H]
		var/has_ai = !QDELETED(H) && H.GetComponent(/datum/component/knpc)
		mob_info += list(list("id" = track.id, "label" = track.label, "team" = track.team, "ai" = has_ai ? 1 : 0, "shots" = track.shots, "hits" = track.hits_taken, "ff" = track.friendly_hits_dealt, "idle" = track.max_idle * KNPC_SIM_FRAME / 10, "osc" = track.oscillations, "goals" = track.goal_switches, "died" = track.died_at || 0, \
			"armed" = track.armed_frames, "band" = track.band_frames, "close" = track.close_frames, "cover" = track.cover_frames, "switches" = track.target_switches, \
			"grenades" = track.grenades, "heals" = track.heals_self, "fallback" = track.falls_back, "medic" = track.heals_ally, "calls" = track.backup_calls, "responses" = track.backup_responses, "blind" = track.blind_shots))
		if(!has_ai)
			continue
		var/tactics = track.tactics_text()
		stats += "[track.label]: strzały [track.shots], trafiony [track.hits_taken], bratobójcze [track.friendly_hits_dealt], maks. zastój [track.max_idle * KNPC_SIM_FRAME / 10] s, wahadło [track.oscillations], zmiany celu AI [track.goal_switches][track.died_at ? ", zginął w [track.died_at] s" : ""][tactics ? ", [tactics]" : ""]"
	var/stat_text = stats.Join(" | ")
	sim_log("WYNIK: [result] [details] || [stat_text]", "result")
	text2file("[scenario];[scenario_run];[result];[elapsed()];[details] || [stat_text]", csv_path)
	var/list/objects = list()
	for(var/list/entry as anything in sim_objects)
		objects += list(list("k" = entry[2], "x" = entry[3], "y" = entry[4]))
	all_scenarios += list(list("name" = scenario, "run" = scenario_run, "result" = result, "details" = details, "duration" = elapsed(), "w" = KNPC_SIM_W, "h" = KNPC_SIM_H, "mobs" = mob_info, "objects" = objects, "frames" = frames, "events" = events))
	// Zapis po każdym scenariuszu: jeśli serwer padnie, zostają wcześniejsze
	fdel(json_path)
	text2file(json_encode(all_scenarios), json_path)
	clear_arena()

// ---------- Scenariusze ----------

/// Boarderzy i obezwładniony ochroniarz 10 pól dalej: ma zostać zakuty
/datum/unit_test/aquila_knpc_sim/proc/scenario_cuff(boarder_type, count, unconscious, name)
	begin(name)
	var/mob/living/carbon/human/victim = add_mob(/mob/living/carbon/human, 14, 8, "załoga", "Ochroniarz")
	victim.equipOutfit(/datum/outfit/job/security)
	for(var/i in 1 to count)
		add_mob(boarder_type, 4, 6 + i, "syndykat", "Boarder[i]")
	if(unconscious)
		victim.SetSleeping(90 SECONDS)
	else
		victim.Paralyze(90 SECONDS)
	var/time = run_until(45, CALLBACK(src, PROC_REF(is_cuffed), victim))
	var/details = "próby zakucia [cuff_attempts], ofiara [victim.stat == DEAD ? "martwa" : "żywa"], HP [round(victim.health)]"
	finish(time ? "ZAKUTY" : "NIEZAKUTY", details)
	if(!time)
		Fail("[name]: ofiara nie została zakuta w 45 s ([details]), przebieg w knpc_sim.log")

/datum/unit_test/aquila_knpc_sim/proc/is_cuffed(mob/living/carbon/C)
	return !QDELETED(C) && C.handcuffed

/// Boarder przed zaryglowaną przeszkloną śluzą, za nią widoczny cel: śluza ma zostać otwarta (hakowanie albo wyważenie)
/datum/unit_test/aquila_knpc_sim/proc/scenario_door(boarder_type, name)
	begin(name)
	for(var/y in 1 to KNPC_SIM_H - 2)
		if(y != 8)
			add_wall(16, y)
	var/obj/machinery/door/airlock/door = add_object(/obj/machinery/door/airlock/security/glass, 16, 8, "door")
	door.req_access = list(ACCESS_ARMORY)
	door.bolt()
	add_mob(/mob/living/carbon/human, 22, 8, "załoga", "Cel")
	add_mob(boarder_type, 10, 8, "napastnicy", "Boarder")
	var/time = run_until(60, CALLBACK(src, PROC_REF(door_open), door))
	finish(time ? "OTWARTE" : "ZAMKNIĘTE", "drzwi [QDELETED(door) ? "zniszczone" : "całe, integralność [door.obj_integrity]/[door.max_integrity]"]")
	if(!time)
		Fail("[name]: boarder nie otworzył śluzy w 60 s, przebieg w knpc_sim.log")

/datum/unit_test/aquila_knpc_sim/proc/door_open(obj/machinery/door/door)
	return QDELETED(door) || !door.density

/// Cel za oknem pancernym, bez przejścia: boarder nie powinien utknąć w wahadle ani strzelać w szybę bez końca
/datum/unit_test/aquila_knpc_sim/proc/scenario_window()
	begin("cel_za_szyba")
	for(var/y in 1 to KNPC_SIM_H - 2)
		if(y >= 6 && y <= 10)
			add_object(/obj/structure/window/reinforced/fulltile, 16, y, "window")
		else
			add_wall(16, y)
	var/mob/living/carbon/human/target = add_mob(/mob/living/carbon/human, 20, 8, "załoga", "Cel")
	add_mob(/mob/living/carbon/human/ai_boarder/syndicate/smg/knpc_sim, 8, 8, "napastnicy", "Boarder")
	run_until(40, CALLBACK(src, PROC_REF(never)))
	finish("OBSERWACJA", "cel [target.stat == DEAD ? "martwy" : "żywy"]")

/datum/unit_test/aquila_knpc_sim/proc/never()
	return FALSE

// ---------- Taktyka z aq33/AquilaStation#609 ----------

/// Rani do części zdrowia toksynami (obrażenia fizyczne rozkładają się na kończyny z limitem)
/datum/unit_test/aquila_knpc_sim/proc/wound(mob/living/carbon/human/H, ratio)
	H.adjustToxLoss(H.health - H.maxHealth * ratio, forced = TRUE)

/datum/unit_test/aquila_knpc_sim/proc/remove_medipens(mob/living/carbon/human/H)
	for(var/obj/item/reagent_containers/hypospray/medipen/survival/P in H.GetAllContents())
		qdel(P)

/// Ciężko ranny boarder z medipenem wstrzykuje go sobie mimo wroga w zasięgu
/datum/unit_test/aquila_knpc_sim/proc/scenario_heal_in_combat()
	begin("leczenie_medipenem_w_walce")
	add_mob(/mob/living/carbon/human, 15, 8, "załoga", "Cel")
	var/mob/living/carbon/human/boarder = add_mob(/mob/living/carbon/human/ai_boarder/syndicate/smg/knpc_sim, 9, 8, "syndykat", "Ranny")
	wound(boarder, 0.3)
	var/datum/component/knpc/ai = boarder.GetComponent(/datum/component/knpc)
	var/time = run_until(25, CALLBACK(src, PROC_REF(medipen_used), ai))
	finish(time ? "MEDIPEN UŻYTY" : "BEZ MEDIPENA", "HP rannego [round(boarder.health)]")
	if(!time)
		Fail("leczenie_medipenem_w_walce: boarder z 30% HP i medipenem nie użył go w 25 s")

/datum/unit_test/aquila_knpc_sim/proc/medipen_used(datum/component/knpc/ai)
	return !QDELETED(ai) && !ai.find_medipen()

/// Ciężko ranny boarder bez medipena wycofuje się do kolegi
/datum/unit_test/aquila_knpc_sim/proc/scenario_fall_back()
	begin("odwrot_bez_medipena")
	add_mob(/mob/living/carbon/human, 15, 8, "załoga", "Cel")
	var/mob/living/carbon/human/wounded = add_mob(/mob/living/carbon/human/ai_boarder/syndicate/smg/knpc_sim, 10, 8, "syndykat", "Ranny")
	var/mob/living/carbon/human/ally = add_mob(/mob/living/carbon/human/ai_boarder/syndicate/smg/knpc_sim, 2, 13, "syndykat", "Kolega")
	remove_medipens(wounded)
	remove_medipens(ally) // inaczej kolega przyjdzie go leczyć i nie sprawdzimy samego odwrotu
	wound(wounded, 0.25)
	var/time = run_until(25, CALLBACK(src, PROC_REF(fell_back), wounded, ally))
	var/datum/knpc_sim_track/track = tracks[wounded]
	finish(time ? "WYCOFAŁ SIĘ" : "BEZ ODWROTU", "odwrót [track.falls_back], odległość od kolegi [get_dist(wounded, ally)]")
	if(!time)
		Fail("odwrot_bez_medipena: ranny boarder bez medipena nie dołączył do kolegi w 25 s")

/datum/unit_test/aquila_knpc_sim/proc/fell_back(mob/living/carbon/human/wounded, mob/living/carbon/human/ally)
	var/datum/knpc_sim_track/track = tracks[wounded]
	return track.falls_back && get_dist(wounded, ally) <= 2

/// Boarder z medipenem leczy nieprzytomnego kolegę, gdy wroga nie ma w pobliżu
/datum/unit_test/aquila_knpc_sim/proc/scenario_medic()
	begin("medyk_leczy_kolege")
	var/mob/living/carbon/human/patient = add_mob(/mob/living/carbon/human/ai_boarder/syndicate/smg/knpc_sim, 12, 8, "syndykat", "Ranny")
	var/mob/living/carbon/human/medic = add_mob(/mob/living/carbon/human/ai_boarder/syndicate/smg/knpc_sim, 6, 8, "syndykat", "Medyk")
	remove_medipens(patient)
	patient.adjustToxLoss(patient.health + 10, forced = TRUE) // miękki krytyk
	var/time = run_until(25, CALLBACK(src, PROC_REF(ally_healed), medic))
	finish(time ? "WYLECZONY" : "BEZ POMOCY", "HP rannego [round(patient.health)], stan [patient.stat]")
	if(!time)
		Fail("medyk_leczy_kolege: boarder z medipenem nie podał go nieprzytomnemu koledze w 25 s")

/datum/unit_test/aquila_knpc_sim/proc/ally_healed(mob/living/carbon/human/medic)
	var/datum/knpc_sim_track/track = tracks[medic]
	return track.heals_ally > 0

/// Na wezwanie przez radio odpowiada najwyżej 3 najbliższych z 5 kolegów
/datum/unit_test/aquila_knpc_sim/proc/scenario_backup()
	begin("wsparcie_najwyzej_trzech")
	add_mob(/mob/living/carbon/human, 27, 8, "załoga", "Cel")
	var/mob/living/carbon/human/caller_mob = add_mob(/mob/living/carbon/human/ai_boarder/syndicate/smg/knpc_sim, 21, 8, "syndykat", "Wzywający")
	var/list/others = list()
	for(var/i in 1 to 5)
		others += add_mob(/mob/living/carbon/human/ai_boarder/syndicate/smg/knpc_sim, 2 + (i % 2) * 2, 1 + i * 2, "syndykat", "Kolega[i]")
	var/time = run_until(20, CALLBACK(src, PROC_REF(backup_called), caller_mob))
	sleep(2 SECONDS) // odpowiedzi padają chwilę po wezwaniu
	var/responders = 0
	for(var/mob/living/carbon/human/H as anything in others)
		var/datum/knpc_sim_track/track = tracks[H]
		if(track.backup_responses)
			responders++
	finish(time ? "ODPOWIEDZIAŁO [responders] Z 5" : "BEZ WEZWANIA", "pierwsze wezwanie w [time || "-"] s")
	if(!time)
		Fail("wsparcie_najwyzej_trzech: boarder widzący wroga nie wezwał wsparcia w 20 s")
	else if(responders < 1 || responders > 3)
		Fail("wsparcie_najwyzej_trzech: na wezwanie odpowiedziało [responders] z 5 boarderów (oczekiwane 1–3)")

/datum/unit_test/aquila_knpc_sim/proc/backup_called(mob/living/carbon/human/caller_mob)
	var/datum/knpc_sim_track/track = tracks[caller_mob]
	return track.backup_calls > 0

/// Grupa trzech wrogów: boarder Syndykatu rzuca granat hukowy, a kolega obok (z ochroną oczu i uszu) nie zostaje ogłuszony
/datum/unit_test/aquila_knpc_sim/proc/scenario_grenade()
	begin("granat_w_grupe")
	for(var/y in 7 to 9)
		add_mob(/mob/living/carbon/human, 21, y, "załoga", "Cel[y - 6]")
	var/mob/living/carbon/human/thrower = add_mob(/mob/living/carbon/human/ai_boarder/syndicate/smg/knpc_sim, 15, 8, "syndykat", "Rzucający")
	var/mob/living/carbon/human/ally = add_mob(/mob/living/carbon/human/ai_boarder/syndicate/smg/knpc_sim, 14, 10, "syndykat", "Kolega")
	ally_stunned = FALSE
	allies_down = list()
	last_grenade_at = 0
	// Granat odłamkowy (10% szansy) poleciałby przed hukowym, a scenariusz sprawdza ochronę przed błyskiem i hukiem
	for(var/mob/living/carbon/human/H as anything in list(thrower, ally))
		for(var/obj/item/grenade/frag/frag in H.GetAllContents())
			qdel(frag)
	var/time = run_until(30, CALLBACK(src, PROC_REF(grenade_thrown), thrower, ally))
	for(var/i in 1 to 10) // zapalnik i błysk
		sleep(KNPC_SIM_FRAME)
		snapshot(i % 2 == 0)
		check_ally_stun(ally)
		check_ally_stun(thrower)
	var/datum/knpc_sim_track/track = tracks[thrower]
	var/datum/knpc_sim_track/ally_track = tracks[ally]
	finish(time ? "RZUCIŁ [track.grenades + ally_track.grenades]" : "BEZ GRANATU", "swój ogłuszony granatem: [ally_stunned ? "TAK" : "nie"][length(allies_down) && !ally_stunned ? " (przewrócony z innego powodu, zob. log)" : ""]")
	if(!time)
		Fail("granat_w_grupe: żaden z dwóch boarderów z granatem hukowym nie rzucił go w grupę trzech wrogów w 30 s")
	if(ally_stunned)
		Fail("granat_w_grupe: boarder Syndykatu (z ochroną oczu i uszu) został ogłuszony, szczegóły w knpc_sim_taktyka.log")

/// Granat może rzucić którykolwiek z dwóch boarderów; ogłuszenie sprawdzamy u obu
/datum/unit_test/aquila_knpc_sim/proc/grenade_thrown(mob/living/carbon/human/thrower, mob/living/carbon/human/ally)
	check_ally_stun(ally)
	check_ally_stun(thrower)
	var/datum/knpc_sim_track/track = tracks[thrower]
	var/datum/knpc_sim_track/ally_track = tracks[ally]
	return track.grenades + ally_track.grenades > 0

/// Suma paraliżu, powalenia i ogłuszenia (w decysekundach) każdego żywego boardera Syndykatu
/datum/unit_test/aquila_knpc_sim/proc/syndicate_stun_levels()
	. = list()
	for(var/mob/living/carbon/human/H as anything in tracks)
		var/datum/knpc_sim_track/track = tracks[H]
		if(track.team == "syndykat" && !QDELETED(H) && H.stat != DEAD)
			.[H] = H.AmountParalyzed() + H.AmountKnockdown() + H.AmountStun()

/// Po wybuchu hukowego: komu z Syndykatu przybyło ogłuszenia (także temu, kto już leżał)
/datum/unit_test/aquila_knpc_sim/proc/check_grenade_stuns(list/before)
	if(!before)
		return
	for(var/mob/living/carbon/human/H as anything in before)
		if(QDELETED(H))
			continue
		var/now = H.AmountParalyzed() + H.AmountKnockdown() + H.AmountStun()
		if(now > before[H] + 1)
			ally_stunned = TRUE
			sim_log("OGŁUSZONY WŁASNYM GRANATEM: [label_of(H)] (+[now - before[H]] ds, ochrona oczu [H.get_eye_protection()], uszu [H.get_ear_protection()])", "ff")

/datum/unit_test/aquila_knpc_sim/proc/check_ally_stun(mob/living/carbon/human/ally)
	if(QDELETED(ally))
		return
	if(!(ally.IsParalyzed() || ally.IsKnockdown() || ally.IsStun()))
		allies_down -= ally // wstał: kolejne przewrócenie znowu sprawdzamy
		return
	if(allies_down[ally])
		return
	allies_down[ally] = TRUE
	// Tylko wpis w logu: winę granatu rozstrzyga check_grenade_stuns() w chwili wybuchu.
	// W symulacji boarder potrafił się też pośliznąć na kałuży obok postrzelonych.
	var/since_throw = elapsed() - last_grenade_at
	var/list/nades = list()
	for(var/obj/item/grenade/nade in range(7, ally))
		nades += "[nade.name] [get_dist(ally, nade)] pól[nade.active ? " uzbrojony" : ""]"
	sim_log("SWÓJ NA ZIEMI ([last_grenade_at ? "[since_throw] s po okrzyku przy rzucie" : "przed rzutem"]): [label_of(ally)] paraliż [ally.AmountParalyzed()], powalenie [ally.AmountKnockdown()], ogłuszenie [ally.AmountStun()], ochrona oczu [ally.get_eye_protection()], uszu [ally.get_ear_protection()], granaty w pobliżu: [length(nades) ? nades.Join(", ") : "brak"]", "stall")

/// Syndykat kontra ERT Nanotrasenu, opcjonalnie z osłonami na środku
/datum/unit_test/aquila_knpc_sim/proc/scenario_fight(per_side, run, name, cover = FALSE)
	begin(name, run)
	if(cover)
		for(var/y in list(4, 8, 12))
			add_object(/obj/structure/barricade/sandbags, 12, y, "sandbags")
			add_object(/obj/structure/barricade/sandbags, 19, y, "sandbags")
	// Pojedynek zaczyna się w zasięgu wzroku: z rogów areny obaj patrolowali w tę samą stronę i nigdy się nie spotykali
	var/syndi_x = per_side == 1 ? 11 : 3
	var/ert_x = per_side == 1 ? 19 : KNPC_SIM_W - 4
	for(var/i in 1 to per_side)
		add_mob(/mob/living/carbon/human/ai_boarder/syndicate/smg/knpc_sim, syndi_x, 4 + i * 2, "syndykat", "Syndykat[i]")
		add_mob(/mob/living/carbon/human/ai_boarder/ert/knpc_sim, ert_x, 4 + i * 2, "ert", "ERT[i]")
	var/time = run_until(120, CALLBACK(src, PROC_REF(fight_over)))
	var/syndi = team_standing("syndykat")
	var/ert = team_standing("ert")
	var/result = time ? (syndi ? "WYGRYWA SYNDYKAT" : (ert ? "WYGRYWA ERT" : "OBIE STRONY LEŻĄ")) : "LIMIT CZASU"
	finish(result, "na nogach: Syndykat [syndi], ERT [ert]")

/// Ilu z drużyny jest przytomnych, nieobezwładnionych (paraliż, ogłuszenie) i niezakutych
/datum/unit_test/aquila_knpc_sim/proc/team_standing(team)
	. = 0
	for(var/mob/living/carbon/human/H as anything in tracks)
		var/datum/knpc_sim_track/track = tracks[H]
		if(track.team == team && !QDELETED(H) && H.stat == CONSCIOUS && !H.incapacitated() && !H.handcuffed)
			.++

/datum/unit_test/aquila_knpc_sim/proc/fight_over()
	return !team_standing("syndykat") || !team_standing("ert")

#undef KNPC_SIM_X
#undef KNPC_SIM_Y
#undef KNPC_SIM_W
#undef KNPC_SIM_H
#undef KNPC_SIM_FRAME
#undef KNPC_SIM_STALL

#endif
