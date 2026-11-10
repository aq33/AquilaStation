// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

// Port BeeStation/BeeStation-Hornet#14139: dostępy w grupach działów SSdepartment, konsola HoP, NtOS, piloty i elektronika śluz.

/// AQUILA - grupy działów pokrywają wszystkie dawne dostępy stacji, kapitan i piloty dostają to co dawniej
/datum/unit_test/aquila_department_access_groups

/datum/unit_test/aquila_department_access_groups/Run()
	// get_all_accesses() nie jest już statyczne: działy muszą istnieć przed SSjob (dostępy stanowisk)
	TEST_ASSERT(SSdepartment.init_order > SSjob.init_order, "SSdepartment initializes after SSjob")
	TEST_ASSERT(length(SSdepartment.sorted_department_for_access), "SSdepartment has no access groups")

	// Kopia dawnej statycznej get_all_accesses() (aq33/master przed portem)
	var/list/old_station_accesses = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_SEC_RECORDS, ACCESS_BRIG, ACCESS_BRIGPHYS, ACCESS_ARMORY, ACCESS_FORENSICS_LOCKERS, ACCESS_COURT,
		ACCESS_MEDICAL, ACCESS_GENETICS, ACCESS_MORGUE, ACCESS_RD,
		ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_CHEMISTRY, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_MAINT_TUNNELS,
		ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CHANGE_IDS, ACCESS_AI_UPLOAD,
		ACCESS_TELEPORTER, ACCESS_EVA, ACCESS_HEADS, ACCESS_CAPTAIN, ACCESS_ALL_PERSONAL_LOCKERS,
		ACCESS_TECH_STORAGE, ACCESS_CHAPEL_OFFICE, ACCESS_ATMOSPHERICS, ACCESS_KITCHEN,
		ACCESS_BAR, ACCESS_JANITOR, ACCESS_CREMATORIUM, ACCESS_ROBOTICS, ACCESS_CARGO, ACCESS_CONSTRUCTION, ACCESS_AUX_BASE,
		ACCESS_HYDROPONICS, ACCESS_LIBRARY, ACCESS_LAWYER, ACCESS_VIROLOGY, ACCESS_CMO, ACCESS_QM, ACCESS_EXPLORATION, ACCESS_SURGERY,
		ACCESS_THEATRE, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_MAILSORTING, ACCESS_WEAPONS,
		ACCESS_MECH_MINING, ACCESS_MECH_ENGINE, ACCESS_MECH_SCIENCE, ACCESS_MECH_SECURITY, ACCESS_MECH_MEDICAL,
		ACCESS_VAULT, ACCESS_MINING_STATION, ACCESS_XENOBIOLOGY, ACCESS_CE, ACCESS_HOP, ACCESS_HOS, ACCESS_RC_ANNOUNCE,
		ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_GATEWAY, ACCESS_MINERAL_STOREROOM, ACCESS_MINISAT, ACCESS_NETWORK, ACCESS_CLONING, ACCESS_RD_SERVER,
		ACCESS_MUNITIONS, ACCESS_MAA, ACCESS_MUNITIONS_STORAGE, ACCESS_COMBAT_PILOT, ACCESS_TRANSPORT_PILOT, ACCESS_MINING_ENGINEERING, ACCESS_MINING_BRIDGE, ACCESS_HANGAR, ACCESS_BIT_DEN, ACCESS_TCOMMS_ADMIN)

	var/list/station_accesses = get_all_accesses()
	var/datum/job/captain/captain_job = new
	var/list/captain_access = captain_job.get_access()
	for(var/access in old_station_accesses)
		TEST_ASSERT(access in station_accesses, "Station access [access] fell out of get_all_accesses(), so the captain, ERT and AI lose it")
		TEST_ASSERT(access in captain_access, "The captain lost station access [access]")
		TEST_ASSERT(get_access_desc(access), "Station access [access] has no description, so access windows hide it")
		var/in_group = FALSE
		for(var/datum/department_group/each_dept as anything in SSdepartment.get_department_by_bitflag(DEPARTMENT_BITFLAG_STATIONS))
			if(access in each_dept.access_list)
				in_group = TRUE
				break
		TEST_ASSERT(in_group, "Station access [access] is in no department group")
	for(var/access in get_all_centcom_access() + list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_ENGINEERING, ACCESS_HERETIC, ACCESS_BLOODCULT))
		TEST_ASSERT(!(access in station_accesses), "Off-station access [access] is in get_all_accesses()")

	// Dostępy spoza stacji są w grupie „Inne”, inaczej konsola Centrali nie mogłaby ich zmieniać
	var/list/other_accesses = SSdepartment.get_accesses_by_bitflag(DEPARTMENT_BITFLAG_OTHER)
	for(var/access in list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_ENGINEERING, ACCESS_SYNDICATE_REQUISITIONS, ACCESS_SYNDICATE_MARINE_ARMOURY, ACCESS_HERETIC, ACCESS_BLOODCULT, ACCESS_CLOCKCULT, ACCESS_AWAY_GENERAL))
		TEST_ASSERT(access in other_accesses, "Access [access] is not in the Inne group")
		TEST_ASSERT(get_department_access_desc(access), "Access [access] has no Polish description for the CentCom console")

	// Stanowiska w działach to te same co w get_all_jobs() (konsola HoP i NtOS przypisują z działów)
	var/list/department_jobs = list()
	for(var/datum/department_group/each_dept as anything in SSdepartment.get_department_by_bitflag(DEPARTMENT_BITFLAG_STATIONS))
		department_jobs |= each_dept.jobs
	for(var/job in get_all_jobs())
		TEST_ASSERT(job in department_jobs, "Job [job] is in no department, so ID consoles cannot assign it")
	TEST_ASSERT_EQUAL(length(department_jobs), length(get_all_jobs()), "Departments list jobs that get_all_jobs() does not have")
	TEST_ASSERT(JOB_NAME_BRIDGESTAFF in SSdepartment.get_jobs_by_dept_id(DEPT_MUNITIONS), "The bridge staff is not in the munitions department")

	// Piloty do drzwi: kapitan zostaje przy Dowództwie, MAA dostaje Uzbrojenie, uniwersalny całą stację
	var/obj/item/door_remote/captain/captain_remote = allocate(/obj/item/door_remote/captain)
	TEST_ASSERT(ACCESS_CAPTAIN in captain_remote.access_list, "The command door remote cannot open the captain's doors")
	TEST_ASSERT(!(ACCESS_ARMORY in captain_remote.access_list), "The command door remote got access outside Command")
	var/obj/item/door_remote/master_at_arms/maa_remote = allocate(/obj/item/door_remote/master_at_arms)
	TEST_ASSERT(ACCESS_MUNITIONS_STORAGE in maa_remote.access_list, "The munitions door remote has no munitions access")
	TEST_ASSERT(!(ACCESS_HEADS in maa_remote.access_list), "The munitions door remote got Command access")
	var/obj/item/door_remote/omni/omni_remote = allocate(/obj/item/door_remote/omni)
	for(var/access in old_station_accesses)
		TEST_ASSERT(access in omni_remote.access_list, "The omni door remote lost station access [access]")

	// Elektronika śluz: region to bitflaga działu, zły region nic nie robi i nie sypie runtime'em
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/obj/item/electronics/airlock/electronics = allocate(/obj/item/electronics/airlock)
	var/datum/tgui/ui = new(user, electronics, "AirlockElectronics")
	electronics.ui_act("grant_region", list("region" = DEPARTMENT_BITFLAG_MUNITIONS), ui)
	TEST_ASSERT(ACCESS_HANGAR in electronics.accesses, "Granting the munitions region on airlock electronics gave no munitions access")
	TEST_ASSERT(!(ACCESS_CAPTAIN in electronics.accesses), "Granting the munitions region gave Command access")
	electronics.ui_act("grant_region", list("region" = (1<<20)), ui)
	TEST_ASSERT_EQUAL(length(electronics.accesses), length(SSdepartment.get_accesses_by_bitflag(DEPARTMENT_BITFLAG_MUNITIONS)), "An unknown region changed the airlock electronics accesses")
	electronics.ui_act("grant_region", list("region" = DEPARTMENT_BITFLAG_OTHER), ui)
	TEST_ASSERT(!(ACCESS_SYNDICATE in electronics.accesses), "Airlock electronics granted off-station access")
	electronics.ui_act("deny_region", list("region" = DEPARTMENT_BITFLAG_MUNITIONS), ui)
	TEST_ASSERT(!length(electronics.accesses), "Denying the munitions region left munitions accesses on the electronics")
	qdel(ui)

