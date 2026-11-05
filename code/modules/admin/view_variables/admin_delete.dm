/client/proc/admin_delete(datum/D)
	var/atom/A = D
	var/coords = ""
	var/jmp_coords = ""
	var/coords_pl = ""
	if(istype(A))
		var/turf/T = get_turf(A)
		if(T)
			coords = "at [COORD(T)]"
			coords_pl = "w [COORD(T)]"
			jmp_coords = "w [ADMIN_COORDJMP(T)]"
		else
			coords = "in nullspace"
			jmp_coords = coords_pl = "w nullspace"

	if (alert(src, "Na pewno chcesz usunąć:\n[D]\n[coords_pl]?", "Potwierdzenie", "Tak", "Nie") == "Tak")
		log_admin("[key_name(usr)] deleted [D] [coords]")
		message_admins("[key_name_admin(usr)] usuwa [D] [jmp_coords]")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Delete") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		if(isturf(D))
			var/turf/T = D
			T.ScrapeAway()
		else
			vv_update_display(D, "deleted", VV_MSG_DELETED)
			qdel(D)
			if(!QDELETED(D))
				vv_update_display(D, "deleted", "")
		return TRUE
