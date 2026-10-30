
///returns TRUE if this mob has sufficient access to use this object.
///Note that this will return FALSE when passed null, unless the door doesn't require any access.
/obj/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(src.check_access(null))
		return TRUE
	if(issilicon(M))
		var/mob/living/silicon/S = M
		return check_access(S.internal_id_card)	//AI can do whatever it wants
	if(IsAdminGhost(M))
		//Access can't stop the abuse
		return TRUE
	else if(istype(M) && SEND_SIGNAL(M, COMSIG_MOB_ALLOWED, src))
		return TRUE
	else if(ishuman(M))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(check_access(H.get_active_held_item()) || src.check_access(H.wear_id) || src.check_access(H.squad))//Nsv13: added "h.wear_neck" here to allow for lanyard access checks.
			return TRUE
	else if(ismonkey(M) || isalienadult(M))
		var/mob/living/carbon/george = M
		//they can only hold things :(
		if(check_access(george.get_active_held_item()))
			return TRUE
	else if(isanimal(M))
		var/mob/living/simple_animal/A = M
		if(check_access(A.get_active_held_item()) || check_access(A.access_card))
			return TRUE
	return FALSE

/obj/item/proc/GetAccess()
	return list()

/obj/item/proc/GetID()
	return null

/obj/item/proc/RemoveID()
	return null

/obj/item/proc/InsertID()
	return FALSE

/obj/proc/text2access(access_text)
	. = list()
	if(!access_text)
		return
	var/list/split = splittext(access_text,";")
	for(var/x in split)
		var/n = text2num(x)
		if(n)
			. += n

//Call this before using req_access or req_one_access directly
/obj/proc/gen_access()
	//These generations have been moved out of /obj/New() because they were slowing down the creation of objects that never even used the access system.
	if(!req_access)
		req_access = list()
		for(var/a in text2access(req_access_txt))
			req_access += a
	if(!req_one_access)
		req_one_access = list()
		for(var/b in text2access(req_one_access_txt))
			req_one_access += b

// Check if an item has access to this object
/obj/proc/check_access(obj/item/I)
	return check_access_list(I ? I.GetAccess() : null)

/obj/proc/check_access_list(list/access_list)
	gen_access()

	if(!islist(req_access)) //something's very wrong
		return TRUE

	if(!req_access.len && !length(req_one_access))
		return TRUE

	if(!length(access_list) || !islist(access_list))
		return FALSE

	for(var/req in req_access)
		if(!(req in access_list)) //doesn't have this access
			return FALSE

	if(length(req_one_access))
		for(var/req in req_one_access)
			if(req in access_list) //has an access from the single access list
				return TRUE
		return FALSE
	return TRUE

/*
 * Checks if this packet can access this device
 *
 * Normally just checks the access list however you can override it for
 * hacking proposes or if wires are cut
 *
 * Arguments:
 * * passkey - passkey from the datum/netdata packet
 */
/obj/proc/check_access_ntnet(list/passkey)
	return check_access_list(passkey)

/proc/get_centcom_access(job)
	switch(job)
		if(JOB_CENTCOM_VIP)
			return list(ACCESS_CENT_GENERAL)
		if(JOB_CENTCOM_CUSTODIAN)
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
		if(JOB_CENTCOM_THUNDERDOME_OVERSEER)
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_THUNDER)
		if(JOB_CENTCOM_OFFICIAL)
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING)
		if("CentCom Intern")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING)
		if("CentCom Head Intern")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING)
		if(JOB_CENTCOM_MEDICAL_DOCTOR)
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL)
		if(JOB_ERT_DEATHSQUAD)
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
		if(JOB_CENTCOM_RESEARCH_OFFICER)
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_TELEPORTER, ACCESS_CENT_STORAGE)
		if("Special Ops Officer")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_THUNDER, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
		if(JOB_CENTCOM_ADMIRAL)
			return get_all_centcom_access()
		if(JOB_CENTCOM_COMMANDER)
			return get_all_centcom_access()
		if(JOB_ERT_COMMANDER)
			return get_ert_access("commander")
		if(JOB_ERT_OFFICER )
			return get_ert_access("sec")
		if(JOB_ERT_ENGINEER)
			return get_ert_access("eng")
		if(JOB_ERT_MEDICAL_DOCTOR)
			return get_ert_access("med")
		if(JOB_CENTCOM_BARTENDER)
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_BAR)
		if("Comedy Response Officer")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING)
		if("HONK Squad Trooper")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)

