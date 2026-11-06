// Smartwires (port BeeStation/BeeStation-Hornet#14275).
// NSV13 machines that draw power straight from the cable under them (turf.get_cable_node())
// are not /obj/machinery/power, so they need a forced power node on the cable they are mapped on.
// Without it a cable running through their tile would not count as a node and they would lose power.

WANTS_POWER_NODE(/obj/machinery/armour_plating_nanorepair_well)
WANTS_POWER_NODE(/obj/machinery/atmospherics/components/binary/drive_pylon)
WANTS_POWER_NODE(/obj/machinery/atmospherics/components/binary/stormdrive_reactor)
WANTS_POWER_NODE(/obj/machinery/atmospherics/components/trinary/defence_screen_reactor)
WANTS_POWER_NODE(/obj/machinery/atmospherics/components/trinary/nuclear_reactor)
WANTS_POWER_NODE(/obj/machinery/atmospherics/miner)
WANTS_POWER_NODE(/obj/machinery/inertial_dampener)
WANTS_POWER_NODE(/obj/machinery/railgun_charger)
WANTS_POWER_NODE(/obj/machinery/shield_generator)
WANTS_POWER_NODE(/obj/machinery/ship_weapon/energy)
WANTS_POWER_NODE(/obj/machinery/ship_weapon/hybrid_rail)

/// Hum of a cable going between decks
/datum/looping_sound/transformer
	mid_sounds = list('aquila/sound/machines/transformer.ogg' = 1)
	mid_length = 0.9 SECONDS
	volume = 100

/// Powernets taken from `dirty_powernets` at the start of this machines tick and not recalculated yet
/datum/controller/subsystem/machines/var/list/dirty_run = list()

/// Recalculates the powernets queued before this machines tick. A powernet queued while the run is going
/// (a split re-marks its old net) waits for the next tick, and a deleted one is skipped, so nothing shifts under the loop.
/// Returns TRUE if it paused on the tick check.
/datum/controller/subsystem/machines/proc/process_dirty_powernets(resumed, tick_check = TRUE)
	if (!resumed)
		dirty_run += dirty_powernets
		dirty_powernets = list()
	while (length(dirty_run))
		var/datum/powernet/powernet = dirty_run[length(dirty_run)]
		dirty_run.len--
		if (QDELETED(powernet))
			continue
		powernet.dirty = FALSE
		powernet.repropogate_cables()
		// No SPLIT_TICK: the powernets have to be recalculated before machines draw power,
		// otherwise a cut-off piece gets a tick of power from the old net
		if (tick_check && MC_TICK_CHECK)
			return TRUE
	return FALSE
