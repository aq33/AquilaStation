/datum/buildmode_mode/delete
	key = "delete"

/datum/buildmode_mode/delete/show_help(client/c)
	to_chat(c, "<span class='notice'>***********************************************************\n\
		LPM na czymkolwiek usuwa to. Zepsujesz – płacisz.\n\
		PPM na czymkolwiek usuwa wszystko tego typu. Lepiej tego nie rób, jeśli nie wiesz, co robisz.\n\
		***********************************************************</span>")

/datum/buildmode_mode/delete/handle_click(client/c, params, object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")

	if(left_click)
		if(isturf(object))
			var/turf/T = object
			T.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		else if(isatom(object))
			qdel(object)

	if(right_click)
		if(!check_rights(R_DEBUG|R_SERVER)) //Prevents buildmoded non-admins from breaking everything.
			return
		if(isturf(object))
			return
		var/atom/deleting = object
		var/action_type = alert(usr,"Tylko ten typ ([deleting.type]) czy typ ze wszystkimi podtypami?","Tylko ten typ","Typ i podtypy","Anuluj")
		if(action_type == "Anuluj" || !action_type)
			return

		if(alert(usr,"Na pewno chcesz usunąć wszystkie instancje typu [deleting.type]?","Tak","Nie") != "Tak")
			return

		if(alert(usr,"Wymagane drugie potwierdzenie. Usunąć?","Tak","Nie") != "Tak")
			return

		var/O_type = deleting.type
		switch(action_type)
			if("Tylko ten typ")
				var/i = 0
				for(var/atom/Obj in world)
					if(Obj.type == O_type)
						i++
						qdel(Obj)
					CHECK_TICK
				if(!i)
					to_chat(usr, "Nie istnieją żadne instancje tego typu")
					return
				log_admin("[key_name(usr)] deleted all instances of type [O_type] ([i] instances deleted) ")
				message_admins("<span class='notice'>[key_name(usr)] usuwa wszystkie instancje typu [O_type] (usunięto: [i])</span>")
			if("Typ i podtypy")
				var/i = 0
				for(var/Obj in world)
					if(istype(Obj,O_type))
						i++
						qdel(Obj)
					CHECK_TICK
				if(!i)
					to_chat(usr, "Nie istnieją żadne instancje tego typu")
					return
				log_admin("[key_name(usr)] deleted all instances of type or subtype of [O_type] ([i] instances deleted) ")
				message_admins("<span class='notice'>[key_name(usr)] usuwa wszystkie instancje typu lub podtypu [O_type] (usunięto: [i])</span> ")
