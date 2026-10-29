/datum/overmap_objective/perform_jumps
	name = "Wykonaj skoki"
	desc = "Wykonaj skoki FTL (liczba: jumps_required)"
	binary = FALSE
	tally = -1 // Don't count staging
	target = 1

	var/minimum_jumps = 6
	var/maximum_jumps = 10

/datum/overmap_objective/perform_jumps/instance()
	.=..()
	target = rand(minimum_jumps, maximum_jumps) // Doing this in instance in case people want different numbers of them
	desc = "Wykonaj skoki FTL (liczba: [target])"
	brief = "Wykonajcie [target] skoków FTL"
	RegisterSignal(SSstar_system.find_main_overmap(), COMSIG_SHIP_ARRIVED, PROC_REF(register_jump))

/datum/overmap_objective/perform_jumps/proc/register_jump()
	tally ++
	SSovermap_mode.update_reminder(objective=TRUE)
	check_completion()

/datum/overmap_objective/perform_jumps/check_completion()
	.=..()
	if(status != 0)
		return
	if(tally >= target)
		status = 1
		UnregisterSignal(SSstar_system.find_main_overmap(), COMSIG_SHIP_ARRIVED)
