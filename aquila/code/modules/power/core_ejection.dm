// AQUILA - awaryjny wyrzut rdzenia reaktora (plan maszynowni, etap E9).
// Wspólny mechanizm dla napędu burzowego, RBMK i supermaterii: główny inżynier albo kapitan uruchamia go z konsoli reaktora,
// 30 s odliczania z możliwością anulowania, potem rdzeń znika z komory i dryfuje na overmapie jak mina, aż wybuchnie po 30–60 s.
// Fizyczny wyrzut jak na Bayu nie zadziała: poziomy statku mają Linkage: Self, więc rdzeń zawinąłby się z powrotem na statek.

#define CORE_EJECTION_COUNTDOWN (30 SECONDS)
#define CORE_EJECTION_MIN_DAMAGE 100
#define CORE_EJECTION_MAX_DAMAGE 400

// Stany napędu burzowego z nsv13/code/modules/power/stormdrive.dm (tamte define'y są #undef na końcu pliku)
#define CORE_EJECTION_SD_MELTDOWN 4
#define CORE_EJECTION_SD_REFIT 7

/datum/component/core_ejection
	/// Nazwa tego, co wylatuje, w komunikatach (biernik po „wyrzut”)
	var/core_name = "rdzenia reaktora"
	/// Timer odliczania, null gdy wyrzut nie trwa
	var/eject_timer
	/// world.time, o którym rdzeń wyleci
	var/eject_at = 0