/// AQUILA - konsola kart ID: biała lista dostępów, MAA zarządza Uzbrojeniem, degradacja Majtka, konsola Centrali
/datum/unit_test/aquila_card_console_whitelist

/datum/unit_test/aquila_card_console_whitelist/Run()
	var/mob/living/carbon/human/hop = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/machinery/computer/card/console = allocate(/obj/machinery/computer/card, get_step(run_loc_floor_bottom_left, EAST))
	var/obj/item/card/id/scan_id = allocate(/obj/item/card/id, console)
	var/obj/item/card/id/target_id = allocate(/obj/item/card/id, console)
	console.inserted_scan_id = scan_id
	console.inserted_modify_id = target_id
	var/datum/tgui/ui = new(hop, console, "IdentificationConsole")
	usr = hop

	// HoP bez ACCESS_CHANGE_IDS: tylko Ogólne i Zaopatrzenie
	scan_id.access = list(ACCESS_HEADS, ACCESS_HOP)
	console.ui_act("login", list(), ui)
	var/hop_auth = console.authenticated
	var/hop_regions = console.accessible_region_bitflag
	console.ui_act("access", list("access" = ACCESS_BAR, "allowed" = TRUE), ui)
	console.ui_act("access", list("access" = ACCESS_CARGO, "allowed" = TRUE), ui)
	console.ui_act("access", list("access" = ACCESS_ARMORY, "allowed" = TRUE), ui)
	console.ui_act("access", list("access" = ACCESS_CAPTAIN, "allowed" = TRUE), ui)
	console.ui_act("access", list("access" = ACCESS_CENT_CAPTAIN, "allowed" = TRUE), ui)
	console.ui_act("access", list("access" = ACCESS_HERETIC, "allowed" = TRUE), ui)
	// spreparowany href prosto do Topic()
	console.Topic("choice=access", list("choice" = "access", "access_target" = "[ACCESS_HOS]", "allowed" = "1"))
	var/list/hop_card_access = target_id.access.Copy()
	var/list/hop_region_names = list()
	for(var/list/region as anything in console.card_regions_data())
		hop_region_names += region["name"]
	console.ui_act("logout", list(), ui)

	// HoP z ACCESS_CHANGE_IDS: cała stacja, ale nic spoza niej
	target_id.access = list()
	scan_id.access = list(ACCESS_HEADS, ACCESS_HOP, ACCESS_CHANGE_IDS)
	console.ui_act("login", list(), ui)
	var/full_auth = console.authenticated
	console.ui_act("access", list("access" = ACCESS_ARMORY, "allowed" = TRUE), ui)
	console.ui_act("access", list("access" = ACCESS_CENT_CAPTAIN, "allowed" = TRUE), ui)
	console.ui_act("access", list("access" = ACCESS_SYNDICATE, "allowed" = TRUE), ui)
	var/list/full_card_access = target_id.access.Copy()
	console.ui_act("logout", list(), ui)

	// MAA: Uzbrojenie (dawniej DEPT_MUN = 7 dawał region Dowództwa)
	target_id.access = list()
	scan_id.access = list(ACCESS_HEADS, ACCESS_MAA)
	console.ui_act("login", list(), ui)
	var/maa_regions = console.accessible_region_bitflag
	console.ui_act("access", list("access" = ACCESS_MUNITIONS_STORAGE, "allowed" = TRUE), ui)
	console.ui_act("access", list("access" = ACCESS_CAPTAIN, "allowed" = TRUE), ui)
	console.ui_act("access", list("access" = ACCESS_CHANGE_IDS, "allowed" = TRUE), ui)
	var/list/maa_card_access = target_id.access.Copy()
	console.ui_act("logout", list(), ui)

	// Degradacja: szef degraduje podwładnych i Majtków, cudzych nie; bez logowania nikogo
	target_id.assignment = JOB_NAME_ASSISTANT
	console.ui_act("demote", list(), ui)
	var/demoted_logged_out = target_id.assignment
	scan_id.access = list(ACCESS_HEADS, ACCESS_CMO)
	console.ui_act("login", list(), ui)
	console.ui_act("demote", list(), ui)
	var/demoted_assistant = target_id.assignment
	target_id.assignment = JOB_NAME_MEDICALDOCTOR
	console.ui_act("demote", list(), ui)
	var/demoted_doctor = target_id.assignment
	target_id.assignment = JOB_NAME_SECURITYOFFICER
	console.ui_act("demote", list(), ui)
	var/demoted_officer = target_id.assignment
	console.ui_act("logout", list(), ui)

	usr = null
	console.inserted_scan_id = null
	console.inserted_modify_id = null
	qdel(ui)

	TEST_ASSERT_EQUAL(hop_auth, 1, "A HoP card without ACCESS_CHANGE_IDS did not log in as a department head")
	TEST_ASSERT_EQUAL(hop_regions, DEPARTMENT_BITFLAG_SERVICE | DEPARTMENT_BITFLAG_CARGO, "The HoP does not manage exactly the Ogólne and Zaopatrzenie groups")
	TEST_ASSERT(ACCESS_BAR in hop_card_access, "The HoP could not grant a general access")
	TEST_ASSERT(ACCESS_CARGO in hop_card_access, "The HoP could not grant a supply access")
	TEST_ASSERT(!(ACCESS_ARMORY in hop_card_access), "The HoP granted a security access through the window")
	TEST_ASSERT(!(ACCESS_CAPTAIN in hop_card_access), "The HoP granted a command access through the window")
	TEST_ASSERT(!(ACCESS_CENT_CAPTAIN in hop_card_access), "The HoP granted a CentCom access through the window")
	TEST_ASSERT(!(ACCESS_HERETIC in hop_card_access), "The HoP granted an off-station access through the window")
	TEST_ASSERT(!(ACCESS_HOS in hop_card_access), "The HoP granted a security access with a crafted href")
	TEST_ASSERT(("Ogólne" in hop_region_names) && ("Zaopatrzenie" in hop_region_names) && length(hop_region_names) == 2, "The HoP sees access groups other than Ogólne and Zaopatrzenie: [jointext(hop_region_names, ", ")]")

	TEST_ASSERT_EQUAL(full_auth, 2, "A card with ACCESS_CHANGE_IDS did not log in fully")
	TEST_ASSERT(ACCESS_ARMORY in full_card_access, "A full login could not grant a station access")
	TEST_ASSERT(!(ACCESS_CENT_CAPTAIN in full_card_access), "The station console granted a CentCom access")
	TEST_ASSERT(!(ACCESS_SYNDICATE in full_card_access), "The station console granted a Syndicate access")

	TEST_ASSERT_EQUAL(maa_regions, DEPARTMENT_BITFLAG_MUNITIONS, "The master at arms does not manage exactly the Uzbrojenie group")
	TEST_ASSERT(ACCESS_MUNITIONS_STORAGE in maa_card_access, "The master at arms could not grant a munitions access")
	TEST_ASSERT(!(ACCESS_CAPTAIN in maa_card_access), "The master at arms granted a command access")
	TEST_ASSERT(!(ACCESS_CHANGE_IDS in maa_card_access), "The master at arms granted ACCESS_CHANGE_IDS")

	TEST_ASSERT_EQUAL(demoted_logged_out, JOB_NAME_ASSISTANT, "The console demoted a card without anyone logged in")
	TEST_ASSERT_EQUAL(demoted_assistant, "Unassigned", "A department head could not demote a Majtek")
	TEST_ASSERT_EQUAL(demoted_doctor, "Unassigned", "The CMO could not demote a doctor")
	TEST_ASSERT_EQUAL(demoted_officer, JOB_NAME_SECURITYOFFICER, "The CMO demoted an officer from another department")

	// Konsola Centrali: dostępy stacji, Centrali i grupy „Inne” (także tekstowe ACCESS_HERETIC)
	var/obj/machinery/computer/card/centcom/cc_console = allocate(/obj/machinery/computer/card/centcom, get_step(run_loc_floor_bottom_left, NORTH))
	var/obj/item/card/id/cc_scan = allocate(/obj/item/card/id, cc_console)
	var/obj/item/card/id/cc_target = allocate(/obj/item/card/id, cc_console)
	// req_one_access z konsoli stacji (HEADS albo CHANGE_IDS) zostaje, a ACCESS_CHANGE_IDS nie jest potrzebny do pełnego logowania
	cc_scan.access = get_all_centcom_access() + ACCESS_HEADS
	cc_console.inserted_scan_id = cc_scan
	cc_console.inserted_modify_id = cc_target
	var/datum/tgui/cc_ui = new(hop, cc_console, "IdentificationConsole")
	usr = hop
	cc_console.ui_act("login", list(), cc_ui)
	var/cc_auth = cc_console.authenticated
	cc_console.ui_act("access", list("access" = ACCESS_HERETIC, "allowed" = TRUE), cc_ui)
	cc_console.ui_act("access", list("access" = ACCESS_SYNDICATE_ENGINEERING, "allowed" = TRUE), cc_ui)
	cc_console.ui_act("access", list("access" = ACCESS_CENT_SPECOPS, "allowed" = TRUE), cc_ui)
	cc_console.ui_act("access", list("access" = ACCESS_ARMORY, "allowed" = TRUE), cc_ui)
	var/list/cc_card_access = cc_target.access.Copy()
	usr = null
	cc_console.inserted_scan_id = null
	cc_console.inserted_modify_id = null
	qdel(cc_ui)
	TEST_ASSERT_EQUAL(cc_auth, 2, "A CentCom card did not log in to the CentCom console")
	TEST_ASSERT(ACCESS_HERETIC in cc_card_access, "The CentCom console could not grant the heretic access")
	TEST_ASSERT(ACCESS_SYNDICATE_ENGINEERING in cc_card_access, "The CentCom console could not grant a Syndicate access")
	TEST_ASSERT(ACCESS_CENT_SPECOPS in cc_card_access, "The CentCom console could not grant a CentCom access")
	TEST_ASSERT(ACCESS_ARMORY in cc_card_access, "The CentCom console could not grant a station access")

