#define JOB_REPORT_MENU_FAIL_REASON_TRACKING_DISABLED 1
#define JOB_REPORT_MENU_FAIL_REASON_NO_RECORDS 2

/datum/job_report_menu
	var/client/owner

/datum/job_report_menu/New(client/owner, mob/viewer)
	src.owner = owner
	ui_interact(viewer)

/datum/job_report_menu/ui_state()
	return GLOB.always_state

/datum/job_report_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "TrackedPlaytime")
		ui.open()

// AQUILA EDIT - przełącznik zwolnienia z wymogów czasu gry (port z tg)
/datum/job_report_menu/ui_data(mob/user)
	var/list/data = list()
	data["exemptStatus"] = !!(owner?.prefs?.job_exempt || (owner?.prefs?.db_flags & DB_FLAG_EXEMPT))
	return data

/datum/job_report_menu/ui_static_data(mob/user)
	if (!CONFIG_GET(flag/use_exp_tracking))
		return list("failReason" = JOB_REPORT_MENU_FAIL_REASON_TRACKING_DISABLED)

	var/list/play_records = owner.prefs.exp
	if (!play_records.len)
		owner.set_exp_from_db()
		play_records = owner.prefs.exp
		if (!play_records.len)
			return list("failReason" = JOB_REPORT_MENU_FAIL_REASON_NO_RECORDS)

	var/list/data = list()
	data["jobPlaytimes"] = list()
	data["specialPlaytimes"] = list()

	for (var/job_name in SSjob.name_occupations)
		var/playtime = play_records[job_name] ? text2num(play_records[job_name]) : 0
		data["jobPlaytimes"][job_name] = playtime

	for (var/special_name in GLOB.exp_specialmap[EXP_TYPE_SPECIAL])
		var/playtime = play_records[special_name] ? text2num(play_records[special_name]) : 0
		data["specialPlaytimes"][special_name] = playtime

	data["livingTime"] = play_records[EXP_TYPE_LIVING]
	data["ghostTime"] = play_records[EXP_TYPE_GHOST]
	data["adminTime"] = play_records[EXP_TYPE_ADMIN] ? play_records[EXP_TYPE_ADMIN] : 0
	data["isAdmin"] = check_rights(R_ADMIN, show_msg = FALSE)

	return data

/datum/job_report_menu/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle_exempt")
			if(!check_rights(R_ADMIN))
				message_admins("[ADMIN_LOOKUPFLW(usr)] próbuje przełączyć zwolnienie z wymogu czasu gry bez uprawnień admina.")
				log_admin("[key_name(usr)] attempted to toggle job playtime exempt status without admin rights.")
				return TRUE

			var/datum/admins/viewer_admin_datum = GLOB.admin_datums[usr.ckey]
			if(!viewer_admin_datum)
				return TRUE

			if(QDELETED(owner))
				to_chat(usr, "<span class='danger'>BŁĄD: nie znaleziono klienta.</span>")
				return TRUE

			viewer_admin_datum.toggle_exempt_status(owner)
			return TRUE
// AQUILA EDIT END

#undef JOB_REPORT_MENU_FAIL_REASON_TRACKING_DISABLED
#undef JOB_REPORT_MENU_FAIL_REASON_NO_RECORDS
