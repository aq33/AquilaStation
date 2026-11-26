// AQUILA - urządzenia do pracy przy rurach pod ciśnieniem (plan maszynowni, etap E3):
// - zawór odcinający: zawór cyfrowy, który sam się zamyka, gdy w sieci po którejś stronie jest pęknięta rura (E1);
// - zacisk rury: zamienia prosty odcinek rury w zamknięty zawór, a zdjęty przywraca rurę (pomysł z Baystation12);
// - iskrownik rurowy: zaślepka rury, która zapala mieszankę paliwa w sieci (pomysł z Baystation12).
// Grafiki zacisku i iskrownika: Baystation12 (icons/atmos/clamp.dmi, pipe-sparker.dmi), CC-BY-SA 3.0.
// Zawór nadmiarowy już jest (/obj/machinery/atmospherics/components/binary/pressure_valve).

/// Temperatura, do której iskrownik podgrzewa mieszankę z paliwem (zapłon plazmy od ok. 373 K)
#define AQ_SPARKER_IGNITION_TEMPERATURE (FIRE_MINIMUM_TEMPERATURE_TO_EXIST + 50)
/// Najmniej moli paliwa i tlenu, żeby iskrownik coś zapalił
#define AQ_SPARKER_MIN_MOLES 0.5

// ---------------------------------------------------------------- Zawór odcinający

/obj/machinery/atmospherics/components/binary/valve/digital/aq_shutoff
	name = "zawór odcinający"
	desc = "Zawór cyfrowy z czujnikiem przecieku: sam się zamyka, gdy rura po którejś stronie pęknie, i otwiera po naprawie. Automat przełącza się multitoolem."
	icon_state = "dvalve_map-3"
	on = TRUE
	/// Automat zamyka zawór przy przecieku
	var/aq_auto = TRUE
	/// Zawór zamknięty przez automat (otworzy się po naprawie)
	var/aq_auto_closed = FALSE

/// Czy w sieci po którejś stronie zaworu przecieka pęknięta rura
/obj/machinery/atmospherics/components/binary/valve/digital/aq_shutoff/proc/aq_network_leaking()
	for(var/datum/pipeline/net as anything in parents)
		if(net && length(net.aq_leaks))
			return TRUE
	return FALSE

/obj/machinery/atmospherics/components/binary/valve/digital/aq_shutoff/process_atmos()
	if(!aq_auto || switching || !is_operational)
		return
	var/leaking = aq_network_leaking()
	if(leaking && on)
		aq_auto_closed = TRUE
		set_open(FALSE)
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
		visible_message("<span class='warning'>[src] zatrzaskuje się z kliknięciem: czujnik wykrył przeciek!</span>")
	else if(!leaking && aq_auto_closed && parents[1])
		aq_auto_closed = FALSE
		if(!on)
			set_open(TRUE)
			visible_message("<span class='notice'>[src] otwiera się: przeciek usunięty.</span>")

/obj/machinery/atmospherics/components/binary/valve/digital/aq_shutoff/interact(mob/user)
	if(aq_auto && aq_auto_closed)
		to_chat(user, "<span class='warning'>Automat trzyma [src] zamknięty, bo w sieci jest przeciek. Wyłącz automat multitoolem, żeby otworzyć ręcznie.</span>")
		return
	return ..()

/obj/machinery/atmospherics/components/binary/valve/digital/aq_shutoff/multitool_act(mob/living/user, obj/item/I)
	aq_auto = !aq_auto
	if(!aq_auto)
		aq_auto_closed = FALSE
	to_chat(user, "<span class='notice'>Automat [src] [aq_auto ? "włączony" : "wyłączony"].</span>")
	return TRUE

/obj/machinery/atmospherics/components/binary/valve/digital/aq_shutoff/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Automat jest [aq_auto ? "włączony" : "wyłączony"].</span>"
	if(aq_auto_closed)
		. += "<span class='warning'>Zawór zamknięty przez czujnik przecieku.</span>"

/obj/machinery/atmospherics/components/binary/valve/digital/aq_shutoff/layer2
	piping_layer = 2
	icon_state = "dvalve_map-2"

/obj/machinery/atmospherics/components/binary/valve/digital/aq_shutoff/layer4
	piping_layer = 4
	icon_state = "dvalve_map-4"

// ---------------------------------------------------------------- Zacisk rury

/obj/item/pipe_clamp
	name = "zacisk rury"
	desc = "Magnetyczny zacisk zakładany na prosty odcinek rury. Zamyka przepływ jak zawór, więc pękniętą rurę da się odciąć z obu stron i zespawać bez spuszczania całej sieci."
	icon = 'aquila/icons/obj/atmospherics/pipe_clamp.dmi'
	icon_state = "pclamp0"
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron = 4000, /datum/material/silver = 500)

