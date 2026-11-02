#define CAN_DEFAULT_RELEASE_PRESSURE (ONE_ATMOSPHERE)

/obj/machinery/portable_atmospherics/canister
	name = "kanister"
	desc = "Kanister do przechowywania gazu."
	icon = 'icons/obj/atmospherics/canisters.dmi'
	icon_state = "#mapme"
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#ffff00#000000"
	density = TRUE
	var/valve_open = FALSE
	var/obj/machinery/atmospherics/components/binary/passive_gate/pump
	var/release_log = ""

	volume = 1000
	var/filled = 0.5
	var/gas_type
	var/release_pressure = ONE_ATMOSPHERE
	var/can_max_release_pressure = (ONE_ATMOSPHERE * 10)
	var/can_min_release_pressure = (ONE_ATMOSPHERE / 10)

	armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 50, "stamina" = 0, "bleed" = 0)
	max_integrity = 250
	integrity_failure = 100
	pressure_resistance = 7 * ONE_ATMOSPHERE
	var/temperature_resistance = 1000 + T0C
	var/starter_temp = T20C
	// Prototype vars
	var/prototype = FALSE
	var/valve_timer = null
	var/timer_set = 30
	var/default_timer_set = 30
	var/minimum_timer_set = 1
	var/maximum_timer_set = 300
	var/timing = FALSE
	var/restricted = FALSE
	req_access = list()

	var/icon/canister_overlay_file = 'icons/obj/atmospherics/canisters.dmi'

	//list of canister types for relabeling
	var/static/list/label2types = list(
		"n2" = /obj/machinery/portable_atmospherics/canister/nitrogen,
		"o2" = /obj/machinery/portable_atmospherics/canister/oxygen,
		"co2" = /obj/machinery/portable_atmospherics/canister/carbon_dioxide,
		"plazma" = /obj/machinery/portable_atmospherics/canister/toxins,
		"n2o" = /obj/machinery/portable_atmospherics/canister/nitrous_oxide,
		"no2" = /obj/machinery/portable_atmospherics/canister/nitryl,
		"bz" = /obj/machinery/portable_atmospherics/canister/bz,
		"powietrze" = /obj/machinery/portable_atmospherics/canister/air,
		"para wodna" = /obj/machinery/portable_atmospherics/canister/water_vapor,
		"tryt" = /obj/machinery/portable_atmospherics/canister/tritium,
		"hipernoblium" = /obj/machinery/portable_atmospherics/canister/nob,
		"stymulum" = /obj/machinery/portable_atmospherics/canister/stimulum,
		"pluoksium" = /obj/machinery/portable_atmospherics/canister/pluoxium,
		"ostrzeżenie" = /obj/machinery/portable_atmospherics/canister,
		"nukleium" = /obj/machinery/portable_atmospherics/canister/nucleium,	//NSV13
		"skondensowana plazma" = /obj/machinery/portable_atmospherics/canister/constricted_plasma, //NSV13
		"miazma" = /obj/machinery/portable_atmospherics/canister/miasma, // AQ EDIT - Miasma
	)

/obj/machinery/portable_atmospherics/canister/interact(mob/user)
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Błąd – nieupoważniony użytkownik</span>")
		playsound(src, 'sound/misc/compiler-failure.ogg', 50, 1)
		return
	..()

/obj/machinery/portable_atmospherics/canister/air
	name = "kanister powietrza"
	desc = "Gotowa mieszanka powietrza."
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#c6c0b5"

/obj/machinery/portable_atmospherics/canister/bz
	name = "\improper kanister BZ"
	desc = "BZ, silny halucynogenny środek paralityczno-drgawkowy."
	gas_type = GAS_BZ
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#9b5d7f#d0d2a0"

/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "kanister CO2"
	desc = "Dwutlenek węgla. Co to, kurwa, jest dwutlenek węgla?"
	gas_type = GAS_CO2
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#4e4c48"

