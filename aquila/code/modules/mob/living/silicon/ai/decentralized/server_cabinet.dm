/obj/machinery/ai/server_cabinet
	name = "szafa serwerowa"
	desc = "Prosta szafa ze slotami bPCIe na racki serwerowe. Dostarcza sztucznej inteligencji moc obliczeniową (CPU) i pamięć (RAM). Grzeje się i potrzebuje chłodnego powietrza."
	icon = 'aquila/icons/obj/machines/ai_servers.dmi'
	icon_state = "expansion_bus"
	base_icon_state = "expansion_bus"

	circuit = /obj/item/circuitboard/machine/server_cabinet

	//Idle power usage when no racks inserted.
	idle_power_usage = 10
	//We manually calculate how power the racks use, so this is accounted for by that
	active_power_usage = 0

	var/list/installed_racks = list()

	var/total_cpu = 0
	var/total_ram = 0

	var/cached_power_usage = 0

	var/max_racks = 2

	var/hardware_synced = FALSE

	var/was_valid_holder = FALSE
	//Atmos hasn't run at the start so this has to be set to true if you map it in
	var/roundstart = FALSE
	///How many ticks we can go without fulfilling the criteria before shutting off
	var/valid_ticks = MAX_AI_EXPANSION_TICKS
	///Heat production multiplied by this
	var/heat_modifier = 1
	///Power modifier, power modified by this. Be aware this indirectly changes heat since power => heat
	var/power_modifier = 1

/obj/machinery/ai/server_cabinet/Initialize(mapload)
	. = ..()
	GLOB.ai_server_cabinets += src
	roundstart = mapload
	RefreshParts()
	update_icon()

/obj/machinery/ai/server_cabinet/Destroy()
	GLOB.ai_server_cabinets -= src
	QDEL_LIST(installed_racks)
	//Recalculate all the CPUs and RAM :) (rebuild_ai_networks() przelicza też sprzęt)
	return ..()

/obj/machinery/ai/server_cabinet/RefreshParts()
	var/new_heat_mod = 1
	var/new_power_mod = 1
	for(var/obj/item/stock_parts/capacitor/capacitor in component_parts)
		new_power_mod -= (capacitor.rating - 1) / 40 //Max -15% at tier 4 parts, min -0% at tier 1

	for(var/obj/item/stock_parts/matter_bin/bin in component_parts)
		new_heat_mod -= (bin.rating - 1) / 30 //Max -20% at tier 4 parts, min -0% at tier 1

	heat_modifier = new_heat_mod
	power_modifier = new_power_mod

	idle_power_usage = initial(idle_power_usage) * power_modifier

/obj/machinery/ai/server_cabinet/examine(mob/user)
	. = ..()
	var/holder_status = get_holder_status()
	if(holder_status)
		. += span_warning("Maszyna nie działa. Powód: [holder_status]")
	if(!valid_ticks)
		. += span_notice("Mały ekran wyświetla napis „OFFLINE”.")
	. += span_notice("Zamontowane racki: [length(installed_racks)] z [max_racks].")
	. += span_notice("Mnożnik poboru mocy: <b>[power_modifier * 100]%</b>")
	. += span_notice("Mnożnik wydzielania ciepła: <b>[heat_modifier * 100]%</b>")
	. += span_notice("Temperatura: <b>[round(core_temp, 0.1)] K</b> (limit [get_os()?.get_temp_limit() || AI_TEMP_LIMIT] K).")

	for(var/obj/item/server_rack/R as anything in installed_racks)
		. += span_notice("Rack: [R.get_cpu()] THz CPU, [R.get_ram()] TB RAM, pobór [R.get_power_usage()] W.")
	. += span_notice("Łomem wyjmiesz wszystkie racki.")

/obj/machinery/ai/server_cabinet/process(delta_time)
	valid_ticks = clamp(valid_ticks, 0, MAX_AI_EXPANSION_TICKS)
	//Od pierwszego ticku liczy się już prawdziwy stan szafy (w Monke szafy z mapy liczyły się zawsze)
	roundstart = FALSE
	if(valid_holder())
		valid_ticks++
		if(!was_valid_holder)
			update_icon()
		was_valid_holder = TRUE

		if(!hardware_synced)
			get_os()?.update_hardware()
			hardware_synced = TRUE
	else
		valid_ticks--
		if(was_valid_holder)
			if(valid_ticks > 0)
				return
			was_valid_holder = FALSE
			update_icon()
			hardware_synced = FALSE
			get_os()?.update_hardware()

