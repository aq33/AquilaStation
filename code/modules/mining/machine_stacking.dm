/**********************Mineral stacking unit console**************************/

/obj/machinery/mineral/stacking_unit_console
	name = "stacking machine console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	desc = "Controls a stacking machine... in theory."
	density = FALSE
	circuit = /obj/item/circuitboard/machine/stacking_unit_console
	var/obj/machinery/mineral/stacking_machine/machine
	var/machinedir = SOUTHEAST
	var/link_id

/obj/machinery/mineral/stacking_unit_console/Initialize(mapload)
	. = ..()
	if(link_id)
		return INITIALIZE_HINT_LATELOAD
	else
		machine = locate(/obj/machinery/mineral/stacking_machine, get_step(src, machinedir))
		if (machine)
			machine.console = src

// Only called if mappers set an ID
/obj/machinery/mineral/stacking_unit_console/LateInitialize()
	for(var/obj/machinery/mineral/stacking_machine/SM in GLOB.machines)
		if(SM.link_id == link_id)
			machine = SM
			machine.console = src
			return

/obj/machinery/mineral/stacking_unit_console/Destroy()
	if(machine)
		machine.console = null
		machine = null
	return ..()

// AQUILA: okno TGUI StackingConsole (z tg) zamiast starego HTML
/obj/machinery/mineral/stacking_unit_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StackingConsole", name)
		ui.open()

/obj/machinery/mineral/stacking_unit_console/ui_data(mob/user)
	var/list/data = list()
	data["machine"] = !!machine
	data["stacking_amount"] = null
	data["contents"] = list()
	if(machine)
		data["stacking_amount"] = machine.stack_amt
		data["input_direction"] = dir2text(machine.input_dir)
		data["output_direction"] = dir2text(machine.output_dir)
		for(var/stack_type in machine.stack_list)
			var/obj/item/stack/sheet/stored_sheet = machine.stack_list[stack_type]
			if(stored_sheet.amount <= 0)
				continue
			data["contents"] += list(list(
				"type" = "[stack_type]",
				"name" = capitalize(stored_sheet.name),
				"amount" = stored_sheet.amount,
			))
	return data

/obj/machinery/mineral/stacking_unit_console/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!machine)
		return
	add_fingerprint(usr)
	switch(action)
		if("release")
			var/release_type = text2path(params["type"])
			if(!release_type || !(release_type in machine.stack_list))
				return //someone tried to spawn materials by spoofing hrefs
			var/obj/item/stack/sheet/inp = machine.stack_list[release_type]
			if(inp.amount <= 0)
				return
			var/obj/item/stack/sheet/out = new inp.type(null, inp.amount)
			inp.amount = 0
			machine.unload_mineral(out)
			return TRUE
		if("rotate")
			machine.rotate(text2num(params["input"]))
			return TRUE

/obj/machinery/mineral/stacking_unit_console/multitool_act(mob/living/user, obj/item/I)
	if(!multitool_check_buffer(user, I))
		return
	var/obj/item/multitool/M = I
	M.buffer = src
	to_chat(user, "<span class='notice'>Zapisujesz informacje o połączeniu w buforze [I].</span>")
	return TRUE

/**********************Mineral stacking unit**************************/


/obj/machinery/mineral/stacking_machine
	name = "stacking machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "stacker"
	desc = "A machine that automatically stacks acquired materials. Controlled by a nearby console."
	density = TRUE
	circuit = /obj/item/circuitboard/machine/stacking_machine
	input_dir = EAST
	output_dir = WEST
	var/obj/machinery/mineral/stacking_unit_console/console
	var/stk_types = list()
	var/stk_amt   = list()
	var/stack_list[0] //Key: Type.  Value: Instance of type.
	var/stack_amt = 50 //amount to stack before releassing
	var/datum/component/remote_materials/materials
	var/force_connect = FALSE
	///Proximity monitor associated with this atom, needed for proximity checks.
	var/datum/proximity_monitor/proximity_monitor
	var/link_id = null

/obj/machinery/mineral/stacking_machine/Initialize(mapload)
	. = ..()
	proximity_monitor = new(src, 1)
	materials = AddComponent(/datum/component/remote_materials, "stacking", mapload, FALSE, mapload && force_connect)

/obj/machinery/mineral/stacking_machine/Destroy()
	if(console)
		console.machine = null
		console = null
	materials = null
	return ..()

/obj/machinery/mineral/stacking_machine/HasProximity(atom/movable/AM)
	if(QDELETED(AM))
		return
	if(istype(AM, /obj/item/stack/sheet) && AM.loc == get_step(src, input_dir))
		var/obj/effect/portal/P = locate() in AM.loc
		if(P)
			visible_message("<span class='warning'>[src] próbuje ułożyć w stos portal!</span>")
			message_admins("Stacking machine exploded via [P.creator ? key_name(P.creator) : "UNKNOWN"]'s portal at [AREACOORD(src)]")
			log_game("Stacking machine exploded via [P.creator ? key_name(P.creator) : "UNKNOWN"]'s portal at [AREACOORD(src)]")
			explosion(src.loc, 0, 1, 2, 3)
			if(!QDELETED(src))
				qdel(src)
		else
			process_sheet(AM)

/obj/machinery/mineral/stacking_machine/multitool_act(mob/living/user, obj/item/multitool/M)
	if(istype(M))
		if(istype(M.buffer, /obj/machinery/mineral/stacking_unit_console))
			console = M.buffer
			console.machine = src
			to_chat(user, "<span class='notice'>Łączysz [src] z konsolą z bufora [M].</span>")
			return TRUE

/// AQUILA: obrót wejścia/wyjścia z konsoli (jak w tg)
/obj/machinery/mineral/stacking_machine/proc/rotate(input)
	if(input)
		input_dir = turn(input_dir, 90)
	else
		output_dir = turn(output_dir, 90)
	if(input_dir == output_dir)
		rotate(input)

/obj/machinery/mineral/stacking_machine/proc/process_sheet(obj/item/stack/sheet/inp)
	if(QDELETED(inp))
		return
	var/key = inp.merge_type
	var/obj/item/stack/sheet/storage = stack_list[key]
	if(!storage) //It's the first of this sheet added
		stack_list[key] = storage = new inp.type(src, 0)
	storage.amount += inp.amount //Stack the sheets
	qdel(inp)

	if(materials.silo && !materials.on_hold()) //Dump the sheets to the silo
		var/matlist = storage.materials & materials.mat_container.materials
		if (length(matlist))
			var/inserted = materials.mat_container.insert_stack(storage)
			materials.silo_log(src, "collected", inserted, "sheets", matlist)
			if (QDELETED(storage))
				stack_list -= key
			return

	while(storage.amount >= stack_amt) //Get rid of excessive stackage
		var/obj/item/stack/sheet/out = new inp.type(null, stack_amt)
		unload_mineral(out)
		storage.amount -= stack_amt
