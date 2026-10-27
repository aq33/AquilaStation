// Pomocnicze procki i wpisy konfiguracji z tg, których wymaga wiremod z tg.

/proc/cmp_port_order_asc(datum/port/compare1, datum/port/compare2)
	return compare1.order - compare2.order

/// Lista kluczy listy asocjacyjnej (z tg).
/proc/assoc_to_keys(list/input)
	var/list/keys = list()
	for(var/key in input)
		keys[++keys.len] = key
	return keys

/// Rozwiązuje weakrefy w liście i jej podlistach (z tg).
/proc/recursive_list_resolve(list/list_to_resolve)
	. = list()
	for(var/element in list_to_resolve)
		if(istext(element))
			. += element
			var/possible_assoc_value = list_to_resolve[element]
			if(possible_assoc_value)
				.[element] = recursive_list_resolve_element(possible_assoc_value)
		else
			. += list(recursive_list_resolve_element(element))

/proc/recursive_list_resolve_element(element)
	if(islist(element))
		var/list/inner_list = element
		return recursive_list_resolve(inner_list)
	else if(isweakref(element))
		var/datum/weakref/ref = element
		return ref.resolve()
	else
		return element

/// Admin może wyłączyć wszystkie dźwięki z circuitów (panel View All Circuits).
/datum/config_entry/flag/disallow_circuit_sounds

/// Czas stacji w formacie 12-godzinnym (z tg).
/proc/time_to_twelve_hour(format = "hh:mm:ss", time = station_time())
	time = MODULUS(time, 24 HOURS)
	var/am_pm = "AM"
	if(time > 12 HOURS)
		am_pm = "PM"
		if(time > 13 HOURS)
			time -= 12 HOURS // e.g. 4:16 PM but not 00:42 PM
	else if (time < 1 HOURS)
		time += 12 HOURS // e.g. 12.23 AM
	return "[time2text(time, format, 0)] [am_pm]"

/proc/log_admin_circuit(text)
	log_admin("CIRCUIT: [text]")

/**
 * Proccall bez klienta, dla komponentów admina (z tg).
 * U nas nie ma moba proccall_handler, więc wołający jest wpisywany wprost do GLOB.AdminProcCaller.
 */
/proc/HandleUserlessProcCall(user, datum/target, procname, list/arguments)
	if(IsAdminAdvancedProcCall())
		return
	if(target != GLOBAL_PROC && !target.CanProcCall(procname))
		return
	if(GLOB.AdminProcCaller && GLOB.AdminProcCaller != user)
		return
	var/lastusr = usr
	usr = null
	GLOB.LastAdminCalledProc = procname
	if(target != GLOBAL_PROC)
		GLOB.LastAdminCalledTargetRef = REF(target)
	GLOB.AdminProcCaller = user
	++GLOB.AdminProcCallCount
	. = world.WrapAdminProcCall(target, procname, arguments)
	if(--GLOB.AdminProcCallCount == 0)
		GLOB.AdminProcCaller = null
	usr = lastusr

/// SDQL bez klienta, dla komponentu SDQL (z tg).
/proc/HandleUserlessSDQL(user, query_text)
	if(IsAdminAdvancedProcCall())
		return
	var/lastusr = usr
	usr = null
	. = world.SDQL2_query(query_text, user, user)
	usr = lastusr

/// Czy NTNet stacji działa (u tg zwraca przekaźnik, u nas wystarczy prawda/fałsz).
/proc/find_functional_ntnet_relay()
	return SSnetworks.station_network?.check_function()

/// Regiony dostępu jak w oknie elektroniki śluzy (1-8, z amunicją NSV13).
#define WIREMOD_ACCESS_REGIONS 8

/// Dane regionu dla okna AccessConfig w TGUI.
/proc/wiremod_region_tgui(name, list/accesses)
	var/list/entries = list()
	for(var/access in accesses)
		var/desc = get_access_desc(access) || get_centcom_access_desc(access)
		if(!desc)
			continue
		entries += list(list(
			"desc" = replacetext(desc, "&nbsp", " "),
			"ref" = access,
		))
	return list(
		"name" = name,
		"regid" = name,
		"accesses" = entries,
	)

/// Dostępy regionu po nazwie z okna (TGUI wysyła nazwę regionu).
/proc/wiremod_region_accesses(region_name)
	if(region_name == "CentCom")
		return get_all_centcom_access()
	for(var/region in 1 to WIREMOD_ACCESS_REGIONS)
		if(get_region_accesses_name(region) == region_name)
			return get_region_accesses(region)
	return list()

/// Nakładka widoczna tylko dla jednej osoby (tg: one_person, u nas onePerson). Nasze add_alt_appearance nic nie zwraca.
/proc/wiremod_one_person_appearance(atom/target, key, image/overlay, mob/seer)
	target.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/onePerson, key, overlay, seer)
	return LAZYACCESS(target.alternate_appearances, key)

/// Wysyła dane circuitów po sieci kabli (z tg).
/datum/powernet/proc/data_transmission(list/data, encryption_key, datum/weakref/port)
	SEND_SIGNAL(src, COMSIG_POWERNET_CIRCUIT_TRANSMISSION, list("data" = data, "enc_key" = encryption_key, "port" = port))
