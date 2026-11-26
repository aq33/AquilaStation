// AQUILA - Kondensator gazu (plan maszynowni E15), port z SS14 (GasCondenserSystem.cs, GasCondenserComponent.cs).
// Urządzenie jednorurowe (wzór: nsv13 plasma_loader): bierze gaz z rury i każdy gaz, który ma odpowiednik
// w chemii, skrapla do zbiornika. Gaz bez odpowiednika zostaje w rurze. Zbiornik oddaje płyn przez plumbing
// (wyjście po stronie przeciwnej do rury gazowej) i daje się z niego nabierać zlewką.
// Ile moli na tik: moc · czas / (0,8 · pojemność cieplna gazu w rurze / 8), jak w SS14 (atmos.heat_scale = 8); 0,2137 u na mol (około 400 u
// z pełnego kanistra). Różnice względem SS14: lista gazów według naszej chemii (doszły wodór i metan, nie ma
// trytu ani amoniaku, bo nie mamy takich reagentów albo gazu), płyn ma temperaturę gazu. Sprite z SS14
// (Structures/Piping/Atmospherics/condenser.rsi, autor EmoGarbage404, edycja chromiumboy, CC0-1.0).

/// Gaz -> reagent, w który kondensator go skrapla
GLOBAL_LIST_INIT(gas_condenser_reagents, list(
	GAS_O2 = /datum/reagent/oxygen,
	GAS_N2 = /datum/reagent/nitrogen,
	GAS_CO2 = /datum/reagent/carbondioxide,
	GAS_PLASMA = /datum/reagent/toxin/plasma,
	GAS_H2O = /datum/reagent/water,
	GAS_NITROUS = /datum/reagent/nitrous_oxide,
	GAS_FREZON = /datum/reagent/frezon,
	GAS_H2 = /datum/reagent/hydrogen,
	GAS_METHANE = /datum/reagent/methane,
))

/obj/machinery/atmospherics/components/unary/gas_condenser
	name = "kondensator gazu"
	desc = "Skrapla gazy z rury w płyny. Teraz brakuje już tylko hydrauliki."
	icon = 'aquila/icons/obj/atmospherics/gas_condenser.dmi'
	icon_state = "condenser-off"
	circuit = /obj/item/circuitboard/machine/gas_condenser
	density = TRUE
	layer = OBJ_LAYER
	dir = SOUTH
	initialize_directions = SOUTH
	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY
	idle_power_usage = 50
	active_power_usage = 10000
	max_integrity = 200
	/// Pojemność zbiornika (SS14: SolutionHuge)
	var/tank_volume = 480
	/// Ile jednostek płynu daje mol gazu
	var/moles_to_reagent = 0.2137
	/// Stała z SS14 dobrana tak, żeby wychodziło około 1 u na sekundę
	var/condense_alpha = 0.8
	/// SS14 liczy tu pojemność cieplną podzieloną przez atmos.heat_scale (8), więc dzielimy tak samo
	var/heat_scale = 8

/obj/machinery/atmospherics/components/unary/gas_condenser/Initialize(mapload)
	. = ..()
	create_reagents(tank_volume, DRAINABLE | TRANSPARENT)
	AddComponent(/datum/component/plumbing/gas_condenser)

/obj/machinery/atmospherics/components/unary/gas_condenser/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Kliknij, żeby włączyć albo wyłączyć. Rura gazowa wchodzi od strony wlotu, płyn wychodzi przez hydraulikę z przeciwnej strony.</span>"
	if(reagents.total_volume >= reagents.maximum_volume)
		. += "<span class='warning'>Zbiornik jest pełny.</span>"

/obj/machinery/atmospherics/components/unary/gas_condenser/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(panel_open)
		to_chat(user, "<span class='warning'>Najpierw zamknij panel [src].</span>")
		return
	set_on(!on)
	to_chat(user, "<span class='notice'>[on ? "Włączasz" : "Wyłączasz"] [src].</span>")
	investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
	return TRUE