/// AQUILA - program NtOS kart ID: biała lista dostępów i regionów (Bee nadawał pierwszy dostępny dział zamiast klikniętego)
/datum/unit_test/aquila_ntos_card_whitelist

/datum/unit_test/aquila_ntos_card_whitelist/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/obj/item/modular_computer/tablet/preset/advanced/command/tablet = allocate(/obj/item/modular_computer/tablet/preset/advanced/command)
	var/obj/item/computer_hardware/card_slot/card_slot = tablet.all_components[MC_CARD]
	var/obj/item/computer_hardware/card_slot/card_slot2 = tablet.all_components[MC_CARD2]
	TEST_ASSERT(card_slot && card_slot2, "The command tablet has no two card slots")
	var/obj/item/card/id/scan_id = allocate(/obj/item/card/id)
	var/obj/item/card/id/target_id = allocate(/obj/item/card/id)
	card_slot.stored_card = scan_id
	card_slot2.stored_card = target_id
	var/datum/computer_file/program/card_mod/program = new(tablet)
	var/datum/tgui/ui = new(user, program, "NtosCard")
	usr = user

	scan_id.access = list(ACCESS_HEADS, ACCESS_HOP)
	program.ui_act("PRG_authenticate", list(), ui)
	var/hop_minor = program.minor
	var/hop_regions = program.accessible_region_bitflag
	program.ui_act("PRG_access", list("access_target" = ACCESS_BAR), ui)
	program.ui_act("PRG_access", list("access_target" = ACCESS_ARMORY), ui)
	program.ui_act("PRG_grantregion", list("region" = DEPARTMENT_BITFLAG_COMMAND), ui)
	program.ui_act("PRG_grantregion", list("region" = 1<<20), ui)
	program.ui_act("PRG_grantregion", list("region" = DEPARTMENT_BITFLAG_CARGO), ui)
	program.ui_act("PRG_grantall", list(), ui)
	program.ui_act("PRG_assign", list("assign_target" = JOB_NAME_CAPTAIN), ui)
	var/list/hop_card_access = target_id.access.Copy()
	var/list/hop_job_tabs = program.ui_static_data(user)["jobs"]
	program.ui_act("PRG_logout", list(), ui)

	target_id.access = list(ACCESS_SYNDICATE)
	scan_id.access = list(ACCESS_HEADS, ACCESS_MAA)
	program.ui_act("PRG_authenticate", list(), ui)
	var/maa_regions = program.accessible_region_bitflag
	program.ui_act("PRG_grantregion", list("region" = DEPARTMENT_BITFLAG_MUNITIONS), ui)
	program.ui_act("PRG_denyregion", list("region" = DEPARTMENT_BITFLAG_OTHER), ui)
	var/list/maa_card_access = target_id.access.Copy()
	program.ui_act("PRG_logout", list(), ui)

	usr = null
	card_slot.stored_card = null
	card_slot2.stored_card = null
	qdel(ui)
	qdel(program)

	TEST_ASSERT(hop_minor, "A HoP card without ACCESS_CHANGE_IDS logged in fully")
	TEST_ASSERT_EQUAL(hop_regions, DEPARTMENT_BITFLAG_SERVICE | DEPARTMENT_BITFLAG_CARGO, "The HoP does not manage exactly the Ogólne and Zaopatrzenie groups in NtOS")
	TEST_ASSERT(ACCESS_BAR in hop_card_access, "The HoP could not grant a general access in NtOS")
	TEST_ASSERT(!(ACCESS_ARMORY in hop_card_access), "The HoP granted a security access in NtOS")
	TEST_ASSERT(!(ACCESS_CAPTAIN in hop_card_access), "Granting the command region worked for the HoP in NtOS")
	TEST_ASSERT(ACCESS_QM in hop_card_access, "Granting the supply region did not give the supply accesses (clicked region ignored)")
	TEST_ASSERT(!(ACCESS_HOS in hop_card_access), "Grant all worked for a department head in NtOS")
	TEST_ASSERT(target_id.assignment != JOB_NAME_CAPTAIN, "The HoP assigned the captain job in NtOS")
	TEST_ASSERT(hop_job_tabs["Służba"], "NtOS job tabs do not use the Polish department names")
	TEST_ASSERT(!hop_job_tabs["Ochrona"], "NtOS shows the HoP jobs of another department")

	TEST_ASSERT_EQUAL(maa_regions, DEPARTMENT_BITFLAG_MUNITIONS, "The master at arms does not manage exactly the Uzbrojenie group in NtOS")
	TEST_ASSERT(ACCESS_HANGAR in maa_card_access, "The master at arms could not grant the munitions region in NtOS")
	TEST_ASSERT(ACCESS_SYNDICATE in maa_card_access, "The master at arms removed an off-station access in NtOS")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
