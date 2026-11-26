// Atmosbot z Bee na basic bocie: łata wyłomy holobarierą, dopompowuje powietrze, filtruje gazy, pilnuje temperatury.

#define BATMOS_MAX_AREA_SCAN 100
#define BATMOS_BARRIER_COOLDOWN_TIME (15 SECONDS)
#define BATMOS_MAX_PRESSURE_CHANGE 150
#define BATMOS_MAX_SCRUB_CHANGE 15
#define BATMOS_CHECK_BREACH 0
#define BATMOS_LOW_OXYGEN 1
#define BATMOS_HIGH_TOXINS 2
#define BATMOS_BAD_TEMP 3
#define BATMOS_AREA_STABLE 4
#define BATMOS_NOTHING 0
#define BATMOS_DEPLOY_BARRIER 1
#define BATMOS_VENT_AIR 2
#define BATMOS_SCRUB_TOXINS 3
#define BATMOS_TEMPERATURE_CONTROL 4

/mob/living/basic/bot/atmosbot
	name = "\improper Atmosbot"
	desc = "Mały robot, który chyba po prostu cieszy się, że utrzymuje cię przy życiu!"
	icon_state = "atmosbot0"
	maxHealth = 25
	health = 25
	radio_key = /obj/item/encryptionkey/headset_eng
	radio_channel = RADIO_CHANNEL_ENGINEERING
	model = "Atmosbot"
	hackables = "protokoły bezpieczeństwa"
	bot_mode_flags = BOT_MODE_ON | BOT_MODE_REMOTE_ENABLED | BOT_MODE_AUTOPATROL | BOT_MODE_CAN_BE_SAPIENT
	work_reach = 0
	work_interval = 1 SECONDS
	possessed_message = "Jesteś atmosbotem! Pilnuj, żeby załoga miała czym oddychać."
	emagged_message = "Jesteś zepsutym atmosbotem! Zatruwaj powietrze dwutlenkiem węgla."
	/// Co bot robi z bieżącym celem
	var/action = BATMOS_NOTHING
	/// Ciśnienie, przy którym szuka wyłomu
	var/breached_pressure = 20
	var/temperature_control = FALSE
	var/ideal_temperature = T20C
	var/datum/weakref/deployed_holobarrier
	COOLDOWN_DECLARE(barrier_cooldown)
	/// Filtrowane gazy
	var/list/gasses = list(
		GAS_BZ = 1,
		GAS_CO2 = 1,
		GAS_HYPERNOB = 1,
		GAS_NITROUS = 1,
		GAS_NITRYL = 1,
		GAS_PLASMA = 1,
		GAS_PLUOXIUM = 0,
		GAS_STIMULUM = 0,
		GAS_TRITIUM = 1,
		GAS_H2O = 0,
		GAS_CONSTRICTED_PLASMA = 1,
		GAS_NUCLEIUM = 1,
		GAS_MIASMA = 1,
		GAS_H2 = 1,
		GAS_FREZON = 1,
		GAS_METHANE = 1,
	)
	var/tank_type = /obj/item/tank/internals/oxygen/empty

/mob/living/basic/bot/atmosbot/Initialize(mapload)
	additional_access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_ATMOSPHERICS, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)

/mob/living/basic/bot/atmosbot/req_bot_access()
	return ..() + list(ACCESS_ENGINE, ACCESS_ATMOSPHERICS)

/mob/living/basic/bot/atmosbot/update_icon_state()
	. = ..()
	var/on = !!(bot_mode_flags & BOT_MODE_ON)
	if(action == BATMOS_VENT_AIR && is_emagged())
		icon_state = "atmosbot[on][on ? "_5" : ""]"
		return
	icon_state = "atmosbot[on][on ? "_[action]" : ""]"

/mob/living/basic/bot/atmosbot/emag_effects(mob/user)
	audible_message(span_danger("[src] warczy złowieszczo."))
	playsound(src, "sparks", 75, TRUE)

/mob/living/basic/bot/atmosbot/idle_chatter()
	audible_message("[src] wydaje podekscytowany warkot!")

