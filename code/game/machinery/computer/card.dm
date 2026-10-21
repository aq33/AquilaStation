#define DEPT_ALL 0
#define DEPT_GEN 1
#define DEPT_SEC 2
#define DEPT_MED 3
#define DEPT_SCI 4
#define DEPT_ENG 5
#define DEPT_SUP 6
#define DEPT_MUN 7 //NSV13

//Keeps track of the time for the ID console. Having it as a global variable prevents people from dismantling/reassembling it to
//increase the slots of many jobs.
GLOBAL_VAR_INIT(time_last_changed_position, 0)

/obj/machinery/computer/card
	name = "identification console"
	desc = "You can use this to manage jobs and ID access."
	icon_screen = "id"
	icon_keyboard = "id_key"
	req_one_access = list(ACCESS_HEADS, ACCESS_CHANGE_IDS)
	circuit = /obj/item/circuitboard/computer/card
	var/mode = 0
	var/printing = null
	var/target_dept = DEPT_ALL //Which department this computer has access to.

	//Cooldown for closing positions in seconds
	//if set to -1: No cooldown... probably a bad idea
	//if set to 0: Not able to close "original" positions. You can only close positions that you have opened before
	var/change_position_cooldown = 30
	//Jobs you cannot open new positions for
	var/list/blacklisted = list(
		JOB_NAME_AI,
		JOB_NAME_ASSISTANT,
		JOB_NAME_CYBORG,
		JOB_NAME_CAPTAIN,
		JOB_NAME_HEADOFPERSONNEL,
		JOB_NAME_HEADOFSECURITY,
		JOB_NAME_CHIEFENGINEER,
		JOB_NAME_RESEARCHDIRECTOR,
		JOB_NAME_CHIEFMEDICALOFFICER,
		JOB_NAME_BRIGPHYSICIAN,
		JOB_NAME_DEPUTY,
		JOB_NAME_MASTERATARMS) //NSV13 - MAA

	//The scaling factor of max total positions in relation to the total amount of people on board the station in %
	var/max_relative_positions = 30 //30%: Seems reasonable, limit of 6 @ 20 players

	//This is used to keep track of opened positions for jobs to allow instant closing
	//Assoc array: "JobName" = (int)<Opened Positions>
	var/list/opened_positions = list();
	var/obj/item/card/id/inserted_scan_id
	var/obj/item/card/id/inserted_modify_id
	var/list/region_access = null
	var/list/head_subordinates = null

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/card/Initialize(mapload)
	. = ..()
	change_position_cooldown = CONFIG_GET(number/id_console_jobslot_delay)
	for(var/G in typesof(/datum/job/gimmick))
		var/datum/job/gimmick/J = new G
		blacklisted += J.title

/obj/machinery/computer/card/examine(mob/user)
	. = ..()
	if(inserted_scan_id || inserted_modify_id)
		. += "<span class='notice'>Alt-kliknij, by wysunąć kartę ID.</span>"

/obj/machinery/computer/card/attackby(obj/I, mob/user, params)
	if(isidcard(I))
		if(check_access(I) && !inserted_scan_id)
			if(id_insert(user, I, inserted_scan_id))
				inserted_scan_id = I
			updateUsrDialog()
		else if(id_insert(user, I, inserted_modify_id))
			inserted_modify_id = I
			updateUsrDialog()
	else
		return ..()

/obj/machinery/computer/card/Destroy()
	if(inserted_scan_id)
		qdel(inserted_scan_id)
		inserted_scan_id = null
	if(inserted_modify_id)
		update_modify_manifest()
		qdel(inserted_modify_id)
		inserted_modify_id = null
	return ..()

/obj/machinery/computer/card/handle_atom_del(atom/A)
	..()
	if(A == inserted_scan_id)
		inserted_scan_id = null
		updateUsrDialog()
	if(A == inserted_modify_id)
		update_modify_manifest()
		inserted_modify_id = null
		updateUsrDialog()