//NSV13 - Added ACCESS_MUNITIONS, ACCESS_MAA, ACCESS_MUNITIONS_STORAGE, ACCESS_COMBAT_PILOT, ACCESS_TRANSPORT_PILOT, ACCESS_MINING_ENGINEERING, ACCESS_MINING_BRIDGE, ACCESS_HANGAR
/proc/get_all_accesses()
	return list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_SEC_RECORDS, ACCESS_BRIG, ACCESS_BRIGPHYS, ACCESS_ARMORY, ACCESS_FORENSICS_LOCKERS, ACCESS_COURT,
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
				ACCESS_MUNITIONS, ACCESS_MAA, ACCESS_MUNITIONS_STORAGE, ACCESS_COMBAT_PILOT, ACCESS_TRANSPORT_PILOT, ACCESS_MINING_ENGINEERING, ACCESS_MINING_BRIDGE, ACCESS_HANGAR, ACCESS_BIT_DEN, ACCESS_TCOMMS_ADMIN) // AQ EDIT - ACCESS_BIT_DEN, ACCESS_TCOMMS_ADMIN

/proc/get_all_centcom_access()
	return list(ACCESS_CENT_GENERAL, ACCESS_CENT_THUNDER, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE, ACCESS_CENT_TELEPORTER, ACCESS_CENT_CAPTAIN, ACCESS_CENT_BAR)

/proc/get_ert_access(class)
	switch(class)
		if("commander")
			return get_all_centcom_access()
		if("sec")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING)
		if("eng")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
		if("med")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_LIVING)

/proc/get_all_syndicate_access()
	return list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER)

/proc/get_all_away_access()
	return list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINT, ACCESS_AWAY_MED, ACCESS_AWAY_SEC, ACCESS_AWAY_ENGINE, ACCESS_AWAY_GENERIC1, ACCESS_AWAY_GENERIC2, ACCESS_AWAY_GENERIC3, ACCESS_AWAY_GENERIC4)

/proc/get_every_access()
	return get_all_accesses() + get_all_centcom_access() + get_all_syndicate_access() + get_all_away_access() + ACCESS_BLOODCULT + ACCESS_CLOCKCULT

/proc/get_region_accesses(code)
	switch(code)
		if(0)
			return get_all_accesses()
		if(1) //station general
			return list(ACCESS_KITCHEN,ACCESS_BAR, ACCESS_HYDROPONICS, ACCESS_JANITOR, ACCESS_CHAPEL_OFFICE, ACCESS_CREMATORIUM, ACCESS_LIBRARY, ACCESS_THEATRE, ACCESS_LAWYER)
		if(2) //security
			return list(ACCESS_SEC_DOORS, ACCESS_SEC_RECORDS, ACCESS_WEAPONS, ACCESS_SECURITY, ACCESS_BRIG, ACCESS_BRIGPHYS, ACCESS_ARMORY, ACCESS_FORENSICS_LOCKERS, ACCESS_COURT, ACCESS_MECH_SECURITY, ACCESS_HOS)
		if(3) //medbay
			return list(ACCESS_MEDICAL, ACCESS_GENETICS, ACCESS_CLONING, ACCESS_MORGUE, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_SURGERY, ACCESS_MECH_MEDICAL, ACCESS_CMO)
		if(4) //research
			return list(ACCESS_RESEARCH, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_GENETICS, ACCESS_ROBOTICS, ACCESS_XENOBIOLOGY, ACCESS_EXPLORATION, ACCESS_MECH_SCIENCE, ACCESS_MINISAT, ACCESS_RD, ACCESS_NETWORK, ACCESS_RD_SERVER)
		if(5) //engineering and maintenance
			return list(ACCESS_CONSTRUCTION, ACCESS_AUX_BASE, ACCESS_MAINT_TUNNELS, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_TECH_STORAGE, ACCESS_ATMOSPHERICS, ACCESS_MECH_ENGINE, ACCESS_TCOMSAT, ACCESS_TCOMMS_ADMIN, ACCESS_MINISAT, ACCESS_CE) // AQ EDIT - ACCESS_TCOMMS_ADMIN
		if(6) //supply
			return list(ACCESS_MAILSORTING, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MECH_MINING, ACCESS_MINERAL_STOREROOM, ACCESS_CARGO, ACCESS_QM, ACCESS_VAULT, ACCESS_BIT_DEN) // AQ EDIT - ACCESS_BIT_DEN
		if(7) //command
			return list(ACCESS_HEADS, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_CHANGE_IDS, ACCESS_AI_UPLOAD, ACCESS_TELEPORTER, ACCESS_EVA, ACCESS_GATEWAY, ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_HOP, ACCESS_CAPTAIN, ACCESS_VAULT)
		if(8) //munitions - NSV13
			return list(ACCESS_MUNITIONS, ACCESS_MUNITIONS_STORAGE, ACCESS_COMBAT_PILOT, ACCESS_TRANSPORT_PILOT, ACCESS_MAA, ACCESS_HANGAR)