/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "kanister N2"
	desc = "Azot. Podobno do czegoś się przydaje."
	gas_type = GAS_N2
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#d41010"

/obj/machinery/portable_atmospherics/canister/nitrous_oxide
	name = "kanister N2O"
	desc = "Podtlenek azotu. Znany z tego, że usypia."
	gas_type = GAS_NITROUS
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#c63e3b#f7d5d3"

/obj/machinery/portable_atmospherics/canister/nitryl
	name = "kanister nitrylu"
	desc = "Nitryl. Czujesz się świetnie, dopóki kwas nie zeżre ci płuc."
	gas_type = GAS_NITRYL
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#7b4732"

/obj/machinery/portable_atmospherics/canister/nob
	name = "kanister hipernoblium"
	desc = "Hipernoblium. Szlachetniejsze od wszystkich innych gazów."
	gas_type = GAS_HYPERNOB
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#6399fc#b2b2b2"

/obj/machinery/portable_atmospherics/canister/oxygen
	name = "kanister O2"
	desc = "Tlen. Niezbędny do życia człowieka."
	gas_type = GAS_O2
	greyscale_config = /datum/greyscale_config/canister/stripe
	greyscale_colors = "#2786e5#e8fefe"

/obj/machinery/portable_atmospherics/canister/pluoxium
	name = "kanister pluoksium"
	desc = "Pluoksium. Jak tlen, tylko wydajniejsze."
	gas_type = GAS_PLUOXIUM
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#2786e5"

/obj/machinery/portable_atmospherics/canister/stimulum
	name = "kanister stymulum"
	desc = "Stymulum. Energetyczny gaz, energetyczni ludzie."
	gas_type = GAS_STIMULUM
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#9b5d7f"

/obj/machinery/portable_atmospherics/canister/toxins
	name = "kanister plazmy"
	desc = "Plazma. Powód, dla którego TY tu jesteś. Bardzo toksyczna."
	gas_type = GAS_PLASMA
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#f62800#000000"

/obj/machinery/portable_atmospherics/canister/tritium
	name = "kanister trytu"
	desc = "Tryt. Wdychanie może napromieniować."
	gas_type = GAS_TRITIUM
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#3fcd40#000000"

/obj/machinery/portable_atmospherics/canister/water_vapor
	name = "kanister pary wodnej"
	desc = "Para wodna. Dobra, łapiemy, wapujesz."
	gas_type = GAS_H2O
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#4c4e4d#f7d5d3"

/obj/machinery/portable_atmospherics/canister/proc/get_time_left()
	if(timing)
		. = round(max(0, valve_timer - world.time) / 10, 1)
	else
		. = timer_set

/obj/machinery/portable_atmospherics/canister/proc/set_active()
	timing = !timing
	if(timing)
		valve_timer = world.time + (timer_set * 10)
	update_icon()

/obj/machinery/portable_atmospherics/canister/proto
	name = "prototypowy kanister"
	greyscale_config = /datum/greyscale_config/prototype_canister
	greyscale_colors = "#ffffff#a50021#ffffff"

/obj/machinery/portable_atmospherics/canister/proto/default
	name = "prototypowy kanister"
	desc = "Najlepszy sposób na opanowanie awarii atmosfery... albo na jej wywołanie."
	volume = 5000
	max_integrity = 300
	temperature_resistance = 2000 + T0C
	can_max_release_pressure = (ONE_ATMOSPHERE * 30)
	can_min_release_pressure = (ONE_ATMOSPHERE / 30)
	prototype = TRUE

/obj/machinery/portable_atmospherics/canister/proto/default/oxygen
	name = "prototypowy kanister"
	desc = "Prototypowy kanister do prototypowego roweru. Co mogłoby pójść nie tak?"
	gas_type = GAS_O2
	filled = 1
	release_pressure = ONE_ATMOSPHERE*2

