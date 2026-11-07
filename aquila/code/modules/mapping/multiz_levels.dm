// AQUILA - połączenia pięter liczone raz przy tworzeniu z-levelu (tgstation/tgstation#76248, lista z tgstation/tgstation#66657)
// Wcześniej każde above()/below() szło przez level_trait() -> get_level() -> traits[...] (3,6 mln wywołań na 30 min rundy,
// głównie z playsound()). Makra GET_TURF_ABOVE/BELOW są w code/__DEFINES/multi_z.dm.
// Jak w tg piętro wyżej to zawsze z + 1, a niżej z - 1. Nasze mapy mają "Up": 1 / "Down": -1, więc liczy się tylko, czy połączenie jest.

/datum/controller/subsystem/mapping
	/// list(z = list(Z_LEVEL_UP = bool, Z_LEVEL_DOWN = bool)) dla każdego z-levelu z z_list
	var/list/multiz_levels = list()

/datum/controller/subsystem/mapping/proc/generate_linkages_for_z_level(z_level)
	if(!isnum(z_level) || z_level <= 0)
		return FALSE
	if(multiz_levels.len < z_level)
		multiz_levels.len = z_level
	multiz_levels[z_level] = new /list(LARGEST_Z_LEVEL_INDEX)
	multiz_levels[z_level][Z_LEVEL_UP] = !!level_trait(z_level, ZTRAIT_UP)
	multiz_levels[z_level][Z_LEVEL_DOWN] = !!level_trait(z_level, ZTRAIT_DOWN)
	return TRUE

/datum/controller/subsystem/mapping/InitializeDefaultZLevels()
	. = ..()
	for(var/datum/space_level/level as anything in z_list)
		generate_linkages_for_z_level(level.z_value)

/datum/controller/subsystem/mapping/add_new_zlevel(name, traits = list(), z_type = /datum/space_level, orbital_body_type)
	var/datum/space_level/new_level = ..()
	generate_linkages_for_z_level(new_level.z_value)
	return new_level

/datum/controller/subsystem/mapping/Recover()
	. = ..()
	multiz_levels = SSmapping.multiz_levels