/proc/get_region_accesses_name(code)
	switch(code)
		if(0)
			return "Wszystko"
		if(1) //station general
			return "Ogólne"
		if(2) //security
			return "Ochrona"
		if(3) //medbay
			return "Ambulatorium"
		if(4) //research
			return "Nauka"
		if(5) //engineering and maintenance
			return "Inżynieria"
		if(6) //supply
			return "Zaopatrzenie"
		if(7) //command
			return "Dowództwo"
		if(8) //munitions - NSV13
			return "Amunicja"

/proc/get_access_desc(A)
	switch(A)
		if(ACCESS_CARGO)
			return "Ładownia"
		if(ACCESS_SECURITY)
			return "Ochrona"
		if(ACCESS_BRIG)
			return "Cele Tymczasowe"
		if(ACCESS_COURT)
			return "Sala Sądowa"
		if(ACCESS_FORENSICS_LOCKERS)
			return "Kryminalistyka"
		if(ACCESS_MEDICAL)
			return "Medyczny"
		if(ACCESS_GENETICS)
			return "Laboratorium Genetyczne"
		if(ACCESS_MORGUE)
			return "Kostnica"
		if(ACCESS_TOX)
			return "Laboratorium B+R"
		if(ACCESS_TOX_STORAGE)
			return "Laboratorium Mieszania Toksyn"
		if(ACCESS_CHEMISTRY)
			return "Pracownia Chemiczna"
		if(ACCESS_BRIGPHYS)
			return "Lekarz Więzienny"
		if(ACCESS_RD)
			return "Biuro Dyrektora Naukowego"
		if(ACCESS_BAR)
			return "Bar"
		if(ACCESS_JANITOR)
			return "Schowek Woźnego"
		if(ACCESS_ENGINE)
			return "Inżynieria"
		if(ACCESS_ENGINE_EQUIP)
			return "Zasilanie i Sprzęt Inżynieryjny"
		if(ACCESS_MAINT_TUNNELS)
			return "Tunele Techniczne"
		if(ACCESS_EXTERNAL_AIRLOCKS)
			return "Śluzy Zewnętrzne"
		if(ACCESS_CHANGE_IDS)
			return "Konsola Identyfikatorów"
		if(ACCESS_AI_UPLOAD)
			return "Komory SI"
		if(ACCESS_TELEPORTER)
			return "Teleporter"
		if(ACCESS_EVA)
			return "EVA"
		if(ACCESS_HEADS)
			return "Mostek"
		if(ACCESS_CAPTAIN)
			return "Kapitan"
		if(ACCESS_ALL_PERSONAL_LOCKERS)
			return "Szafki Osobiste"
		if(ACCESS_CHAPEL_OFFICE)
			return "Biuro Kaplicy"
		if(ACCESS_TECH_STORAGE)
			return "Magazyn Techniczny"
		if(ACCESS_ATMOSPHERICS)
			return "Atmosferyka"
		if(ACCESS_CREMATORIUM)
			return "Krematorium"
		if(ACCESS_ARMORY)
			return "Zbrojownia"
		if(ACCESS_CONSTRUCTION)
			return "Budowa"
		if(ACCESS_KITCHEN)
			return "Kuchnia"
		if(ACCESS_HYDROPONICS)
			return "Hydroponika"
		if(ACCESS_LIBRARY)
			return "Biblioteka"
		if(ACCESS_LAWYER)
			return "Biuro Prawne"
		if(ACCESS_ROBOTICS)
			return "Robotyka"
		if(ACCESS_VIROLOGY)
			return "Wirusologia"
		if(ACCESS_CMO)
			return "Biuro Ordynatora"
		if(ACCESS_QM)
			return "Kwatermistrz"
		if(ACCESS_EXPLORATION)
			return "Dok Eksploracyjny"
		if(ACCESS_SURGERY)
			return "Chirurgia"
		if(ACCESS_THEATRE)
			return "Teatr"
		if(ACCESS_RESEARCH)
			return "Nauka"
		if(ACCESS_RD_SERVER)
			return "Serwerownia"
		if(ACCESS_MINING)
			return "Górnictwo"
		if(ACCESS_MAILSORTING)
			return "Biuro Zaopatrzenia"
		if(ACCESS_VAULT)
			return "Skarbiec"
		if(ACCESS_MINING_STATION)
			return "EVA Górnicze"
		if(ACCESS_XENOBIOLOGY)
			return "Laboratorium Ksenobiologii"
		if(ACCESS_HOP)
			return "Biuro Starszego Oficera"
		if(ACCESS_HOS)
			return "Gabinet Komendanta"
		if(ACCESS_CE)
			return "Biuro Głównego Inżyniera"
		if(ACCESS_RC_ANNOUNCE)
			return "Ogłoszenia przez konsolę zgłoszeń"
		if(ACCESS_KEYCARD_AUTH)
			return "Autoryzacja kluczem"
		if(ACCESS_TCOMSAT)
			return "Telekomunikacja"
		if(ACCESS_GATEWAY)
			return "Brama"
		if(ACCESS_SEC_DOORS)
			return "Areszt"
		if(ACCESS_SEC_RECORDS)
			return "Akta Ochrony"
		if(ACCESS_MINERAL_STOREROOM)
			return "Magazyn Minerałów"
		if(ACCESS_MINISAT)
			return "Satelita SI"
		if(ACCESS_WEAPONS)
			return "Pozwolenie na Broń"
		if(ACCESS_NETWORK)
			return "Dostęp do Sieci"
		if(ACCESS_CLONING)
			return "Laboratorium Klonowania"
		if(ACCESS_MECH_MINING)
			return "Dostęp do Mechów Górniczych"
		if(ACCESS_MECH_MEDICAL)
			return "Dostęp do Mechów Medycznych"
		if(ACCESS_MECH_SECURITY)
			return "Dostęp do Mechów Ochrony"
		if(ACCESS_MECH_SCIENCE)
			return "Dostęp do Mechów Naukowych"
		if(ACCESS_MECH_ENGINE)
			return "Dostęp do Mechów Inżynieryjnych"
		if(ACCESS_MUNITIONS) //Nsv13 - munitions
			return "Dostęp do Amunicji"
		if(ACCESS_MAA) //NSV13 - Munitions
			return "Biuro Mistrza Uzbrojenia"
		if(ACCESS_MUNITIONS_STORAGE) // NSV13 - Munitions
			return "Magazyn Amunicji"
		if(ACCESS_COMBAT_PILOT) //NSV13 - Munitions
			return "Licencja Pilota Bojowego"
		if(ACCESS_TRANSPORT_PILOT) //NSV13 - Munitions
			return "Licencja Pilota Transportowego"
		if(ACCESS_HANGAR) //NSV13 - Munitions
			return "Dostęp do Hangaru"
		if(ACCESS_AUX_BASE)
			return "Baza Pomocnicza"
		if(ACCESS_BIT_DEN) // AQ EDIT - bitrunning
			return "Nora Bitrunnerów"
		if(ACCESS_TCOMMS_ADMIN) // AQ EDIT - NTSL
			return "Administracja Telekomunikacji"

