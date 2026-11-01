/datum/admins/proc/open_shuttlepanel()
	set category = "Round"
	set name = "Shuttle Manipulator"
	set desc = "Otwiera interfejs manipulatora promów."

	if(!check_rights(R_ADMIN))
		return

	SSshuttle.ui_interact(usr)


/obj/docking_port/mobile/proc/admin_fly_shuttle(mob/user)
	var/list/options = list()

	for(var/port in SSshuttle.stationary)
		if (istype(port, /obj/docking_port/stationary/transit))
			continue  // please don't do this
		var/obj/docking_port/stationary/S = port
		if (canDock(S) == SHUTTLE_CAN_DOCK)
			options[S.name || S.id] = S

	options += "--------"
	options += "Nieskończony tranzyt"
	options += "Usuń prom"
	options += "W stronę zachodu słońca (usuń i zalicz cele 'ucieczki')"

	var/selection = input(user, "Wybierz, dokąd ma lecieć [name || id]:", "Lot promu") as null|anything in options
	if(!selection)
		return

	switch(selection)
		if("Nieskończony tranzyt")
			destination = null
			mode = SHUTTLE_IGNITING
			setTimer(ignitionTime)

		if("Usuń prom")
			if(alert(user, "Na pewno usunąć [name || id]?", "Usuń prom", "Anuluj", "Na pewno!") != "Na pewno!")
				return
			jumpToNullSpace()

		if("W stronę zachodu słońca (usuń i zalicz cele 'ucieczki')")
			if(alert(user, "Na pewno usunąć [name || id] i zaliczyć cele ucieczki?", "Usuń prom", "Anuluj", "Na pewno!") != "Na pewno!")
				return
			intoTheSunset()

		else
			if(options[selection])
				request(options[selection])

				//Remove shuttle object
				if(SSorbits.assoc_shuttles.Find(options[selection]))
					//Removing from the list is handled by deleting the shuttle
					qdel(SSorbits.assoc_shuttles[options[selection]])

/obj/docking_port/mobile/emergency/admin_fly_shuttle(mob/user)
	return  // use the existing verbs for this

/obj/docking_port/mobile/arrivals/admin_fly_shuttle(mob/user)
	switch(alert(user, "Chcesz raz polecieć promem przylotów czy zmienić jego cel?", "Lot promu", "Leć", "Zmień cel", "Anuluj"))
		if("Anuluj")
			return
		if("Leć")
			return ..()

	var/list/options = list()

	for(var/port in SSshuttle.stationary)
		if (istype(port, /obj/docking_port/stationary/transit))
			continue  // please don't do this
		var/obj/docking_port/stationary/S = port
		if (canDock(S) == SHUTTLE_CAN_DOCK)
			options[S.name || S.id] = S

	var/selection = input(user, "Wybierz nowy cel promu przylotów:", "Lot promu") as null|anything in options
	if(!selection)
		return
	target_dock = options[selection]
	if(!QDELETED(target_dock))
		destination = target_dock

