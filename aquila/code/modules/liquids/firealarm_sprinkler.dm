// AQUILA - Zraszacze w oczyszczaczach powietrza (nowe, nie ma tego w Monke).
// Alarm przeciwpożarowy włączony ręcznie przez gracza wylewa wodę z każdego oczyszczacza powietrza w obszarze.
// Zemagowany alarm pociągnięty ręcznie i alarm trafiony EMP wylewają jej bardzo dużo.
// Alarm z czujnika temperatury (prawdziwy pożar) wody nie wylewa, żeby zwykły pożar nie zalewał statku.

/// Ile wody wylewa jeden oczyszczacz po ręcznym włączeniu alarmu (kałuża od LIQUID_SPILL_THRESHOLD)
#define SPRINKLER_WATER_NORMAL 60
/// Ile wody wylewa jeden oczyszczacz przy zemagowanym alarmie albo po EMP
#define SPRINKLER_WATER_FLOOD 400
/// Ile szybciej parują kałuże ze zraszaczy (zwykłe; zalanie paruje normalnie)
#define SPRINKLER_EVAPORATION_MULTIPLIER 10
/// Odstęp między wylaniami z jednego alarmu (EMP potrafi trafić kilka razy)
#define SPRINKLER_COOLDOWN (10 SECONDS)

/datum/liquid_group
	/// Szybkie parowanie nadał zwykły zraszacz (zalanie je cofa do stanu sprzed zraszacza)
	var/sprinkler_evaporation = FALSE
	/// Parowanie grupy sprzed zraszacza (always_evaporates, evaporation_multiplier)
	var/list/pre_sprinkler_evaporation

/obj/machinery/firealarm
	/// Kiedy ten alarm ostatnio wylał wodę
	var/last_sprinkle = -SPRINKLER_COOLDOWN

/obj/machinery/firealarm/alarm(mob/user)
	var/old_alarm = last_alarm
	. = ..()
	if(user && last_alarm != old_alarm)
		release_sprinkler_water(obj_flags & EMAGGED, user)

/obj/machinery/firealarm/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	release_sprinkler_water(TRUE)

// Guzik imprezy to podtyp alarmu, ale wody nie leje
/obj/machinery/firealarm/partyalarm/release_sprinkler_water(flood, mob/user)
	return FALSE

/**
 * Wylewa wodę z każdego niezaspawanego oczyszczacza powietrza w obszarze alarmu.
 * flood - bardzo dużo wody (emag, EMP); inaczej mała kałuża, która szybko paruje
 * Zwraca liczbę oczyszczaczy, z których poleciała woda.
 */
/obj/machinery/firealarm/proc/release_sprinkler_water(flood, mob/user)
	if(world.time < last_sprinkle + SPRINKLER_COOLDOWN)
		return 0
	var/area/alarm_area = get_area(src)
	if(!alarm_area)
		return 0
	last_sprinkle = world.time
	var/amount = flood ? SPRINKLER_WATER_FLOOD : SPRINKLER_WATER_NORMAL
	. = 0
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber in GLOB.machines)
		if(scrubber.welded || get_area(scrubber) != alarm_area)
			continue
		var/turf/open/scrubber_turf = get_turf(scrubber)
		if(!isopenturf(scrubber_turf) || isgroundlessturf(scrubber_turf))
			continue
		var/had_liquid = !QDELETED(scrubber_turf.liquids)
		scrubber_turf.add_liquid(/datum/reagent/water, amount)
		if(QDELETED(scrubber_turf.liquids)) // bariera na ciecze zablokowała wodę: nic nie poleciało
			continue
		var/datum/liquid_group/group = scrubber_turf.liquids.liquid_group
		if(group)
			// Szybkie parowanie tylko dla nowej kałuży ze zraszacza; istniejącej (powódź, krew) nie zmieniamy
			if(!flood && !had_liquid)
				if(!group.sprinkler_evaporation)
					group.pre_sprinkler_evaporation = list(group.always_evaporates, group.evaporation_multiplier)
				group.sprinkler_evaporation = TRUE
				group.always_evaporates = TRUE
				group.evaporation_multiplier = max(group.evaporation_multiplier, SPRINKLER_EVAPORATION_MULTIPLIER)
			// Zalanie dolane do kałuży ze zwykłego zraszacza zabiera jej szybkie parowanie (głęboka woda ma stać)
			else if(flood && group.sprinkler_evaporation)
				group.sprinkler_evaporation = FALSE
				var/list/before = group.pre_sprinkler_evaporation || list(initial(group.always_evaporates), initial(group.evaporation_multiplier))
				group.always_evaporates = before[1]
				group.evaporation_multiplier = before[2]
				group.pre_sprinkler_evaporation = null
		scrubber.visible_message(flood ? "<span class='danger'>Z [scrubber] bucha strumień wody!</span>" : "<span class='warning'>Z [scrubber] tryska woda!</span>")
		playsound(scrubber_turf, 'aquila/sound/effects/splash_loud.ogg', flood ? 60 : 35, TRUE)
		.++
	if(. && flood)
		log_game("Fire alarm at [AREACOORD(src)] flooded [.] scrubbers with water[user ? " (triggered by [key_name(user)])" : " (EMP)"]")
		message_admins("Alarm przeciwpożarowy w [ADMIN_VERBOSEJMP(src)] zalewa wodą [.] oczyszczaczy[user ? " ([ADMIN_LOOKUPFLW(user)])" : " (EMP)"].")

#undef SPRINKLER_WATER_NORMAL
#undef SPRINKLER_WATER_FLOOD
#undef SPRINKLER_EVAPORATION_MULTIPLIER
#undef SPRINKLER_COOLDOWN
