// Działy i grupy dostępów kart ID: minimalny rdzeń SSdepartment z BeeStation/BeeStation-Hornet#11209
// z grupami dostępów z BeeStation/BeeStation-Hornet#14139. Bez manifestu, preferencji, banku i bez zamiany GLOB.*_positions.
// Podział działów zostaje nasz (Służba/Ogólne, Ochrona, Medyczny, Nauka, Inżynieria, Zaopatrzenie, Dowództwo, Uzbrojenie)
// plus Centrala i Inne (dostępy spoza stacji, widzi i zmienia je tylko konsola Centrali).

#define DEPT_CENTCOM "CentCom"
#define DEPT_OTHER "Other"

SUBSYSTEM_DEF(department)
	name = "Departments"
	init_order = INIT_ORDER_DEPARTMENT
	flags = SS_NO_FIRE

	/// Wszystkie datumy działów
	var/list/department_datums
	/// Datumy działów po dept_id
	var/list/department_assoc
	/// Datumy działów w kolejności okien dostępów (konsole ID, elektronika śluz)
	var/list/sorted_department_for_access

/datum/controller/subsystem/department/Initialize(timeofday)
	setup_departments()
	return ..()

/datum/controller/subsystem/department/Recover()
	department_datums = SSdepartment.department_datums
	department_assoc = SSdepartment.department_assoc
	sorted_department_for_access = SSdepartment.sorted_department_for_access

/// Tworzy datumy działów. Wołane też leniwie, bo get_all_accesses() bywa potrzebne przed Initialize() (Initialize przedmiotów z dostępem).
/datum/controller/subsystem/department/proc/setup_departments()
	if(department_datums)
		return
	var/static/list/access_order = list(
		DEPT_SERVICE,
		DEPT_SECURITY,
		DEPT_MEDICAL,
		DEPT_SCIENCE,
		DEPT_ENGINEERING,
		DEPT_SUPPLY,
		DEPT_COMMAND,
		DEPT_MUNITIONS,
		DEPT_CENTCOM,
		DEPT_OTHER,
	)
	department_datums = list()
	department_assoc = list()
	for(var/dept_type in subtypesof(/datum/department_group))
		var/datum/department_group/dept = new dept_type
		department_datums += dept
		department_assoc[dept.dept_id] = dept
	sorted_department_for_access = list()
	for(var/dept_id in access_order)
		if(department_assoc[dept_id])
			sorted_department_for_access += department_assoc[dept_id]

/// Działy, których bitflaga ma wspólny bit z podaną. Zawsze zwraca listę, także dla jednego działu.
/datum/controller/subsystem/department/proc/get_department_by_bitflag(bitflag)
	RETURN_TYPE(/list)
	setup_departments()
	. = list()
	if(!isnum(bitflag))
		return
	for(var/datum/department_group/dept as anything in department_datums)
		if(dept.dept_bitflag & bitflag)
			. += dept

/datum/controller/subsystem/department/proc/get_department_by_dept_id(id)
	setup_departments()
	. = department_assoc[id]
	if(!.)
		CRASH("[id] isn't an existing department id.")

/// Stanowiska działu (albo kilku działów z listy dept_id), bez powtórzeń
/datum/controller/subsystem/department/proc/get_jobs_by_dept_id(id_or_list)
	RETURN_TYPE(/list)
	setup_departments()
	. = list()
	if(!id_or_list)
		stack_trace("get_jobs_by_dept_id() called without a department id")
		return
	if(!islist(id_or_list))
		id_or_list = list(id_or_list)
	for(var/id in id_or_list)
		var/datum/department_group/dept = department_assoc[id]
		if(!dept)
			stack_trace("[id] isn't an existing department id.")
			continue
		. |= dept.jobs

/// Dostępy wszystkich działów z bitflagi, bez powtórzeń
/datum/controller/subsystem/department/proc/get_accesses_by_bitflag(bitflag)
	RETURN_TYPE(/list)
	. = list()
	for(var/datum/department_group/dept as anything in get_department_by_bitflag(bitflag))
		. |= dept.access_list

