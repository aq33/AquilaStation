// AQUILA - połączenia pięter liczone raz przy tworzeniu z-levelu (tgstation/tgstation#76248, lista z tgstation/tgstation#66657)
// Wcześniej każde above()/below() szło przez level_trait() -> get_level() -> traits[...] (3,6 mln wywołań na 30 min rundy,
// głównie z playsound()). Makra GET_TURF_ABOVE/BELOW są w code/__DEFINES/multi_z.dm.
// Jak w tg piętro wyżej to zawsze z + 1, a niżej z - 1. Nasze mapy mają "Up": 1 / "Down": -1, więc liczy się tylko, czy połączenie jest.

/datum/controller/subsystem/mapping
	/// list(z = list(Z_LEVEL_UP = bool, Z_LEVEL_DOWN = bool)) dla każdego z-levelu z z_list
	var/list/multiz_levels = list()
	/// "[z]" = list(z-levele wyżej po kolei, z-levele niżej po kolei); liczone przy pierwszym użyciu, czyszczone przy każdym nowym z-levelu
	var/list/multiz_stacks = list()

/datum/controller/subsystem/mapping/proc/generate_linkages_for_z_level(z_level)
	if(!isnum(z_level) || z_level <= 0)
		return FALSE
	if(multiz_levels.len < z_level)
		multiz_levels.len = z_level
	var/z_above = level_trait(z_level, ZTRAIT_UP)
	var/z_below = level_trait(z_level, ZTRAIT_DOWN)
	// Makra zawsze idą o jedno piętro, więc każde inne przesunięcie z mapy (także "Down": 1, czyli dawniej z+1) byłoby po cichu zmienione
	if(!(z_above in list(null, FALSE, TRUE)) || !(z_below in list(null, FALSE, -1)))
		stack_trace("Z-level [z_level]: obsługiwane są tylko \"Up\": 1 i \"Down\": -1 (jest Up: [z_above], Down: [z_below]), piętro wyżej to zawsze z+1, a niżej z-1")
	multiz_levels[z_level] = new /list(LARGEST_Z_LEVEL_INDEX)
	multiz_levels[z_level][Z_LEVEL_UP] = !!z_above
	multiz_levels[z_level][Z_LEVEL_DOWN] = !!z_below
	// Nowy z-level może przedłużyć stos innych pięter
	multiz_stacks.Cut()
	return TRUE

/// Z-levele połączone z z_level w górę i w dół, w kolejności od najbliższego: list(list(wyżej), list(niżej))
/datum/controller/subsystem/mapping/proc/get_multiz_stack(z_level)
	if(!isnum(z_level) || z_level < 1)
		return list(list(), list())
	var/list/stack = multiz_stacks["[z_level]"]
	if(stack)
		return stack
	var/list/above = list()
	var/list/below = list()
	// Te same warunki co GET_TURF_ABOVE/BELOW: połączenie w multiz_levels i istniejący z-level obok
	var/z = z_level
	while(z < world.maxz && z <= length(multiz_levels) && multiz_levels[z]?[Z_LEVEL_UP])
		z++
		above += z
	z = z_level
	while(z > 1 && z <= length(multiz_levels) && multiz_levels[z]?[Z_LEVEL_DOWN])
		z--
		below += z
	stack = list(above, below)
	multiz_stacks["[z_level]"] = stack
	return stack

/datum/controller/subsystem/mapping/InitializeDefaultZLevels()
	. = ..()
	for(var/datum/space_level/level as anything in z_list)
		if(level.z_value > length(multiz_levels) || !multiz_levels[level.z_value])
			generate_linkages_for_z_level(level.z_value)

/datum/controller/subsystem/mapping/add_new_zlevel(name, traits = list(), z_type = /datum/space_level, orbital_body_type)
	var/datum/space_level/new_level = ..()
	generate_linkages_for_z_level(new_level.z_value)
	return new_level

/datum/controller/subsystem/mapping/Recover()
	. = ..()
	multiz_levels = SSmapping.multiz_levels
	multiz_stacks = SSmapping.multiz_stacks
