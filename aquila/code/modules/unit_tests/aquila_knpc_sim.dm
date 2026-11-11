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

/datum/knpc_sim_track/Destroy(force)
	mob = null
	last_turf = null
	prev_turf = null
	return ..()

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

/datum/unit_test/aquila_knpc_sim/Run()
	GLOB.knpc_sim = src
	sim_z = run_loc_floor_bottom_left.z
	arena_area = get_area(run_loc_floor_bottom_left)
	// Grupa scenariuszy z parametru serwera (-params "knpc_sim=walki1"), bez niego wszystkie. Na 516 serwer potrafi paść
	// po kilku minutach (rust_g.dll_unloaded, niezależnie od symulacji), więc grupy da się puszczać osobno.
	var/group = world.params["knpc_sim"]
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
	add_event("shot", null, track.id, id_of(ai?.current_target?.resolve()))

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
	sim_log("[label_of(source)] mówi: \"[speech_args[SPEECH_MESSAGE]]\"", "say")

/datum/unit_test/aquila_knpc_sim/proc/on_cuff_attempt(mob/living/source, mob/attemptee)
	SIGNAL_HANDLER
	cuff_attempts++
	sim_log("[label_of(attemptee)] zaczyna zakuwać [label_of(source)]", "cuff")

/// Ruch w trakcie zakuwania przerywa do_mob: zapisujemy, kto go wywołał (stos w runtime.log)
/datum/unit_test/aquila_knpc_sim/proc/on_moved(mob/living/source, atom/old_loc, dir)
	SIGNAL_HANDLER
	var/datum/component/knpc/ai = source.GetComponent(/datum/component/knpc)
	if(!ai?.cuffing)
		return
	sim_log("RUCH W TRAKCIE ZAKUWANIA: [label_of(source)] ([dir2text(dir)])", "stall")
	stack_trace("knpc_sim: [label_of(source)] moved while cuffing")

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
		mob_info += list(list("id" = track.id, "label" = track.label, "team" = track.team, "ai" = has_ai ? 1 : 0, "shots" = track.shots, "hits" = track.hits_taken, "ff" = track.friendly_hits_dealt, "idle" = track.max_idle * KNPC_SIM_FRAME / 10, "osc" = track.oscillations, "goals" = track.goal_switches, "died" = track.died_at || 0))
		if(!has_ai)
			continue
		stats += "[track.label]: strzały [track.shots], trafiony [track.hits_taken], bratobójcze [track.friendly_hits_dealt], maks. zastój [track.max_idle * KNPC_SIM_FRAME / 10] s, wahadło [track.oscillations], zmiany celu [track.goal_switches][track.died_at ? ", zginął w [track.died_at] s" : ""]"
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

/// Syndykat kontra ERT Nanotrasenu, opcjonalnie z osłonami na środku
/datum/unit_test/aquila_knpc_sim/proc/scenario_fight(per_side, run, name, cover = FALSE)
	begin(name, run)
	if(cover)
		for(var/y in list(4, 8, 12))
			add_object(/obj/structure/barricade/sandbags, 12, y, "sandbags")
			add_object(/obj/structure/barricade/sandbags, 19, y, "sandbags")
	for(var/i in 1 to per_side)
		add_mob(/mob/living/carbon/human/ai_boarder/syndicate/smg/knpc_sim, 3, 4 + i * 2, "syndykat", "Syndykat[i]")
		add_mob(/mob/living/carbon/human/ai_boarder/ert/knpc_sim, KNPC_SIM_W - 4, 4 + i * 2, "ert", "ERT[i]")
	var/time = run_until(120, CALLBACK(src, PROC_REF(fight_over)))
	var/syndi = team_standing("syndykat")
	var/ert = team_standing("ert")
	var/result = time ? (syndi ? "WYGRYWA SYNDYKAT" : (ert ? "WYGRYWA ERT" : "OBIE STRONY LEŻĄ")) : "LIMIT CZASU"
	finish(result, "na nogach: Syndykat [syndi], ERT [ert]")

/// Ilu z drużyny jest przytomnych, nieobezwładnionych i niezakutych
/datum/unit_test/aquila_knpc_sim/proc/team_standing(team)
	. = 0
	for(var/mob/living/carbon/human/H as anything in tracks)
		var/datum/knpc_sim_track/track = tracks[H]
		if(track.team == team && !QDELETED(H) && H.stat == CONSCIOUS && !H.handcuffed)
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
