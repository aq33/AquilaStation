//NSV13 makes RCDs use our own airlocks
/obj/item/construction/rcd/proc/change_airlock_setting(mob/user)
	if(!user)
		return

	var/list/solid_or_glass_choices = list(
		"Solid" = get_airlock_image(/obj/machinery/door/airlock/ship/station),
		"Glass" = get_airlock_image(/obj/machinery/door/airlock/ship/station/glass)
	)

	var/list/solid_choices = list(
		"Standard" = get_airlock_image(/obj/machinery/door/airlock/ship/station),
		"Public" = get_airlock_image(/obj/machinery/door/airlock/ship/public),
		"Engineering" = get_airlock_image(/obj/machinery/door/airlock/ship/engineering),
		"Security" = get_airlock_image(/obj/machinery/door/airlock/ship/security),
		"Command" = get_airlock_image(/obj/machinery/door/airlock/ship/command),
		"Medical" = get_airlock_image(/obj/machinery/door/airlock/ship/medical),
		"Mining" = get_airlock_image(/obj/machinery/door/airlock/ship/station/mining),
		"Maintenance" = get_airlock_image(/obj/machinery/door/airlock/ship/maintenance),
		"External" = get_airlock_image(/obj/machinery/door/airlock/ship/external),
		"Airtight Hatch" = get_airlock_image(/obj/machinery/door/airlock/ship/hatch),
		"Ship" = get_airlock_image(/obj/machinery/door/airlock/ship)
	)

	var/list/glass_choices = list(
		"Standard" = get_airlock_image(/obj/machinery/door/airlock/ship/station/glass),
		"Public" = get_airlock_image(/obj/machinery/door/airlock/ship/public/glass),
		"Engineering" = get_airlock_image(/obj/machinery/door/airlock/ship/engineering/glass),
		"Security" = get_airlock_image(/obj/machinery/door/airlock/ship/security/glass),
		"Command" = get_airlock_image(/obj/machinery/door/airlock/ship/command/glass),
		"Medical" = get_airlock_image(/obj/machinery/door/airlock/ship/medical/glass),
		"Mining" = get_airlock_image(/obj/machinery/door/airlock/ship/station/mining/glass),
		"Maintenance" = get_airlock_image(/obj/machinery/door/airlock/ship/maintenance/glass),
		"External" = get_airlock_image(/obj/machinery/door/airlock/ship/external/glass),
		"Airtight Hatch" = get_airlock_image(/obj/machinery/door/airlock/ship/hatch/glass),
		"Ship" = get_airlock_image(/obj/machinery/door/airlock/ship/glass)
	)

	var/airlockcat = show_radial_menu(user, src, solid_or_glass_choices, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return
	switch(airlockcat)
		if("Solid")
			if(advanced_airlock_setting == 1)
				var/airlockpaint = show_radial_menu(user, src, solid_choices, radius = 42, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
				if(!check_menu(user))
					return
				switch(airlockpaint)
					if("Standard")
						airlock_type = /obj/machinery/door/airlock/ship/station
					if("Public")
						airlock_type = /obj/machinery/door/airlock/ship/public
					if("Engineering")
						airlock_type = /obj/machinery/door/airlock/ship/engineering
					if("Security")
						airlock_type = /obj/machinery/door/airlock/ship/security
					if("Command")
						airlock_type = /obj/machinery/door/airlock/ship/command
					if("Medical")
						airlock_type = /obj/machinery/door/airlock/ship/medical
					if("Mining")
						airlock_type = /obj/machinery/door/airlock/ship/station/mining
					if("Maintenance")
						airlock_type = /obj/machinery/door/airlock/ship/maintenance
					if("External")
						airlock_type = /obj/machinery/door/airlock/ship/external
					if("Airtight Hatch")
						airlock_type = /obj/machinery/door/airlock/ship/hatch
					if("Ship")
						airlock_type = /obj/machinery/door/airlock/ship/station
				airlock_glass = FALSE
			else
				airlock_type = /obj/machinery/door/airlock/ship
				airlock_glass = FALSE

		if("Glass")
			if(advanced_airlock_setting == 1)
				var/airlockpaint = show_radial_menu(user, src , glass_choices, radius = 42, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
				if(!check_menu(user))
					return
				switch(airlockpaint)
					if("Standard")
						airlock_type = /obj/machinery/door/airlock/ship/station/glass
					if("Public")
						airlock_type = /obj/machinery/door/airlock/ship/public/glass
					if("Engineering")
						airlock_type = /obj/machinery/door/airlock/ship/engineering/glass
					if("Security")
						airlock_type = /obj/machinery/door/airlock/ship/security/glass
					if("Command")
						airlock_type = /obj/machinery/door/airlock/ship/command/glass
					if("Medical")
						airlock_type = /obj/machinery/door/airlock/ship/medical/glass
					if("Research")
						airlock_type = /obj/machinery/door/airlock/research/glass
					if("Mining")
						airlock_type = /obj/machinery/door/airlock/ship/station/mining/glass
					if("Maintenance")
						airlock_type = /obj/machinery/door/airlock/ship/maintenance/glass
					if("External")
						airlock_type = /obj/machinery/door/airlock/ship/external/glass
					if("Airtight Hatch")
						airlock_type = /obj/machinery/door/airlock/ship/hatch/glass
					if("Ship")
						airlock_type = /obj/machinery/door/airlock/ship/station/glass
				airlock_glass = TRUE
			else
				airlock_type = /obj/machinery/door/airlock/ship/glass
				airlock_glass = TRUE
		else
			airlock_type = /obj/machinery/door/airlock/ship
			airlock_glass = FALSE

/// AQUILA: lista śluz dla okna TGUI RCD: nazwa = list(typ, szklana)
/obj/item/construction/rcd/proc/get_rcd_airlock_types()
	if(advanced_airlock_setting != 1)
		return list(
			"śluza okrętowa" = list(/obj/machinery/door/airlock/ship, FALSE),
			"śluza okrętowa (szklana)" = list(/obj/machinery/door/airlock/ship/glass, TRUE),
		)
	return list(
		"śluza standardowa" = list(/obj/machinery/door/airlock/ship/station, FALSE),
		"śluza publiczna" = list(/obj/machinery/door/airlock/ship/public, FALSE),
		"śluza inżynierii" = list(/obj/machinery/door/airlock/ship/engineering, FALSE),
		"śluza ochrony" = list(/obj/machinery/door/airlock/ship/security, FALSE),
		"śluza dowodzenia" = list(/obj/machinery/door/airlock/ship/command, FALSE),
		"śluza medyczna" = list(/obj/machinery/door/airlock/ship/medical, FALSE),
		"śluza górnicza" = list(/obj/machinery/door/airlock/ship/station/mining, FALSE),
		"śluza techniczna" = list(/obj/machinery/door/airlock/ship/maintenance, FALSE),
		"śluza zewnętrzna" = list(/obj/machinery/door/airlock/ship/external, FALSE),
		"właz hermetyczny" = list(/obj/machinery/door/airlock/ship/hatch, FALSE),
		"śluza okrętowa" = list(/obj/machinery/door/airlock/ship, FALSE),
		"śluza standardowa (szklana)" = list(/obj/machinery/door/airlock/ship/station/glass, TRUE),
		"śluza publiczna (szklana)" = list(/obj/machinery/door/airlock/ship/public/glass, TRUE),
		"śluza inżynierii (szklana)" = list(/obj/machinery/door/airlock/ship/engineering/glass, TRUE),
		"śluza ochrony (szklana)" = list(/obj/machinery/door/airlock/ship/security/glass, TRUE),
		"śluza dowodzenia (szklana)" = list(/obj/machinery/door/airlock/ship/command/glass, TRUE),
		"śluza medyczna (szklana)" = list(/obj/machinery/door/airlock/ship/medical/glass, TRUE),
		"śluza górnicza (szklana)" = list(/obj/machinery/door/airlock/ship/station/mining/glass, TRUE),
		"śluza techniczna (szklana)" = list(/obj/machinery/door/airlock/ship/maintenance/glass, TRUE),
		"śluza zewnętrzna (szklana)" = list(/obj/machinery/door/airlock/ship/external/glass, TRUE),
		"właz hermetyczny (szklany)" = list(/obj/machinery/door/airlock/ship/hatch/glass, TRUE),
		"śluza okrętowa (szklana)" = list(/obj/machinery/door/airlock/ship/glass, TRUE),
	)
