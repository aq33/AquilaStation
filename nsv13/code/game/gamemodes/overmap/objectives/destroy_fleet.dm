/datum/overmap_objective/destroy_fleets
	name = "Zniszcz floty"
	desc = "Zniszcz wrogie floty (liczba: fleets_required)"
	binary = FALSE
	target = 1

	var/minimum_fleets = 1
	var/maximum_fleets = 3

	var/target_faction = "any"

	extension_supported = FALSE

/datum/overmap_objective/destroy_fleets/instance()
	.=..()
	target = rand(minimum_fleets, maximum_fleets) // Doing this in instance in case people want different numbers of them
	desc = "Zniszcz wrogie floty (liczba: [target])"
	brief = "Pokonajcie [(target != 1) ? "wrogie floty" : "wrogą flotę"][(target_faction == "any") ? "" : " ([target_faction])"] (liczba: [target])"
	RegisterSignal(SSstar_system.find_main_overmap(), COMSIG_SHIP_KILLED_FLEET, PROC_REF(register_kill))

/datum/overmap_objective/destroy_fleets/proc/register_kill()
	tally ++
	SSovermap_mode.update_reminder(objective=TRUE)
	check_completion()

/datum/overmap_objective/destroy_fleets/check_completion()
	.=..()
	if(status != 0)
		return
	if(tally >= target)
		status = 1