/obj/machinery/portable_atmospherics/canister/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_MODIFY_CANISTER_GAS, "Zmień gaz w kanistrze")

/obj/machinery/portable_atmospherics/canister/vv_do_topic(href_list)
	. = ..()
	if(href_list[VV_HK_MODIFY_CANISTER_GAS])
		usr.client.modify_canister_gas(src)

/obj/machinery/portable_atmospherics/canister/Initialize(mapload, datum/gas_mixture/existing_mixture)
	. = ..()
	if(existing_mixture)
		air_contents.copy_from(existing_mixture)
	else
		create_gas()
	pump = new(src, FALSE)
	pump.on = TRUE
	pump.machine_stat = 0
	SSair.add_to_rebuild_queue(pump)

/obj/machinery/portable_atmospherics/canister/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/portable_atmospherics/canister/Destroy()
	qdel(pump)
	pump = null
	return ..()

/obj/machinery/portable_atmospherics/canister/proc/create_gas()
	if(gas_type)
		if(starter_temp)
			air_contents.set_temperature(starter_temp)
		if(air_contents.return_volume() == 0)
			CRASH("Air content volume is zero, this shouldn't be the case volume is: [volume]!")
		if(air_contents.return_temperature() == 0)
			CRASH("Air content temperature is zero, this shouldn't be the case!")
		if (gas_type)
			air_contents.set_moles(gas_type, (maximum_pressure * filled) * air_contents.return_volume() / (R_IDEAL_GAS_EQUATION * air_contents.return_temperature()))

/obj/machinery/portable_atmospherics/canister/air/create_gas()
	if(air_contents.return_volume() == 0)
		CRASH("Air content volume is zero, this shouldn't be the case volume is: [volume]!")
	if(air_contents.return_temperature() == 0)
		CRASH("Air content temperature is zero, this shouldn't be the case!")
	air_contents.set_temperature(starter_temp)
	air_contents.set_moles(GAS_O2, (O2STANDARD * maximum_pressure * filled) * air_contents.return_volume() / (R_IDEAL_GAS_EQUATION * air_contents.return_temperature()))
	air_contents.set_moles(GAS_N2, (N2STANDARD * maximum_pressure * filled) * air_contents.return_volume() / (R_IDEAL_GAS_EQUATION * air_contents.return_temperature()))

/obj/machinery/portable_atmospherics/canister/update_icon()
	. = ..()
	update_overlays()

/obj/machinery/portable_atmospherics/canister/update_overlays()
	. = ..()
	if(machine_stat & BROKEN)
		. += mutable_appearance(canister_overlay_file, "broken")
		return
	if(holding)
		. += mutable_appearance(canister_overlay_file, "can-open")
	if(connected_port)
		. += mutable_appearance(canister_overlay_file, "can-connector")
	var/pressure = air_contents.return_pressure()
	switch(pressure)
		if((40 * ONE_ATMOSPHERE) to INFINITY)
			. += mutable_appearance(canister_overlay_file, "can-3")
		if((10 * ONE_ATMOSPHERE) to (40 * ONE_ATMOSPHERE))
			. += mutable_appearance(canister_overlay_file, "can-2")
		if((5 * ONE_ATMOSPHERE) to (10 * ONE_ATMOSPHERE))
			. += mutable_appearance(canister_overlay_file, "can-1")
		else
			. += mutable_appearance(canister_overlay_file, "can-0")

/obj/machinery/portable_atmospherics/canister/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > temperature_resistance)
		take_damage(5, BURN, 0)

/obj/machinery/portable_atmospherics/canister/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!(machine_stat & BROKEN))
			canister_break()
		if(disassembled)
			new /obj/item/stack/sheet/iron (loc, 10)
		else
			new /obj/item/stack/sheet/iron (loc, 5)
	qdel(src)