/// Dostęp z działów bitflagi pasujący do wartości z okna albo hrefa (liczba lub tekst, bo ACCESS_HERETIC jest tekstem).
/// Biała lista konsol ID: null, gdy żaden z tych działów nie ma takiego dostępu.
/datum/controller/subsystem/department/proc/find_access_in_departments(access_value, bitflag)
	if(isnull(access_value) || !bitflag)
		return null
	var/access_text = "[access_value]"
	for(var/access in get_accesses_by_bitflag(bitflag))
		if("[access]" == access_text)
			return access
	return null

/// Działy, którymi karta szefa zarządza w konsolach ID bez ACCESS_CHANGE_IDS (po manager_access działu).
/// console_bitflag ogranicza wynik do działów konsoli, NONE = wszystkie działy stacji.
/datum/controller/subsystem/department/proc/get_managed_departments(list/card_access, console_bitflag = NONE)
	. = NONE
	if(!length(card_access))
		return
	for(var/datum/department_group/dept as anything in get_department_by_bitflag(console_bitflag || DEPARTMENT_BITFLAG_STATIONS))
		if(dept.manager_access && (dept.manager_access in card_access))
			. |= dept.dept_bitflag

/// Stanowiska podwładnych szefów działów z bitflagi (department_head stanowiska), do przypisywania i degradacji
/datum/controller/subsystem/department/proc/get_subordinate_jobs(bitflag)
	RETURN_TYPE(/list)
	. = list()
	var/list/heads = list()
	for(var/datum/department_group/dept as anything in get_department_by_bitflag(bitflag))
		heads |= dept.leaders
	if(!length(heads))
		return
	for(var/datum/job/job as anything in SSjob.occupations)
		for(var/head in job.department_head)
			if(head in heads)
				. |= job.title
				break

// --------------------------------------------
// Datumy działów

/datum/department_group
	/// Nazwa działu (zakładki stanowisk w konsolach ID)
	var/dept_name = "Brak działu"
	/// Klucz działu (DEPT_*)
	var/dept_id
	/// Bitflaga działu (DEPARTMENT_BITFLAG_*)
	var/dept_bitflag = NONE
	/// Szefowie działu: ich podwładnych (department_head) szef przypisuje i degraduje w konsolach ID
	var/list/leaders = list()
	/// Dostęp biura szefa, z którym karta bez ACCESS_CHANGE_IDS zarządza działem w konsolach ID
	var/manager_access
	/// Stanowiska działu do przypisania w konsolach ID (ten sam podział co w get_all_jobs())
	var/list/jobs = list()
	/// Nazwa grupy dostępów
	var/access_group_name = "Nieznane"
	/// Dostępy działu
	var/list/access_list = list()
	/// TRUE: grupę widzi i zmienia tylko konsola Centrali
	var/access_filter = FALSE

/datum/department_group/service
	dept_name = "Służba"
	dept_id = DEPT_SERVICE
	dept_bitflag = DEPARTMENT_BITFLAG_SERVICE
	leaders = list(JOB_NAME_HEADOFPERSONNEL)
	manager_access = ACCESS_HOP
	jobs = list(
		JOB_NAME_ASSISTANT,
		JOB_NAME_HEADOFPERSONNEL,
		JOB_NAME_BARTENDER,
		JOB_NAME_COOK,
		JOB_NAME_BOTANIST,
		JOB_NAME_JANITOR,
		JOB_NAME_CURATOR,
		JOB_NAME_CHAPLAIN,
		JOB_NAME_LAWYER,
		JOB_NAME_CLOWN,
		JOB_NAME_MIME,
		JOB_NAME_BARBER,
		JOB_NAME_STAGEMAGICIAN,
	)
	access_group_name = "Ogólne"
	access_list = list(
		ACCESS_KITCHEN,
		ACCESS_BAR,
		ACCESS_HYDROPONICS,
		ACCESS_JANITOR,
		ACCESS_CHAPEL_OFFICE,
		ACCESS_CREMATORIUM,
		ACCESS_LIBRARY,
		ACCESS_THEATRE,
		ACCESS_LAWYER,
	)

