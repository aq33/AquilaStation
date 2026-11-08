// AQ EDIT - działy z grup SSdepartment zamiast CARDCON_DEPARTMENT_* i numerów regionów (port BeeStation/BeeStation-Hornet#14139)

/datum/computer_file/program/card_mod
	filename = "cardmod"
	filedesc = "Modyfikacja kart identyfikacyjnych"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "id"
	extended_desc = "Program do programowania kart identyfikacyjnych pracowników, nadających dostęp do części stacji."
	transfer_access = list(ACCESS_HEADS)
	requires_ntnet = 0
	size = 8
	tgui_id = "NtosCard"
	program_icon = "id-card"



	var/is_centcom = FALSE
	var/minor = FALSE
	var/authenticated = FALSE
	// AQ EDIT START - działy jako bitflagi SSdepartment (port BeeStation/BeeStation-Hornet#14139)
	/// Działy, którymi zarządza zalogowana karta szefa
	var/accessible_region_bitflag = NONE
	var/list/head_subordinates
	/// Działy, którymi program może zarządzać (bitflaga). NONE = wszystkie działy
	var/department_bitflag = NONE
	// AQ EDIT END

/datum/computer_file/program/card_mod/proc/authenticate(mob/user, obj/item/card/id/id_card)
	if(!id_card)
		return

	// AQ EDIT START - szef dostaje działy po dostępie swojego biura (HoP: Ogólne i Zaopatrzenie, MAA: Uzbrojenie), podwładni do przypisania jak dotąd (port BeeStation/BeeStation-Hornet#14139)
	accessible_region_bitflag = NONE
	head_subordinates = list()
	if(!department_bitflag && (ACCESS_CHANGE_IDS in id_card.access))
		minor = FALSE
		authenticated = TRUE
		update_static_data(user)
		return TRUE

	accessible_region_bitflag = SSdepartment.get_managed_departments(id_card.access, department_bitflag)
	if(accessible_region_bitflag)
		head_subordinates = SSdepartment.get_subordinate_jobs(accessible_region_bitflag)
		minor = TRUE
		authenticated = TRUE
		update_static_data(user)
		return TRUE
	// AQ EDIT END

	return FALSE

