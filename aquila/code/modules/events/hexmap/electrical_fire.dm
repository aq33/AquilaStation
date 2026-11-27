// AQUILA - Pożar instalacji: jedno włączone urządzenie w używanym pomieszczeniu sypie iskrami i zapala się (port z CHOMPStation2 modular_chomp/code/modules/event/electrical_fire.dm)
// As in CHOMP, the candidates are light switches of rooms with the lights on and powered washing machines, microwaves and
// cyborg rechargers outside maintenance and shuttles. CHOMP sets a short lingering fire on the turf; we have no
// lingering turf fire, so the machine leaks a small puddle of burning insulation oil (welding fuel in our liquids) that
// burns out on its own or can be put out with an extinguisher. Nothing is spilled on a turf without enough oxygen to
// burn, and the fuel is taken back if the puddle does not light. No announcement, as in CHOMP: the fire alarm reports it.

/// Welding fuel spilled under the burning machine
#define ELECTRICAL_FIRE_FUEL 50

/datum/round_event_control/aquila_hex_electrical_fire
	name = "Pożar instalacji"
	typepath = /datum/round_event/aquila_hex_electrical_fire
	weight = 10
	min_players = 3
	max_occurrences = 3
	earliest_start = 15 MINUTES

/datum/round_event/aquila_hex_electrical_fire
	fakeable = FALSE
	startWhen = 1

/datum/round_event/aquila_hex_electrical_fire/start()
	var/list/candidates = list()
	for(var/obj/machinery/machine as anything in GLOB.machines)
		if(can_burn(machine))
			candidates += machine
	if(!length(candidates))
		log_game("Electrical Fire: no powered machine in a room in use, cancelling the event.")
		return kill()
	var/obj/machinery/machine = pick(candidates)
	if(!ignite_machine(machine))
		log_game("Electrical Fire: [machine] at [AREACOORD(machine)] did not catch fire.")
		return kill()
	log_game("Electrical Fire: [machine] in [get_area_name(machine, TRUE)] caught fire at [AREACOORD(machine)].")
	message_admins("Pożar instalacji: [machine] w [get_area_name(machine, TRUE)] zapalił się. [ADMIN_VERBOSEJMP(machine)]")

/// A powered machine of the right kind in a room in use (lights on), outside maintenance and shuttles
/datum/round_event/aquila_hex_electrical_fire/proc/can_burn(obj/machinery/machine)
	if(QDELETED(machine) || !isturf(machine.loc) || !is_station_level(machine.z))
		return FALSE
	var/area/machine_area = get_area(machine)
	if(!machine_area || !(machine_area.type in GLOB.the_station_areas) || istype(machine_area, /area/maintenance) || istype(machine_area, /area/shuttle))
		return FALSE
	if(istype(machine, /obj/machinery/light_switch))
		return machine_area.lightswitch && !(machine.machine_stat & (NOPOWER|BROKEN))
	if(istype(machine, /obj/machinery/washing_machine) || istype(machine, /obj/machinery/microwave) || istype(machine, /obj/machinery/recharge_station))
		return !(machine.machine_stat & (NOPOWER|BROKEN))
	return FALSE

/// Sparks and a burning puddle under the machine. Returns the burning turf or null
/datum/round_event/aquila_hex_electrical_fire/proc/ignite_machine(obj/machinery/machine)
	var/turf/open/fire_turf = get_turf(machine)
	if(QDELETED(machine) || !istype(fire_turf))
		return null
	var/datum/gas_mixture/air = fire_turf.return_air()
	if(!air || air.get_moles(GAS_O2) < 0.5 || air.get_moles(GAS_HYPERNOB) > REACTION_OPPRESSION_THRESHOLD) // as in try_ignite()
		return null
	machine.visible_message("<span class='warning'>Z [machine] sypią się iskry, a spod obudowy bucha ogień!</span>")
	do_sparks(4, TRUE, machine)
	fire_turf.add_liquid(/datum/reagent/fuel, ELECTRICAL_FIRE_FUEL, no_react = TRUE)
	if(QDELETED(fire_turf.liquids))
		return null
	if(!fire_turf.liquids.fire_state) // the sparks may have lit it already
		fire_turf.liquids.try_ignite(1000)
	if(!QDELETED(fire_turf.liquids) && fire_turf.liquids.fire_state)
		return fire_turf
	// it did not light: take the fuel back, so no puddle of fuel is left for nothing
	if(!QDELETED(fire_turf.liquids?.liquid_group))
		fire_turf.liquids.liquid_group.remove_specific(fire_turf.liquids, ELECTRICAL_FIRE_FUEL, /datum/reagent/fuel)
	return null

#undef ELECTRICAL_FIRE_FUEL
