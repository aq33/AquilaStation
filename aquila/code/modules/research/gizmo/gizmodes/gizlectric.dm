/// Suck power and shoot it out again
/datum/gizmodes/electric
	possible_active_modes = list(
		/datum/gizpulse/electric/emp = 1,
		/datum/gizpulse/electric/discharge = 1,
		/datum/gizpulse/electric/charge = 1,
		/datum/gizpulse/electric/revive = 1,
	)

	guaranteed_active_gizmodes = list(
		GIZMO_PICK_ONE = list(
			/datum/gizpulse/electric/draw = 1,
			/datum/gizpulse/electric/passive_charge = 1,
		)
	)

	mode_pulses = list(
		/datum/gizpulse/mode_controle/select_mode,
		/datum/gizpulse/mode_controle/cycle_mode,
		/datum/gizpulse/mode_controle/direct_activate,
	)

	min_modes = 3
	max_modes = 4

	cooldown_time = 6 SECONDS

	/// The internal power cell
	var/obj/item/stock_parts/cell/gizmo/power

/datum/gizmodes/electric/activate(atom/movable/holder)
	if(QDELETED(power))
		power = new(holder)

	return ..()

/// Batter used in the gizmo device
/// AQUILA: tg /obj/item/stock_parts/power_store/battery (1 MJ), u nas ogniwo o pojemności 100 zwykłych ogniw
/obj/item/stock_parts/cell/gizmo
	name = "gizmo battery"
	maxcharge = GIZMO_BATTERY_CHARGE
	charge = GIZMO_BATTERY_CHARGE * 0.1 //you gotta work for your fun

/obj/item/stock_parts/cell/gizmo/Initialize(mapload, override_maxcharge)
	. = ..()
	charge = GIZMO_BATTERY_CHARGE * 0.1 // nadpisujemy pełne naładowanie z Initialize()

/// Get the total charge
/datum/gizpulse/electric/proc/get_power(atom/movable/holder, datum/gizmodes/master)
	if(istype(master, /datum/gizmodes/electric))
		var/datum/gizmodes/electric/electromaster = master
		return electromaster.power.charge
	return 0

/// Use some charge
/datum/gizpulse/electric/proc/use_power(amount, atom/movable/holder, datum/gizmodes/master)
	if(istype(master, /datum/gizmodes/electric))
		var/datum/gizmodes/electric/electromaster = master
		return electromaster.power.use(amount)
	return FALSE

/// Do an EMP blast
/datum/gizpulse/electric/emp
	/// Min power to do an EMP
	var/min_power = GIZMO_CELL_CHARGE

/// Do an EMP blast using the cell of our gizmode
/datum/gizpulse/electric/emp/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	var/charge = get_power(holder, master)
	if(charge < min_power)
		return
	/// Max charge is 100 cells. A full charge EMP is 100 / 15 is 6 tiles of light emp range
	empulse(get_turf(holder), FLOOR(charge / GIZMO_CELL_CHARGE / 40, 1), FLOOR(charge / GIZMO_CELL_CHARGE / 15, 1))
	use_power(charge, holder, master)

/// Shoot our current charge away as lightning
/datum/gizpulse/electric/discharge/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	var/charge = get_power(holder, master)
	// AQUILA: w tg warunek był odwrócony (if(charge) return), przez co wyładowanie nigdy nie strzelało
	if(!charge)
		return

	tesla_zap(holder, 3, charge * GIZMO_TG_JOULES_PER_CHARGE, GIZMO_ZAP_FLAGS)
	use_power(charge, holder, master)

/// Look for an object with a cell, and CHARGE IT!!!
/datum/gizpulse/electric/charge/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	if(!istype(master, /datum/gizmodes/electric))
		return

	var/datum/gizmodes/electric/electromaster = master

	for(var/atom/movable/power_source in oview(4, holder))
		var/obj/item/stock_parts/cell/cell = power_source.get_cell()
		if(!istype(cell) || cell == electromaster.power)
			continue

		// AQUILA: w tg liczone jako (nasz ładunek - brak w ogniwie), co przepalało ładunek; bierzemy mniejszą z wartości
		var/charge = min(electromaster.power.charge, cell.maxcharge - cell.charge)
		if(charge <= 0)
			continue

		cell.give(charge)
		electromaster.power.use(charge)

		holder.Beam(power_source, icon_state = "g_beam", time = 5)
		playsound(power_source, 'sound/magic/ethereal_exit.ogg', 40)
		return

/// Revive people in a radius like the revival surgery
/datum/gizpulse/electric/revive
	/// The charge cost for a defibrillation pulse
	var/defib_cost = GIZMO_CELL_CHARGE * 0.5

/datum/gizpulse/electric/revive/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	if(!istype(master, /datum/gizmodes/electric))
		return

	var/datum/gizmodes/electric/electromaster = master

	if(electromaster.power.charge < defib_cost)
		return

	electromaster.power.use(defib_cost)

	for(var/mob/living/dead in orange(3, holder))
		if(dead.stat != DEAD)
			continue
		// AQUILA: nasz revive() nie ma excess_healing, więc najpierw leczymy trochę, żeby dało się wskrzesić
		dead.adjustOxyLoss(-200)
		dead.adjustBruteLoss(-5)
		dead.adjustFireLoss(-5)
		dead.adjustToxLoss(-5)
		if(iscarbon(dead)) //still want it to work for simple/basicmobs too
			var/mob/living/carbon/dead_but_carbon = dead
			dead_but_carbon.set_heartattack(FALSE)
		dead.revive()
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), dead, 'sound/machines/defib_zap.ogg', 60), 3 SECONDS)

	new /obj/effect/temp_visual/circle_wave(get_turf(holder), COLOR_YELLOW)
	playsound(holder, 'sound/machines/defib_charge.ogg', 80)

/// Look for the nearest power-containing object and suck the power out
/datum/gizpulse/electric/draw/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	if(!istype(master, /datum/gizmodes/electric))
		return

	var/datum/gizmodes/electric/electromaster = master

	for(var/atom/movable/power_source in oview(4, holder))
		var/obj/item/stock_parts/cell/cell = power_source.get_cell()
		if(!istype(cell) || cell == electromaster.power)
			continue

		// AQUILA: jak wyżej, bierzemy mniejszą z wartości (ładunek ogniwa / wolne miejsce w baterii gizma)
		var/charge = min(cell.charge, electromaster.power.maxcharge - electromaster.power.charge)
		if(charge <= 0)
			continue

		cell.use(charge)
		electromaster.power.give(charge)

		holder.Beam(power_source, icon_state = "r_beam", time = 5)
		playsound(power_source, 'sound/magic/ethereal_exit.ogg', 40)
		return

/// Give a bit of charge, FOR FREE
/datum/gizpulse/electric/passive_charge
	/// How much we magically charge from nothing per pulse
	var/recharge = GIZMO_BATTERY_CHARGE * 0.001

/datum/gizpulse/electric/passive_charge/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	if(!istype(master, /datum/gizmodes/electric))
		return

	var/datum/gizmodes/electric/electromaster = master
	electromaster.power.give(recharge)

	playsound(holder, 'sound/magic/charge.ogg', 50, TRUE)