/proc/get_centcom_access_desc(A)
	switch(A)
		if(ACCESS_CENT_GENERAL)
			return "Kod Szary"
		if(ACCESS_CENT_THUNDER)
			return "Kod Żółty"
		if(ACCESS_CENT_STORAGE)
			return "Kod Pomarańczowy"
		if(ACCESS_CENT_LIVING)
			return "Kod Zielony"
		if(ACCESS_CENT_MEDICAL)
			return "Kod Biały"
		if(ACCESS_CENT_TELEPORTER)
			return "Kod Niebieski"
		if(ACCESS_CENT_SPECOPS)
			return "Kod Czarny"
		if(ACCESS_CENT_CAPTAIN)
			return "Kod Złoty"
		if(ACCESS_CENT_BAR)
			return "Kod Szkocki"

/proc/get_all_jobs()
	return list(JOB_NAME_CAPTAIN,
				// Service
				JOB_NAME_ASSISTANT, JOB_NAME_HEADOFPERSONNEL, JOB_NAME_BARTENDER, JOB_NAME_COOK, JOB_NAME_BOTANIST, JOB_NAME_JANITOR, JOB_NAME_CURATOR,
				JOB_NAME_CHAPLAIN, JOB_NAME_LAWYER, JOB_NAME_CLOWN, JOB_NAME_MIME, JOB_NAME_BARBER, JOB_NAME_STAGEMAGICIAN,
				// Cargo
				JOB_NAME_QUARTERMASTER, JOB_NAME_CARGOTECHNICIAN,JOB_NAME_SHAFTMINER, JOB_NAME_BITRUNNER, // AQ EDIT - bitrunning
				// Engineering
				JOB_NAME_CHIEFENGINEER, JOB_NAME_STATIONENGINEER, JOB_NAME_ATMOSPHERICTECHNICIAN,
				// R&D
				JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_SCIENTIST, JOB_NAME_ROBOTICIST, JOB_NAME_EXPLORATIONCREW,
				// Medical
				JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_MEDICALDOCTOR, JOB_NAME_CHEMIST, JOB_NAME_GENETICIST, JOB_NAME_VIROLOGIST, JOB_NAME_PARAMEDIC, JOB_NAME_PSYCHIATRIST,
				// Security
				JOB_NAME_HEADOFSECURITY, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_SECURITYOFFICER, JOB_NAME_BRIGPHYSICIAN, JOB_NAME_DEPUTY,
				// NSV13 - munitions
				JOB_NAME_MASTERATARMS, JOB_NAME_PILOT, JOB_NAME_MUNITIONSTECHNICIAN, JOB_NAME_AIRTRAFFICCONTROLLER, JOB_NAME_DECKTECHNICIAN, JOB_NAME_BRIDGESTAFF)
				// Each job is supposed to be in their department due to the HoP console.

