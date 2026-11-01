/client/proc/callproc()
	set category = "Debug"
	set name = "Advanced ProcCall"
	set waitfor = FALSE
	if(!check_rights(R_DEBUG))
		return
	// AQUILA: okno TGUI (ProcCallMenu) zamiast serii input(); wersja blokująca zostaje dla VV_PROCCALL_RETVAL
	if(!proccall_menu)
		proccall_menu = new(src)
	proccall_menu.ui_interact(mob)

/client/proc/callproc_blocking(list/get_retval)
	if(!check_rights(R_DEBUG))
		return

	var/datum/target
	var/targetselected = FALSE

	switch(alert("Czy proc ma właściciela?",,"Tak","Nie"))
		if("Tak")
			targetselected = TRUE
			var/list/value = vv_get_value(default_class = VV_ATOM_REFERENCE, classes = list(VV_ATOM_REFERENCE, VV_DATUM_REFERENCE, VV_MOB_REFERENCE, VV_MARKED_DATUM, VV_TEXT_LOCATE, VV_PROCCALL_RETVAL))
			if (!value["class"] || !value["value"])
				return
			target = value["value"]
			if(!istype(target))
				to_chat(usr, "<span class='danger'>Nieprawidłowy cel.</span>")
				return
		if("Nie")
			target = null
			targetselected = FALSE

	var/procpath = capped_input(usr, "Ścieżka procki, np.: /proc/fake_blood","Ścieżka:", null)
	if(!procpath)
		return

	var/procname = callproc_check_path(target, targetselected, procpath)
	if(!procname)
		return

	var/list/lst = get_callproc_args()
	if(!lst)
		return

	. = callproc_execute(target, targetselected, procname, lst, get_retval)

/// Sprawdza ścieżkę procedury; zwraca samą nazwę procedury albo null (z komunikatem dla admina)
/client/proc/callproc_check_path(datum/target, targetselected, procpath)
	//strip away everything but the proc name
	var/list/proclist = splittext(procpath, "/")
	if (!length(proclist))
		return

	var/procname = proclist[proclist.len]
	if(!procname)
		return
	var/proctype = ("verb" in proclist) ? "verb" :"proc"

	if(targetselected)
		if(!hascall(target, procname))
			to_chat(usr, "<span class='warning'>Błąd: callproc(): typ [target.type] nie ma [proctype] o nazwie [procpath].</span>")
			return
	else
		procpath = "/[proctype]/[procname]"
		if(!text2path(procpath))
			to_chat(usr, "<span class='warning'>Błąd: callproc(): [procpath] nie istnieje.</span>")
			return
	return procname

