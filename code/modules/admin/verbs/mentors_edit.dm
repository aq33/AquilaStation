/******************************************
It's like permissions panel, but for mentors,
also probably less secure, but honestly dude
its mentors, not actual dangerous perms
******************************************/
// AQUILA EDIT - panel mentorów w TGUI (okno "MentorPanel") zamiast HTML + /client/Topic
/client/proc/edit_mentors()
	set category = "Admin"
	set name = "Mentor Panel"
	set desc = "Edit mentors"

	if(!check_rights(R_PERMISSIONS))
		return
	if(!SSdbcore.IsConnected())
		to_chat(src, "<span class='danger'>Nie udało się połączyć z bazą danych.</span>")
		return

	if(!holder.mentor_panel_ui)
		holder.mentor_panel_ui = new(holder)
	holder.mentor_panel_ui.ui_interact(mob)
	holder.mentor_panel_ui.update_static_data(mob)

/datum/admins
	/// AQUILA - okno TGUI panelu mentorów
	var/datum/mentor_panel/mentor_panel_ui

/datum/mentor_panel
	var/datum/admins/holder

/datum/mentor_panel/New(datum/admins/holder)
	. = ..()
	src.holder = holder

/datum/mentor_panel/Destroy(force)
	if(holder?.mentor_panel_ui == src)
		holder.mentor_panel_ui = null
	holder = null
	return ..()

/datum/mentor_panel/ui_state(mob/user)
	return get_admin_state(R_PERMISSIONS)

/datum/mentor_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MentorPanel")
		ui.set_autoupdate(FALSE)
		ui.open()

// Lista z bazy danych, odświeżana po każdej zmianie
/datum/mentor_panel/ui_static_data(mob/user)
	var/list/data = list()
	var/list/mentors = list()
	data["db_connected"] = SSdbcore.IsConnected()
	if(data["db_connected"])
		var/datum/DBQuery/query_mentor_list = SSdbcore.NewQuery("SELECT ckey FROM [format_table_name("mentor")]")
		if(query_mentor_list.warn_execute())
			while(query_mentor_list.NextRow())
				mentors += query_mentor_list.item[1]
		else
			to_chat(user, "<span class='danger'>Unable to pull the mentor list from the database.</span>")
		qdel(query_mentor_list)
	data["mentors"] = mentors
	return data

/datum/mentor_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!check_rights(R_PERMISSIONS))
		message_admins("[key_name_admin(usr)] attempted to edit mentor permissions without sufficient rights.")
		log_admin("[key_name(usr)] attempted to edit mentor permissions without sufficient rights.")
		return
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='admin prefix'>Mentor Edit blocked: Advanced ProcCall detected.</span>")
		return

	switch(action)
		if("refresh")
			update_static_data(usr, ui)
			return
		if("add")
			var/newguy = params["ckey"]
			if(!istext(newguy) || !length(newguy))
				newguy = tgui_input_text(usr, "Podaj klucz nowego mentora.", "Dodaj mentora")
			newguy = ckey(newguy)
			if(!newguy)
				return
			var/datum/DBQuery/query_add_mentor = SSdbcore.NewQuery(
				"INSERT INTO [format_table_name("mentor")] (ckey) VALUES (:newguy)",
				list("newguy" = newguy)
			)
			if(!query_add_mentor.warn_execute())
				qdel(query_add_mentor)
				return
			message_admins("[key_name(usr)] made [newguy] a mentor.")
			log_admin("[key_name(usr)] made [newguy] a mentor.")
			qdel(query_add_mentor)
			load_mentors()
			update_static_data(usr, ui)
			return
		if("remove")
			var/removed_mentor = params["ckey"]
			if(!istext(removed_mentor))
				return
			if(tgui_alert(usr, "Odebrać rangę mentora graczowi [removed_mentor]?", "Usuń mentora", list("Tak", "Nie")) != "Tak")
				return
			var/datum/DBQuery/query_remove_mentor = SSdbcore.NewQuery(
				"DELETE FROM [format_table_name("mentor")] WHERE ckey = :removed_mentor",
				list("removed_mentor" = removed_mentor)
			)
			if(!query_remove_mentor.warn_execute())
				qdel(query_remove_mentor)
				return
			message_admins("[key_name(usr)] de-mentored [removed_mentor]")
			log_admin("[key_name(usr)] de-mentored [removed_mentor]")
			qdel(query_remove_mentor)
			load_mentors()
			update_static_data(usr, ui)
			return