/obj/machinery/portable_atmospherics/canister/welder_act_secondary(mob/living/user, obj/item/I)
	. = ..()
	if(!I.tool_start_check(user, amount=1))
		return TRUE
	var/pressure = air_contents.return_pressure()
	if(pressure > 300)
		to_chat(user, "<span class='alert'>Manometr [src] wskazuje wysokie ciśnienie w środku... może lepiej się zastanów?</span>")
		message_admins("[src] rozcina: [ADMIN_LOOKUPFLW(user)]")
		log_game("[src] deconstructed by [key_name(user)]")
	to_chat(user, "<span class='notice'>Zaczynasz rozcinać [src]...</span>")
	if(I.use_tool(src, user, 3 SECONDS, volume=50))
		to_chat(user, "<span class='notice'>Rozcinasz [src].</span>")
		deconstruct(TRUE)
	return TRUE

/obj/machinery/portable_atmospherics/canister/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	if(user.combat_mode)
		return FALSE
	if(obj_integrity >= max_integrity)
		return TRUE
	if(machine_stat & BROKEN)
		return TRUE
	if(!tool.tool_start_check(user, amount=1))
		return TRUE
	to_chat(user, "<span class='notice'>Zaczynasz łatać pęknięcia w [src]...</span>")
	while(tool.use_tool(src, user, 2.5 SECONDS, volume=40))
		obj_integrity = min(obj_integrity + 25, max_integrity)
		if(obj_integrity >= max_integrity)
			to_chat(user, "<span class='notice'>Kończysz naprawiać [src].</span>")
			return TRUE
		to_chat(user, "<span class='notice'>Łatasz część pęknięć w [src]...</span>")
	return TRUE

/obj/machinery/portable_atmospherics/canister/obj_break(damage_flag)
	. = ..()
	if(!.)
		return
	canister_break()

/obj/machinery/portable_atmospherics/canister/proc/canister_break()
	disconnect()
	var/datum/gas_mixture/expelled_gas = air_contents.remove(air_contents.total_moles())
	var/turf/T = get_turf(src)
	T.assume_air(expelled_gas)

	set_machine_stat(machine_stat | BROKEN)
	density = FALSE
	playsound(src.loc, 'sound/effects/spray.ogg', 10, 1, -3)
	update_icon()
	investigate_log("was destroyed.", INVESTIGATE_ATMOS)

	if(holding)
		holding.forceMove(T)
		holding = null

	animate(src, 0.5 SECONDS, transform=turn(transform, rand(-179, 180)), easing=BOUNCE_EASING)

/obj/machinery/portable_atmospherics/canister/replace_tank(mob/living/user, close_valve)
	. = ..()
	if(!.)
		return
	if(close_valve)
		valve_open = FALSE
		update_icon()
		investigate_log("Valve was <b>closed</b> by [key_name(user)].", INVESTIGATE_ATMOS)
	else if(valve_open && holding)
		investigate_log("[key_name(user)] started a transfer into [holding].", INVESTIGATE_ATMOS)

/obj/machinery/portable_atmospherics/canister/process_atmos()
	..()
	if(machine_stat & BROKEN)
		return PROCESS_KILL
	if(timing && valve_timer < world.time)
		valve_open = !valve_open
		timing = FALSE

	// Handle gas transfer.
	if(valve_open)
		var/turf/T = get_turf(src)
		var/datum/gas_mixture/target_air = holding ? holding.air_contents : T.return_air()

		air_contents.release_gas_to(target_air, release_pressure)
	update_icon()

/obj/machinery/portable_atmospherics/canister/ui_status(mob/user)
	. = ..()
	if(. > UI_UPDATE && !allowed(user))
		. = UI_UPDATE

/obj/machinery/portable_atmospherics/canister/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/portable_atmospherics/canister/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Canister")
		ui.open()
		ui.set_autoupdate(TRUE) // Canister pressure, tank pressure, prototype canister timer