/obj/machinery/computer/card/on_deconstruction()
	if(inserted_scan_id)
		inserted_scan_id.forceMove(drop_location())
		inserted_scan_id = null
	if(inserted_modify_id)
		update_modify_manifest()
		inserted_modify_id.forceMove(drop_location())
		inserted_modify_id = null

//Check if you can't open a new position for a certain job
/obj/machinery/computer/card/proc/job_blacklisted(jobtitle)
	return (jobtitle in blacklisted)

//Logic check for Topic() if you can open the job
/obj/machinery/computer/card/proc/can_open_job(datum/job/job)
	if(job)
		if(!job_blacklisted(job.title))
			if((job.total_positions <= GLOB.player_list.len * (max_relative_positions / 100)))
				var/delta = (world.time / 10) - GLOB.time_last_changed_position
				if((change_position_cooldown < delta) || (opened_positions[job.title] < 0))
					return 1
				return -2
			return -1
	return 0

//Logic check for Topic() if you can close the job
/obj/machinery/computer/card/proc/can_close_job(datum/job/job)
	if(job)
		if(!job_blacklisted(job.title))
			if(job.total_positions > job.current_positions)
				var/delta = (world.time / 10) - GLOB.time_last_changed_position
				if((change_position_cooldown < delta) || (opened_positions[job.title] > 0))
					return 1
				return -2
			return -1
	return 0

/obj/machinery/computer/card/proc/id_insert(mob/user, obj/item/inserting_item, obj/item/target)
	var/obj/item/card/id/card_to_insert = inserting_item
	var/holder_item = FALSE

	if(!isidcard(card_to_insert))
		card_to_insert = inserting_item.RemoveID()
		holder_item = TRUE

	if(!card_to_insert || !user.transferItemToLoc(card_to_insert, src))
		return FALSE

	if(target)
		if(holder_item && inserting_item.InsertID(target))
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
		else
			id_eject(user, target)

	user.visible_message("<span class='notice'>[user] wkłada [card_to_insert] do [src].</span>",
						"<span class='notice'>Wkładasz [card_to_insert] do [src].</span>")
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
	updateUsrDialog()
	return TRUE

/obj/machinery/computer/card/proc/id_eject(mob/user, obj/target)
	if(!target)
		to_chat(user, "<span class='warning'>To gniazdo jest puste!</span>")
		return FALSE
	else
		if(target == inserted_modify_id)
			update_modify_manifest()
		target.forceMove(drop_location())
		if(!issilicon(user) && Adjacent(user))
			user.put_in_hands(target)
		user.visible_message("<span class='notice'>[user] wyjmuje [target] z [src].</span>", \
							"<span class='notice'>Wyjmujesz [target] z [src].</span>")
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
		updateUsrDialog()
		return TRUE

/obj/machinery/computer/card/proc/update_modify_manifest()
	if(inserted_modify_id.registered_account)
		inserted_modify_id.registered_account.account_department = get_department_by_hud(inserted_modify_id.hud_state) // your true department by your hud icon color
	GLOB.data_core.manifest_modify(inserted_modify_id.registered_name, inserted_modify_id.assignment, inserted_modify_id.hud_state)

/obj/machinery/computer/card/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, !issilicon(user)) || !is_operational)
		return
	if(inserted_modify_id)
		if(id_eject(user, inserted_modify_id))
			inserted_modify_id = null
			updateUsrDialog()
			return
	if(inserted_scan_id)
		if(id_eject(user, inserted_scan_id))
			inserted_scan_id = null
			updateUsrDialog()
			return

// Okno konsoli jest w TGUI (IdentificationConsole): aquila/code/game/machinery/computer/card_ui.dm
// Przyciski okna nadal idą przez Topic() poniżej.

