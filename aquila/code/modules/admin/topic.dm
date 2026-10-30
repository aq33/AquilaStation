/datum/admins/Topic(href, href_list)
	if(href_list["makeAntag"])
		if(!check_rights(R_ADMIN))
			return
		if (!SSticker.mode)
			to_chat(usr, span_danger("Nie przed rozpoczęciem rundy!"))
			return
		switch(href_list["makeAntag"])
			if("infiltrator")
				message_admins("[key_name(usr)] tworzy drużynę infiltratorów...")
				if(makeInfiltratorTeam())
					message_admins("[key_name(usr)] tworzy drużynę infiltratorów.")
					log_admin("[key_name(usr)] created an infiltration team.")
				else
					message_admins("[key_name_admin(usr)] próbuje stworzyć drużynę infiltratorów, ale zabrakło kandydatów.")
					log_admin("[key_name(usr)] failed to create an infiltration team.")
			if("vampire")
				if(makeVampire())
					message_admins("[key_name(usr)] tworzy wampira.")
					log_admin("[key_name(usr)] created a vampire.")
				else
					message_admins("[key_name_admin(usr)] próbuje stworzyć wampira, ale nie ma żadnych kandydatów.")
					log_admin("[key_name(usr)] failed to create a vampire.")
	.=..()
