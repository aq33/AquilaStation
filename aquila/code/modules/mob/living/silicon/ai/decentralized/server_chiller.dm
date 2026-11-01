// AQUILA: chłodziarka serwerowni. Własna maszyna, nie z Monke: komory SI mają 20°C, a rdzeń danych działa do 15°C.
// Zasilana z APC, bez rur. Odbiera ciepło z powietrza na swoim kaflu, a ruch powietrza rozprowadza chłód po pomieszczeniu.

/obj/machinery/server_chiller
	name = "chłodziarka serwerowni"
	desc = "Klimatyzator do serwerowni. Schładza powietrze w pomieszczeniu do zadanej temperatury, żeby rdzenie danych i szafy serwerowe się nie przegrzały. Działa na prąd z APC."
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "freezer"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	active_power_usage = 2000
	circuit = /obj/item/circuitboard/machine/server_chiller
	max_integrity = 300
	///Temperatura, do której chłodzimy powietrze (K)
	var/target_temperature = T0C + 5
	///Ile ciepła (J) chłodziarka odbiera z powietrza na tick atmosu
	var/cooling_power = 20000
	///Czy w ostatnim ticku chłodziła
	var/cooling = FALSE

/obj/machinery/server_chiller/Initialize(mapload)
	. = ..()
	SSair.start_processing_machine(src)
	RefreshParts()

/obj/machinery/server_chiller/Destroy()
	SSair.stop_processing_machine(src)
	return ..()

/obj/machinery/server_chiller/RefreshParts()
	var/laser_rating = 0
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		laser_rating += laser.rating
	cooling_power = 20000 * max(laser_rating, 1)

/obj/machinery/server_chiller/examine(mob/user)
	. = ..()
	. += span_notice("Zadana temperatura: <b>[round(target_temperature - T0C, 0.1)]°C</b>. Moc chłodzenia: <b>[cooling_power / 1000] kJ</b> na kafel na cykl (swój kafel i sąsiednie).")
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/env = T?.return_air()
	if(env)
		. += span_notice("Temperatura powietrza: <b>[round(env.return_temperature() - T0C, 0.1)]°C</b>.")

/obj/machinery/server_chiller/process_atmos()
	var/was_cooling = cooling
	cooling = FALSE
	if(!(machine_stat & (BROKEN|NOPOWER)) && !panel_open && anchored)
		// Chłodzi swój kafel i sąsiednie, żeby nadążyć za nawiewami z ciepłym powietrzem
		for(var/turf/open/T in range(1, src))
			if(cool_turf(T))
				cooling = TRUE
	if(cooling == was_cooling)
		return
	use_power = cooling ? ACTIVE_POWER_USE : IDLE_POWER_USE
	update_icon()

///Odbiera do cooling_power ciepła z powietrza na kaflu. Zwraca TRUE, jeśli chłodziła.
/obj/machinery/server_chiller/proc/cool_turf(turf/open/T)
	var/datum/gas_mixture/env = T.return_air()
	if(!env)
		return FALSE
	var/env_temp = env.return_temperature()
	var/heat_capacity = env.heat_capacity()
	if(env_temp <= target_temperature + 0.5 || heat_capacity <= 0)
		return FALSE
	var/heat_removed = min(cooling_power, (env_temp - target_temperature) * heat_capacity)
	env.set_temperature(env_temp - heat_removed / heat_capacity)
	T.air_update_turf()
	return TRUE

/obj/machinery/server_chiller/update_icon_state()
	if(panel_open)
		icon_state = "freezer-o"
	else if(cooling)
		icon_state = "freezer_1"
	else
		icon_state = "freezer"
	return ..()

/obj/machinery/server_chiller/screwdriver_act(mob/living/user, obj/item/I)
	default_deconstruction_screwdriver(user, "freezer-o", "freezer", I)
	return TRUE

/obj/machinery/server_chiller/crowbar_act(mob/living/user, obj/item/I)
	default_deconstruction_crowbar(I)
	return TRUE

/obj/machinery/server_chiller/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I)
	return TRUE

/obj/machinery/server_chiller/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	var/new_temp = tgui_input_number(user, "Zadana temperatura (°C, od -20 do 20)", "Chłodziarka serwerowni", round(target_temperature - T0C), 20, -20)
	if(isnull(new_temp) || !user.canUseTopic(src, BE_CLOSE))
		return
	target_temperature = T0C + clamp(round(new_temp), -20, 20)
	balloon_alert(user, "ustawiono [round(target_temperature - T0C)]°C")

/obj/machinery/server_chiller/attack_ai(mob/user)
	return attack_hand(user)

/obj/item/circuitboard/machine/server_chiller
	name = "chłodziarka serwerowni (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/server_chiller
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/cable_coil = 2,
	)

/datum/design/board/server_chiller
	name = "Projekt maszyny (chłodziarka serwerowni)"
	desc = "Płytka chłodziarki serwerowni, która schładza powietrze bez rur."
	id = "server_chiller"
	build_path = /obj/item/circuitboard/machine/server_chiller
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING
