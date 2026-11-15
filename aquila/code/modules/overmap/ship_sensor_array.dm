// AQUILA - matryca sensorów okrętu (rework systemów okrętu, etap A3; wzór: sensory statków z Aurory,
// Aurorastation/Aurora.3, sprite icons/obj/machinery/sensors.dmi na CC-BY-SA 3.0).
// Cztery matryce na kadłubie statku, każda w próżni i skierowana w swoją stronę (dir: wschód = dziób, południe =
// prawa burta, zachód = rufa, północ = lewa burta; wszystkie nasze statki mają dziób na wschodzie mapy).
// Każda obejmuje swoją ćwiartkę wokół statku: zestawy sensorów (ai_sensor_suites.dm, player_sensors.dm) widzą cel
// na zasięgu proporcjonalnym do zasięgu matrycy z jego strony (zasięg 10 = dzisiejszy pełny zasięg).
// Zasięg ustawia operator na stanowisku rozpoznania; pobór z APC rośnie z kwadratem zasięgu (do 150 kW),
// a matryca grzeje się i przy przegrzaniu sama się uszkadza i wyłącza. Bez działającej matrycy w danej ćwiartce
// zostaje tam tylko kamera szerokokątna na SENSOR_ARRAY_BLIND_OPTICAL zasięgu. Statek bez matryc na mapie (SI,
// starsze mapy) widzi jak dotąd.

#define SENSOR_ARRAY_MAX_RANGE 10
/// Pobór na pełnym zasięgu: SENSOR_ARRAY_POWER_PER_RANGE2 * zasięg²
#define SENSOR_ARRAY_POWER_PER_RANGE2 1500
/// Ciepło na cykl: pobór / to
#define SENSOR_ARRAY_HEAT_DIVISOR 15000
/// Chłodzenie na cykl (utrzyma zasięg ok. 6)
#define SENSOR_ARRAY_COOLING 3.5
#define SENSOR_ARRAY_CRITICAL_HEAT 50
/// Ile zasięgu kamery zostaje, gdy matryca nie działa
#define SENSOR_ARRAY_BLIND_OPTICAL 0.25
/// Do jakiego ciśnienia (kPa) matryca uznaje kafel za próżnię
#define SENSOR_ARRAY_VACUUM 10
/// Kierunek mapy, w którym statek ma dziób
#define SHIP_MAP_BOW_DIR EAST

/// Ćwiartka obejmowana przez matrycę skierowaną w dir: namiar względem dziobu (0 = dziób, zgodnie z ruchem wskazówek)
/proc/sensor_array_sector_center(dir)
	return SIMPLIFY_DEGREES(dir2angle(dir) - dir2angle(SHIP_MAP_BOW_DIR))

/proc/sensor_array_sector_name(dir)
	switch(sensor_array_sector_center(dir))
		if(0)
			return "dziób"
		if(90)
			return "prawa burta"
		if(180)
			return "rufa"
		if(270)
			return "lewa burta"
	return "?"

/obj/structure/overmap
	/// AQUILA - matryce sensorów zgłoszone na tym statku
	var/list/sensor_arrays
	/// AQUILA - czy statek kiedykolwiek miał matrycę (wtedy jej brak oślepia)
	var/had_sensor_array = FALSE

/obj/structure/overmap/Destroy()
	for(var/obj/machinery/ship_sensor_array/array as anything in sensor_arrays)
		array.linked_ship = null
	sensor_arrays = null
	return ..()

/// Mnożnik zasięgu zestawu od matryc wobec target: 1 dla statków bez matryc, zasięg/10 matrycy z jego strony,
/// a bez działającej matrycy w tej ćwiartce tylko krótka kamera. Bez target: najlepsza matryca (do wyświetlania).
/obj/structure/overmap/proc/get_sensor_array_mult(suite, obj/structure/overmap/target)
	if(ai_controlled || !had_sensor_array)
		return 1
	if(suite == SENSOR_MEMORY)
		return 1
	var/bearing
	if(target)
		var/absolute = overmap_angle(src, target)
		if(!isnull(absolute))
			bearing = SIMPLIFY_DEGREES(absolute - angle)
	var/best = 0
	for(var/obj/machinery/ship_sensor_array/array as anything in sensor_arrays)
		if(!array.is_working())
			continue
		if(!isnull(bearing) && abs(closer_angle_difference(sensor_array_sector_center(array.dir), bearing)) > 45)
			continue
		best = max(best, array.range / SENSOR_ARRAY_MAX_RANGE)
	if(best > 0)
		return best
	return suite == SENSOR_OPTICAL ? SENSOR_ARRAY_BLIND_OPTICAL : 0