/// Loguje i wywołuje procedurę (po callproc_check_path), wypisuje wynik do czatu admina
/client/proc/callproc_execute(datum/target, targetselected, procname, list/lst, list/get_retval)
	if(!check_rights(R_DEBUG))
		return
	var/returnval
	if(targetselected)
		if(!target)
			to_chat(usr, "<font color='red'>Błąd: callproc(): właściciel procki już nie istnieje.</font>")
			return
		var/msg = "[key_name(src)] called [target]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"]."
		log_admin(msg)
		message_admins(msg)				//Proccall announce removed.
		admin_ticket_log(target, msg)
		returnval = WrapAdminProcCall(target, procname, lst) // Pass the lst as an argument list to the proc
	else
		//this currently has no hascall protection. wasn't able to get it working.
		log_admin("[key_name(src)] called [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
		message_admins("[key_name(src)] wywołuje [procname]() [lst.len ? "z argumentami [list2params(lst)]":"bez argumentów"].")			//Proccall announce removed.
		returnval = WrapAdminProcCall(GLOBAL_PROC, procname, lst) // Pass the lst as an argument list to the proc
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Advanced ProcCall") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	if(get_retval)
		get_retval += returnval
	. = get_callproc_returnval(returnval, procname)
	if(.)
		to_chat(usr, .)

GLOBAL_VAR(AdminProcCaller)
GLOBAL_PROTECT(AdminProcCaller)
GLOBAL_VAR_INIT(AdminProcCallCount, 0)
GLOBAL_PROTECT(AdminProcCallCount)
GLOBAL_VAR(LastAdminCalledTargetRef)
GLOBAL_PROTECT(LastAdminCalledTargetRef)
GLOBAL_VAR(LastAdminCalledTarget)
GLOBAL_PROTECT(LastAdminCalledTarget)
GLOBAL_VAR(LastAdminCalledProc)
GLOBAL_PROTECT(LastAdminCalledProc)

/proc/WrapAdminProcCall(datum/target, procname, list/arguments)
	if(target && procname == "Del")
		to_chat(usr, "Wywoływanie Del() jest niedozwolone")
		return

	if(target != GLOBAL_PROC && !target.CanProcCall(procname))
		to_chat(usr, "Proccall na [target.type]/proc/[procname] jest niedozwolony!")
		return
	var/current_caller = GLOB.AdminProcCaller
	var/ckey = usr ? usr.client.ckey : GLOB.AdminProcCaller
	if(!ckey)
		CRASH("WrapAdminProcCall with no ckey: [target] [procname] [english_list(arguments)]")

	if(current_caller && current_caller != ckey)
		to_chat(usr, "<span class='adminnotice'>Wciąż działają procki wywołane przez innego admina. Spróbuj później.</span>")
		return
	GLOB.LastAdminCalledProc = procname
	if(target != GLOBAL_PROC)
		GLOB.LastAdminCalledTargetRef = REF(target)
	GLOB.AdminProcCaller = ckey	//if this runtimes, too bad for you
	++GLOB.AdminProcCallCount
	. = world.WrapAdminProcCall(target, procname, arguments)
	if(--GLOB.AdminProcCallCount == 0)
		GLOB.AdminProcCaller = null

//adv proc call this, ya nerds
/world/proc/WrapAdminProcCall(datum/target, procname, list/arguments)
	if(target == GLOBAL_PROC)
		return call("/proc/[procname]")(arglist(arguments))
	else if(target != world)
		return call(target, procname)(arglist(arguments))
	else
		log_admin("[key_name(usr)] attempted to call world/proc/[procname] with arguments: [english_list(arguments)]")

/proc/IsAdminAdvancedProcCall()
#ifdef TESTING
	return FALSE
#else
	return usr && usr.client && GLOB.AdminProcCaller == usr.client.ckey
#endif

/client/proc/callproc_datum(datum/A as null|area|mob|obj|turf)
	set category = "Debug"
	set name = "Atom ProcCall"
	set waitfor = 0

	if(!check_rights(R_DEBUG))
		return

	var/procname = capped_input(usr, "Nazwa procki, np.: fake_blood","Procka:", null)
	if(!procname)
		return
	if(!hascall(A,procname))
		to_chat(usr, "<font color='red'>Błąd: callproc_datum(): typ [A.type] nie ma procki o nazwie [procname].</font>")
		return
	var/list/lst = get_callproc_args()
	if(!lst)
		return

	if(!A || !is_valid_src(A))
		to_chat(usr, "<span class='warning'>Błąd: callproc_datum(): właściciel procki już nie istnieje.</span>")
		return
	log_admin("[key_name(src)] called [A]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
	var/msg = "[key_name(src)] called [A]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"]."
	message_admins(msg)
	admin_ticket_log(A, msg)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Atom ProcCall") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	var/returnval = WrapAdminProcCall(A, procname, lst) // Pass the lst as an argument list to the proc
	. = get_callproc_returnval(returnval,procname)
	if(.)
		to_chat(usr, .)

/client/proc/get_callproc_args()
	var/argnum = input("Liczba argumentów","Liczba:",0) as num|null
	if(isnull(argnum))
		return

	. = list()
	var/list/named_args = list()
	while(argnum--)
		var/named_arg = capped_input(usr, "Zostaw puste dla argumentu pozycyjnego. Argumenty pozycyjne są traktowane tak, jakby zostały dodane jako pierwsze.", "Argument nazwany")
		var/value = vv_get_value(restricted_classes = list(VV_RESTORE_DEFAULT))
		if (!value["class"])
			return
		if(named_arg)
			named_args[named_arg] = value["value"]
		else
			. += LIST_VALUE_WRAP_LISTS(value["value"])
	if(LAZYLEN(named_args))
		. += named_args

/client/proc/get_callproc_returnval(returnval,procname)
	. = ""
	if(islist(returnval))
		var/list/returnedlist = returnval
		. = "<font color='blue'>"
		if(returnedlist.len)
			var/assoc_check = returnedlist[1]
			if(istext(assoc_check) && (returnedlist[assoc_check] != null))
				. += "[procname] zwraca listę asocjacyjną:"
				for(var/key in returnedlist)
					. += "\n[key] = [returnedlist[key]]"

			else
				. += "[procname] zwraca listę:"
				for(var/elem in returnedlist)
					. += "\n[elem]"
		else
			. = "[procname] zwraca pustą listę"
		. += "</font>"

	else
		. = "<font color='blue'>[procname] zwraca: [!isnull(returnval) ? returnval : "null"]</font>"

// AQUILA: okno TGUI dla Advanced ProcCall (ProcCallMenu z tg, tam konfiguracja komponentu wiremod).
// Ustawienia zostają na kliencie między otwarciami; referencje do datumów trzymane jako weakref.
#define PROCCALL_ARG_TEXT "Tekst"
#define PROCCALL_ARG_NUM "Liczba"
#define PROCCALL_ARG_NULL "null"
#define PROCCALL_ARG_VV "Zaawansowany (VV)"

/client/var/datum/proccall_menu/proccall_menu

/datum/proccall_menu
	var/client/holder
	/// Czy procedura należy do obiektu (FALSE = procedura globalna)
	var/target_selected = FALSE
	var/datum/weakref/target_ref
	var/target_name
	var/procpath = ""
	/// Lista argumentów: list("name", "type", "value", "is_ref", "display")
	var/list/arguments = list()

/datum/proccall_menu/New(client/C)
	holder = C

/datum/proccall_menu/Destroy(force)
	if(holder?.proccall_menu == src)
		holder.proccall_menu = null
	holder = null
	target_ref = null
	arguments = null
	return ..()

/datum/proccall_menu/ui_state(mob/user)
	return GLOB.debug_state

/datum/proccall_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ProcCallMenu", "Advanced ProcCall")
		ui.open()

/datum/proccall_menu/ui_static_data(mob/user)
	return list("possible_types" = list(PROCCALL_ARG_TEXT, PROCCALL_ARG_NUM, PROCCALL_ARG_NULL, PROCCALL_ARG_VV))

/datum/proccall_menu/ui_data(mob/user)
	var/list/data = list()
	data["target_selected"] = target_selected
	var/datum/target = target_ref?.resolve()
	data["target_name"] = target_selected ? (target ? target_name : null) : null
	data["procpath"] = procpath
	var/list/arg_data = list()
	for(var/list/argument as anything in arguments)
		arg_data += list(list(
			"name" = argument["name"],
			"datatype" = argument["type"],
			"value" = argument["display"],
		))
	data["arguments"] = arg_data
	return data

/// Zwraca listę argumentu o indeksie z okna (od 1) albo null
/datum/proccall_menu/proc/get_argument(index)
	index = text2num(index)
	if(!isnum(index) || index < 1 || index > length(arguments))
		return null
	return arguments[index]

/datum/proccall_menu/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!holder || usr?.client != holder || !check_rights(R_DEBUG))
		return
	switch(action)
		if("select_target")
			var/list/value = holder.vv_get_value(default_class = VV_ATOM_REFERENCE, classes = list(VV_ATOM_REFERENCE, VV_DATUM_REFERENCE, VV_MOB_REFERENCE, VV_MARKED_DATUM, VV_TEXT_LOCATE, VV_PROCCALL_RETVAL))
			if(QDELETED(src) || !value["class"] || !value["value"])
				return TRUE
			var/datum/target = value["value"]
			if(!istype(target) || istype(target, /datum/weakref))
				to_chat(usr, "<span class='danger'>Nieprawidłowy cel.</span>")
				return TRUE
			target_selected = TRUE
			target_ref = WEAKREF(target)
			target_name = "[target] ([target.type])"
			return TRUE
		if("clear_target")
			target_selected = FALSE
			target_ref = null
			target_name = null
			return TRUE
		if("set_procpath")
			procpath = trim(copytext("[params["path"]]", 1, 256))
			return TRUE
		if("add_argument")
			arguments += list(list("name" = "", "type" = PROCCALL_ARG_TEXT, "value" = "", "is_ref" = FALSE, "display" = ""))
			return TRUE
		if("remove_argument")
			var/list/argument = get_argument(params["index"])
			if(argument)
				arguments -= list(argument)
			return TRUE
		if("rename_argument")
			var/list/argument = get_argument(params["index"])
			if(argument)
				argument["name"] = trim(copytext("[params["name"]]", 1, 128))
			return TRUE
		if("set_argument_datatype")
			var/list/argument = get_argument(params["index"])
			var/datatype = params["datatype"]
			if(!argument || !(datatype in list(PROCCALL_ARG_TEXT, PROCCALL_ARG_NUM, PROCCALL_ARG_NULL, PROCCALL_ARG_VV)))
				return TRUE
			argument["type"] = datatype
			argument["is_ref"] = FALSE
			switch(datatype)
				if(PROCCALL_ARG_TEXT)
					argument["value"] = ""
					argument["display"] = ""
				if(PROCCALL_ARG_NUM)
					argument["value"] = 0
					argument["display"] = "0"
				else
					argument["value"] = null
					argument["display"] = (datatype == PROCCALL_ARG_NULL) ? "null" : ""
			return TRUE
		if("set_argument_value")
			var/list/argument = get_argument(params["index"])
			if(!argument)
				return TRUE
			switch(argument["type"])
				if(PROCCALL_ARG_TEXT)
					argument["value"] = "[params["value"]]"
					argument["display"] = argument["value"]
				if(PROCCALL_ARG_NUM)
					var/number = text2num("[params["value"]]")
					argument["value"] = isnum(number) ? number : 0
					argument["display"] = "[argument["value"]]"
			return TRUE
		if("pick_argument_value")
			var/list/argument = get_argument(params["index"])
			if(!argument || argument["type"] != PROCCALL_ARG_VV)
				return TRUE
			var/list/value = holder.vv_get_value(restricted_classes = list(VV_RESTORE_DEFAULT))
			if(QDELETED(src) || !value["class"] || !(argument in arguments))
				return TRUE
			var/picked = value["value"]
			if(isdatum(picked) && !istype(picked, /datum/weakref))
				argument["is_ref"] = TRUE
				argument["value"] = WEAKREF(picked)
			else
				argument["is_ref"] = FALSE
				argument["value"] = picked
			argument["display"] = "[value["class"]]: [isnull(picked) ? "null" : picked]"
			return TRUE
		if("call")
			call_proc()
			return TRUE