/obj/machinery/ai/server_cabinet/process_atmos()
	. = ..()
	if(!.)
		return FALSE
	if(!valid_holder())
		return FALSE
	var/total_usage = (cached_power_usage * power_modifier)
	use_power(total_usage)
	var/temperature_increase = (total_usage / AI_HEATSINK_CAPACITY) * heat_modifier
	core_temp += temperature_increase * AI_TEMPERATURE_MULTIPLIER
	return TRUE

/obj/machinery/ai/server_cabinet/update_icon_state()
	icon_state = panel_open ? "[base_icon_state]_o" : base_icon_state
	return ..()

/obj/machinery/ai/server_cabinet/update_overlays()
	. = ..()
	if(length(installed_racks) > 0)
		. += mutable_appearance(icon, "[base_icon_state]_top")
	if(length(installed_racks) > 1)
		. += mutable_appearance(icon, "[base_icon_state]_bottom")

	if(machine_stat & (BROKEN|NOPOWER|EMPED))
		return .

	. += mutable_appearance(icon, "[base_icon_state]_on")
	if(!valid_ticks || !was_valid_holder)
		return
	if(length(installed_racks) > 0)
		. += mutable_appearance(icon, "[base_icon_state]_top_on")
	if(length(installed_racks) > 1)
		. += mutable_appearance(icon, "[base_icon_state]_bottom_on")

/obj/machinery/ai/server_cabinet/valid_holder()
	. = ..()
	//if you have no racks, you generate no heat.
	if(!length(installed_racks))
		return FALSE
	return .

/obj/machinery/ai/server_cabinet/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/server_rack))
		install_rack(user, I)
		return TRUE
	return ..()

/obj/machinery/ai/server_cabinet/screwdriver_act(mob/living/user, obj/item/I)
	if(length(installed_racks))
		balloon_alert(user, "najpierw wyjmij racki!")
		return TRUE
	default_deconstruction_screwdriver(user, "[base_icon_state]_o", base_icon_state, I)
	return TRUE

/obj/machinery/ai/server_cabinet/crowbar_act(mob/living/user, obj/item/I)
	if(remove_racks(user))
		I.play_tool_sound(src, 50)
		return TRUE
	default_deconstruction_crowbar(I)
	return TRUE

/obj/machinery/ai/server_cabinet/proc/install_rack(mob/living/user, obj/item/server_rack/new_rack)
	if(length(installed_racks) >= max_racks)
		if(user)
			balloon_alert(user, "nie zmieści się!")
		return FALSE
	if(user && !user.transferItemToLoc(new_rack, src))
		return FALSE
	if(!user)
		new_rack.forceMove(src)
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	if(user)
		balloon_alert(user, "rack zamontowany")
	installed_racks += new_rack
	total_cpu += new_rack.get_cpu()
	total_ram += new_rack.get_ram()
	cached_power_usage += new_rack.get_power_usage()
	get_os()?.update_hardware()
	use_power = ACTIVE_POWER_USE
	update_icon()
	return TRUE

/obj/machinery/ai/server_cabinet/proc/remove_racks(mob/living/user)
	if(!length(installed_racks))
		return FALSE
	var/turf/turf_dropped = drop_location()
	for(var/obj/item/server_rack/rack as anything in installed_racks)
		rack.forceMove(turf_dropped)
	installed_racks.Cut()
	total_cpu = 0
	total_ram = 0
	cached_power_usage = 0
	roundstart = FALSE
	get_os()?.update_hardware()
	if(user)
		balloon_alert(user, "racki wyjęte")
	use_power = IDLE_POWER_USE
	update_icon()
	return TRUE

/obj/machinery/ai/server_cabinet/prefilled/Initialize(mapload)
	. = ..()
	install_rack(null, new /obj/item/server_rack/roundstart(src))
