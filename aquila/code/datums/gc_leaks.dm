// AQUILA - wycieki pamięci wyłapane przez strażnika testów (aquila/code/modules/unit_tests/aquila_gc_guard.dm).
// Każdy blok przerywa cykl albo zdejmuje usuwany obiekt z listy, która żyje dłużej od niego. Bez tego obiekt po qdel
// zostawał w pamięci na zawsze (a w grze, po GC_CHECK_QUEUE, kończył jako kosztowne twarde usunięcie).

// ---- Okręty overmapy ----

/// Wpis w SSstar_system.ships (okręt jako klucz i jako "ship"), listy floty i salwy torpedowe innych flot
/// trzymały usunięty okręt. Flota zdejmuje okręt w remove_ship(), ale tylko przy normalnym zniszczeniu w układzie.
/// Wejścia na pokład (landmarki) i rezerwacja wnętrza (overmap_fallback) żyją dłużej od okrętu i też go wskazywały.
/obj/structure/overmap/Destroy(force)
	var/datum/fleet/own_fleet = fleet
	var/list/entry_points = interior_entry_points?.Copy()
	. = ..()
	if(. == QDEL_HINT_LETMELIVE && !force)
		return
	SSstar_system.ships -= src
	if(own_fleet)
		own_fleet.all_ships -= src
		for(var/role in own_fleet.taskforces)
			var/list/members = own_fleet.taskforces[role]
			members?.Remove(src)
	for(var/datum/fleet/any_fleet as anything in GLOB.aquila_fleets)
		any_fleet.forget_ai_salvo_ship(src)
		LAZYREMOVE(any_fleet.ai_salvos, src)
	for(var/obj/effect/landmark/dropship_entry/entry in entry_points)
		if(entry.linked == src)
			entry.linked = null
	for(var/datum/turf_reservation/reservation as anything in SSmapping.turf_reservations)
		if(reservation.overmap_fallback == src)
			reservation.overmap_fallback = null

/// Wszystkie floty, także te poza układem (salwy torpedowe innych flot trzymały usunięte okręty)
GLOBAL_LIST_EMPTY(aquila_fleets)

/datum/fleet/New()
	. = ..()
	GLOB.aquila_fleets += src

/// Usunięta flota: okręty zabiera ze sobą (QDEL_LIST(all_ships) w upstreamie), ale ich listy zadań i salw
/// zostawały, a dowódca z mapy wojny dalej wskazywał flotę.
/datum/fleet/Destroy()
	GLOB.aquila_fleets -= src
	. = ..()
	for(var/role in taskforces)
		var/list/members = taskforces[role]
		members?.Cut()
	ai_salvos = null
	for(var/datum/hex_commander/commander as anything in GLOB.hex_war?.commanders)
		if(commander.fleet == src)
			commander.fleet = null

/// Usunięty układ (tylko testy) trzymał swoje anomalie, a one układ w `current_system`
/datum/star_system/Destroy()
	for(var/obj/effect/overmap_anomaly/anomaly in system_contents)
		if(anomaly.current_system == src)
			qdel(anomaly)
	system_contents?.Cut()
	contents_positions?.Cut()
	return ..()

/// Anomalia była na globalnej liście i w pozycjach układu także po usunięciu
/obj/effect/overmap_anomaly/Destroy(force)
	GLOB.overmap_anomalies -= src
	if(current_system)
		current_system.system_contents -= src
		current_system.contents_positions -= src
		current_system = null
	return ..()

// ---- Załoga ----

/// Mob trafia do mobs_in_ship także bez ustawienia last_overmap (wejście do myśliwca nadpisuje last_overmap pilota),
/// a upstream zdejmuje go przy usunięciu tylko z listy last_overmap
/mob/Destroy()
	for(var/obj/structure/overmap/ship as anything in GLOB.overmap_objects)
		if(ship.mobs_in_ship)
			ship.mobs_in_ship -= src
	return ..()

// ---- Promy ----

/// Obszar promu wskazuje swój port w `mobile_port`, a obszary żyją dłużej od portu
/obj/docking_port/mobile/Destroy(force)
	var/list/areas = shuttle_areas?.Copy()
	. = ..()
	if(!force)
		return
	for(var/area/shuttle/shuttle_area in areas)
		if(shuttle_area.mobile_port == src)
			shuttle_area.mobile_port = null

// ---- Silikony i mechy ----

/// Prawa trzymają silikon w `owner`, a silikon prawa w `laws`
/mob/living/silicon/Destroy()
	if(laws?.owner == src)
		laws.owner = null
	laws = null
	return ..()

/// System iskier SI trzyma SI w `holder`, a przycisk komputera SI w HUD-zie SI w `robot`
/mob/living/silicon/ai/Destroy()
	QDEL_NULL(spark_system)
	if(interfaceButton?.robot == src)
		interfaceButton.robot = null
	return ..()

/// Mech jest dopisywany do diagnostycznych HUD-ów w Initialize(), a Destroy() go z nich nie zdejmował
/obj/mecha/Destroy()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.remove_from_hud(src)
	return ..()

// ---- Antagoniści ----

/// Cel smoka trzyma rolę w `dragon`, rola cel w `objectives`; przycisk szczeliny zostawał przy roli usuniętej bez on_removal()
/datum/antagonist/space_dragon/Destroy()
	for(var/datum/objective/summon_carp/objective in objectives)
		if(objective.dragon == src)
			objective.dragon = null
	QDEL_NULL(rift_ability)
	return ..()

/// Moce wampira (akcje na ciele) trzymają rolę w `vampiredatum_power`; rola usunięta razem z umysłem ich nie zabierała
/datum/antagonist/vampire/Destroy()
	QDEL_LIST(powers)
	return ..()

// ---- Misje ładunkowe ----

/// Cel ładunkowy trzyma grupę ładunków, a ładunek cel w `overmap_objective`
/datum/overmap_objective/cargo/Destroy()
	freight_type_group = null
	last_freight_type_check = null
	return ..()

// ---- Przedmioty ----

/// Dysza bierze odczynniki plecaka; gdy odczynniki wskazywały dyszę w `my_atom`, plecak trzymał usuniętą dyszę
/obj/item/extinguisher/mini/nozzle/Destroy()
	if(reagents?.my_atom == src)
		reagents.my_atom = tank
	return ..()

// ---- TGUI ----

/// Okno usunięte bez close() zostawało w SStgui.open_uis_by_src
/datum/tgui/Destroy()
	SStgui.on_close(src)
	return ..()

// ---- QDEL_IN ----

/// QDEL_IN (code/__HELPERS/qdel.dm) trzymał obiekt w argumentach globalnego timera aż do jego końca, także gdy obiekt
/// usunięto wcześniej. Timer należy teraz do samego obiektu, więc znika razem z nim (datum/Destroy() kasuje active_timers).
/proc/aquila_qdel_in(thing, time)
	if(istype(thing, /datum))
		return addtimer(CALLBACK(thing, TYPE_PROC_REF(/datum, aquila_qdel_self)), time, TIMER_STOPPABLE)
	return addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), thing), time, TIMER_STOPPABLE)

/datum/proc/aquila_qdel_self()
	qdel(src)

// ---- NTSL ----

/// Kompilator trzyma interpreter, a interpreter kompilator (`Compiler`, `container`); garbage_collect() przerywa cykl,
/// ale wołał je tylko serwer telekomunikacji
/datum/TCS_Compiler/Destroy()
	garbage_collect()
	interpreter = null
	return ..()
