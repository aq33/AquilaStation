/client/proc/fax_manager()
	set name = "Fax Manager"
	set desc = "Otwiera panel menedżera ze wszystkimi zgłoszeniami z trwającej rundy."
	set category = "Admin"
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Fax Manager")
	GLOB.fax_manager.ui_interact(usr)
