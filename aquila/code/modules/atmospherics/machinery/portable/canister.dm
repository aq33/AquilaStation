/obj/machinery/portable_atmospherics/canister/ui_act(action, params)
	var/was_open = valve_open
	. = ..()
	if(valve_open != was_open)
		playsound(src, 'aquila/sound/effects/valve_opening.ogg', 50)

/// Dragging a canister scrapes the floor
/obj/machinery/portable_atmospherics/canister/Moved(atom/OldLoc, Dir, Forced)
	. = ..()
	if(!Forced && isturf(loc) && has_gravity())
		playsound(src, 'aquila/sound/effects/canister_drag.ogg', 40, TRUE, -3)

// AQUILA - kanister pęka od ciśnienia i temperatury wnętrza (plan maszynowni E2, port tg take_atmos_damage).
// Zwykłe napełnianie pompą (do 9000 kPa) nic nie robi; pożar plazmy albo trytu w środku rozrywa kanister.
/obj/machinery/portable_atmospherics/canister
	/// Ciśnienie wnętrza, od którego kanister niszczeje (kPa)
	var/aq_pressure_limit = 50000
	/// Temperatura wnętrza, od której kanister niszczeje (K)
	var/aq_temp_limit = 10000

/obj/machinery/portable_atmospherics/canister/proto/default
	aq_pressure_limit = 150000
	aq_temp_limit = 30000

/obj/machinery/portable_atmospherics/canister/Initialize(mapload, datum/gas_mixture/existing_mixture)
	. = ..()
	// jak w tg: każdy kanister trochę inny (0–20% zapasu)
	aq_pressure_limit = round(aq_pressure_limit * (1 + rand() * 0.2))
	aq_temp_limit = round(aq_temp_limit * (1 + rand() * 0.2))

/obj/machinery/portable_atmospherics/canister/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Naklejka ostrzega: wnętrze wytrzymuje do [aq_pressure_limit] kPa i [aq_temp_limit] K.</span>"

/obj/machinery/portable_atmospherics/canister/process_atmos()
	. = ..()
	if(. == PROCESS_KILL || (machine_stat & BROKEN))
		return
	aq_take_atmos_damage()

/// Obrażenia od wnętrza ponad limity: clamp(T/limit × p/limit, 5, 50) na cykl, jak w tg. Zwraca TRUE, gdy zadane.
/obj/machinery/portable_atmospherics/canister/proc/aq_take_atmos_damage()
	if(!air_contents)
		return FALSE
	var/temperature = air_contents.return_temperature()
	var/pressure = air_contents.return_pressure()
	var/temp_damage = 1
	var/pressure_damage = 1
	var/taking_damage = FALSE
	if(temperature > aq_temp_limit)
		temp_damage = temperature / aq_temp_limit
		taking_damage = TRUE
	if(pressure > aq_pressure_limit)
		pressure_damage = pressure / aq_pressure_limit
		taking_damage = TRUE
	if(!taking_damage)
		return FALSE
	take_damage(clamp(temp_damage * pressure_damage, 5, 50), BURN, 0)
	return TRUE