/datum/computer_file/program/card_mod/ui_act(action, params)
	if(..())
		return TRUE

	if(!computer)
		return

	var/obj/item/computer_hardware/card_slot/card_slot = computer.all_components[MC_CARD]
	var/obj/item/computer_hardware/card_slot/card_slot2 = computer.all_components[MC_CARD2]
	var/obj/item/computer_hardware/printer/printer = computer.all_components[MC_PRINT]
	if(!card_slot || !card_slot2)
		return

	var/mob/user = usr
	var/obj/item/card/id/user_id_card = card_slot.stored_card
	var/obj/item/card/id/target_id_card = card_slot2.stored_card

	switch(action)
		if("PRG_authenticate")
			if(!user_id_card)
				playsound(computer, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)
				return
			if(authenticate(user, user_id_card))
				playsound(computer, 'sound/machines/terminal_on.ogg', 50, FALSE)
				return TRUE
		if("PRG_logout")
			authenticated = FALSE
			playsound(computer, 'sound/machines/terminal_off.ogg', 50, FALSE)
			return TRUE
		if("PRG_print")
			if(!printer)
				return
			if(!authenticated)
				return
			var/contents = {"<h4>Raport dostępu</h4><u>Przygotował:</u> [user_id_card && user_id_card.registered_name ? user_id_card.registered_name : "Nieznany"]<br><u>Dla:</u> [target_id_card.registered_name ? target_id_card.registered_name : "Niezarejestrowany"]<br><hr><u>Stanowisko:</u> [target_id_card.assignment]<br><u>Dostęp:</u><br>
						"}

			var/known_access_rights = get_all_accesses()
			for(var/A in target_id_card.access)
				if(A in known_access_rights)
					contents += "  [get_access_desc(A)]"

			if(!printer.print_text(contents,"raport dostępu"))
				to_chat(usr, "<span class='notice'>Błąd sprzętu: drukarka nie mogła wydrukować pliku. Może brakuje papieru.</span>")
				return
			else
				playsound(computer, 'sound/machines/terminal_on.ogg', 50, FALSE)
				computer.visible_message("<span class='notice'>[computer] drukuje kartkę.</span>")
			return TRUE
		if("PRG_eject")
			if(!card_slot2)
				return
			if(target_id_card)
				GLOB.data_core.manifest_modify(target_id_card.registered_name, target_id_card.assignment, target_id_card.hud_state)
				return card_slot2.try_eject(user)
			else
				var/obj/item/I = user.get_active_held_item()
				if(istype(I, /obj/item/card/id))
					return card_slot2.try_insert(I, user)
			return FALSE
		if("PRG_terminate")
			if(!authenticated)
				return
			if(minor)
				if(!(target_id_card.assignment in head_subordinates) && target_id_card.assignment != JOB_NAME_ASSISTANT)
					return

			target_id_card.access -= get_all_centcom_access() + get_all_accesses()
			target_id_card.assignment = "Unassigned"
			target_id_card.update_label()
			log_id("[key_name(usr)] unassigned and stripped all access from [target_id_card] using [user_id_card] via a portable ID console at [AREACOORD(usr)].")
			playsound(computer, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)
			return TRUE
		if("PRG_edit")
			if(!authenticated || !target_id_card)
				return

			// Sanitize the name first. We're not using the full sanitize_name proc as ID cards can have a wider variety of things on them that
			// would not pass as a formal character name, but would still be valid on an ID card created by a player.
			var/new_name = sanitize(params["name"])
			// However, we are going to reject bad names overall including names with invalid characters in them, while allowing numbers.
			new_name = reject_bad_name(new_name, allow_numbers = TRUE)

			if(!new_name)
				to_chat(usr, "<span class='notice'>Błąd oprogramowania: karta ID odrzuciła nowe imię, bo zawiera zakazane znaki.</span>")
				return
			log_id("[key_name(usr)] changed [target_id_card] name to '[new_name]', using [user_id_card] via a portable ID console at [AREACOORD(usr)].")
			target_id_card.registered_name = new_name
			target_id_card.update_label()
			playsound(computer, "terminal_type", 50, FALSE)
			return TRUE
		if("PRG_assign")
			if(!authenticated || !target_id_card)
				return
			var/target = params["assign_target"]
			if(!target)
				return

			if(target == "Custom")
				// Sanitize the custom assignment name first.
				var/custom_name = sanitize(params["custom_name"])
				// However, we are going to assignments containing bad text overall.
				custom_name = reject_bad_text(custom_name)
				if(!custom_name)
					to_chat(usr, "<span class='notice'>Błąd oprogramowania: karta ID odrzuciła nowe stanowisko, bo zawiera zakazane znaki.</span>")
				else
					log_id("[key_name(usr)] assigned a custom assignment '[custom_name]' to [target_id_card] using [user_id_card] via a portable ID console at [AREACOORD(usr)].")
					target_id_card.assignment = custom_name
					target_id_card.update_label()
			else
				if(minor && !(target in head_subordinates))
					return
				var/list/new_access = list()
				if(is_centcom && (target in get_all_centcom_jobs())) // AQ EDIT - Centrala przypisuje też stanowiska stacji (port BeeStation/BeeStation-Hornet#14139)
					new_access = get_centcom_access(target)
				else
					var/datum/job/job
					for(var/jobtype in subtypesof(/datum/job))
						var/datum/job/J = new jobtype
						if(J.title == target)
							job = J
							break
					if(!job)
						to_chat(user, "<span class='warning'>Nie istnieje klasa dla tego stanowiska: [target].</span>")
						return
					new_access = job.get_access()
				log_id("[key_name(usr)] changed [target_id_card] assignment to '[target]', overriding all previous access using [user_id_card] via a portable ID console at [AREACOORD(usr)].")
				target_id_card.access -= get_all_centcom_access() + get_all_accesses()
				target_id_card.access |= new_access
				target_id_card.assignment = target
				target_id_card.update_label()

			playsound(computer, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			return TRUE
		if("PRG_access")
			if(!authenticated || !target_id_card) // AQ EDIT - bez karty do zmiany był runtime
				return
			// AQ EDIT START - biała lista: tylko dostępy działów, którymi zarządza zalogowana karta (port BeeStation/BeeStation-Hornet#14139)
			var/access_type = SSdepartment.find_access_in_departments(params["access_target"], get_manageable_department_bitflag())
			if(isnull(access_type))
				log_id("[key_name(usr)] tried to change access [params["access_target"]] of [target_id_card], which [user_id_card] does not manage, via a portable ID console at [AREACOORD(usr)].")
				return
			// AQ EDIT END
			if(access_type in target_id_card.access)
				target_id_card.access -= access_type
				log_id("[key_name(usr)] removed [get_department_access_desc(access_type)] from [target_id_card] using [user_id_card] via a portable ID console at [AREACOORD(usr)].")
			else
				target_id_card.access |= access_type
				log_id("[key_name(usr)] added [get_department_access_desc(access_type)] to [target_id_card] using [user_id_card] via a portable ID console at [AREACOORD(usr)].")
			playsound(computer, "terminal_type", 50, FALSE)
			return TRUE
		if("PRG_grantall")
			if(!authenticated || minor || !target_id_card) // AQ EDIT - bez karty do zmiany był runtime
				return
			target_id_card.access |= (is_centcom ? get_all_centcom_access() + get_all_accesses() : get_all_accesses()) // AQ EDIT - Centrala nadaje też dostępy stacji (port BeeStation/BeeStation-Hornet#14139)
			log_id("[key_name(usr)] granted All Access to [target_id_card] using [user_id_card] via a portable ID console at [AREACOORD(usr)].")
			playsound(computer, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			return TRUE
		if("PRG_denyall")
			if(!authenticated || minor || !target_id_card) // AQ EDIT - bez karty do zmiany był runtime
				return
			target_id_card.access -= (is_centcom ? get_all_centcom_access() + get_all_accesses() : get_all_accesses()) // AQ EDIT - zdejmuje tylko dostępy, którymi program zarządza, nie wszystkie (port BeeStation/BeeStation-Hornet#14139)
			log_id("[key_name(usr)] removed All Access from [target_id_card] using [user_id_card] via a portable ID console at [AREACOORD(usr)].")
			playsound(computer, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)
			return TRUE
		if("PRG_grantregion")
			if(!authenticated || !target_id_card) // AQ EDIT - bez karty do zmiany był runtime
				return
			var/region = text2num(params["region"])
			if(isnull(region))
				return
			// AQ EDIT START - kliknięty region (Bee bierze pierwszy dostępny dział), tylko działy zalogowanej karty, zły href nic nie robi (port BeeStation/BeeStation-Hornet#14139)
			var/list/granted_departments = SSdepartment.get_department_by_bitflag(region & get_manageable_department_bitflag())
			if(!length(granted_departments))
				return
			for(var/datum/department_group/each_dept as anything in granted_departments)
				target_id_card.access |= each_dept.access_list
				log_id("[key_name(usr)] granted [each_dept.access_group_name] regional access to [target_id_card] using [user_id_card] via a portable ID console at [AREACOORD(usr)].")
			// AQ EDIT END
			playsound(computer, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			return TRUE
		if("PRG_denyregion")
			if(!authenticated || !target_id_card) // AQ EDIT - bez karty do zmiany był runtime
				return
			var/region = text2num(params["region"])
			if(isnull(region))
				return
			// AQ EDIT START - kliknięty region (Bee bierze pierwszy dostępny dział), tylko działy zalogowanej karty, zły href nic nie robi (port BeeStation/BeeStation-Hornet#14139)
			var/list/denied_departments = SSdepartment.get_department_by_bitflag(region & get_manageable_department_bitflag())
			if(!length(denied_departments))
				return
			for(var/datum/department_group/each_dept as anything in denied_departments)
				target_id_card.access -= each_dept.access_list
				log_id("[key_name(usr)] removed [each_dept.access_group_name] regional access from [target_id_card] using [user_id_card] via a portable ID console at [AREACOORD(usr)].")
			// AQ EDIT END
			playsound(computer, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)
			return TRUE



/datum/computer_file/program/card_mod/ui_static_data(mob/user)
	var/list/data = list()
	data["station_name"] = station_name()
	data["centcom_access"] = is_centcom
	data["minor"] = department_bitflag || minor ? TRUE : FALSE // AQ EDIT - bitflaga działów

	// AQ EDIT START - stanowiska i dostępy z grup działów SSdepartment, zakładki z polskimi nazwami działów (port BeeStation/BeeStation-Hornet#14139)
	data["jobs"] = list()
	for(var/datum/department_group/each_dept as anything in SSdepartment.sorted_department_for_access)
		if(!length(each_dept.jobs) || (each_dept.access_filter && !is_centcom))
			continue
		var/list/department_jobs = list()
		for(var/job in each_dept.jobs)
			if(minor && !(job in head_subordinates))
				continue
			department_jobs += list(list(
				"display_name" = job,
				"job" = job
			))
		if(length(department_jobs))
			data["jobs"][each_dept.dept_name] = department_jobs

	var/manageable_bitflag = get_manageable_department_bitflag()
	var/list/regions = list()
	for(var/datum/department_group/each_dept as anything in SSdepartment.sorted_department_for_access)
		if(!(each_dept.dept_bitflag & manageable_bitflag) || !length(each_dept.access_list))
			continue
		if(each_dept.access_filter && !is_centcom)
			continue

		var/list/accesses = list()
		for(var/access in each_dept.access_list)
			var/access_desc = get_department_access_desc(access)
			if(access_desc)
				accesses += list(list(
					"desc" = replacetext(access_desc, "&nbsp", " "),
					"ref" = access,
				))

		regions += list(list(
			"name" = each_dept.access_group_name,
			"regid" = each_dept.dept_bitflag,
			"accesses" = accesses
		))
	// AQ EDIT END

	data["regions"] = regions

	return data

/datum/computer_file/program/card_mod/ui_data(mob/user)
	var/list/data = list()

	data["station_name"] = station_name()

	var/obj/item/computer_hardware/card_slot/card_slot2
	var/obj/item/computer_hardware/printer/printer

	if(computer)
		card_slot2 = computer.all_components[MC_CARD2]
		printer = computer.all_components[MC_PRINT]
		data["have_id_slot"] = !!(card_slot2)
		data["have_printer"] = !!(printer)
	else
		data["have_id_slot"] = FALSE
		data["have_printer"] = FALSE

	data["authenticated"] = authenticated
	if(!card_slot2)
		return data //We're just gonna error out on the js side at this point anyway

	var/obj/item/card/id/id_card = card_slot2.stored_card
	data["has_id"] = !!id_card
	data["id_name"] = id_card ? id_card.name : "-----"
	if(id_card)
		data["id_rank"] = id_card.assignment ? id_card.assignment : "Unassigned"
		data["id_owner"] = id_card.registered_name ? id_card.registered_name : "-----"
		data["access_on_card"] = id_card.access

	return data