/obj/machinery/portable_atmospherics/canister/ui_data()
	var/data = list()
	data["portConnected"] = connected_port ? 1 : 0
	data["tankPressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["releasePressure"] = round(release_pressure ? release_pressure : 0)
	data["defaultReleasePressure"] = round(CAN_DEFAULT_RELEASE_PRESSURE)
	data["minReleasePressure"] = round(can_min_release_pressure)
	data["maxReleasePressure"] = round(can_max_release_pressure)
	data["valveOpen"] = valve_open ? 1 : 0

	data["isPrototype"] = prototype ? 1 : 0
	if (prototype)
		data["restricted"] = restricted
		data["timing"] = timing
		data["time_left"] = get_time_left()
		data["timer_set"] = timer_set
		data["timer_is_not_default"] = timer_set != default_timer_set
		data["timer_is_not_min"] = timer_set != minimum_timer_set
		data["timer_is_not_max"] = timer_set != maximum_timer_set

	data["hasHoldingTank"] = holding ? 1 : 0
	if (holding)
		data["holdingTank"] = list()
		data["holdingTank"]["name"] = holding.name
		data["holdingTank"]["tankPressure"] = round(holding.air_contents.return_pressure())
	// AQUILA: progi zbiornika dla wskaźnika w oknie z tg
	data["holdingTankLeakPressure"] = round(TANK_LEAK_PRESSURE)
	data["holdingTankFragPressure"] = round(TANK_FRAGMENT_PRESSURE)
	return data

/obj/machinery/portable_atmospherics/canister/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("relabel")
			var/label = input("Nowa etykieta kanistra:", name) as null|anything in sortList(label2types)
			if(label && !..())
				var/newtype = label2types[label]
				if(newtype)
					var/obj/machinery/portable_atmospherics/canister/replacement = newtype
					name = initial(replacement.name)
					desc = initial(replacement.desc)
					icon_state = initial(replacement.icon_state)
					set_greyscale(initial(replacement.greyscale_colors), initial(replacement.greyscale_config))
		if("restricted")
			if(!prototype)
				return // Prototype canister only feature
			restricted = !restricted
			if(restricted)
				req_access = list(ACCESS_ENGINE)
			else
				req_access = list()
			. = TRUE
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "reset")
				pressure = CAN_DEFAULT_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "min")
				pressure = can_min_release_pressure
				. = TRUE
			else if(pressure == "max")
				pressure = can_max_release_pressure
				. = TRUE
			else if(pressure == "input")
				pressure = input("Nowe ciśnienie wypuszczania ([can_min_release_pressure]-[can_max_release_pressure] kPa):", name, release_pressure) as num|null
				if(!isnull(pressure) && !..())
					. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				release_pressure = clamp(round(pressure), can_min_release_pressure, can_max_release_pressure)
				investigate_log("was set to [release_pressure] kPa by [key_name(usr)].", INVESTIGATE_ATMOS)
		if("valve")
			var/logmsg
			valve_open = !valve_open
			if(valve_open)
				logmsg = "Valve was <b>opened</b> by [key_name(usr)], starting a transfer into \the [holding || "air"].<br>"
				if(!holding)
					var/list/danger = list()
					for(var/id in air_contents.get_gases())
						if(!(GLOB.gas_data.flags[id] & GAS_FLAG_DANGEROUS))
							continue
						if(air_contents.get_moles(id) > (GLOB.gas_data.visibility[id] || MOLES_GAS_VISIBLE)) //if moles_visible is undefined, default to default visibility
							danger[GLOB.gas_data.names[id]] = air_contents.get_moles(id) //ex. "plasma" = 20

					if(danger.len)
						message_admins("[ADMIN_LOOKUPFLW(usr)] otwiera kanister z następującą zawartością w [ADMIN_VERBOSEJMP(src)]:")
						log_admin("[key_name(usr)] opened a canister that contains the following at [AREACOORD(src)]:")
						for(var/name in danger)
							var/msg = "[name]: [danger[name]] moles."
							log_admin(msg)
							message_admins(msg)
			else
				logmsg = "Valve was <b>closed</b> by [key_name(usr)], stopping the transfer into \the [holding || "air"].<br>"
			investigate_log(logmsg, INVESTIGATE_ATMOS)
			release_log += logmsg
			. = TRUE
		/* // Apparently the timer isn't present in TGUI - commenting out so it can't be used via exploits
		if("timer")
			if(!prototype)
				return
			var/change = params["change"]
			switch(change)
				if("reset")
					timer_set = default_timer_set
					. = TRUE
				if("decrease")
					timer_set = max(minimum_timer_set, timer_set - 10)
					. = TRUE
				if("increase")
					timer_set = min(maximum_timer_set, timer_set + 10)
					. = TRUE
				if("input")
					var/user_input = input(usr, "Set time to valve toggle.", name) as null|num
					if(!user_input)
						return
					var/N = text2num(user_input)
					if(!N)
						return
					timer_set = clamp(N,minimum_timer_set,maximum_timer_set)
					log_admin("[key_name(usr)] has activated a prototype valve timer")
					. = TRUE
				if("toggle_timer")
					set_active()
					. = TRUE
		*/
		if("eject")
			if(holding)
				if(valve_open)
					message_admins("[ADMIN_LOOKUPFLW(usr)] wyjmuje [holding] z [src] przy otwartym zaworze w [ADMIN_VERBOSEJMP(src)] i wypuszcza zawartość <span class='boldannounce'>do powietrza</span>.")
					investigate_log("[key_name(usr)] removed the [holding], leaving the valve open and transferring into the <span class='boldannounce'>air</span>.", INVESTIGATE_ATMOS)
				replace_tank(usr, FALSE)
				. = TRUE
	if(.)
		update_icon()