/datum/department_group/security
	dept_name = "Ochrona"
	dept_id = DEPT_SECURITY
	dept_bitflag = DEPARTMENT_BITFLAG_SECURITY
	leaders = list(JOB_NAME_HEADOFSECURITY)
	manager_access = ACCESS_HOS
	jobs = list(
		JOB_NAME_HEADOFSECURITY,
		JOB_NAME_WARDEN,
		JOB_NAME_DETECTIVE,
		JOB_NAME_SECURITYOFFICER,
		JOB_NAME_BRIGPHYSICIAN,
		JOB_NAME_DEPUTY,
	)
	access_group_name = "Ochrona"
	access_list = list(
		ACCESS_SEC_DOORS,
		ACCESS_SEC_RECORDS,
		ACCESS_WEAPONS,
		ACCESS_SECURITY,
		ACCESS_BRIG,
		ACCESS_BRIGPHYS,
		ACCESS_ARMORY,
		ACCESS_FORENSICS_LOCKERS,
		ACCESS_COURT,
		ACCESS_MECH_SECURITY,
		ACCESS_HOS,
	)

/datum/department_group/medical
	dept_name = "Medyczny"
	dept_id = DEPT_MEDICAL
	dept_bitflag = DEPARTMENT_BITFLAG_MEDICAL
	leaders = list(JOB_NAME_CHIEFMEDICALOFFICER)
	manager_access = ACCESS_CMO
	jobs = list(
		JOB_NAME_CHIEFMEDICALOFFICER,
		JOB_NAME_MEDICALDOCTOR,
		JOB_NAME_CHEMIST,
		JOB_NAME_GENETICIST,
		JOB_NAME_VIROLOGIST,
		JOB_NAME_PARAMEDIC,
		JOB_NAME_PSYCHIATRIST,
	)
	access_group_name = "Ambulatorium"
	access_list = list(
		ACCESS_MEDICAL,
		ACCESS_GENETICS,
		ACCESS_CLONING,
		ACCESS_MORGUE,
		ACCESS_CHEMISTRY,
		ACCESS_VIROLOGY,
		ACCESS_SURGERY,
		ACCESS_MECH_MEDICAL,
		ACCESS_CMO,
	)

/datum/department_group/science
	dept_name = "Nauka"
	dept_id = DEPT_SCIENCE
	dept_bitflag = DEPARTMENT_BITFLAG_SCIENCE
	leaders = list(JOB_NAME_RESEARCHDIRECTOR)
	manager_access = ACCESS_RD
	jobs = list(
		JOB_NAME_RESEARCHDIRECTOR,
		JOB_NAME_SCIENTIST,
		JOB_NAME_ROBOTICIST,
		JOB_NAME_EXPLORATIONCREW,
	)
	access_group_name = "Nauka"
	access_list = list(
		ACCESS_RESEARCH,
		ACCESS_TOX,
		ACCESS_TOX_STORAGE,
		ACCESS_GENETICS,
		ACCESS_ROBOTICS,
		ACCESS_XENOBIOLOGY,
		ACCESS_EXPLORATION,
		ACCESS_MECH_SCIENCE,
		ACCESS_MINISAT,
		ACCESS_RD,
		ACCESS_NETWORK,
		ACCESS_RD_SERVER,
	)

