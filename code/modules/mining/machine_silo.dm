GLOBAL_DATUM(ore_silo_default, /obj/machinery/ore_silo)
GLOBAL_LIST_EMPTY(silo_access_logs)

/obj/machinery/ore_silo
	name = "ore silo"
	desc = "An all-in-one bluespace storage and transmission system for the station's mineral distribution needs."
	icon = 'icons/obj/mining.dmi'
	icon_state = "silo"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/ore_silo

	var/list/holds = list()
	var/list/datum/component/remote_materials/connected = list()

/obj/machinery/ore_silo/Initialize(mapload)
	. = ..()
	var/static/list/materials_list = list(
		/datum/material/iron,
		/datum/material/glass,
		/datum/material/copper,
		/datum/material/silver,
		/datum/material/gold,
		/datum/material/diamond,
		/datum/material/plasma,
		/datum/material/uranium,
		/datum/material/bananium,
		/datum/material/titanium,
		/datum/material/bluespace,
		/datum/material/plastic,
		)
	AddComponent(/datum/component/material_container, materials_list, INFINITY, allowed_types=/obj/item/stack, _disable_attackby=TRUE)

	if (!GLOB.ore_silo_default && mapload && is_station_level(z))
		GLOB.ore_silo_default = src

/obj/machinery/ore_silo/Destroy()
	if (GLOB.ore_silo_default == src)
		GLOB.ore_silo_default = null

	for(var/C in connected)
		var/datum/component/remote_materials/mats = C
		mats.disconnect_from(src)

	connected = null

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.retrieve_all()

	return ..()

/obj/machinery/ore_silo/proc/remote_attackby(obj/machinery/M, mob/user, obj/item/stack/I)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)

	// stolen from /datum/component/material_container/proc/OnAttackBy
	if(user.combat_mode)
		return
	if(I.item_flags & ABSTRACT)
		return
	if(!istype(I) || (I.flags_1 & HOLOGRAM_1) || (I.item_flags & NO_MAT_REDEMPTION))
		to_chat(user, "<span class='warning'>[M] won't accept [I]!</span>")
		return
	var/item_mats = I.materials & materials.materials
	if(!length(item_mats))
		to_chat(user, "<span class='warning'>[I] nie zawiera dość materiałów, by [M] je przyjął.</span>")
		return
	// assumes unlimited space...
	var/amount = I.amount
	materials.user_insert(I, user)
	silo_log(M, "deposited", amount, "sheets", item_mats)
	return TRUE

/obj/machinery/ore_silo/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, W))
		return

	if(default_deconstruction_crowbar(W))
		return

	if(!powered())
		return ..()

	if(istype(W, /obj/item/stack))
		return remote_attackby(src, user, W)

	return ..()

/obj/machinery/ore_silo/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OreSilo")
		ui.open()

/obj/machinery/ore_silo/ui_data(mob/user)
	var/list/data = list()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	data["materials"] = materials.ui_data(user)

	//Ikony maszyn liczymy raz na typ wyglądu
	var/static/list/machine_icons = list()
	var/list/machines = list()
	for(var/datum/component/remote_materials/mats as anything in connected)
		var/atom/parent = mats.parent
		var/icon_key = "[parent.icon]-[parent.icon_state]"
		if(!machine_icons[icon_key])
			machine_icons[icon_key] = icon2base64(icon(parent.icon, parent.icon_state, SOUTH, 1))
		machines += list(list(
			"name" = parent.name,
			"icon" = machine_icons[icon_key],
			"on_hold" = !!holds["[get_area(parent)]/[mats.category]"],
			"location" = get_area_name(parent, TRUE),
		))
	data["machines"] = machines

	var/list/logs = list()
	for(var/datum/ore_silo_log/entry as anything in GLOB.silo_access_logs[REF(src)])
		logs += list(entry.log_ui_data())
	data["logs"] = logs
	return data

/obj/machinery/ore_silo/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("remove")
			var/index = text2num(params["id"])
			if(!index || index < 1 || index > length(connected))
				return
			var/datum/component/remote_materials/mats = connected[index]
			mats.disconnect_from(src)
			connected -= mats
			return TRUE
		if("hold")
			var/index = text2num(params["id"])
			if(!index || index < 1 || index > length(connected))
				return
			var/datum/component/remote_materials/mats = connected[index]
			var/hold_key = "[get_area(mats.parent)]/[mats.category]"
			if(holds[hold_key])
				holds -= hold_key
			else
				holds[hold_key] = TRUE
			return TRUE
		if("eject")
			var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
			var/datum/material/eject_sheet = locate(params["ref"]) in materials.materials
			var/amount = text2num(params["amount"])
			if(!eject_sheet || !amount || amount < 1)
				return
			var/count = materials.retrieve_sheets(round(amount), eject_sheet, drop_location())
			var/list/matlist = list()
			matlist[eject_sheet] = MINERAL_MATERIAL_AMOUNT
			silo_log(src, "ejected", -count, "sheets", matlist)
			return TRUE