/proc/get_all_job_icons() //We need their HUD icons, but we don't want to give these jobs to people from the job list of HoP console.
	return get_all_jobs() + list("Prisoner", "King", JOB_NAME_VIP, "Acting Captain")

/proc/get_all_centcom_jobs()
	return list(JOB_CENTCOM_VIP,JOB_CENTCOM_CUSTODIAN, JOB_CENTCOM_THUNDERDOME_OVERSEER,JOB_CENTCOM_OFFICIAL,JOB_CENTCOM_MEDICAL_DOCTOR,JOB_ERT_DEATHSQUAD,JOB_CENTCOM_RESEARCH_OFFICER,"Special Ops Officer",JOB_CENTCOM_ADMIRAL,JOB_CENTCOM_COMMANDER,JOB_ERT_COMMANDER,JOB_ERT_OFFICER ,JOB_ERT_ENGINEER, JOB_ERT_MEDICAL_DOCTOR,JOB_CENTCOM_BARTENDER,"Comedy Response Officer", "HONK Squad Trooper")

/obj/item/proc/GetJobIcon() //Used in secHUD icon generation (the new one)
	var/obj/item/card/id/I = GetID()
	if(!I)
		return
	var/I_hud = I.hud_state
	if(I_hud)
		return I_hud
	return "unknown"