/datum/component/core_ejection/Initialize()
	if(!ismachinery(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/core_ejection/Destroy(force, silent)
	if(eject_timer)
		deltimer(eject_timer)
		eject_timer = null
	return ..()

/// Czy reaktor ma teraz co wyrzucić. Zwraca powód blokady (tekst dla gracza) albo null, gdy wyrzut jest możliwy
/datum/component/core_ejection/proc/eject_block_reason()
	return null

/// Siła wybuchu rdzenia na overmapie, zależna od stanu reaktora w chwili wyrzutu
/datum/component/core_ejection/proc/blast_damage()
	return CORE_EJECTION_MIN_DAMAGE

/// Usuwa rdzeń z komory i zostawia reaktor w stanie gotowym do odbudowy
/datum/component/core_ejection/proc/purge_core()
	return

/// Główny inżynier albo kapitan (dostęp z karty), a do tego admin-duch
/datum/component/core_ejection/proc/has_eject_access(mob/user)
	if(!user)
		return FALSE
	if(isAdminGhostAI(user))
		return TRUE
	if(!isliving(user))
		return FALSE
	var/obj/item/card/id/card = user.get_idcard(TRUE)
	var/list/access = card?.GetAccess()
	if(!length(access))
		return FALSE
	return (ACCESS_CE in access) || (ACCESS_CAPTAIN in access)

/datum/component/core_ejection/proc/announce(message, sound = 'sound/misc/notice1.ogg')
	var/obj/machinery/reactor = parent
	var/obj/structure/overmap/OM = reactor.get_overmap()
	if(OM)
		OM.relay(sound, "<span class='big boldannounce'>[message]</span>")
	else
		reactor.visible_message("<span class='boldannounce'>[message]</span>")

/datum/component/core_ejection/proc/start_ejection(mob/user)
	var/obj/machinery/reactor = parent
	if(eject_timer)
		return FALSE
	if(!has_eject_access(user))
		to_chat(user, "<span class='warning'>Odmowa dostępu: wyrzut rdzenia wymaga dostępu głównego inżyniera albo kapitana.</span>")
		return FALSE
	var/reason = eject_block_reason()
	if(reason)
		to_chat(user, "<span class='warning'>[reason]</span>")
		return FALSE
	eject_at = world.time + CORE_EJECTION_COUNTDOWN
	eject_timer = addtimer(CALLBACK(src, PROC_REF(finish_ejection)), CORE_EJECTION_COUNTDOWN, TIMER_STOPPABLE)
	announce("UWAGA: rozpoczęto awaryjny wyrzut [core_name]. Wyrzut za 30 sekund, odliczanie można przerwać z konsoli reaktora.", 'sound/misc/notice2.ogg')
	reactor.investigate_log("core ejection started by [key_name(user)].", INVESTIGATE_ENGINES)
	message_admins("[ADMIN_LOOKUPFLW(user)] rozpoczął wyrzut rdzenia: [reactor] [ADMIN_VERBOSEJMP(reactor)].")
	log_game("[key_name(user)] started a core ejection of [reactor] at [AREACOORD(reactor)].")
	return TRUE

/datum/component/core_ejection/proc/cancel_ejection(mob/user)
	var/obj/machinery/reactor = parent
	if(!eject_timer)
		return FALSE
	if(!has_eject_access(user))
		to_chat(user, "<span class='warning'>Odmowa dostępu: wyrzut rdzenia wymaga dostępu głównego inżyniera albo kapitana.</span>")
		return FALSE
	deltimer(eject_timer)
	eject_timer = null
	eject_at = 0
	announce("Awaryjny wyrzut [core_name] został przerwany.")
	reactor.investigate_log("core ejection cancelled by [key_name(user)].", INVESTIGATE_ENGINES)
	message_admins("[ADMIN_LOOKUPFLW(user)] przerwał wyrzut rdzenia: [reactor] [ADMIN_VERBOSEJMP(reactor)].")
	log_game("[key_name(user)] cancelled a core ejection of [reactor] at [AREACOORD(reactor)].")
	return TRUE

/// Koniec odliczania. Zwraca wyrzucony obiekt overmapy, TRUE (rdzeń wyrzucony, ale okrętu nie ma na overmapie) albo FALSE
/datum/component/core_ejection/proc/finish_ejection()
	var/obj/machinery/reactor = parent
	eject_timer = null
	eject_at = 0
	var/reason = eject_block_reason()
	if(reason)
		announce("Awaryjny wyrzut [core_name] nie powiódł się: [reason]")
		return FALSE
	var/damage = clamp(round(blast_damage()), CORE_EJECTION_MIN_DAMAGE, CORE_EJECTION_MAX_DAMAGE)
	var/obj/structure/overmap/OM = reactor.get_overmap()
	var/turf/reactor_turf = get_turf(reactor)
	var/name_for_core = core_name
	reactor.investigate_log("ejected its core (overmap blast damage [damage]).", INVESTIGATE_ENGINES)
	log_game("[reactor] at [AREACOORD(reactor)] ejected its core.")
	// purge_core() może usunąć reaktor razem z tym komponentem (supermateria), więc dalej nie używamy src ani parent
	purge_core()
	if(reactor_turf)
		playsound(reactor_turf, 'sound/effects/bang.ogg', 100, TRUE)
		for(var/mob/living/M in range(7, reactor_turf))
			shake_camera(M, 3, 2)
	OM?.stop_relay(CHANNEL_REACTOR_ALERT)
	var/obj/structure/space_mine/ejected_core/core = spawn_ejected_core(OM, damage, name_for_core)
	if(OM)
		OM.relay('nsv13/sound/effects/ship/reactor/explode.ogg', "<span class='big boldannounce'>Wyrzucono [name_for_core]. Rdzeń dryfuje za rufą i wybuchnie w ciągu minuty, odleć od niego.</span>")
	return core || TRUE

/// Stawia dryfujący rdzeń dwa pola za rufą okrętu. Nie czyta zmiennych komponentu, bo ten może już być usunięty razem z reaktorem
/datum/component/core_ejection/proc/spawn_ejected_core(obj/structure/overmap/OM, damage, name_for_core)
	if(!OM?.current_system)
		return null
	var/turf/start = get_turf(OM)
	if(!start)
		return null
	var/back_dir = angle2dir(OM.angle + 180)
	var/turf/target = get_ranged_target_turf(start, back_dir, 2) || start
	var/obj/structure/space_mine/ejected_core/core = new(target, null, OM.current_system)
	core.arm(damage, back_dir, name_for_core)
	return core

/datum/component/core_ejection/proc/ejection_ui_data()
	var/reason = eject_block_reason()
	return list(
		"ejecting" = !!eject_timer,
		"time_left" = eject_timer ? max(0, round((eject_at - world.time) / 10)) : 0,
		"available" = !reason,
		"reason" = reason,
	)

/// Obsługa przycisków wyrzutu w oknach konsol. TRUE, gdy akcja była nasza
/datum/component/core_ejection/proc/handle_ui_act(action, mob/user)
	switch(action)
		if("core_eject")
			start_ejection(user)
			return TRUE
		if("core_eject_cancel")
			cancel_ejection(user)
			return TRUE
	return FALSE

// --- Napęd burzowy ---

/datum/component/core_ejection/stormdrive
	core_name = "rdzenia napędu burzowego"

/datum/component/core_ejection/stormdrive/eject_block_reason()
	var/obj/machinery/atmospherics/components/binary/stormdrive_reactor/R = parent
	if(R.state == CORE_EJECTION_SD_MELTDOWN)
		return "Reaktor już się stopił, nie ma czego wyrzucić."
	if(R.state > CORE_EJECTION_SD_MELTDOWN)
		return "W komorze reaktora nie ma rdzenia."
	return null

/datum/component/core_ejection/stormdrive/blast_damage()
	var/obj/machinery/atmospherics/components/binary/stormdrive_reactor/R = parent
	return CORE_EJECTION_MIN_DAMAGE + R.heat / 4

/datum/component/core_ejection/stormdrive/purge_core()
	var/obj/machinery/atmospherics/components/binary/stormdrive_reactor/R = parent
	QDEL_LIST(R.control_rods) // pręty sterujące wylatują razem z rdzeniem
	R.handle_control_rod_efficiency()
	R.handle_control_rod_integrity()
	R.heat = 0
	R.reaction_rate = 0
	R.last_power_produced = 0
	R.reactor_stability = 0
	R.dumping_fuel = FALSE
	R.warning_state = 0
	R.reactor_end_times = FALSE
	R.state = CORE_EJECTION_SD_REFIT // dalej istniejąca ścieżka naprawy: nowy rdzeń z cargo
	R.set_light(0)
	R.cut_overlays()
	R.update_icon()
	var/area/A = get_area(R)
	if(A)
		A.ambient_buzz = 'nsv13/sound/ambience/shipambience.ogg'

// --- RBMK ---

/datum/component/core_ejection/rbmk
	core_name = "prętów paliwowych reaktora"

/datum/component/core_ejection/rbmk/eject_block_reason()
	var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/R = parent
	if(R.slagged)
		return "Reaktor jest przetopiony, nie ma czego wyrzucić."
	if(!length(R.fuel_rods))
		return "W reaktorze nie ma prętów paliwowych."
	return null

/datum/component/core_ejection/rbmk/blast_damage()
	var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/R = parent
	return CORE_EJECTION_MIN_DAMAGE + max(R.temperature, 0) / 5

/datum/component/core_ejection/rbmk/purge_core()
	var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/R = parent
	QDEL_LIST(R.fuel_rods) // nowe pręty z cargo uruchamiają reaktor jak zwykle (pierwszy pręt woła start_up)
	R.pressure = 0
	R.power = 0
	R.last_power_produced = 0
	R.warning = FALSE
	R.color = null
	R.shut_down()

// --- Supermateria ---

/datum/component/core_ejection/supermatter
	core_name = "kryształu supermaterii"

/datum/component/core_ejection/supermatter/eject_block_reason()
	var/obj/machinery/power/supermatter_crystal/S = parent
	if(S.final_countdown) // pętla odliczania delaminacji śpi i po usunięciu kryształu sięgnęłaby do usuniętego radia
		return "Delaminacja już trwa, na wyrzut jest za późno."
	if(!isturf(S.loc))
		return "Kryształ nie stoi w komorze."
	return null

/datum/component/core_ejection/supermatter/blast_damage()
	var/obj/machinery/power/supermatter_crystal/S = parent
	return CORE_EJECTION_MIN_DAMAGE + S.power / 10 + S.damage / 10

/datum/component/core_ejection/supermatter/purge_core()
	// Nowy kryształ: paczka „Skrzynia z odłamkiem supermaterii” w cargo
	qdel(parent)

// --- Podpięcie do reaktorów ---

/obj/machinery/atmospherics/components/binary/stormdrive_reactor/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/core_ejection/stormdrive)

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/core_ejection/rbmk)

