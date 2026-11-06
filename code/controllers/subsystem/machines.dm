SUBSYSTEM_DEF(machines)
	name = "Machines"
	init_order = INIT_ORDER_MACHINES
	flags = SS_KEEP_TIMING
	wait = 2 SECONDS
	var/list/processing = list()
	var/list/currentrun = list()
	var/list/powernets = list()
	// AQ EDIT START - Smartwires
	var/list/dirty_powernets = list()
	var/unique_powernets = 0
	// AQ EDIT END

/datum/controller/subsystem/machines/Initialize()
	makepowernets()
	fire()
	return ..()


/datum/controller/subsystem/machines/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["processing"] = length(processing)
	.["custom"] = cust

/datum/controller/subsystem/machines/proc/makepowernets()
	for(var/datum/powernet/PN in powernets)
		qdel(PN)
	powernets.Cut()

	// AQ EDIT START - Smartwires
	var/datum/powernet/new_powernet = new()
	for(var/obj/structure/cable/cable as anything in GLOB.cable_list)
		new_powernet.add_cable(cable)
	new_powernet.repropogate_cables()
	new_powernet.dirty = FALSE
	dirty_powernets.len = 0
	// AQ EDIT END

/datum/controller/subsystem/machines/stat_entry()
	. = ..("M:[processing.len]|PN:[powernets.len]")


/datum/controller/subsystem/machines/fire(resumed = 0)
	if (!resumed)
		for(var/datum/powernet/Powernet in powernets)
			Powernet.reset() //reset the power state.
		src.currentrun = processing.Copy()

	if (process_dirty_powernets(resumed)) // AQ EDIT - Smartwires: recalculate cut powernets before machines draw power
		return

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/obj/machinery/thing = currentrun[currentrun.len]
		currentrun.len--
		if(!QDELETED(thing) && thing.process(wait * 0.1) != PROCESS_KILL)
			if(thing.use_power)
				thing.auto_use_power() //add back the power state
		else
			processing -= thing
			if (!QDELETED(thing))
				thing.datum_flags &= ~DF_ISPROCESSING
		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/machines/proc/setup_template_powernets(list/cables)
	// AQ EDIT START - Smartwires
	if(!length(cables))
		return
	var/obj/structure/cable/cable
	var/datum/powernet/new_powernet = new()
	for(var/A in 1 to cables.len)
		cable = cables[A]
		new_powernet.add_cable(cable)
	new_powernet.repropogate_cables()
	new_powernet.dirty = FALSE
	dirty_powernets -= new_powernet
	// AQ EDIT END

/datum/controller/subsystem/machines/Recover()
	if (istype(SSmachines.processing))
		processing = SSmachines.processing
	if (istype(SSmachines.powernets))
		powernets = SSmachines.powernets

// AQ EDIT START - Smartwires
/datum/controller/subsystem/machines/proc/queue_recalculation(datum/powernet/powernet)
	if (powernet.dirty)
		return
	dirty_powernets += powernet
	powernet.dirty = TRUE
// AQ EDIT END