/obj/machinery/computer/card/Topic(href, href_list)
	if(..())
		return

	if(!usr.canUseTopic(src, !issilicon(usr)) || !is_operational)
		usr.unset_machine()
		usr << browse(null, "window=id_com")
		return

	usr.set_machine(src)
	switch(href_list["choice"])
		if ("inserted_modify_id")
			if(inserted_modify_id && !usr.get_active_held_item())
				if(id_eject(usr, inserted_modify_id))
					inserted_modify_id = null
					updateUsrDialog()
					return
			if(usr.get_id_in_hand())
				var/obj/item/held_item = usr.get_active_held_item()
				var/obj/item/card/id/id_to_insert = held_item.GetID()
				if(id_insert(usr, held_item, inserted_modify_id))
					inserted_modify_id = id_to_insert
					updateUsrDialog()
		if ("inserted_scan_id")
			if(inserted_scan_id && !usr.get_active_held_item())
				if(id_eject(usr, inserted_scan_id))
					inserted_scan_id = null
					updateUsrDialog()
					return
			if(usr.get_id_in_hand())
				var/obj/item/held_item = usr.get_active_held_item()
				var/obj/item/card/id/id_to_insert = held_item.GetID()
				if(id_insert(usr, held_item, inserted_scan_id))
					inserted_scan_id = id_to_insert
					updateUsrDialog()
		if ("auth")
			if ((!( authenticated ) && (inserted_scan_id || issilicon(usr)) && (inserted_modify_id || mode)))
				if (check_access(inserted_scan_id))
					region_access = list()
					head_subordinates = list()
					if(ACCESS_CHANGE_IDS in inserted_scan_id.access)
						if(target_dept)
							head_subordinates = get_all_jobs()
							region_access |= target_dept
							authenticated = 1
						else
							authenticated = 2
						playsound(src, 'sound/machines/terminal_on.ogg', 50, FALSE)

					else
						if((ACCESS_HOP in inserted_scan_id.access) && ((target_dept==DEPT_GEN) || !target_dept))
							region_access |= DEPT_GEN
							region_access |= DEPT_SUP //Currently no seperation between service/civillian and supply
							get_subordinates(JOB_NAME_HEADOFPERSONNEL)
						if((ACCESS_HOS in inserted_scan_id.access) && ((target_dept==DEPT_SEC) || !target_dept))
							region_access |= DEPT_SEC
							get_subordinates(JOB_NAME_HEADOFSECURITY)
						if((ACCESS_CMO in inserted_scan_id.access) && ((target_dept==DEPT_MED) || !target_dept))
							region_access |= DEPT_MED
							get_subordinates(JOB_NAME_CHIEFMEDICALOFFICER)
						if((ACCESS_RD in inserted_scan_id.access) && ((target_dept==DEPT_SCI) || !target_dept))
							region_access |= DEPT_SCI
							get_subordinates(JOB_NAME_RESEARCHDIRECTOR)
						if((ACCESS_CE in inserted_scan_id.access) && ((target_dept==DEPT_ENG) || !target_dept))
							region_access |= DEPT_ENG
							get_subordinates(JOB_NAME_CHIEFENGINEER)
						if((ACCESS_MAA in inserted_scan_id.access) && ((target_dept==DEPT_MUN) || !target_dept)) //NSV13 - munitions
							region_access |= DEPT_MUN
							get_subordinates(JOB_NAME_MASTERATARMS)
						if(region_access)
							authenticated = 1
			else if ((!( authenticated ) && issilicon(usr)) && (!inserted_modify_id))
				to_chat(usr, "<span class='warning'>Nie możesz zmodyfikować ID bez włożonej karty do modyfikacji! Gdy będzie w gnieździe modyfikacji komputera, możesz się zalogować.</span>")
		if ("logout")
			region_access = null
			head_subordinates = null
			authenticated = 0
			playsound(src, 'sound/machines/terminal_off.ogg', 50, FALSE)

		if("access")
			if(href_list["allowed"])
				if(authenticated)
					var/access_type = text2num(href_list["access_target"])
					var/access_allowed = text2num(href_list["allowed"])
					if(access_type in (istype(src, /obj/machinery/computer/card/centcom)?get_all_centcom_access() : get_all_accesses()))
						inserted_modify_id.access -= access_type
						log_id("[key_name(usr)] removed [get_access_desc(access_type)] from [inserted_modify_id] using [inserted_scan_id] at [AREACOORD(usr)].")
						if(access_allowed == 1)
							inserted_modify_id.access += access_type
							log_id("[key_name(usr)] added [get_access_desc(access_type)] to [inserted_modify_id] using [inserted_scan_id] at [AREACOORD(usr)].")
						playsound(src, "terminal_type", 50, FALSE)
		if ("assign")
			if (authenticated == 2)
				var/t1 = href_list["assign_target"]
				if(t1 == "Custom")
					var/newJob = reject_bad_text(stripped_input("Podaj własny przydział stanowiska.", "Assignment", inserted_modify_id ? inserted_modify_id.assignment : "Unassigned"), MAX_NAME_LEN)
					if(newJob)
						t1 = newJob
						log_id("[key_name(usr)] changed [inserted_modify_id] assignment to [newJob] using [inserted_scan_id] at [AREACOORD(usr)].")

				else if(t1 == "Unassigned")
					inserted_modify_id.access -= get_all_accesses()
					log_id("[key_name(usr)] unassigned and stripped all access from [inserted_modify_id] using [inserted_scan_id] at [AREACOORD(usr)].")

				else
					var/datum/job/jobdatum
					for(var/jobtype in typesof(/datum/job))
						var/datum/job/J = new jobtype
						if(ckey(J.title) == ckey(t1))
							jobdatum = J
							updateUsrDialog()
							break

					if(!jobdatum)
						to_chat(usr, "<span class='error'>Brak logu dla tego stanowiska.</span>")
						updateUsrDialog()
						return

					inserted_modify_id.access = ( istype(src, /obj/machinery/computer/card/centcom) ? get_centcom_access(t1) : jobdatum.get_access() )
					log_id("[key_name(usr)] assigned [jobdatum] job to [inserted_modify_id], overriding all previous access using [inserted_scan_id] at [AREACOORD(usr)].")

				if (inserted_modify_id)
					inserted_modify_id.assignment = t1
					playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
		if ("demote")
			if(inserted_modify_id.assignment in head_subordinates || inserted_modify_id.assignment == "Assistant")
				inserted_modify_id.assignment = "Unassigned"
				log_id("[key_name(usr)] demoted [inserted_modify_id], unassigning the card without affecting access, using [inserted_scan_id] at [AREACOORD(usr)].")
				playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			else
				to_chat(usr, "<span class='error'>Nie masz uprawnień do degradowania tego stanowiska.</span>")
		if ("reg")
			if (authenticated)
				var/t2 = inserted_modify_id
				if ((authenticated && inserted_modify_id == t2 && (in_range(src, usr) || issilicon(usr)) && isturf(loc)))
					// Sanitize the name first. We're not using the full sanitize_name proc as ID cards can have a wider variety of things on them that
					// would not pass as a formal character name, but would still be valid on an ID card created by a player.
					var/new_name = sanitize(href_list["reg"])
					// However, we are going to reject bad names overall including names with invalid characters in them, while allowing numbers.
					new_name = reject_bad_name(new_name, allow_numbers = TRUE)

					if(new_name)
						log_id("[key_name(usr)] changed [inserted_modify_id] name to '[new_name]', using [inserted_scan_id] at [AREACOORD(usr)].")
						inserted_modify_id.registered_name = new_name
						playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
					else
						to_chat(usr, "<span class='error'>Podano nieprawidłowe imię.</span>")
						updateUsrDialog()
						return
		if ("mode")
			mode = text2num(href_list["mode_target"])

		if("return")
			//DISPLAY MAIN MENU
			mode = 0
			playsound(src, "terminal_type", 25, FALSE)

		if("make_job_available")
			// MAKE ANOTHER JOB POSITION AVAILABLE FOR LATE JOINERS
			if(inserted_scan_id && (ACCESS_CHANGE_IDS in inserted_scan_id.access) && !target_dept)
				var/edit_job_target = href_list["job"]
				var/datum/job/j = SSjob.GetJob(edit_job_target)
				if(!j)
					updateUsrDialog()
					return 0
				if(can_open_job(j) != 1)
					updateUsrDialog()
					return 0
				if(opened_positions[edit_job_target] >= 0)
					GLOB.time_last_changed_position = world.time / 10
				j.total_positions++
				opened_positions[edit_job_target]++
				playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)

		if("make_job_unavailable")
			// MAKE JOB POSITION UNAVAILABLE FOR LATE JOINERS
			if(inserted_scan_id && (ACCESS_CHANGE_IDS in inserted_scan_id.access) && !target_dept)
				var/edit_job_target = href_list["job"]
				var/datum/job/j = SSjob.GetJob(edit_job_target)
				if(!j)
					updateUsrDialog()
					return 0
				if(can_close_job(j) != 1)
					updateUsrDialog()
					return 0
				//Allow instant closing without cooldown if a position has been opened before
				if(opened_positions[edit_job_target] <= 0)
					GLOB.time_last_changed_position = world.time / 10
				j.total_positions--
				opened_positions[edit_job_target]--
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)

		if ("prioritize_job")
			// TOGGLE WHETHER JOB APPEARS AS PRIORITIZED IN THE LOBBY
			if(inserted_scan_id && (ACCESS_CHANGE_IDS in inserted_scan_id.access) && !target_dept)
				var/priority_target = href_list["job"]
				var/datum/job/j = SSjob.GetJob(priority_target)
				if(!j)
					updateUsrDialog()
					return 0
				var/priority = TRUE
				if(j in SSjob.prioritized_jobs)
					SSjob.prioritized_jobs -= j
					priority = FALSE
				else if(j.total_positions <= j.current_positions)
					to_chat(usr, "<span class='notice'>Wszystkie miejsca na stanowisku [j.title] są obsadzone. Otwórz więcej miejsc, zanim nadasz mu priorytet.</span>")
					updateUsrDialog()
					return
				else
					SSjob.prioritized_jobs += j
				to_chat(usr, "<span class='notice'>Stanowisku [j.title] pomyślnie [priority ?  "nadano priorytet" : "odebrano priorytet"]. Potencjalni pracownicy zauważą twoją prośbę.</span>")
				playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)

		if ("adjust_pay")
			//Adjust the paycheck of a crew member. Can't be less than zero.
			if(!inserted_scan_id)
				updateUsrDialog()
				return
			var/account_name = href_list["account"]
			var/datum/bank_account/account = null
			for(var/datum/bank_account/B in SSeconomy.bank_accounts)
				if(B.account_holder == account_name)
					account = B
					break
			if(isnull(account))
				updateUsrDialog()
				return
			switch(account.account_department) //Checking if the user has access to change pay.
				if(ACCOUNT_SRV,ACCOUNT_CIV,ACCOUNT_CAR)
					if(!(ACCESS_HOP in inserted_scan_id.access))
						updateUsrDialog()
						return
				if(ACCOUNT_SEC)
					if(!(ACCESS_HOS in inserted_scan_id.access))
						updateUsrDialog()
						return
				if(ACCOUNT_MED)
					if(!(ACCESS_CMO in inserted_scan_id.access))
						updateUsrDialog()
						return
				if(ACCOUNT_SCI)
					if(!(ACCESS_RD in inserted_scan_id.access))
						updateUsrDialog()
						return
				if(ACCOUNT_ENG)
					if(!(ACCESS_CE in inserted_scan_id.access))
						updateUsrDialog()
						return
			var/new_pay = FLOOR(input(usr, "Podaj nową kwotę pensji.", "Ustaw nową kwotę pensji.", account.paycheck_amount) as num|null, 1)
			if(isnull(new_pay))
				updateUsrDialog()
				return
			if(new_pay < 0)
				to_chat(usr, "<span class='warning'>Pensje nie mogą być ujemne.</span>")
				updateUsrDialog()
				return
			account.paycheck_amount = new_pay

		if ("adjust_bonus")
			//Adjust the bonus pay of a crew member. Negative amounts dock pay.
			if(!inserted_scan_id)
				updateUsrDialog()
				return
			var/account_name = href_list["account"]
			var/datum/bank_account/account = null
			for(var/datum/bank_account/B in SSeconomy.bank_accounts)
				if(B.account_holder == account_name)
					account = B
					break
			if(isnull(account))
				updateUsrDialog()
				return
			switch(account.account_department) //Checking if the user has access to change pay.
				if(ACCOUNT_SRV,ACCOUNT_CIV,ACCOUNT_CAR)
					if(!(ACCESS_HOP in inserted_scan_id.access))
						updateUsrDialog()
						return
				if(ACCOUNT_SEC)
					if(!(ACCESS_HOS in inserted_scan_id.access))
						updateUsrDialog()
						return
				if(ACCOUNT_MED)
					if(!(ACCESS_CMO in inserted_scan_id.access))
						updateUsrDialog()
						return
				if(ACCOUNT_SCI)
					if(!(ACCESS_RD in inserted_scan_id.access))
						updateUsrDialog()
						return
				if(ACCOUNT_ENG)
					if(!(ACCESS_CE in inserted_scan_id.access))
						updateUsrDialog()
						return
			var/new_bonus = FLOOR(input(usr, "Podaj kwotę premii. Wartości ujemne obniżą pensje.", "Ustaw premię", account.paycheck_bonus) as num|null, 1)
			if(isnull(new_bonus))
				updateUsrDialog()
				return
			account.paycheck_bonus = new_bonus

		if ("print")
			if (!( printing ))
				printing = 1
				sleep(50)
				var/obj/item/paper/P = new /obj/item/paper( loc )
				var/t1 = "<B>Manifest załogi:</B><BR>"
				for(var/datum/data/record/t in sortRecord(GLOB.data_core.general))
					t1 += t.fields["name"] + " - " + t.fields["rank"] + "<br>"
				P.default_raw_text = t1
				P.name = "paper- 'Crew Manifest'"
				printing = null
				playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
	if (inserted_modify_id)
		inserted_modify_id.update_label()
	updateUsrDialog()