/obj/machinery/power/supermatter_crystal/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/core_ejection/supermatter)

// --- Przyciski w konsolach ---

/obj/machinery/computer/ship/reactor_control_computer/ui_data(mob/user)
	. = ..()
	var/datum/component/core_ejection/ejection = reactor?.GetComponent(/datum/component/core_ejection)
	.["core_ejection"] = ejection?.ejection_ui_data()

/obj/machinery/computer/ship/reactor_control_computer/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	var/datum/component/core_ejection/ejection = reactor?.GetComponent(/datum/component/core_ejection)
	if(ejection?.handle_ui_act(action, usr))
		return TRUE

/obj/machinery/computer/reactor/control_rods/ui_data(mob/user)
	. = ..()
	var/datum/component/core_ejection/ejection = reactor?.GetComponent(/datum/component/core_ejection)
	.["core_ejection"] = ejection?.ejection_ui_data()

/obj/machinery/computer/reactor/control_rods/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/datum/component/core_ejection/ejection = reactor?.GetComponent(/datum/component/core_ejection)
	if(ejection?.handle_ui_act(action, usr))
		return TRUE

/datum/computer_file/program/supermatter_monitor/ui_data(mob/user)
	. = ..()
	if(!islist(.) || !istype(active))
		return
	var/datum/component/core_ejection/ejection = active.GetComponent(/datum/component/core_ejection)
	.["core_ejection"] = ejection?.ejection_ui_data()

