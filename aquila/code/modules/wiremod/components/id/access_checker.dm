/obj/item/circuit_component/compare/access
	display_name = "Access Checker"
	desc = "Wykonuje proste porównanie dwóch list tekstów, z dodatkowymi funkcjami ułatwiającymi sprawdzanie dostępów na kartach ID."
	category = "ID"

	/// A list of the accesses to check
	var/datum/port/input/subject_accesses

	/// A list of the accesses required to return true
	var/datum/port/input/required_accesses

	/// Whether to check for all or any of the required accesses
	var/datum/port/input/check_any

	ui_buttons = list(
		"id-card" = "access",
	)

/obj/item/circuit_component/compare/access/get_ui_notices()
	. = ..()
	. += create_ui_notice("Gdy \"Check Any\" jest prawdą, zwraca prawdę, jeśli \"Access To Check\" zawiera DOWOLNĄ wartość z \"Required Access\".", "orange", "info")
	. += create_ui_notice("Gdy \"Check Any\" jest fałszem, zwraca prawdę tylko wtedy, gdy \"Access To Check\" zawiera WSZYSTKIE wartości z \"Required Access\".", "orange", "info")

/obj/item/circuit_component/compare/access/populate_custom_ports()
	subject_accesses = add_input_port("Access To Check", PORT_TYPE_LIST(PORT_TYPE_NUMBER))
	required_accesses = add_input_port("Required Access", PORT_TYPE_LIST(PORT_TYPE_NUMBER))
	check_any = add_input_port("Check Any", PORT_TYPE_BOOLEAN)

/obj/item/circuit_component/compare/access/save_data_to_list(list/component_data)
	. = ..()
	component_data["input_ports_stored_data"] = list(required_accesses.name = list("stored_data" = required_accesses.value))

/obj/item/circuit_component/compare/access/add_to(obj/item/integrated_circuit/added_to)
	. = ..()
	RegisterSignal(added_to, COMSIG_CIRCUIT_POST_LOAD, PROC_REF(on_post_load))

/obj/item/circuit_component/compare/access/removed_from(obj/item/integrated_circuit/removed_from)
	UnregisterSignal(removed_from, COMSIG_CIRCUIT_POST_LOAD)
	return ..()

/obj/item/circuit_component/compare/access/proc/on_post_load(datum/source)
	regenerate_access()

/obj/item/circuit_component/compare/access/proc/regenerate_access()
	var/check_any_value = check_any.value
	var/list/required_accesses_list = required_accesses.value
	if(!islist(required_accesses_list))
		return
	if(check_any_value)
		LAZYCLEARLIST(req_access)
		req_one_access = required_accesses_list.Copy()
	else
		LAZYCLEARLIST(req_one_access)
		req_access = required_accesses_list.Copy()

/obj/item/circuit_component/compare/access/pre_input_received(datum/port/input/port)
	. = ..()
	if(port == required_accesses || port == check_any)
		regenerate_access()

/obj/item/circuit_component/compare/access/do_comparisons()
	return check_access_list(subject_accesses.value)

/obj/item/circuit_component/compare/access/ui_perform_action(mob/user, action)
	if(LAZYLEN(required_accesses.connected_ports))
		balloon_alert(user, "odłącz port przed ręczną konfiguracją!")
		return
	interact(user)

/obj/item/circuit_component/compare/access/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CircuitAccessChecker", display_name)
		ui.open()

/obj/item/circuit_component/compare/access/ui_static_data(mob/user)
	var/list/data = list()

	var/list/regions = list()
	for(var/region in 1 to WIREMOD_ACCESS_REGIONS)
		regions += list(wiremod_region_tgui(get_region_accesses_name(region), get_region_accesses(region)))
	if(parent?.admin_only)
		regions += list(wiremod_region_tgui("CentCom", get_all_centcom_access()))
	data["regions"] = regions
	return data

/obj/item/circuit_component/compare/access/ui_data(mob/user)
	var/list/data = list()
	data["accesses"] = required_accesses.value || list()
	data["oneAccess"] = check_any.value
	return data

/obj/item/circuit_component/compare/access/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("clear_all")
			required_accesses.set_value(list())
			check_any.set_value(0)
			. = TRUE
		if("grant_all")
			required_accesses.set_value(get_all_accesses())
			. = TRUE
		if("one_access")
			check_any.set_value(!check_any.value)
			. = TRUE
		if("set")
			var/list/required_accesses_list = required_accesses.value
			var/list/new_accesses_value = LAZYCOPY(required_accesses_list)
			var/access = text2num(params["access"])
			if(isnull(access))
				return
			if (!(access in new_accesses_value))
				new_accesses_value += access
			else
				new_accesses_value -= access
			required_accesses.set_value(new_accesses_value)
			. = TRUE
		if("grant_region")
			var/list/required_accesses_list = required_accesses.value
			var/list/required_accesses_value = LAZYCOPY(required_accesses_list)
			var/region = params["region"]
			if(isnull(region))
				return
			required_accesses.set_value(required_accesses_value | wiremod_region_accesses(region))
			. = TRUE
		if("deny_region")
			var/list/required_accesses_list = required_accesses.value
			var/list/required_accesses_value = LAZYCOPY(required_accesses_list)
			var/region = params["region"]
			if(isnull(region))
				return
			required_accesses.set_value(required_accesses_value - wiremod_region_accesses(region))
			. = TRUE
	if(.)
		regenerate_access()
		SStgui.update_uis(parent)