/obj/machinery/computer/card/proc/get_subordinates(rank)
	for(var/datum/job/job in SSjob.occupations)
		if(rank in job.department_head)
			head_subordinates += job.title

/obj/machinery/computer/card/centcom
	name = "\improper CentCom identification console"
	circuit = /obj/item/circuitboard/computer/card/centcom
	req_access = list(ACCESS_CENT_CAPTAIN)

/obj/machinery/computer/card/minor
	name = "department management console"
	desc = "You can use this to change ID's for specific departments."
	icon_screen = "idminor"
	circuit = /obj/item/circuitboard/computer/card/minor

/obj/machinery/computer/card/minor/Initialize(mapload)
	. = ..()
	var/obj/item/circuitboard/computer/card/minor/typed_circuit = circuit
	if(target_dept)
		typed_circuit.target_dept = target_dept
	else
		target_dept = typed_circuit.target_dept
	var/list/dept_list = list("general","security","medical","science","engineering")
	name = "[dept_list[target_dept]] department console"

/obj/machinery/computer/card/minor/hos
	target_dept = DEPT_SEC
	icon_screen = "idhos"

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/card/minor/cmo
	target_dept = DEPT_MED
	icon_screen = "idcmo"

/obj/machinery/computer/card/minor/rd
	target_dept = DEPT_SCI
	icon_screen = "idrd"

	light_color = LIGHT_COLOR_PINK

/obj/machinery/computer/card/minor/ce
	target_dept = DEPT_ENG
	icon_screen = "idce"

	light_color = LIGHT_COLOR_YELLOW

#undef DEPT_ALL
#undef DEPT_GEN
#undef DEPT_SEC
#undef DEPT_MED
#undef DEPT_SCI
#undef DEPT_ENG
#undef DEPT_SUP
#undef DEPT_MUN //NSV13