/obj/structure/overmap/get_suite_range(suite, obj/structure/overmap/target)
	. = ..()
	// Radar gracza ma mnożnik już w get_player_lidar_range (player_sensors.dm)
	if(!ai_controlled && suite == SENSOR_LIDAR)
		return
	. *= get_sensor_array_mult(suite, target)


/obj/machinery/ship_sensor_array
	name = "matryca sensorów"
	desc = "Anteny i czujniki okrętu na kadłubie. Obejmuje jedną ćwiartkę wokół statku: bez niej radar, teleskop i podczerwień są tam ślepe."
	icon = 'aquila/icons/obj/machinery/ship_sensors.dmi'
	icon_state = "sensors"
	density = TRUE
	anchored = TRUE
	max_integrity = 300
	integrity_failure = 100
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 20, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 70, "stamina" = 0, "bleed" = 0)
	use_power = IDLE_POWER_USE
	idle_power_usage = 500
	active_power_usage = 0
	/// Statek, któremu matryca daje zasięg
	var/obj/structure/overmap/linked_ship
	/// Czy operator ją włączył
	var/on = TRUE
	/// Bieżący zasięg (dochodzi do żądanego o 1 na cykl)
	var/range = 0
	/// Zasięg ustawiony przez operatora
	var/desired_range = 6
	var/heat = 0

/obj/machinery/ship_sensor_array/Destroy()
	unlink_ship()
	return ..()

/obj/machinery/ship_sensor_array/proc/link_to_ship(obj/structure/overmap/ship)
	if(linked_ship == ship)
		return
	unlink_ship()
	if(!ship)
		return
	linked_ship = ship
	ship.had_sensor_array = TRUE
	LAZYOR(ship.sensor_arrays, src)

/obj/machinery/ship_sensor_array/proc/unlink_ship()
	if(!linked_ship)
		return
	LAZYREMOVE(linked_ship.sensor_arrays, src)
	linked_ship = null

/obj/machinery/ship_sensor_array/proc/in_vacuum()
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/air = T?.return_air()
	return !air || air.return_pressure() < SENSOR_ARRAY_VACUUM

/obj/machinery/ship_sensor_array/proc/is_working()
	return on && range > 0 && !(machine_stat & (BROKEN|NOPOWER)) && in_vacuum()

/// Najwyższy zasięg, na jaki pozwala limit sensorów z podziału mocy
/obj/machinery/ship_sensor_array/proc/allowed_range()
	var/datum/ship_power/power = linked_ship?.ship_power
	if(!power)
		return SENSOR_ARRAY_MAX_RANGE
	var/max_draw = SENSOR_ARRAY_POWER_PER_RANGE2 * SENSOR_ARRAY_MAX_RANGE ** 2
	return clamp(round(sqrt(power.limits[SHIP_POWER_SENSORS] * max_draw / SENSOR_ARRAY_POWER_PER_RANGE2)), 0, SENSOR_ARRAY_MAX_RANGE)

/obj/machinery/ship_sensor_array/process(delta_time)
	if(!linked_ship || QDELETED(linked_ship))
		link_to_ship(get_overmap())
	var/working = on && !(machine_stat & (BROKEN|NOPOWER)) && in_vacuum()
	var/target = working ? min(desired_range, allowed_range()) : 0
	if(range < target)
		range++
	else if(range > target)
		range--
	active_power_usage = SENSOR_ARRAY_POWER_PER_RANGE2 * range ** 2
	use_power = range > 0 ? ACTIVE_POWER_USE : IDLE_POWER_USE
	linked_ship?.get_ship_power().record(SHIP_POWER_SENSORS, active_power_usage, src, SENSOR_ARRAY_POWER_PER_RANGE2 * SENSOR_ARRAY_MAX_RANGE ** 2)
	heat = max(0, heat + active_power_usage / SENSOR_ARRAY_HEAT_DIVISOR - SENSOR_ARRAY_COOLING)
	if(heat > SENSOR_ARRAY_CRITICAL_HEAT)
		overheat()
	update_icon()

/obj/machinery/ship_sensor_array/proc/overheat()
	visible_message("<span class='danger'>[src] sypie iskrami i wyłącza się z przegrzania!</span>")
	do_sparks(5, TRUE, src)
	on = FALSE
	heat = SENSOR_ARRAY_CRITICAL_HEAT * 0.6
	take_damage(rand(30, 60), BURN, "fire", FALSE)

/obj/machinery/ship_sensor_array/update_icon_state()
	. = ..()
	if(machine_stat & BROKEN)
		icon_state = "sensors_off"
	else
		icon_state = is_working() ? "sensors_on" : "sensors"

/obj/machinery/ship_sensor_array/update_overlays()
	. = ..()
	if(!is_working())
		return
	. += "sensors-effect[clamp(round(range / 2), 1, 5)]"
	if(heat > SENSOR_ARRAY_CRITICAL_HEAT * 0.7)
		. += "sensors-effect-hot"