/datum/computer_file/program/supermatter_monitor/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!istype(active))
		return
	var/datum/component/core_ejection/ejection = active.GetComponent(/datum/component/core_ejection)
	if(ejection?.handle_ui_act(action, usr))
		return TRUE

// --- Rdzeń na overmapie ---

/obj/structure/space_mine/ejected_core
	name = "wyrzucony rdzeń reaktora"
	desc = "Rozżarzony rdzeń reaktora wyrzucony z okrętu. Zaraz wybuchnie, lepiej trzymać się od niego z daleka."
	icon_state = "mine_unaligned"
	color = "#ff7b00"
	alpha = 255
	faction = "ejected_core" // nie należy do nikogo, więc wybucha przy każdym okręcie
	damage = CORE_EJECTION_MIN_DAMAGE
	/// Przez pierwsze sekundy nie wybucha od zetknięcia, żeby nie trafić okrętu, który go właśnie wyrzucił
	var/armed = FALSE
	var/fuse_timer

/obj/structure/space_mine/ejected_core/update_icon(updates)
	. = ..()
	icon_state = initial(icon_state)

/obj/structure/space_mine/ejected_core/proc/arm(new_damage, drift_dir, name_for_core)
	damage = new_damage
	if(name_for_core)
		desc = "Rozżarzona pozostałość [name_for_core] wyrzucona z okrętu. Zaraz wybuchnie, lepiej trzymać się od niej z daleka."
	addtimer(VARSET_CALLBACK(src, armed, TRUE), 5 SECONDS)
	fuse_timer = addtimer(CALLBACK(src, PROC_REF(mine_explode)), rand(30, 60) SECONDS, TIMER_STOPPABLE)
	if(drift_dir)
		walk(src, drift_dir, 1 SECONDS)

/obj/structure/space_mine/ejected_core/on_entered(datum/source, atom/movable/AM)
	if(!armed && istype(AM, /obj/structure/overmap))
		return
	return ..()

/obj/structure/space_mine/ejected_core/obj_break(damage_flag)
	if(broken)
		return
	broken = TRUE
	obj_destruction(damage_flag)

/obj/structure/space_mine/ejected_core/Destroy(force)
	walk(src, 0)
	if(fuse_timer)
		deltimer(fuse_timer)
		fuse_timer = null
	return ..()

#undef CORE_EJECTION_COUNTDOWN
#undef CORE_EJECTION_MIN_DAMAGE
#undef CORE_EJECTION_MAX_DAMAGE
#undef CORE_EJECTION_SD_MELTDOWN
#undef CORE_EJECTION_SD_REFIT