/obj/machinery/ore_silo/multitool_act(mob/living/user, obj/item/multitool/I)
	if (istype(I))
		to_chat(user, "<span class='notice'>Zapisujesz [src] w buforze multitoola.</span>")
		I.buffer = src
		return TRUE

/obj/machinery/ore_silo/proc/silo_log(obj/machinery/M, action, amount, noun, list/mats)
	if (!length(mats))
		return
	var/datum/ore_silo_log/entry = new(M, action, amount, noun, mats)

	var/list/datum/ore_silo_log/logs = GLOB.silo_access_logs[REF(src)]
	if(!LAZYLEN(logs))
		GLOB.silo_access_logs[REF(src)] = logs = list(entry)
	else if(!logs[1].merge(entry))
		logs.Insert(1, entry)

	SStgui.update_uis(src)
	flick("silo_active", src)

/obj/machinery/ore_silo/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] można połączyć z techfabami, drukarkami obwodów i protolatami za pomocą multitoola.</span>"

/obj/machinery/ore_silo/on_object_saved(var/depth = 0)
	if(depth >= 10)
		return ""
	var/dat
	var/datum/component/material_container/material_holder = GetComponent(/datum/component/material_container)
	for(var/each in material_holder.materials)
		var/amount = material_holder.materials[each] / MINERAL_MATERIAL_AMOUNT
		var/datum/material/material_datum = each
		while(amount > 0)
			var/amount_in_stack = max(1, min(50, amount))
			amount -= amount_in_stack
			dat += "[dat ? ",\n" : ""][material_datum.sheet_type]{\n\tamount = [amount_in_stack]\n\t}"
	return dat

/datum/ore_silo_log
	var/name  // for VV
	var/formatted  // for display

	var/timestamp
	var/machine_name
	var/area_name
	var/action
	var/noun
	var/amount
	var/list/materials

/datum/ore_silo_log/New(obj/machinery/M, _action, _amount, _noun, list/mats=list())
	timestamp = station_time_timestamp()
	machine_name = M.name
	area_name = get_area_name(M, TRUE)
	action = _action
	amount = _amount
	noun = _noun
	materials = mats.Copy()
	for(var/each in materials)
		materials[each] *= abs(_amount)
	format()

/datum/ore_silo_log/proc/merge(datum/ore_silo_log/other)
	if (other == src || action != other.action || noun != other.noun)
		return FALSE
	if (machine_name != other.machine_name || area_name != other.area_name)
		return FALSE

	timestamp = other.timestamp
	amount += other.amount
	for(var/each in other.materials)
		materials[each] += other.materials[each]
	format()
	return TRUE

/datum/ore_silo_log/proc/format()
	name = "[machine_name]: [action] [amount]x [noun]"

	var/list/msg = list("([timestamp]) <b>[machine_name]</b> in [area_name]<br>[action] [abs(amount)]x [noun]<br>")
	var/sep = ""
	for(var/key in materials)
		var/datum/material/M = key
		var/val = round(materials[key]) / MINERAL_MATERIAL_AMOUNT
		msg += sep
		sep = ", "
		msg += "[amount < 0 ? "-" : "+"][val] [M.name]"
	formatted = msg.Join()

/// Dane wpisu dla okna TGUI silosu
/datum/ore_silo_log/proc/log_ui_data()
	var/list/raw = list()
	for(var/key in materials)
		var/datum/material/M = key
		raw += "[amount < 0 ? "-" : "+"][round(materials[key]) / MINERAL_MATERIAL_AMOUNT] [M.name]"
	return list(
		"raw_materials" = jointext(raw, ", "),
		"machine_name" = machine_name,
		"area_name" = area_name,
		"action" = action,
		"amount" = amount,
		"time" = timestamp,
		"noun" = noun,
	)

/obj/machinery/ore_silo/Bumped(atom/movable/AM) //NSV13 Throwing Upgrade
	. = ..()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)

	if(!powered())
		return ..()

	if(istype(AM, /obj/item/stack))
		var/obj/item/stack/S = AM

		var/item_mats = S.materials & materials.materials
		if(!length(item_mats))
			return

		var/amount = S.amount
		materials.insert_item(S, 1)
		silo_log(src, "deposited", amount, "sheets", item_mats)
		return TRUE