/datum/department_group/engineering
	dept_name = "Inżynieria"
	dept_id = DEPT_ENGINEERING
	dept_bitflag = DEPARTMENT_BITFLAG_ENGINEERING
	leaders = list(JOB_NAME_CHIEFENGINEER)
	manager_access = ACCESS_CE
	jobs = list(
		JOB_NAME_CHIEFENGINEER,
		JOB_NAME_STATIONENGINEER,
		JOB_NAME_ATMOSPHERICTECHNICIAN,
	)
	access_group_name = "Inżynieria"
	access_list = list(
		ACCESS_CONSTRUCTION,
		ACCESS_AUX_BASE,
		ACCESS_MAINT_TUNNELS,
		ACCESS_ENGINE,
		ACCESS_ENGINE_EQUIP,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_TECH_STORAGE,
		ACCESS_ATMOSPHERICS,
		ACCESS_MECH_ENGINE,
		ACCESS_TCOMSAT,
		ACCESS_TCOMMS_ADMIN,
		ACCESS_MINISAT,
		ACCESS_CE,
	)

/datum/department_group/cargo
	dept_name = "Zaopatrzenie"
	dept_id = DEPT_SUPPLY
	dept_bitflag = DEPARTMENT_BITFLAG_CARGO
	leaders = list(JOB_NAME_HEADOFPERSONNEL)
	manager_access = ACCESS_HOP
	jobs = list(
		JOB_NAME_QUARTERMASTER,
		JOB_NAME_CARGOTECHNICIAN,
		JOB_NAME_SHAFTMINER,
		JOB_NAME_BITRUNNER,
	)
	access_group_name = "Zaopatrzenie"
	// NSV13: dostępy statku górniczego nie były w żadnym regionie, a kapitan, ERT i SI dostają sumę działów
	access_list = list(
		ACCESS_MAILSORTING,
		ACCESS_MINING,
		ACCESS_MINING_STATION,
		ACCESS_MECH_MINING,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_CARGO,
		ACCESS_QM,
		ACCESS_VAULT,
		ACCESS_BIT_DEN,
		ACCESS_MINING_ENGINEERING,
		ACCESS_MINING_BRIDGE,
	)

/datum/department_group/command
	dept_name = "Dowództwo"
	dept_id = DEPT_COMMAND
	dept_bitflag = DEPARTMENT_BITFLAG_COMMAND
	leaders = list(JOB_NAME_CAPTAIN)
	jobs = list(JOB_NAME_CAPTAIN)
	access_group_name = "Dowództwo"
	access_list = list(
		ACCESS_HEADS,
		ACCESS_RC_ANNOUNCE,
		ACCESS_KEYCARD_AUTH,
		ACCESS_CHANGE_IDS,
		ACCESS_AI_UPLOAD,
		ACCESS_TELEPORTER,
		ACCESS_EVA,
		ACCESS_GATEWAY,
		ACCESS_ALL_PERSONAL_LOCKERS,
		ACCESS_HOP,
		ACCESS_CAPTAIN,
		ACCESS_VAULT,
	)

/datum/department_group/munitions
	dept_name = "Uzbrojenie"
	dept_id = DEPT_MUNITIONS
	dept_bitflag = DEPARTMENT_BITFLAG_MUNITIONS
	leaders = list(JOB_NAME_MASTERATARMS)
	manager_access = ACCESS_MAA
	jobs = list(
		JOB_NAME_MASTERATARMS,
		JOB_NAME_PILOT,
		JOB_NAME_MUNITIONSTECHNICIAN,
		JOB_NAME_AIRTRAFFICCONTROLLER,
		JOB_NAME_DECKTECHNICIAN,
		JOB_NAME_BRIDGESTAFF,
	)
	access_group_name = "Uzbrojenie"
	access_list = list(
		ACCESS_MUNITIONS,
		ACCESS_MUNITIONS_STORAGE,
		ACCESS_COMBAT_PILOT,
		ACCESS_TRANSPORT_PILOT,
		ACCESS_MAA,
		ACCESS_HANGAR,
	)

/datum/department_group/centcom
	dept_name = "Centrala"
	dept_id = DEPT_CENTCOM
	dept_bitflag = DEPARTMENT_BITFLAG_CENTCOM
	access_group_name = "Centrala"
	access_filter = TRUE

/datum/department_group/centcom/New()
	. = ..()
	jobs = get_all_centcom_jobs()
	access_list = get_all_centcom_access()