/// Zniszczona matryca zostaje jako wrak do naprawy spawarką
/obj/machinery/ship_sensor_array/obj_destruction(damage_flag)
	obj_integrity = 1
	obj_break(damage_flag)

/obj/machinery/ship_sensor_array/obj_break(damage_flag)
	. = ..()
	if(machine_stat & BROKEN)
		do_sparks(3, TRUE, src)
		update_icon()

/obj/machinery/ship_sensor_array/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	on = FALSE
	take_damage(20 / severity, BURN, "energy", FALSE)

/obj/machinery/ship_sensor_array/welder_act(mob/living/user, obj/item/I)
	if(user.combat_mode)
		return FALSE
	if(obj_integrity >= max_integrity && !(machine_stat & BROKEN))
		to_chat(user, "<span class='notice'>[src] nie wymaga naprawy.</span>")
		return TRUE
	if(!I.tool_start_check(user, amount = 1))
		return TRUE
	to_chat(user, "<span class='notice'>Zaczynasz spawać [src]...</span>")
	if(!I.use_tool(src, user, (machine_stat & BROKEN) ? 8 SECONDS : 4 SECONDS, volume = 50, amount = 1))
		return TRUE
	obj_integrity = max_integrity
	set_machine_stat(machine_stat & ~BROKEN)
	update_icon()
	user.visible_message("<span class='notice'>[user] naprawia [src].</span>", "<span class='notice'>Naprawiasz [src].</span>")
	return TRUE

/// Stan dla okna stanowiska rozpoznania
/obj/machinery/ship_sensor_array/proc/status_text()
	if(machine_stat & BROKEN)
		return "ZNISZCZONA"
	if(machine_stat & NOPOWER)
		return "BRAK ZASILANIA"
	if(!in_vacuum())
		return "NIESZCZELNA WNĘKA"
	if(!on)
		return "WYŁĄCZONA"
	return "DZIAŁA"

/obj/machinery/ship_sensor_array/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Stan: [status_text()], zasięg [range]/[SENSOR_ARRAY_MAX_RANGE], ciepło [round(heat)]/[SENSOR_ARRAY_CRITICAL_HEAT].</span>"
	if(obj_integrity < max_integrity)
		. += "<span class='notice'>Obudowa jest uszkodzona ([round(obj_integrity / max_integrity * 100)]%). Spawarka ją naprawi.</span>"

// --- Stanowisko rozpoznania: sterowanie matrycami ---

/obj/machinery/computer/ship/dradis/sensors/ui_data(mob/user)
	. = ..()
	if(!linked || !linked.had_sensor_array)
		return
	var/list/arrays = list()
	var/desired = SENSOR_ARRAY_MAX_RANGE
	var/allowed = SENSOR_ARRAY_MAX_RANGE
	var/any_on = FALSE
	for(var/obj/machinery/ship_sensor_array/array as anything in linked.sensor_arrays)
		desired = array.desired_range
		allowed = array.allowed_range()
		any_on = any_on || array.on
		arrays += list(list(
			"sector" = sensor_array_sector_name(array.dir),
			"status" = array.status_text(),
			"working" = array.is_working(),
			"range" = array.range,
			"heat" = round(array.heat),
			"power" = display_power(array.active_power_usage)
		))
	.["sensor_array"] = list(
		"arrays" = arrays,
		"on" = any_on,
		"desired_range" = desired,
		"allowed_range" = allowed,
		"max_range" = SENSOR_ARRAY_MAX_RANGE,
		"critical_heat" = SENSOR_ARRAY_CRITICAL_HEAT
	)

/obj/machinery/computer/ship/dradis/sensors/ui_act(action, params)
	. = ..()
	if(. || isobserver(usr) || !linked)
		return
	switch(action)
		if("array_range")
			var/value = text2num(params["value"])
			if(!isnum_safe(value))
				return TRUE
			for(var/obj/machinery/ship_sensor_array/array as anything in linked.sensor_arrays)
				array.desired_range = clamp(round(value), 1, SENSOR_ARRAY_MAX_RANGE)
			return TRUE
		if("array_toggle")
			var/turn_on = !!params["on"]
			for(var/obj/machinery/ship_sensor_array/array as anything in linked.sensor_arrays)
				if(!(array.machine_stat & BROKEN))
					array.on = turn_on
			return TRUE

#undef SENSOR_ARRAY_MAX_RANGE
#undef SENSOR_ARRAY_POWER_PER_RANGE2
#undef SENSOR_ARRAY_HEAT_DIVISOR
#undef SENSOR_ARRAY_COOLING
#undef SENSOR_ARRAY_CRITICAL_HEAT
#undef SENSOR_ARRAY_BLIND_OPTICAL
#undef SENSOR_ARRAY_VACUUM
#undef SHIP_MAP_BOW_DIR