/// Ocena powietrza i wybór działania: kandydatem jest jeden kafelek (wyłom albo miejsce na wentylację)
/mob/living/basic/bot/atmosbot/get_work_candidates()
	var/turf/our_turf = get_turf(src)
	action = BATMOS_NOTHING
	if(!our_turf || isspaceturf(our_turf))
		return list()
	var/turf/target
	switch(check_area_atmos())
		if(BATMOS_CHECK_BREACH)
			if(COOLDOWN_FINISHED(src, barrier_cooldown))
				target = return_nearest_breach()
				action = BATMOS_DEPLOY_BARRIER
			if(!target)
				target = get_vent_turf()
				action = BATMOS_VENT_AIR
		if(BATMOS_LOW_OXYGEN)
			target = get_vent_turf()
			action = BATMOS_VENT_AIR
		if(BATMOS_HIGH_TOXINS)
			target = get_vent_turf()
			action = BATMOS_SCRUB_TOXINS
		if(BATMOS_BAD_TEMP)
			target = get_vent_turf()
			action = BATMOS_TEMPERATURE_CONTROL
		if(BATMOS_AREA_STABLE)
			if(is_emagged() && prob(20))
				target = get_vent_turf()
				action = BATMOS_VENT_AIR
	update_appearance()
	return target ? list(target) : list()

/mob/living/basic/bot/atmosbot/work_on_target(atom/target)
	if(get_turf(src) != get_turf(target))
		return BOT_WORK_OUT_OF_REACH
	switch(action)
		if(BATMOS_DEPLOY_BARRIER)
			deploy_holobarrier()
		if(BATMOS_VENT_AIR)
			vent_air()
		if(BATMOS_SCRUB_TOXINS)
			scrub_toxins()
		if(BATMOS_TEMPERATURE_CONTROL)
			change_temperature()
	return BOT_WORK_DONE

/mob/living/basic/bot/atmosbot/proc/change_temperature()
	var/datum/gas_mixture/environment = loc.return_air()
	environment?.set_temperature(ideal_temperature)

/mob/living/basic/bot/atmosbot/proc/vent_air()
	var/datum/gas_mixture/environment = loc.return_air()
	if(!environment)
		return
	var/pressure_delta = min(BATMOS_MAX_PRESSURE_CHANGE, (ONE_ATMOSPHERE - environment.return_pressure()))
	if(pressure_delta <= 0)
		return
	var/transfer_moles = pressure_delta * environment.return_volume() / (T20C * R_IDEAL_GAS_EQUATION)
	if(is_emagged())
		environment.adjust_moles(GAS_CO2, transfer_moles)
	else
		environment.adjust_moles(GAS_N2, transfer_moles * 0.7885)
		environment.adjust_moles(GAS_O2, transfer_moles * 0.2115)
	new /obj/effect/temp_visual/vent_wind(get_turf(src))

/mob/living/basic/bot/atmosbot/proc/scrub_toxins()
	var/datum/gas_mixture/environment = loc.return_air()
	if(!environment)
		return
	for(var/gas_id in gasses)
		if(gasses[gas_id])
			environment.adjust_moles(gas_id, -min(environment.get_moles(gas_id), BATMOS_MAX_SCRUB_CHANGE))

/mob/living/basic/bot/atmosbot/proc/deploy_holobarrier()
	qdel(deployed_holobarrier?.resolve())
	deployed_holobarrier = WEAKREF(new /obj/structure/holosign/barrier/atmos(get_turf(src)))
	COOLDOWN_START(src, barrier_cooldown, BATMOS_BARRIER_COOLDOWN_TIME)

/mob/living/basic/bot/atmosbot/proc/check_area_atmos()
	var/datum/gas_mixture/gas_mix = loc.return_air()
	if(!gas_mix)
		return BATMOS_AREA_STABLE
	if(gas_mix.return_pressure() < breached_pressure)
		return BATMOS_CHECK_BREACH
	if(!is_emagged())
		for(var/gas_id in gasses)
			if(gasses[gas_id] && gas_mix.get_moles(gas_id) > 0.2)
				return BATMOS_HIGH_TOXINS
	var/partial_pressure = R_IDEAL_GAS_EQUATION * gas_mix.return_temperature() / gas_mix.return_volume()
	if(gas_mix.get_moles(GAS_O2) * partial_pressure < 20 || gas_mix.return_pressure() < WARNING_LOW_PRESSURE)
		return BATMOS_LOW_OXYGEN
	if(temperature_control && abs(gas_mix.return_temperature() - ideal_temperature) > 0.5)
		return BATMOS_BAD_TEMP
	return BATMOS_AREA_STABLE

/mob/living/basic/bot/atmosbot/proc/get_vent_turf()
	var/turf/target_turf = get_turf(src)
	var/blocked = locate(/obj/structure/holosign/barrier/atmos) in target_turf
	if(!target_turf.CanAtmosPass(target_turf) || blocked)
		var/turf/open/floor/floor_turf = pick(view(3, src))
		if(istype(floor_turf))
			target_turf = floor_turf
	return target_turf

/// Najbliższy kafelek przy wyłomie (sąsiad próżni)
/mob/living/basic/bot/atmosbot/proc/return_nearest_breach()
	var/turf/origin = get_turf(src)
	if(origin.blocks_air)
		return null
	var/room_limit = BATMOS_MAX_AREA_SCAN
	var/list/checked_turfs = list()
	var/list/to_check_turfs = list(origin)
	while(room_limit > 0 && length(to_check_turfs))
		room_limit--
		var/turf/checking_turf = to_check_turfs[1]
		checked_turfs += checking_turf
		to_check_turfs -= checking_turf
		if(locate(/obj/structure/holosign/barrier/atmos) in checking_turf)
			continue
		if(!checking_turf.CanAtmosPass(checking_turf))
			continue
		for(var/direction in GLOB.cardinals)
			var/turf/adjacent_turf = get_step(checking_turf, direction)
			if(!adjacent_turf || (adjacent_turf in checked_turfs) || !adjacent_turf.CanAtmosPass(adjacent_turf))
				continue
			// próżnia (także w /area/space) to wyłom; dalej po kafelkach w kosmosie nie szuka
			if(isspaceturf(adjacent_turf))
				return checking_turf
			if(istype(adjacent_turf.loc, /area/space))
				continue
			to_check_turfs |= adjacent_turf
	return null

/mob/living/basic/bot/atmosbot/UnarmedAttack(atom/target, proximity_flag)
	if(isturf(target) && target == get_turf(src))
		deploy_holobarrier()
		return
	return ..()

/mob/living/basic/bot/atmosbot/get_custom_controls(mob/user)
	return list(
		"breach_pressure" = breached_pressure,
		"temperature_control" = temperature_control,
		"ideal_temperature" = ideal_temperature,
	)

/mob/living/basic/bot/atmosbot/ui_data(mob/user)
	var/list/data = ..()
	var/list/scrub_gases = list()
	for(var/gas_id in gasses)
		scrub_gases += list(list(
			"id" = "[gas_id]",
			"name" = GLOB.gas_data.names[gas_id],
			"enabled" = gasses[gas_id],
		))
	data["scrub_gases"] = scrub_gases
	return data

/mob/living/basic/bot/atmosbot/bot_custom_act(action, list/params, mob/user)
	switch(action)
		if("breach_pressure")
			var/new_breach_pressure = text2num(params["value"])
			if(!isnum(new_breach_pressure))
				return FALSE
			breached_pressure = clamp(new_breach_pressure, 0, 100)
		if("temperature_control")
			temperature_control = !temperature_control
		if("ideal_temperature")
			var/new_temp = text2num(params["value"])
			if(!isnum(new_temp))
				return FALSE
			ideal_temperature = clamp(new_temp, T0C, T20C + 20)
		if("toggle_gas")
			var/gas_id = params["gas"]
			for(var/gas in gasses)
				if("[gas]" == gas_id)
					gasses[gas] = !gasses[gas]
		else
			return FALSE
	update_appearance()
	return TRUE

/mob/living/basic/bot/atmosbot/explode()
	var/atom/drop_spot = drop_location()
	new /obj/item/assembly/prox_sensor(drop_spot)
	new /obj/item/analyzer(drop_spot)
	var/obj/item/tank/tank = new tank_type(drop_spot)
	var/datum/gas_mixture/environment = drop_spot.return_air()
	if(tank && environment)
		environment.merge(tank.air_contents)
		new /obj/effect/temp_visual/vent_wind(drop_spot)
	qdel(deployed_holobarrier?.resolve())
	return ..()

#undef BATMOS_MAX_AREA_SCAN
#undef BATMOS_BARRIER_COOLDOWN_TIME
#undef BATMOS_MAX_PRESSURE_CHANGE
#undef BATMOS_MAX_SCRUB_CHANGE
#undef BATMOS_CHECK_BREACH
#undef BATMOS_LOW_OXYGEN
#undef BATMOS_HIGH_TOXINS
#undef BATMOS_BAD_TEMP
#undef BATMOS_AREA_STABLE
#undef BATMOS_NOTHING
#undef BATMOS_DEPLOY_BARRIER
#undef BATMOS_VENT_AIR
#undef BATMOS_SCRUB_TOXINS
#undef BATMOS_TEMPERATURE_CONTROL