/* yog- ADMEME CANISTERS */

/// Canister 1 Kelvin below the fusion point. Is highly unoptimal, do not spawn to start fusion, only good for testing low instability mixes.
/obj/machinery/portable_atmospherics/canister/fusion_test
	name = "testowy kanister fuzji"
	desc = "To nie powinno nigdy pojawić się w grze."
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#0099ff#ff3300"

/obj/machinery/portable_atmospherics/canister/fusion_test/create_gas()
	air_contents.set_moles(GAS_TRITIUM, 10)
	air_contents.set_moles(GAS_PLASMA, 500)
	air_contents.set_moles(GAS_CO2, 500)
	air_contents.set_moles(GAS_NITROUS, 100)
	air_contents.set_temperature(FUSION_TEMPERATURE_THRESHOLD)

/// Canister 1 Kelvin below the fusion point. Contains far too much plasma. Only good for adding more fuel to ongoing fusion reactions.
 /obj/machinery/portable_atmospherics/canister/fusion_test_2
	name = "testowy kanister fuzji"
	desc = "To nie powinno nigdy pojawić się w grze."
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#0099ff#ff3300"

/obj/machinery/portable_atmospherics/canister/fusion_test_2/create_gas()
	air_contents.set_moles(GAS_TRITIUM, 10)
	air_contents.set_moles(GAS_PLASMA, 15000)
	air_contents.set_moles(GAS_CO2, 1500)
	air_contents.set_moles(GAS_NITROUS, 100)
	air_contents.set_temperature(FUSION_TEMPERATURE_THRESHOLD - 1)

/// Canister at the perfect conditions to start and continue fusion for a long time.
/obj/machinery/portable_atmospherics/canister/fusion_test_3
	name = "testowy kanister fuzji"
	desc = "To nie powinno nigdy pojawić się w grze."
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#0099ff#ff3300"

/obj/machinery/portable_atmospherics/canister/fusion_test_3/create_gas()
	air_contents.set_moles(GAS_TRITIUM, 1000)
	air_contents.set_moles(GAS_PLASMA, 4500)
	air_contents.set_moles(GAS_CO2, 1500)
	air_contents.set_temperature(1000000)