/obj/machinery/atmospherics/pipe/simple/attackby(obj/item/W, mob/user, params)
	if(!istype(W, /obj/item/pipe_clamp))
		return ..()
	if(!(dir in GLOB.cardinals))
		to_chat(user, "<span class='warning'>Zacisk da się założyć tylko na prosty odcinek rury.</span>")
		return TRUE
	to_chat(user, "<span class='notice'>Zakładasz [W] na [src]...</span>")
	if(!do_after(user, 3 SECONDS, src) || QDELETED(src) || QDELETED(W))
		return TRUE
	if(!user.temporarilyRemoveItemFromInventory(W))
		return TRUE
	var/obj/machinery/atmospherics/components/binary/valve/aq_clamp/clamp = aq_apply_clamp(W)
	user.visible_message("<span class='notice'>[user] zakłada [clamp] na rurę.</span>", "<span class='notice'>Zakładasz zacisk. Rura jest zamknięta.</span>")
	return TRUE

/**
 * Stawia urządzenie z rur w miejscu innego, usuniętego w tym samym ticku (jak on_construction()).
 * Do sieci sąsiada dołącza tylko wtedy, gdy ta sieć żyje: po usunięciu rury sieci sąsiadów są zniszczone
 * (parent = null), a add_member() zrobiłby im pustą sieć bez gazu. Wtedy sieć zbuduje kolejka przebudowy SSair,
 * do której sąsiedzi już trafili. Gaz z air_temporary nowej rury trafia do sieci, do której dołączyła.
 */
