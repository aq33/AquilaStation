/proc/machine_upgrade(obj/machinery/M in world)
	set name = "Tweak Component Ratings"
	set category = "Debug"
	if (!istype(M))
		return

	var/new_rating = input(i18n_dialog_text(usr, "Enter new rating:"),i18n_dialog_text(usr, "Num")) as num // AQ EDIT - i18n okienka
	if(new_rating && M.component_parts)
		for(var/obj/item/stock_parts/P in M.component_parts)
			P.rating = new_rating
		M.RefreshParts()

	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Machine Upgrade", "[new_rating]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