/// Dostępy spoza stacji: Syndykat (też skrzydła NSV13), piraci, łowcy, misje, kulty, heretyk, więzień
/datum/department_group/other
	dept_name = "Inne"
	dept_id = DEPT_OTHER
	dept_bitflag = DEPARTMENT_BITFLAG_OTHER
	access_group_name = "Inne"
	access_filter = TRUE

/datum/department_group/other/New()
	. = ..()
	access_list = get_all_syndicate_access() + list(
		ACCESS_SYNDICATE_ENGINEERING,
		ACCESS_SYNDICATE_REQUISITIONS,
		ACCESS_SYNDICATE_MARINE_ARMOURY,
		ACCESS_PIRATES,
		ACCESS_HUNTERS,
	) + get_all_away_access() + list(
		ACCESS_BLOODCULT,
		ACCESS_CLOCKCULT,
		ACCESS_HERETIC,
		ACCESS_PRISONER,
	)

// --------------------------------------------
// Konsole ID

/// Opis dostępu do okien konsol ID: stacja, Centrala i dostępy z grupy „Inne”
/proc/get_department_access_desc(access)
	. = get_access_desc(access) || get_centcom_access_desc(access)
	if(.)
		return
	switch(access)
		if(ACCESS_SYNDICATE)
			return "Syndykat"
		if(ACCESS_SYNDICATE_LEADER)
			return "Przywódca Syndykatu"
		if(ACCESS_SYNDICATE_ENGINEERING)
			return "Inżynieria Syndykatu"
		if(ACCESS_SYNDICATE_REQUISITIONS)
			return "Zaopatrzenie Syndykatu"
		if(ACCESS_SYNDICATE_MARINE_ARMOURY)
			return "Zbrojownia piechoty Syndykatu"
		if(ACCESS_PIRATES)
			return "Kosmiczni piraci"
		if(ACCESS_HUNTERS)
			return "Łowcy zbiegów"
		if(ACCESS_AWAY_GENERAL)
			return "Misja zewnętrzna: ogólne"
		if(ACCESS_AWAY_MAINT)
			return "Misja zewnętrzna: tunele techniczne"
		if(ACCESS_AWAY_MED)
			return "Misja zewnętrzna: medyczny"
		if(ACCESS_AWAY_SEC)
			return "Misja zewnętrzna: ochrona"
		if(ACCESS_AWAY_ENGINE)
			return "Misja zewnętrzna: inżynieria"
		if(ACCESS_AWAY_GENERIC1)
			return "Misja zewnętrzna: dostęp 1"
		if(ACCESS_AWAY_GENERIC2)
			return "Misja zewnętrzna: dostęp 2"
		if(ACCESS_AWAY_GENERIC3)
			return "Misja zewnętrzna: dostęp 3"
		if(ACCESS_AWAY_GENERIC4)
			return "Misja zewnętrzna: dostęp 4"
		if(ACCESS_BLOODCULT)
			return "Kult krwi"
		if(ACCESS_CLOCKCULT)
			return "Kult zegara"
		if(ACCESS_HERETIC)
			return "Heretyk"
		if(ACCESS_PRISONER)
			return "Więzień"

/// Bitflaga działów, których dostępy konsola kart może teraz zmieniać (biała lista przycisków dostępów)
/obj/machinery/computer/card/proc/get_manageable_department_bitflag()
	switch(authenticated)
		if(2)
			return is_centcom ? ALL : DEPARTMENT_BITFLAG_STATIONS
		if(1)
			return accessible_region_bitflag
	return NONE

/// Bitflaga działów, których dostępy program NtOS może teraz zmieniać (biała lista przycisków dostępów)
/datum/computer_file/program/card_mod/proc/get_manageable_department_bitflag()
	if(!authenticated)
		return NONE
	if(minor)
		return accessible_region_bitflag
	return is_centcom ? ALL : DEPARTMENT_BITFLAG_STATIONS