/proc/aq_place_atmos_device(obj/machinery/atmospherics/device, obj_color, layer_number)
	if(obj_color)
		device.pipe_color = obj_color
		device.add_atom_colour(obj_color, FIXED_COLOUR_PRIORITY)
	device.set_piping_layer(layer_number)
	device.atmos_init()
	for(var/obj/machinery/atmospherics/node in device.pipeline_expansion())
		node.atmos_init()
		var/datum/pipeline/node_net
		if(istype(node, /obj/machinery/atmospherics/components))
			var/obj/machinery/atmospherics/components/node_component = node
			if(device in node_component.nodes)
				node_net = node_component.return_pipenet(device)
		else
			node_net = node.return_pipenet()
		if(node_net && !QDELETED(node_net) && node_net.air && !node_net.building)
			node.add_member(device)
		node.update_icon()
	if(istype(device, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/new_pipe = device
		if(new_pipe.air_temporary && new_pipe.parent?.air)
			new_pipe.parent.air.merge(new_pipe.air_temporary)
			new_pipe.air_temporary = null
	SSair.add_to_rebuild_queue(device)
	device.update_icon()

/// Zamienia tę rurę w zamknięty zacisk (zawór) z tym samym kierunkiem, warstwą i kolorem
/obj/machinery/atmospherics/pipe/simple/proc/aq_apply_clamp(obj/item/pipe_clamp/clamp_item)
	var/turf/pipe_turf = loc
	var/pipe_dir = dir
	var/layer_number = piping_layer
	var/old_color = pipe_color
	// gaz z tego odcinka zostaje w zacisku: rura wychodzi z sieci przed usunięciem, więc nic nie leci na kafelek
	var/datum/gas_mixture/kept = air_temporary
	air_temporary = null
	if(parent?.air && (src in parent.members))
		var/total_volume = parent.air.return_volume()
		if(total_volume > 0)
			kept = parent.air.remove_ratio(volume / total_volume)
			parent.air.set_volume(max(total_volume - volume, 0))
		parent.members -= src
	investigate_log("was clamped by [key_name(usr)].", INVESTIGATE_ATMOS)
	var/obj/machinery/atmospherics/components/binary/valve/aq_clamp/clamp = new(pipe_turf, TRUE, pipe_dir)
	clamp.restored_type = type
	clamp.restored_name = name
	clamp.stored_clamp = clamp_item
	clamp_item.forceMove(clamp)
	if(kept)
		var/datum/gas_mixture/clamp_air = clamp.airs[1]
		clamp_air.merge(kept)
	qdel(src)
	aq_place_atmos_device(clamp, old_color, layer_number)
	return clamp

/obj/machinery/atmospherics/components/binary/valve/aq_clamp
	name = "zacisk rury"
	desc = "Zacisk założony na rurę. Kliknięciem otwierasz i zamykasz przepływ; otwarty zdejmiesz kluczem."
	icon = 'aquila/icons/obj/atmospherics/pipe_clamp.dmi'
	icon_state = "vclamp"
	can_unwrench = FALSE
	on = FALSE
	/// Przedmiot zacisku oddawany przy zdjęciu
	var/obj/item/pipe_clamp/stored_clamp
	/// Typ i nazwa rury, która wraca po zdjęciu zacisku
	var/restored_type = /obj/machinery/atmospherics/pipe/simple
	var/restored_name

/obj/machinery/atmospherics/components/binary/valve/aq_clamp/Destroy()
	QDEL_NULL(stored_clamp)
	return ..()

/obj/machinery/atmospherics/components/binary/valve/aq_clamp/update_icon_nopipes(animation = FALSE)
	normalize_cardinal_directions()
	icon_state = "vclamp"
	cut_overlays()
	if(!on)
		add_overlay(mutable_appearance(icon, "closed1"))

/obj/machinery/atmospherics/components/binary/valve/aq_clamp/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Zacisk jest [on ? "otwarty: można go zdjąć kluczem" : "zamknięty"].</span>"

/obj/machinery/atmospherics/components/binary/valve/aq_clamp/wrench_act(mob/living/user, obj/item/I)
	if(!on)
		to_chat(user, "<span class='warning'>Zacisk trzyma rurę zamkniętą. Najpierw go otwórz.</span>")
		return TRUE
	to_chat(user, "<span class='notice'>Zdejmujesz [src]...</span>")
	if(!I.use_tool(src, user, 3 SECONDS, volume = 50) || !on)
		return TRUE
	var/obj/item/pipe_clamp/clamp_item = aq_remove_clamp()
	if(clamp_item)
		user.put_in_hands(clamp_item)
	user.visible_message("<span class='notice'>[user] zdejmuje zacisk z rury.</span>", "<span class='notice'>Zdejmujesz zacisk.</span>")
	return TRUE

/// Przywraca rurę (ten sam typ, nazwa, kolor i warstwa) w miejscu zacisku, zwraca przedmiot zacisku
/obj/machinery/atmospherics/components/binary/valve/aq_clamp/proc/aq_remove_clamp()
	var/turf/clamp_turf = loc
	var/clamp_dir = dir
	var/layer_number = piping_layer
	var/old_color = pipe_color
	var/obj/item/pipe_clamp/clamp_item = stored_clamp
	stored_clamp = null
	clamp_item?.forceMove(clamp_turf)
	// gaz z komór zacisku wraca do rury (komponenty nie oddają go przy usunięciu)
	var/datum/gas_mixture/kept = new
	for(var/datum/gas_mixture/clamp_air as anything in airs)
		if(clamp_air)
			kept.merge(clamp_air.remove_ratio(1))
	investigate_log("was unclamped by [key_name(usr)].", INVESTIGATE_ATMOS)
	qdel(src)
	var/obj/machinery/atmospherics/pipe/simple/pipe = new restored_type(clamp_turf, TRUE, clamp_dir)
	if(restored_name)
		pipe.name = restored_name
	kept.set_volume(pipe.volume)
	pipe.air_temporary = kept
	aq_place_atmos_device(pipe, old_color, layer_number)
	return clamp_item

/obj/machinery/atmospherics/components/binary/valve/aq_clamp/deconstruct(disassembled = TRUE)
	if(stored_clamp && loc)
		stored_clamp.forceMove(loc)
		stored_clamp = null
	return ..()

/datum/design/aq_pipe_clamp
	name = "Zacisk rury"
	desc = "Zacisk zamykający prosty odcinek rury jak zawór."
	id = "aq_pipe_clamp"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/silver = 500)
	build_path = /obj/item/pipe_clamp
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_CARGO

/datum/techweb_node/engineering/New()
	. = ..()
	design_ids += "aq_pipe_clamp"

// ---------------------------------------------------------------- Iskrownik rurowy

/obj/machinery/atmospherics/components/unary/aq_sparker
	name = "iskrownik rurowy"
	desc = "Zaślepka rury z iskrownikiem. Zapala mieszankę paliwa i tlenu w rurach bez wchodzenia do komory. Działa z ręki albo z przycisku zapłonu połączonego multitoolem."
	icon = 'aquila/icons/obj/atmospherics/pipe_sparker.dmi'
	icon_state = "pipe-igniter"
	shift_underlay_only = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 2000
	pipe_state = "injector"
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OFFLINE | INTERACT_MACHINE_OPEN | INTERACT_MACHINE_OPEN_SILICON
	/// Wspólny identyfikator z przyciskiem zapłonu (/obj/machinery/button/ignition)
	var/id = null
	/// Kiedy można iskrzyć ponownie
	var/next_spark = 0

/obj/machinery/atmospherics/components/unary/aq_sparker/update_icon_nopipes()
	icon_state = is_operational ? "pipe-igniter" : "pipe-sparker-d"

/obj/machinery/atmospherics/components/unary/aq_sparker/interact(mob/user)
	add_fingerprint(user)
	if(!aq_spark())
		to_chat(user, "<span class='warning'>[src] nie iskrzy: brak zasilania albo jeszcze się ładuje.</span>")

/**
 * Iskra w rurze: gdy sieć ma paliwo (plazmę albo tryt) i tlen, wszystkie mieszaniny sieci dostają temperaturę
 * zapłonu (jak „wymuszona reakcja” Baya), potem reagują w zwykłym cyklu sieci. Podgrzanie samej komory iskrownika
 * nie wystarcza, bo sieć najpierw wyrównuje temperaturę, a dopiero potem reaguje. Mieszanki bez paliwa nie rusza.
 * Zwraca TRUE, gdy iskra była.
 */
/obj/machinery/atmospherics/components/unary/aq_sparker/proc/aq_spark()
	if(!is_operational || world.time < next_spark)
		return FALSE
	next_spark = world.time + 5 SECONDS
	use_power(active_power_usage)
	flick("pipe-sparker-spark", src)
	playsound(src, "sparks", 50, TRUE)
	var/datum/pipeline/net = parents[1]
	var/list/datum/gas_mixture/mixtures = list(airs[1])
	if(net)
		mixtures |= net.get_all_connected_airs()
	var/fuel = 0
	var/oxygen = 0
	for(var/datum/gas_mixture/mixture as anything in mixtures)
		if(!mixture)
			continue
		fuel += mixture.get_moles(GAS_PLASMA) + mixture.get_moles(GAS_TRITIUM)
		oxygen += mixture.get_moles(GAS_O2)
	if(fuel < AQ_SPARKER_MIN_MOLES || oxygen < AQ_SPARKER_MIN_MOLES)
		return TRUE
	for(var/datum/gas_mixture/mixture as anything in mixtures)
		if(mixture && mixture.return_temperature() < AQ_SPARKER_IGNITION_TEMPERATURE)
			mixture.set_temperature(AQ_SPARKER_IGNITION_TEMPERATURE)
	investigate_log("ignited a pipe mix ([round(fuel, 0.1)] mol of fuel) used by [usr ? key_name(usr) : "a remote signal"].", INVESTIGATE_ATMOS)
	if(net)
		net.update = TRUE
	return TRUE

/// Multitool z zapamiętanym przyciskiem zapłonu łączy iskrownik z tym przyciskiem
/obj/machinery/atmospherics/components/unary/aq_sparker/multitool_act(mob/living/user, obj/item/I)
	var/obj/item/multitool/tool = I
	var/obj/machinery/button/ignition/button = istype(tool) ? tool.buffer : null
	if(!istype(button) || QDELETED(button))
		to_chat(user, "<span class='warning'>Najpierw zapisz w multitoolu przycisk zapłonu (multitool na przycisk).</span>")
		return TRUE
	if(!button.id)
		button.id = "aq_iskrownik_[REF(button)]"
		var/obj/item/assembly/control/button_device = button.device
		if(istype(button_device))
			button_device.id = button.id
	id = button.id
	to_chat(user, "<span class='notice'>[src] reaguje teraz na [button].</span>")
	return TRUE

/obj/machinery/button/ignition/multitool_act(mob/living/user, obj/item/I)
	var/obj/item/multitool/tool = I
	if(!istype(tool))
		return ..()
	tool.buffer = src
	to_chat(user, "<span class='notice'>Zapisujesz [src] w buforze multitoola. Teraz użyj go na iskrowniku rurowym.</span>")
	return TRUE

/obj/machinery/atmospherics/components/unary/aq_sparker/layer2
	piping_layer = 2

/obj/machinery/atmospherics/components/unary/aq_sparker/layer4
	piping_layer = 4

/obj/item/assembly/control/igniter/activate()
	var/was_cooling = cooldown
	. = ..()
	if(was_cooling)
		return
	for(var/obj/machinery/atmospherics/components/unary/aq_sparker/sparker in GLOB.machines)
		if(sparker.id == id)
			INVOKE_ASYNC(sparker, TYPE_PROC_REF(/obj/machinery/atmospherics/components/unary/aq_sparker, aq_spark))

#undef AQ_SPARKER_IGNITION_TEMPERATURE
#undef AQ_SPARKER_MIN_MOLES
