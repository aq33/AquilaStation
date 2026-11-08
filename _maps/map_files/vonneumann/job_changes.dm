/*
	  __            ___   _      _
      \ \          /  /  | |    ||
	    \ \      /  /    |   \  ||
	      \ \__/  /      | |\  \||
            \___/        |_|  \__|   C L A S S

pardon my godawful ascii art. it has been some time. anyway this is a solgov ship with a focus on *compactness* and *muni*(suprisingly, it's possible)
*/
// Munitechs get something to do on this ship. the jobs I just couldn't cram in don't though
MAP_REMOVE_JOB(curator)
MAP_REMOVE_JOB(lawyer)
MAP_REMOVE_JOB(chaplain)
MAP_REMOVE_JOB(virologist)
MAP_REMOVE_JOB(brig_physician) // AQ EDIT - typ profesji to brig_physician, brig_phys nie istnieje
MAP_REMOVE_JOB(deputy)
MAP_REMOVE_JOB(air_traffic_controller)
/datum/job/bartender/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1

/datum/job/cook/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1

/datum/job/pilot/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2 // AQ EDIT - job_slots.dm obniża spawn_positions, bez tego dodatkowe sloty byłyby tylko dla latejoinu

/datum/job/munitions_tech/New()  // this ship needs gunners, or it will not achieve it's full firepower.
	..()
	MAP_JOB_CHECK
	total_positions = 4
	spawn_positions = 4 // AQ EDIT - jak wyżej

/datum/uplink_item/explosives/syndicate_bomb/New()
    . = ..()

    if(SSmapping?.config?.map_name != JOB_MODIFICATION_MAP_NAME)
        return
    limited_stock = 0 //This ship is way too small for this shit. //I second this, litterally, I am stealing it.
    cant_discount = TRUE
    surplus = 0

#undef JOB_MODIFICATION_MAP_NAME