/obj/machinery/atmospherics/components/unary/gas_condenser/set_on(active)
	. = ..()
	use_power = on ? ACTIVE_POWER_USE : IDLE_POWER_USE

/obj/machinery/atmospherics/components/unary/gas_condenser/attackby(obj/item/I, mob/user, params)
	if(!on && default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_icon()
		return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/atmospherics/components/unary/gas_condenser/default_change_direction_wrench(mob/user, obj/item/I)
	if(!..())
		return FALSE
	disconnect_nodes()
	set_init_directions()
	connect_nodes()
	update_icon()
	return TRUE

/obj/machinery/atmospherics/components/unary/gas_condenser/power_change()
	. = ..()
	update_icon()

/obj/machinery/atmospherics/components/unary/gas_condenser/on_reagent_change(changetype)
	. = ..()
	update_icon()

/obj/machinery/atmospherics/components/unary/gas_condenser/update_icon()
	cut_overlays()
	icon_state = (on && is_operational) ? "condenser-on" : "condenser-off"
	if(reagents?.total_volume)
		var/fill_level = clamp(CEILING(reagents.total_volume / reagents.maximum_volume * 7, 1), 1, 7)
		var/mutable_appearance/fill = mutable_appearance(icon, "condenser-fill-[fill_level]")
		fill.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(fill)
	add_overlay("condenser-glass")
	if(panel_open)
		add_overlay("condenser-panel")
	add_overlay(get_pipe_image(icon, "pipe", dir, null, piping_layer))
	var/list/plumbing_overlays = list()
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_OVERLAYS, plumbing_overlays) // złączki hydrauliki
	add_overlay(plumbing_overlays)

/obj/machinery/atmospherics/components/unary/gas_condenser/process_atmos(delta_time = 1)
	if(!on || !is_operational)
		return
	condense(airs[1], delta_time)

/// Skrapla część gazu z mieszanki do zbiornika. Zwraca, ile jednostek płynu przybyło.
/obj/machinery/atmospherics/components/unary/gas_condenser/proc/condense(datum/gas_mixture/air, delta_time = 1)
	. = 0
	var/free_volume = reagents.maximum_volume - reagents.total_volume
	if(free_volume <= 0 || air.total_moles() <= 0)
		return
	var/heat_capacity = air.heat_capacity()
	if(heat_capacity <= 0)
		return
	var/datum/gas_mixture/removed = air.remove(active_power_usage * delta_time / (condense_alpha * heat_capacity / heat_scale))
	var/temperature = removed.return_temperature()
	for(var/gas_id in removed.get_gases())
		var/reagent_type = GLOB.gas_condenser_reagents[gas_id]
		if(!reagent_type)
			continue
		var/amount = min(removed.get_moles(gas_id) * moles_to_reagent, free_volume)
		if(amount <= 0)
			continue
		reagents.add_reagent(reagent_type, amount, reagtemp = temperature)
		removed.adjust_moles(gas_id, -amount / moles_to_reagent)
		free_volume -= amount
		. += amount
	air.merge(removed) // gaz bez odpowiednika i nadmiar przy pełnym zbiorniku wracają do rury
	update_parents()

/// Hydraulika kondensatora: tylko wyjście, po stronie przeciwnej do rury gazowej (rura od strony dir)
/datum/component/plumbing/gas_condenser
	supply_connects = NORTH

/obj/item/circuitboard/machine/gas_condenser
	name = "kondensator gazu (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/atmospherics/components/unary/gas_condenser
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 2)

/datum/design/board/gas_condenser
	name = "Projekt maszyny (kondensator gazu)"
	desc = "Płytka drukowana: kondensator gazu."
	id = "gas_condenser"
	build_path = /obj/item/circuitboard/machine/gas_condenser
	category = list("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/techweb_node/engineering/New()
	. = ..()
	design_ids += "gas_condenser"