/// Składa argumenty i wywołuje procedurę z tymi samymi sprawdzeniami i logami co callproc_blocking
/datum/proccall_menu/proc/call_proc()
	var/datum/target = null
	if(target_selected)
		target = target_ref?.resolve()
		if(!target)
			to_chat(usr, "<font color='red'>Błąd: callproc(): właściciel procki już nie istnieje.</font>")
			return
	if(!procpath)
		return
	var/procname = holder.callproc_check_path(target, target_selected, procpath)
	if(!procname)
		return
	var/list/lst = list()
	var/list/named_args = list()
	for(var/list/argument as anything in arguments)
		var/value = argument["value"]
		if(argument["is_ref"])
			var/datum/weakref/ref = value
			value = ref?.resolve()
			if(isnull(value))
				to_chat(usr, "<font color='red'>Błąd: callproc(): argument [argument["display"]] już nie istnieje.</font>")
				return
		if(argument["name"])
			named_args[argument["name"]] = value
		else
			lst += LIST_VALUE_WRAP_LISTS(value)
	if(LAZYLEN(named_args))
		lst += named_args
	holder.callproc_execute(target, target_selected, procname, lst)

#undef PROCCALL_ARG_TEXT
#undef PROCCALL_ARG_NUM
#undef PROCCALL_ARG_NULL
#undef PROCCALL_ARG_VV
