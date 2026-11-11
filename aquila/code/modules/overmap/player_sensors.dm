/// AQUILA - sensory okrętu gracza z konsolą sensorów: te same zestawy co u AI (ai_sensor_suites.dm), czyli
/// kamera szerokokątna, teleskop, podczerwień ze ślepym klinem za rufą i radar, zamiast jednego zasięgu z sygnatury.
/// Teleskopem kieruje operator (cel, kurs albo kierunek ręczny). Okręt bez konsoli sensorów działa jak dotąd.
/// Zasięgi gracza są dłuższe o ten sam stosunek co dawniej (60 pól bazowego zasięgu DRADIS gracza wobec 50 u AI).

/// Admin: sensory gracza (Debug > Toggle player sensor suites)
GLOBAL_VAR_INIT(player_sensor_suites_enabled, TRUE)

#define PLAYER_SUITE_RANGE_MULT 1.2
#define TELESCOPE_MODE_TARGET "cel"
#define TELESCOPE_MODE_COURSE "kurs"
#define TELESCOPE_MODE_MANUAL "recznie"

/obj/structure/overmap
	/// AQUILA - jak operator kieruje teleskopem okrętu gracza (TELESCOPE_MODE_*)
	var/telescope_mode = TELESCOPE_MODE_TARGET
	/// AQUILA - namiar teleskopu w trybie ręcznym
	var/telescope_manual_bearing = 0

/// Czy ten okręt wykrywa przez zestawy sensorów
/obj/structure/overmap/proc/uses_sensor_suites()
	if(ai_controlled)
		return TRUE
	return GLOB.player_sensor_suites_enabled && !QDELETED(sensor_console)

/obj/structure/overmap/get_suite_range(suite, obj/structure/overmap/target)
	. = ..()
	if(!ai_controlled && suite != SENSOR_LIDAR)
		. *= PLAYER_SUITE_RANGE_MULT

/// Cel teleskopu w trybie "cel": cel główny od operatora, potem cel działonowego
/obj/structure/overmap/proc/get_telescope_target()
	for(var/obj/structure/overmap/target as anything in designated_targets)
		if(designated_targets[target] == "primary" && !QDELETED(target) && target.z == z)
			return target
	if(istype(target_lock) && !QDELETED(target_lock) && target_lock.z == z)
		return target_lock

/obj/structure/overmap/get_telescope_bearing()
	if(ai_controlled || !uses_sensor_suites())
		return ..()
	switch(telescope_mode)
		if(TELESCOPE_MODE_MANUAL)
			return telescope_manual_bearing
		if(TELESCOPE_MODE_TARGET)
			var/obj/structure/overmap/target = get_telescope_target()
			if(target)
				var/bearing = overmap_angle(src, target)
				if(!isnull(bearing))
					return bearing
	return angle

/// Co każdy sensor tego okrętu widzi na target: lista list("suite", "reach" w polach, "state").
/// state: "sees" widzi, "far" za daleko, "cone" poza stożkiem teleskopu, "blind" oślepiony własnym napędem, "off" wyłączony
/obj/structure/overmap/proc/get_suite_report(obj/structure/overmap/target)
	. = list()
	var/dist = overmap_dist(src, target)
	var/pulse = world.time < last_radar_pulse + RADAR_VISIBILITY_PENALTY
	var/mult = ai_controlled ? 1 : PLAYER_SUITE_RANGE_MULT
	for(var/suite in get_sensor_suites())
		var/reach = 0
		var/state
		switch(suite)
			if(SENSOR_TELESCOPE)
				reach = get_telescope_reach(target) * mult
				state = !is_in_telescope_cone(target) ? "cone" : (reach >= dist ? "sees" : "far")
			if(SENSOR_INFRARED)
				reach = get_infrared_reach(target) * mult
				state = is_infrared_blinded_toward(target) ? "blind" : (reach >= dist ? "sees" : "far")
			if(SENSOR_LIDAR)
				reach = pulse ? (ai_controlled ? max_tracking_range : SENSOR_MAX_DETECTION * 2) : 0
				state = pulse ? "sees" : "off"
			else
				reach = get_suite_range(suite, target)
				state = reach >= dist ? "sees" : "far"
		. += list(list("suite" = suite, "reach" = round(reach), "state" = state))

/obj/machinery/computer/ship/dradis/sensors/ui_act(action, params)
	. = ..()
	if(. || isobserver(usr) || !linked)
		return
	switch(action)
		if("set_telescope")
			if(params["mode"] in list(TELESCOPE_MODE_TARGET, TELESCOPE_MODE_COURSE, TELESCOPE_MODE_MANUAL))
				linked.telescope_mode = params["mode"]
			var/bearing = text2num(params["bearing"])
			if(isnum(bearing))
				linked.telescope_manual_bearing = SIMPLIFY_DEGREES(round(bearing))
				linked.telescope_mode = TELESCOPE_MODE_MANUAL
			return TRUE

/obj/machinery/computer/ship/dradis/sensors/ui_data(mob/user)
	. = ..()
	var/list/data = .
	if(!linked)
		return
	var/suites = GLOB.ai_sensor_suites_enabled && linked.uses_sensor_suites()
	var/cones = suites && GLOB.ai_sensor_cones_enabled
	data["suites"] = suites
	data["cones"] = cones
	data["heading"] = round(linked.angle)
	data["heat"] = round(linked.thrust_heat, 0.01)
	data["dampeners"] = !!linked.inertial_dampeners
	data["telescope_mode"] = linked.telescope_mode
	data["telescope_bearing"] = cones ? round(linked.get_telescope_bearing()) : null
	data["telescope_half"] = TELESCOPE_HALF_ANGLE
	var/obj/structure/overmap/aim = linked.telescope_mode == TELESCOPE_MODE_TARGET ? linked.get_telescope_target() : null
	data["telescope_target"] = aim ? "\ref[aim]" : null
	data["ir_blind"] = cones && linked.is_infrared_rear_blind()
	data["ir_blind_half"] = INFRARED_BLIND_HALF_ANGLE
	data["camera_reach"] = round(linked.get_optical_reach(1) * PLAYER_SUITE_RANGE_MULT)
	if(!suites)
		return
	for(var/list/contact as anything in data["contacts"])
		var/obj/structure/overmap/OM = locate(contact["id"])
		if(!istype(OM))
			continue
		contact["sensor"] = linked.get_contact_suite(OM)
		contact["suites"] = linked.get_suite_report(OM)

/world/AVerbsDebug()
	. = ..()
	. += /client/proc/toggle_player_sensor_suites

/client/proc/toggle_player_sensor_suites()
	set category = "Debug"
	set name = "Toggle player sensor suites"
	set desc = "Włącza lub wyłącza zestawy sensorów (kamera, teleskop, podczerwień) na okrętach graczy z konsolą sensorów."
	if(!check_rights(R_DEBUG))
		return
	GLOB.player_sensor_suites_enabled = !GLOB.player_sensor_suites_enabled
	var/state = GLOB.player_sensor_suites_enabled ? "włączył" : "wyłączył"
	message_admins("[key_name_admin(usr)] [state] zestawy sensorów okrętów graczy.")
	log_admin("[key_name(usr)] toggled player sensor suites to [GLOB.player_sensor_suites_enabled].")

#undef PLAYER_SUITE_RANGE_MULT
#undef TELESCOPE_MODE_TARGET
#undef TELESCOPE_MODE_COURSE
#undef TELESCOPE_MODE_MANUAL
