// Kabel ethernet (port Yogstation). Łączy się sam z sąsiednimi kablami jak nasze kable zasilające (smartwires),
// zamiast ręcznie łączonych odcinków d1/d2 z Yoga.

/obj/structure/ethernet_cable
	name = "kabel sieciowy"
	desc = "Sztywny, ekranowany kabel kategorii 16a do przesyłania ogromnych ilości danych na duże odległości. Łączy maszyny zdecentralizowanej SI w jedną sieć."
	icon = 'aquila/icons/obj/power_cond/ethernet.dmi'
	icon_state = "0-1-2-4-8"
	level = 1 //is underfloor
	layer = ETHERNET_LAYER
	anchored = TRUE
	obj_flags = CAN_BE_HIT | ON_BLUEPRINTS
	///Sieć, do której należy kabel (ustawia rebuild_ai_networks())
	var/datum/ai_network/network
	///Sąsiednie kable, z którymi jesteśmy połączeni
	var/list/obj/structure/ethernet_cable/connected = list()
	///Kierunki połączeń
	var/linked_dirs = NONE

/obj/structure/ethernet_cable/Initialize(mapload)
	. = ..()
#ifdef CIBUILDING
	for(var/obj/structure/ethernet_cable/other in get_turf(src))
		if(other == src)
			continue
		stack_trace("An ethernet cable was created when one already exists at [COORD(src)].")
		return INITIALIZE_HINT_QDEL
#endif
	var/turf/T = get_turf(src)
	if(level == 1 && T)
		hide(T.intact)
	GLOB.ethernet_cables += src
	return INITIALIZE_HINT_LATELOAD

/obj/structure/ethernet_cable/LateInitialize()
	reform_connections()
	update_appearance(UPDATE_ICON)
	queue_ai_network_rebuild()

/obj/structure/ethernet_cable/Destroy()
	clear_connections()
	GLOB.ethernet_cables -= src
	network?.cables -= src
	network = null
	queue_ai_network_rebuild()
	return ..()

/obj/structure/ethernet_cable/proc/reform_connections()
	for(var/cardinal in GLOB.cardinals)
		for(var/obj/structure/ethernet_cable/adjacent in get_step(src, cardinal))
			connected |= adjacent
			linked_dirs |= cardinal
			adjacent.connected |= src
			adjacent.linked_dirs |= REVERSE_DIR(cardinal)
			adjacent.update_appearance(UPDATE_ICON)

/obj/structure/ethernet_cable/proc/clear_connections()
	for(var/obj/structure/ethernet_cable/adjacent as anything in connected)
		adjacent.connected -= src
		adjacent.linked_dirs &= ~get_dir(adjacent, src)
		adjacent.update_appearance(UPDATE_ICON)
	connected.Cut()
	linked_dirs = NONE

/obj/structure/ethernet_cable/hide(i)
	if(level == 1 && isturf(loc))
		invisibility = i ? INVISIBILITY_MAXIMUM : 0
	update_appearance(UPDATE_ICON)

/obj/structure/ethernet_cable/update_icon_state()
	. = ..()
	var/list/adjacencies = list()
	if(!!(linked_dirs & NORTH) + !!(linked_dirs & SOUTH) + !!(linked_dirs & WEST) + !!(linked_dirs & EAST) <= 1)
		adjacencies += "0"
	if(linked_dirs & NORTH)
		adjacencies += "1"
	if(linked_dirs & SOUTH)
		adjacencies += "2"
	if(linked_dirs & EAST)
		adjacencies += "4"
	if(linked_dirs & WEST)
		adjacencies += "8"
	icon_state = jointext(adjacencies, "-")

/obj/structure/ethernet_cable/examine(mob/user)
	. = ..()
	if(isobserver(user))
		. += get_network_info()

/obj/structure/ethernet_cable/attackby(obj/item/attacking_item, mob/user, params)
	var/turf/our_turf = get_turf(src)
	if(our_turf.intact)
		return FALSE
	add_fingerprint(user)
	return ..()

