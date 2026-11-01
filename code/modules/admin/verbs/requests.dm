/// Verb for opening the requests manager panel
/client/proc/requests()
	set name = "Requests Manager"
	set desc = "Otwiera panel menedżera próśb ze wszystkimi prośbami z tej rundy"
	set category = "Admin"
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Request Manager") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	GLOB.requests.ui_interact(usr)
