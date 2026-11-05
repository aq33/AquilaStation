/client/proc/jumptoarea(area/A in GLOB.sortedAreas)
	set name = "Jump to Area"
	set desc = "Obszar, do którego skoczyć"
	set category = "Adminbus"
	if(!src.holder)
		to_chat(src, "Tylko administratorzy mogą używać tej komendy.")
		return

	if(!A)
		return

	var/list/turfs = list()
	for(var/turf/T in A)
		if(T.density)
			continue
		turfs.Add(T)

	var/turf/T = safepick(turfs)
	if(!T)
		to_chat(src, "Nie ma dokąd skoczyć!")
		return
	usr.forceMove(T)
	log_admin("[key_name(usr)] jumped to [AREACOORD(A)]")
	message_admins("[key_name_admin(usr)] skacze do: [AREACOORD(A)]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Jump To Area") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/jumptoturf(turf/T in world)
	set name = "Jump to Turf"
	set category = "Adminbus"
	if(!src.holder)
		to_chat(src, "Tylko administratorzy mogą używać tej komendy.")
		return

	log_admin("[key_name(usr)] jumped to [AREACOORD(T)]")
	message_admins("[key_name_admin(usr)] skacze do: [AREACOORD(T)]")
	usr.forceMove(T)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Jump To Turf") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/jumptomob(mob/M in GLOB.mob_list)
	set category = "Adminbus"
	set name = "Jump to Mob"

	if(!src.holder)
		to_chat(src, "Tylko administratorzy mogą używać tej komendy.")
		return

	log_admin("[key_name(usr)] jumped to [key_name(M)]")
	message_admins("[key_name_admin(usr)] skacze do: [ADMIN_LOOKUPFLW(M)] ([AREACOORD(M)])")
	if(src.mob)
		var/mob/A = src.mob
		var/turf/T = get_turf(M)
		if(T && isturf(T))
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Jump To Mob") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
			A.forceMove(M.loc)
		else
			to_chat(A, "Ten mob nie znajduje się w świecie gry.")

/client/proc/jumptocoord(tx as num, ty as num, tz as num)
	set category = "Adminbus"
	set name = "Jump to Coordinate"

	if (!holder)
		to_chat(src, "Tylko administratorzy mogą używać tej komendy.")
		return

	if(src.mob)
		var/mob/A = src.mob
		var/turf/T = locate(tx,ty,tz)
		A.forceMove(T)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Jump To Coordiate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	message_admins("[key_name_admin(usr)] skacze na współrzędne [tx], [ty], [tz]")

/client/proc/jumptokey()
	set category = "Adminbus"
	set name = "Jump to Key"

	if(!src.holder)
		to_chat(src, "Tylko administratorzy mogą używać tej komendy.")
		return

	var/list/keys = list()
	for(var/mob/M in GLOB.player_list)
		keys += M.client
	var/client/selection = input("Wybierz gracza!", "Skok admina", null, null) as null|anything in sortKey(keys)
	if(!selection)
		to_chat(src, "Nie znaleziono kluczy.")
		return
	var/mob/M = selection.mob
	log_admin("[key_name(usr)] jumped to [key_name(M)]")
	message_admins("[key_name_admin(usr)] skacze do: [ADMIN_LOOKUPFLW(M)]")

	usr.forceMove(M.loc)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Jump To Key") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/Getmob(mob/M in GLOB.mob_list - GLOB.dummy_mob_list)
	set category = "Adminbus"
	set name = "Get Mob"
	set desc = "Mob do teleportacji"
	if(!src.holder)
		to_chat(src, "Tylko administratorzy mogą używać tej komendy.")
		return

	var/atom/loc = get_turf(usr)
	log_admin("[key_name(usr)] teleported [key_name(M)] to [AREACOORD(loc)]")
	var/msg = "[key_name_admin(usr)] teleportuje [ADMIN_LOOKUPFLW(M)] do: [ADMIN_VERBOSEJMP(loc)]"
	message_admins(msg)
	admin_ticket_log(M, msg, color="orange")
	//NSV13 - support for getting mobs out of fighters
	var/obj/structure/overmap/OM = M.loc
	if(istype(OM))
		OM.stop_piloting(M)
	//NSV13 end
	M.forceMove(loc)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Get Mob") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/Getkey()
	set category = "Adminbus"
	set name = "Get Key"
	set desc = "Klucz do teleportacji"

	if(!src.holder)
		to_chat(src, "Tylko administratorzy mogą używać tej komendy.")
		return

	var/list/keys = list()
	for(var/mob/M in GLOB.player_list)
		keys += M.client
	var/client/selection = input("Wybierz gracza!", "Skok admina", null, null) as null|anything in sortKey(keys)
	if(!selection)
		return
	var/mob/M = selection.mob

	if(!M)
		return
	log_admin("[key_name(usr)] teleported [key_name(M)]")
	var/msg = "[key_name_admin(usr)] teleportuje do siebie: [ADMIN_LOOKUPFLW(M)]"
	message_admins(msg)
	admin_ticket_log(M, msg, color="orange")
	if(M)
		M.forceMove(get_turf(usr))
		usr.forceMove(M.loc)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Get Key") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/sendmob(mob/M in sortmobs())
	set category = "Adminbus"
	set name = "Send Mob"
	if(!src.holder)
		to_chat(src, "Tylko administratorzy mogą używać tej komendy.")
		return
	var/area/A = input(usr, "Wybierz obszar.", "Wybierz obszar") in GLOB.sortedAreas|null
	if(A && istype(A))
		if(M.forceMove(safepick(get_area_turfs(A))))

			log_admin("[key_name(usr)] teleported [key_name(M)] to [AREACOORD(A)]")
			var/msg = "[key_name_admin(usr)] teleportuje [ADMIN_LOOKUPFLW(M)] do: [AREACOORD(A)]"
			message_admins(msg)
			admin_ticket_log(M, msg, color="orange")
		else
			to_chat(src, "Nie udało się przenieść moba w prawidłowe miejsce.")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Send Mob") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
