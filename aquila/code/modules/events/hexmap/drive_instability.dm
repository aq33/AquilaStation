// AQUILA - niestabilność napędu: napęd FTL traci część ładunku, a pady kwantowe i teleportery zawodzą (port z Baystation12 code/modules/events/bsd_instability.dm)

/// Ile eventów zakłóca teraz teleportację na okręcie (pady kwantowe i węzły teleporterów)
GLOBAL_VAR_INIT(aquila_hex_teleport_interference, 0)

/// Szansa (%) na zawód teleportacji w czasie zakłóceń
#define AQUILA_HEX_TELEPORT_MISFIRE_CHANCE 50

/datum/round_event_control/aquila_hex_drive_instability
	name = "Niestabilność napędu"
	typepath = /datum/round_event/aquila_hex_drive_instability
	weight = 10
	min_players = 5
	max_occurrences = 2
	earliest_start = 15 MINUTES

/datum/round_event/aquila_hex_drive_instability
	announceWhen = 1
	startWhen = 1
	/// Czy ten event włączył zakłócenia teleportacji (żeby end() zdjął tylko swoje)
	var/interference_active = FALSE

/datum/round_event/aquila_hex_drive_instability/setup()
	endWhen = rand(150, 350) // 5–12 min, jak 350 ticków w Bay

/datum/round_event/aquila_hex_drive_instability/announce(fake)
	priority_announce("Ostrzeżenie: wykryto niestabilność napędu FTL. Część ładunku napędu uległa rozproszeniu. Systemy nawigacji i teleportacji mogą działać nieprawidłowo.", "Monitoring napędu FTL", ANNOUNCER_SPANOMALIES)

/datum/round_event/aquila_hex_drive_instability/start()
	GLOB.aquila_hex_teleport_interference++
	interference_active = TRUE
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	var/drained = drain_drive(main, rand(20, 50) / 100)
	if(drained)
		log_game("Drive Instability drained [round(drained, 0.1)]% of the FTL drive charge of [main].")

/datum/round_event/aquila_hex_drive_instability/end()
	release_interference()
	priority_announce("Napęd FTL wrócił do stabilnej pracy. Systemy teleportacji działają normalnie.", "Monitoring napędu FTL")

/datum/round_event/aquila_hex_drive_instability/kill()
	release_interference() // zatrzymany przez admina przed end()
	return ..()

/// Zdejmuje udział tego eventu w zakłóceniach teleportacji, najwyżej raz
/datum/round_event/aquila_hex_drive_instability/proc/release_interference()
	if(!interference_active)
		return
	GLOB.aquila_hex_teleport_interference = max(0, GLOB.aquila_hex_teleport_interference - 1)
	interference_active = FALSE

/**
 * Zabiera napędowi okrętu podaną część obecnego ładunku (0–1). Nie rusza napędu w czasie skoku.
 * Zwraca, ile punktów procentowych ładunku ubyło.
 */
/datum/round_event/aquila_hex_drive_instability/proc/drain_drive(obj/structure/overmap/ship, fraction)
	var/obj/machinery/computer/ship/ftl_core/drive = ship?.ftl_drive
	if(!drive || fraction <= 0)
		return 0
	if(drive.ftl_state == FTL_STATE_JUMPING || SSstar_system.ships[ship]?["target_system"])
		return 0
	var/before = ship.hex_charge()
	if(before <= 0)
		return 0
	if(istype(drive, /obj/machinery/computer/ship/ftl_core))
		drive.progress = max(0, drive.progress * (1 - fraction))
	else
		var/obj/machinery/computer/ship/ftl_computer/legacy = drive
		if(!istype(legacy))
			return 0
		legacy.progress = max(0, legacy.progress * (1 - fraction))
	ship.hex_resume_charging() // gotowy napęd wraca do ładowania, wyłączony zostaje wyłączony
	. = before - ship.hex_charge()
	drive.radio?.talk_into(drive, "Ostrzeżenie: niestabilność napędu. Utracono [round(., 1)]% ładunku.", drive.radio_channel)

/// Czy teleportacja z tego miejsca ma teraz zawieść
/proc/aquila_hex_teleport_misfire(atom/source)
	if(GLOB.aquila_hex_teleport_interference <= 0 || !source)
		return FALSE
	var/turf/T = get_turf(source)
	if(!T || !is_station_level(T.z))
		return FALSE
	return prob(AQUILA_HEX_TELEPORT_MISFIRE_CHANCE)

// Pad kwantowy w czasie zakłóceń: wiązka gaśnie albo rozrzuca ładunek wokół docelowego padu
/obj/machinery/quantumpad/doteleport(mob/user, obj/machinery/quantumpad/target_pad = linked_pad)
	if(!target_pad || QDELETED(target_pad) || !aquila_hex_teleport_misfire(src))
		return ..()
	last_teleport = world.time
	INVOKE_ASYNC(src, PROC_REF(aquila_hex_misfire), target_pad) // doteleport() bywa wołane z miejsc, które nie mogą czekać (układy scalone), jak oryginał przez spawn()

/// Zawód padu: wiązka gaśnie albo rozrzuca wszystko z padu wokół docelowego padu
/obj/machinery/quantumpad/proc/aquila_hex_misfire(obj/machinery/quantumpad/target_pad)
	use_power(10000 / power_efficiency)
	sparks()
	playsound(get_turf(src), 'sound/magic/lightningshock.ogg', 40, TRUE)
	if(prob(50) || QDELETED(target_pad))
		visible_message("<span class='warning'>[src] trzeszczy i gaśnie: zakłócenia bluespace rozproszyły wiązkę!</span>")
		return
	visible_message("<span class='danger'>Wiązka [src] rozszczepia się w zakłóceniach bluespace!</span>")
	target_pad.sparks()
	for(var/atom/movable/ROI in get_turf(src))
		if(QDELETED(ROI) || ROI == src || ROI.anchored || isobserver(ROI))
			continue
		do_teleport(ROI, get_turf(target_pad), rand(2, 4), channel = TELEPORT_CHANNEL_QUANTUM)

// Węzeł teleportera w czasie zakłóceń: odrzuca obiekt albo wysyła go obok celu
/obj/machinery/teleport/hub/teleport(atom/movable/M, turf/T)
	if(!aquila_hex_teleport_misfire(src))
		return ..()
	var/obj/machinery/computer/teleporter/com = power_station?.teleporter_console
	var/atom/target = com?.target_ref?.resolve()
	if(!target)
		return ..()
	do_sparks(3, TRUE, src)
	if(prob(50))
		visible_message("<span class='warning'>[src] iskrzy: zakłócenia bluespace nie pozwalają ustalić współrzędnych!</span>")
		return
	if(do_teleport(M, target, rand(3, 6), channel = TELEPORT_CHANNEL_BLUESPACE))
		use_power(7500)
		calibrated = FALSE
		visible_message("<span class='danger'>[src] wyrzuca wiązkę w zakłóceniach bluespace!</span>")

#undef AQUILA_HEX_TELEPORT_MISFIRE_CHANCE