/obj/structure/ethernet_cable/wirecutter_act(mob/living/user, obj/item/tool)
	var/turf/our_turf = get_turf(src)
	if(our_turf.intact)
		return
	user.visible_message(span_notice("[user] przecina [src]."), span_notice("Przecinasz [src]."))
	investigate_log("was cut by [key_name(user)] in [AREACOORD(src)]", INVESTIGATE_WIRES)
	deconstruct()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/structure/ethernet_cable/multitool_act(mob/living/user, obj/item/tool)
	var/turf/our_turf = get_turf(src)
	if(our_turf.intact)
		return
	add_fingerprint(user)
	to_chat(user, EXAMINE_BLOCK(get_network_info()))
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/structure/ethernet_cable/proc/get_network_info()
	flush_ai_network_rebuild()
	var/datum/ai_os/resources = network?.resources
	if(!resources)
		return span_warning("Kabel nie przenosi żadnych danych.")
	var/list/info = list()
	info += span_notice("Maszyny SI w tej sieci: [length(network.nodes)]. Sieci połączone nadajnikami: [length(resources.networks)].")
	info += span_notice("Zasoby: [resources.total_cpu] THz CPU, [resources.total_ram] TB RAM.")
	info += span_notice("SI w sieci: [length(resources.ai_list)].")
	return info.Join("<br>")

/obj/structure/ethernet_cable/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/obj/item/stack/ethernet_coil/dropped = new(drop_location(), 1)
		if(!QDELETED(dropped))
			transfer_fingerprints_to(dropped)
	return ..()

/obj/structure/ethernet_cable/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()

/obj/structure/ethernet_cable/beforeShuttleMove(turf/newT, rotation, move_mode, obj/docking_port/mobile/moving_dock)
	. = ..()
	clear_connections()

/obj/structure/ethernet_cable/afterShuttleMove(turf/oldT, list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir, rotation)
	. = ..()
	reform_connections()
	update_appearance(UPDATE_ICON)
	queue_ai_network_rebuild()

///////////////////////////////////////////////
// Zwój kabla sieciowego
///////////////////////////////////////////////

/obj/item/stack/ethernet_coil
	name = "zwój kabla sieciowego"
	singular_name = "odcinek kabla sieciowego"
	desc = "Zwój ekranowanego kabla ethernet. Kabel kładzie się na poszyciu, a maszyny SI łączą się z kablem pod sobą."
	icon = 'aquila/icons/obj/ethernet_coil.dmi'
	icon_state = "coil"
	item_state = "coil"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	gender = NEUTER
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	full_w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 5
	attack_verb = list("chłoszcze", "smaga", "dyscyplinuje")
	custom_price = 25
	max_amount = MAXCOIL
	amount = MAXCOIL
	merge_type = /obj/item/stack/ethernet_coil
	novariants = TRUE
	usesound = 'sound/items/deconstruct.ogg'
	materials = list(/datum/material/iron = 10, /datum/material/glass = 5)
	grind_results = list(/datum/reagent/copper = 2)

/obj/item/stack/ethernet_coil/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	pixel_x = base_pixel_x + rand(-2, 2)
	pixel_y = base_pixel_y + rand(-2, 2)
	update_appearance(UPDATE_ICON_STATE)

/obj/item/stack/ethernet_coil/update_icon_state()
	. = ..()
	icon_state = "coil[amount < 3 ? amount : ""]"

/obj/item/stack/ethernet_coil/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	var/turf/target_turf = get_turf(target)
	if(target_turf)
		place_on_turf(target_turf, user)

///Kładzie odcinek kabla na kafelku. Zwraca nowy kabel albo null.
/obj/item/stack/ethernet_coil/proc/place_on_turf(turf/target_turf, mob/user)
	if(!isturf(user.loc))
		return
	if(target_turf.intact || !target_turf.can_have_cabling())
		to_chat(user, span_warning("Kabel możesz kłaść tylko na zewnętrznych pomostach i poszyciu!"))
		return
	if(get_dist(target_turf, user) > 1)
		to_chat(user, span_warning("Nie możesz położyć kabla tak daleko!"))
		return
	if(locate(/obj/structure/ethernet_cable) in target_turf)
		to_chat(user, span_warning("W tym miejscu już jest kabel sieciowy!"))
		return
	if(!use(1))
		to_chat(user, span_warning("Nie został już żaden kabel!"))
		return
	var/obj/structure/ethernet_cable/new_cable = new(target_turf)
	new_cable.add_fingerprint(user)
	playsound(target_turf, 'sound/items/deconstruct.ogg', 25, TRUE)
	return new_cable

/obj/item/stack/ethernet_coil/cyborg
	is_cyborg = TRUE
	materials = list()
	cost = 1

/obj/item/stack/ethernet_coil/five
	amount = 5
